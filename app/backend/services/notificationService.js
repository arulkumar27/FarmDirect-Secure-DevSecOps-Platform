const nodemailer = require("nodemailer");
const pool = require("../config/database");

function getTransporter() {
  if (
    !process.env.SMTP_HOST ||
    !process.env.SMTP_USER ||
    !process.env.SMTP_PASSWORD
  ) {
    return null;
  }

  return nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 587),
    secure: process.env.SMTP_SECURE === "true",
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASSWORD
    }
  });
}

async function createNotification({
  userId,
  email,
  type,
  title,
  message
}) {
  try {
    await pool.query(
      `
        INSERT INTO notifications (user_id, type, title, message)
        VALUES ($1, $2, $3, $4)
      `,
      [userId, type, title, message]
    );

    const transporter = getTransporter();

    if (!transporter || !email) {
      return;
    }

    await transporter.sendMail({
      from: process.env.SMTP_FROM || "FarmDirect <no-reply@farmdirect.local>",
      to: email,
      subject: title,
      text: message
    });
  } catch (error) {
    console.error("Notification delivery failed:", error.message);
  }
}

module.exports = {
  createNotification
};