const fs = require('fs');
const path = require('path');
const Database = require('better-sqlite3');

const dataDir = path.join(__dirname, '..', 'data');
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
}

const dbPath = path.join(dataDir, 'fooding.sqlite');
const db = new Database(dbPath);

db.exec(`
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  mobile TEXT NOT NULL,
  password TEXT NOT NULL,
  fcm_token TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS foods (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  image TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
  order_id TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  payment_id TEXT,
  payment_status TEXT NOT NULL DEFAULT 'pending',
  order_status TEXT NOT NULL DEFAULT 'pending',
  name TEXT NOT NULL,
  mobile TEXT NOT NULL,
  address TEXT NOT NULL,
  pincode TEXT NOT NULL,
  razorpay_order_id TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
`);

function seedFoods() {
  const count = db.prepare('SELECT COUNT(*) AS c FROM foods').get().c;
  if (count > 0) return;

  const insert = db.prepare(
    'INSERT INTO foods (name, price, image) VALUES (?, ?, ?)',
  );
  const foods = [
    ['Veg Burger', 149, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80'],
    ['Margherita Pizza', 249, 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80'],
    ['White Sauce Pasta', 199, 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?auto=format&fit=crop&w=800&q=80'],
    ['Chicken Biryani', 219, 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=800&q=80'],
    ['Veg Fried Rice', 159, 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=800&q=80'],
    ['Grill Sandwich', 99, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80'],
    ['Veg Momos', 129, 'https://images.unsplash.com/photo-1496116218417-1a781b2c4163?auto=format&fit=crop&w=800&q=80'],
    ['Chocolate Ice Cream', 89, 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=800&q=80'],
  ];
  const tx = db.transaction((rows) => {
    for (const row of rows) insert.run(...row);
  });
  tx(foods);
}

function seedTestUser(hashPassword) {
  const existing = db.prepare('SELECT id FROM users WHERE email = ?').get('test@fooding.com');
  if (existing) return;
  db.prepare(
    'INSERT INTO users (name, email, mobile, password) VALUES (?, ?, ?, ?)',
  ).run('Test User', 'test@fooding.com', '9876543210', hashPassword);
}

module.exports = { db, seedFoods, seedTestUser };
