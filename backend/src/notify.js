const fs = require('fs');
const path = require('path');

let admin = null;
const saPath = path.join(__dirname, '..', 'serviceAccount.json');
console.log('[FCM] serviceAccount.json', fs.existsSync(saPath) ? 'READY' : 'MISSING');

function getAdmin() {
  if (admin) return admin;
  if (!fs.existsSync(saPath)) {
    return null;
  }
  admin = require('firebase-admin');
  const { getMessaging } = require('firebase-admin/messaging');
  if (!admin.getApps().length) {
    admin.initializeApp({
      credential: admin.cert(require(saPath)),
    });
  }
  admin._messaging = getMessaging();
  return admin;
}

async function sendFcmAfterConfirm({ token, orderId, amount }) {
  if (!token) {
    console.log('[FCM] No device token for order', orderId);
    return { sent: false };
  }

  const title = 'Order confirmed';
  const body = `Order ${orderId} of ₹${amount} is confirmed`;
  const data = { order_id: String(orderId), order_status: 'confirmed' };

  const fb = getAdmin();
  if (fb) {
    try {
      const id = await fb._messaging.send({
        token,
        notification: { title, body },
        data,
        android: { priority: 'high' },
      });
      console.log('[FCM] sent', id);
      return { sent: true };
    } catch (err) {
      console.log('[FCM] ADMIN SEND FAILED', err.message);
    }
  }

  const serverKey = process.env.FCM_SERVER_KEY;
  if (serverKey) {
    const res = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `key=${serverKey}`,
      },
      body: JSON.stringify({
        to: token,
        notification: { title, body },
        data,
      }),
    });
    const json = await res.json().catch(() => ({}));
    console.log('[FCM] legacy response', json);
    return { sent: res.ok };
  }

  console.log('[FCM] SKIPPED — put Firebase service account at backend/serviceAccount.json');
  console.log('[FCM] would send after confirmed order', { token: token.slice(0, 12) + '...', title, body, data });
  return { sent: false, logged: true };
}

module.exports = { sendFcmAfterConfirm };
