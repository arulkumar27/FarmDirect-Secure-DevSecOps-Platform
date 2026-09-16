const express = require("express");

const {
  getProducts,
  getMyProducts,
  createProduct,
  updateProduct,
  deleteProduct
} = require("../controllers/productController");

const {
  authenticateToken,
  authorizeRoles
} = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", getProducts);

router.get(
  "/mine",
  authenticateToken,
  authorizeRoles("FARMER"),
  getMyProducts
);

router.post(
  "/",
  authenticateToken,
  authorizeRoles("FARMER"),
  createProduct
);

router.patch(
  "/:productId",
  authenticateToken,
  authorizeRoles("FARMER"),
  updateProduct
);

router.delete(
  "/:productId",
  authenticateToken,
  authorizeRoles("FARMER"),
  deleteProduct
);

module.exports = router;