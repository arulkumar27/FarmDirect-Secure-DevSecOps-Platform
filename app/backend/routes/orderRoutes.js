const express = require("express");

const {
  createOrder,
  getMyOrders
} = require("../controllers/orderController");

const {
  authenticateToken,
  authorizeRoles
} = require("../middleware/authMiddleware");

const router = express.Router();

router.get(
  "/mine",
  authenticateToken,
  authorizeRoles("RETAILER"),
  getMyOrders
);

router.post(
  "/",
  authenticateToken,
  authorizeRoles("RETAILER"),
  createOrder
);

module.exports = router;