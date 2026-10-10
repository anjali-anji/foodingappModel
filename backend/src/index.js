require('dotenv').config();

const crypto = require('crypto');
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Razorpay = require('razorpay');

const { db, seedFoods, seedTestUser } = require('./db');
const { sendOrderEmail } = require('./mail');
const { sendFcmAfterConfirm } = require('./notify');

const PORT = Number(process.env.PORT || 3000);
const JWT_SECRET = process.env.JWT_SECRET || 'fooding_dev_jwt_secret';

seedFoods();
seedTestUser(bcrypt.hashSync('Test@123', 10));

const app = express();
app.use(cors());
app.use(express.json());
app.use((req, res, next) => {
  const body = { ...(req.body || {}) };
  if (body.password) body.password = '***';
  console.log('API', req.method, req.originalUrl, JSON.stringify(body));
  const originalJson = res.json.bind(res);
  res.json = (data) => {
    console.log('API RES', req.method, req.originalUrl, res.statusCode, JSON.stringify(data));
    return originalJson(data);
  };
  next();
});

function signToken(user) {
  return jwt.sign({ userId: user.id, email: user.email }, JWT_SECRET, {
    expiresIn: '7d',
  });
}

function auth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) {
    return res.status(401).json({ success: false, message: 'Login required' });
  }
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    return next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid token' });
  }
}

function publicUser(row) {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    mobile: row.mobile,
  };
}

app.get('/', (_req, res) => {
  res.json({ success: true, app: 'Fooding API' });
});

app.post('/register', (req, res) => {
  const { name, email, mobile, password, fcm_token } = req.body || {};
  if (!name || !email || !mobile || !password) {
    return res.status(400).json({ success: false, message: 'All fields are required' });
  }
  if (String(password).length < 6) {
    return res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });
  }
  const exists = db.prepare('SELECT id FROM users WHERE email = ?').get(String(email).trim().toLowerCase());
  if (exists) {
    return res.status(409).json({ success: false, message: 'Email already registered' });
  }
  const hash = bcrypt.hashSync(String(password), 10);
  const result = db.prepare(
    'INSERT INTO users (name, email, mobile, password, fcm_token) VALUES (?, ?, ?, ?, ?)',
  ).run(
    String(name).trim(),
    String(email).trim().toLowerCase(),
    String(mobile).trim(),
    hash,
    fcm_token || null,
  );
  const user = db.prepare('SELECT * FROM users WHERE id = ?').get(result.lastInsertRowid);
  return res.status(201).json({
    success: true,
    token: signToken(user),
    user: publicUser(user),
  });
});

app.post('/login', (req, res) => {
  const { email, password, fcm_token } = req.body || {};
  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'Email and password required' });
  }
  const user = db.prepare('SELECT * FROM users WHERE email = ?').get(String(email).trim().toLowerCase());
  if (!user || !bcrypt.compareSync(String(password), user.password)) {
    return res.status(401).json({ success: false, message: 'Invalid email or password' });
  }
  if (fcm_token) {
    db.prepare('UPDATE users SET fcm_token = ? WHERE id = ?').run(fcm_token, user.id);
    user.fcm_token = fcm_token;
  }
  return res.json({
    success: true,
    token: signToken(user),
    user: publicUser(user),
  });
});

app.get('/foods', (_req, res) => {
  const foods = db.prepare('SELECT id, name, price, image FROM foods ORDER BY id').all();
  return res.json({ success: true, foods });
});

app.post('/orders', auth, (req, res) => {
  const { amount, name, mobile, address, pincode } = req.body || {};
  if (amount == null || !name || !mobile || !address || !pincode) {
    return res.status(400).json({
      success: false,
      message: 'name, mobile, address, pincode and amount are required',
    });
  }
  const orderId = `ORD${Date.now()}`;
  db.prepare(
    `INSERT INTO orders
      (order_id, user_id, amount, payment_id, payment_status, order_status, name, mobile, address, pincode)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
  ).run(
    orderId,
    req.user.userId,
    Number(amount),
    null,
    'pending',
    'pending',
    String(name).trim(),
    String(mobile).trim(),
    String(address).trim(),
    String(pincode).trim(),
  );
  const order = db.prepare('SELECT * FROM orders WHERE order_id = ?').get(orderId);
  return res.status(201).json({ success: true, order });
});

app.get('/orders', auth, (req, res) => {
  const orders = db.prepare(
    'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
  ).all(req.user.userId);
  return res.json({ success: true, orders });
});

app.get('/orders/:id', auth, (req, res) => {
  const order = db.prepare(
    'SELECT * FROM orders WHERE order_id = ? AND user_id = ?',
  ).get(req.params.id, req.user.userId);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Order not found' });
  }
  return res.json({ success: true, order });
});

app.post('/payment/create', auth, async (req, res) => {
  const { order_id, amount } = req.body || {};
  if (!order_id || amount == null) {
    return res.status(400).json({ success: false, message: 'order_id and amount required' });
  }
  const order = db.prepare(
    'SELECT * FROM orders WHERE order_id = ? AND user_id = ?',
  ).get(order_id, req.user.userId);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Order not found' });
  }

  const keyId = process.env.RAZORPAY_KEY_ID;
  const keySecret = process.env.RAZORPAY_KEY_SECRET;
  const paise = Math.round(Number(amount) * 100);

  if (!keyId || !keySecret) {
    const razorpayOrderId = `order_test_${Date.now()}`;
    db.prepare('UPDATE orders SET razorpay_order_id = ? WHERE order_id = ?').run(
      razorpayOrderId,
      order_id,
    );
    return res.json({
      success: true,
      key_id: 'rzp_test_placeholder',
      razorpay_order: { id: razorpayOrderId, amount: paise, currency: 'INR' },
      test_mode: true,
    });
  }

  try {
    const razorpay = new Razorpay({ key_id: keyId, key_secret: keySecret });
    const razorpayOrder = await razorpay.orders.create({
      amount: paise,
      currency: 'INR',
      receipt: order_id,
    });
    db.prepare('UPDATE orders SET razorpay_order_id = ? WHERE order_id = ?').run(
      razorpayOrder.id,
      order_id,
    );
    return res.json({
      success: true,
      key_id: keyId,
      razorpay_order: razorpayOrder,
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.post('/payment/verify', auth, async (req, res) => {
  const { order_id, razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body || {};
  if (!order_id || !razorpay_order_id || !razorpay_payment_id) {
    return res.status(400).json({ success: false, message: 'Payment fields required' });
  }

  const order = db.prepare(
    'SELECT * FROM orders WHERE order_id = ? AND user_id = ?',
  ).get(order_id, req.user.userId);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Order not found' });
  }

  const secret = process.env.RAZORPAY_KEY_SECRET;
  if (secret && razorpay_signature) {
    const expected = crypto
      .createHmac('sha256', secret)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');
    if (expected !== razorpay_signature) {
      return res.status(400).json({ success: false, message: 'Invalid payment signature' });
    }
  } else if (!String(razorpay_order_id).startsWith('order_test_')) {
    return res.status(400).json({ success: false, message: 'Cannot verify without Razorpay secret' });
  }

  db.prepare(
    `UPDATE orders
     SET payment_id = ?, payment_status = ?, order_status = ?
     WHERE order_id = ?`,
  ).run(razorpay_payment_id, 'paid', 'confirmed', order_id);

  const updated = db.prepare('SELECT * FROM orders WHERE order_id = ?').get(order_id);
  const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.user.userId);

  let emailResult = { sent: false };
  let fcmResult = { sent: false };
  if (updated.order_status === 'confirmed') {
    try {
      emailResult = await sendOrderEmail({
        to: user.email,
        orderId: updated.order_id,
        amount: updated.amount,
        paymentStatus: updated.payment_status,
      });
    } catch (err) {
      console.log('[EMAIL] throw', err.message);
    }
    try {
      fcmResult = await sendFcmAfterConfirm({
        token: user.fcm_token,
        orderId: updated.order_id,
        amount: updated.amount,
      });
    } catch (err) {
      console.log('[FCM] throw', err.message);
    }
  }

  return res.json({
    success: true,
    order: updated,
    email: emailResult,
    fcm: fcmResult,
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Fooding API running on http://0.0.0.0:${PORT}`);
});
