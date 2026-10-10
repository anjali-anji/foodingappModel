# Mini Food Ordering App

Flutter + Dart client, Node.js + Express backend, SQLite.

## Test credentials

- Email: `test@fooding.com`
- Password: `Test@123`

## Run backend

```bash
cd backend
npm install
npm start
```

API: `http://localhost:3000` (phone: `http://10.190.1.213:3000`)

## Run Flutter

```bash
cd mobile
flutter pub get
flutter run
```

Phone and PC same Wi-Fi pe hone chahiye. Emulator ke liye `mobile/lib/constants/api_constants.dart` me baseUrl `http://10.0.2.2:3000` karo.

## APIs

- `POST /register`
- `POST /login`
- `GET /foods`
- `POST /orders` (auth)
- `POST /payment/create` (auth)
- `POST /payment/verify` (auth)
- `GET /orders` (auth)
- `GET /orders/:id` (auth)

Postman: `docs/Fooding.postman_collection.json`  
Schema: `docs/schema.sql`

## Razorpay Test Mode

1. Free account: https://dashboard.razorpay.com (Test Mode)
2. `backend/.env` me daalo:

```
RAZORPAY_KEY_ID=rzp_test_xxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxx
```

3. Backend restart: `npm start`
4. Checkout pe **Pay with Razorpay**
5. Test card: `4111 1111 1111 1111`, CVV `123`, expiry koi future date, name koi bhi

Payment success ke baad server signature verify karta hai, order **confirmed** hota hai, phir email + FCM.
