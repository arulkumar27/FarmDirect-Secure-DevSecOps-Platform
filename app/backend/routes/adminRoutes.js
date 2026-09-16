const express = require("express");

const {
  getDashboard,
  getPendingFarmers,
  approveFarmer,
  suspendFarmer,
  getAllOrders,
  updateOrderStatus
} = require("../controllers/adminOrderController");

const {
  authenticateToken,
  authorizeRoles
} = require("../middleware/authMiddleware");

const router = express.Router();

router.use(authenticateToken, authorizeRoles("ADMIN"));

router.get("/dashboard", getDashboard);

router.get("/farmers/pending", getPendingFarmers);
router.patch("/farmers/:farmerId/approve", approveFarmer);
router.patch("/farmers/:farmerId/suspend", suspendFarmer);

router.get("/orders", getAllOrders);
router.patch("/orders/:orderId/status", updateOrderStatus);

module.exports = router;