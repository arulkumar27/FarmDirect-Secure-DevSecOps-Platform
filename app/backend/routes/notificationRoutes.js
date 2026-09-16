const express = require("express");

const {
  getMyNotifications,
  markAllNotificationsRead
} = require("../controllers/notificationController");

const { authenticateToken } = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", authenticateToken, getMyNotifications);

router.patch(
  "/read-all",
  authenticateToken,
  markAllNotificationsRead
);

module.exports = router;