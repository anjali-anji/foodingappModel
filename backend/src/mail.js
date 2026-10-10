const nodemailer = require('nodemailer');

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
    console.log('[EMAIL] sent', { to, orderId, amount, paymentStatus, id: info.messageId, previewUrl });
    if (previewUrl) {
      console.log('[EMAIL] OPEN THIS LINK:', previewUrl);
    }
    return { sent: true, previewUrl, ethereal: usingEthereal };
  } catch (err) {
    console.log('[EMAIL] FAILED', err.message);
    return { sent: false, error: err.message };
  }
}

module.exports = { sendOrderEmail };
