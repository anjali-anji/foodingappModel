# Mini Food Ordering App

Flutter + Node.js (Express) + SQLite + Razorpay Test + FCM + Email.

## Test credentials

- Email: `test@fooding.com`
- Password: `Test@123`

Your registered account also works (example: `anjalishukla8090yt@gmail.com`).

## Run backend

```bash
cd backend
npm install
npm start
```

API: `http://localhost:3000`

Phone USB: `adb reverse tcp:3000 tcp:3000` then app uses `http://127.0.0.1:3000`

## Run Flutter

```bash
cd mobile
flutter pub get
flutter run
```

## APIs

- `POST /register`
- `POST /login`
- `GET /foods`
- `POST /orders` (Bearer token)
- `POST /payment/create` (Bearer token)
- `POST /payment/verify` (Bearer token)
- `GET /orders` (Bearer token)
- `GET /orders/:id` (Bearer token)

Postman: `docs/Fooding.postman_collection.json`  
Schema: `docs/schema.sql`  
Debug APK: `docs/fooding-debug.apk` (after build)

## Git

Local repo is ready on branch `main`. GitHub pe naya empty repo banao, phir:

```bash
git remote add origin https://github.com/YOUR_USER/foodingApp.git
git push -u origin main
```

## Notifications + email (done)

- Firebase Admin key is at `backend/serviceAccount.json` (gitignored). Confirmed order sends FCM.
- Email goes out after confirm (Ethereal test inbox if Gmail SMTP is empty).
- Last email: `GET http://localhost:3000/emails/last` and `GET http://localhost:3000/emails/last?format=html`

## Razorpay Test keys (optional, asli card UI)

Keys ke bina app **Razorpay Test** dialog se payment complete karti hai.

Asli Razorpay sheet ke liye:

1. https://dashboard.razorpay.com → Test Mode → API Keys
2. `backend/.env`:

```
RAZORPAY_KEY_ID=rzp_test_xxxx
RAZORPAY_KEY_SECRET=xxxx
```

3. Backend restart

Test card: `4111 1111 1111 1111` CVV `123` expiry future

Gmail inbox chahiye ho to SMTP App Password `.env` me daalo.

## Login flow

Saved session: pehle se login ho to Home, warna Login screen.
