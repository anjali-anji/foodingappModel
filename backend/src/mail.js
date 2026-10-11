const fs = require('fs');
const path = require('path');
const nodemailer = require('nodemailer');

const dataDir = path.join(__dirname, '..', 'data');
const lastJsonPath = path.join(dataDir, 'last-order-email.json');
const lastHtmlPath = path.join(dataDir, 'last-order-email.html');

function saveLocalCopy({ to, orderId, amount, paymentStatus, html, subject, previewUrl, ethereal }) {
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
  }
  const record = {
    to,
    orderId,
    amount,
    paymentStatus,
    subject,
    previewUrl: previewUrl || null,
    ethereal: !!ethereal,
    savedAt: new Date().toISOString(),
  };
  fs.writeFileSync(lastJsonPath, JSON.stringify(record, null, 2));
  fs.writeFileSync(lastHtmlPath, html);
  return record;
}

async function sendOrderEmail({ to, orderId, amount, paymentStatus }) {
  const html = `
    <h2>Fooding order update</h2>
    <p><b>Order ID:</b> ${orderId}</p>
    <p><b>Amount:</b> ₹${amount}</p>
    <p><b>Payment Status:</b> ${paymentStatus}</p>
  `;
  const subject = `Fooding order ${orderId}`;

  try {
    let transporter;
    let usingEthereal = false;

    if (process.env.SMTP_HOST && process.env.SMTP_USER) {
      transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: Number(process.env.SMTP_PORT || 587),
        secure: false,
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS,
        },
      });
    } else {
      const testAccount = await nodemailer.createTestAccount();
      usingEthereal = true;
      transporter = nodemailer.createTransport({
        host: 'smtp.ethereal.email',
        port: 587,
        secure: false,
        auth: { user: testAccount.user, pass: testAccount.pass },
      });
      console.log('[EMAIL] Using Ethereal test inbox', testAccount.user);
    }

    const info = await transporter.sendMail({
      from: process.env.MAIL_FROM || process.env.SMTP_USER || 'fooding@test.com',
      to,
      subject,
      html,
    });

    const previewUrl = nodemailer.getTestMessageUrl(info);
    const local = saveLocalCopy({
      to,
      orderId,
      amount,
      paymentStatus,
      html,
      subject,
      previewUrl,
      ethereal: usingEthereal,
    });
    console.log('[EMAIL] sent', { to, orderId, amount, paymentStatus, id: info.messageId, previewUrl });
    if (previewUrl) {
      console.log('[EMAIL] OPEN THIS LINK:', previewUrl);
    }
    console.log('[EMAIL] local copy', lastHtmlPath);
    return { sent: true, previewUrl, ethereal: usingEthereal, ...local };
  } catch (err) {
    console.log('[EMAIL] FAILED', err.message);
    saveLocalCopy({
      to,
      orderId,
      amount,
      paymentStatus,
      html,
      subject,
      previewUrl: null,
      ethereal: false,
    });
    return { sent: false, error: err.message, localSaved: true };
  }
}

function readLastEmail() {
  if (!fs.existsSync(lastJsonPath)) return null;
  return JSON.parse(fs.readFileSync(lastJsonPath, 'utf8'));
}

function lastEmailHtml() {
  if (!fs.existsSync(lastHtmlPath)) return null;
  return fs.readFileSync(lastHtmlPath, 'utf8');
}

module.exports = { sendOrderEmail, readLastEmail, lastEmailHtml };
