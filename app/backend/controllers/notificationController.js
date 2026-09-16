const pool = require("../config/database");

async function getMyNotifications(req, res, next) {
  try {
    const result = await pool.query(
      `
        SELECT id, type, title, message, is_read, created_at
        FROM notifications
        WHERE user_id = $1
        ORDER BY created_at DESC
        LIMIT 20
      `,
      [req.user.userId]
    );

    res.status(200).json({
      notifications: result.rows
    });
  } catch (error) {
    next(error);
  }
}

async function markAllNotificationsRead(req, res, next) {
  try {
    await pool.query(
      `
        UPDATE notifications
        SET is_read = TRUE
        WHERE user_id = $1
          AND is_read = FALSE
      `,
      [req.user.userId]
    );

    res.status(200).json({
      message: "Notifications marked as read"
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getMyNotifications,
  markAllNotificationsRead
};