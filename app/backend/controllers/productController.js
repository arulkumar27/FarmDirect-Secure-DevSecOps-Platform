const pool = require("../config/database");

function validateProductInput(product) {
  const {
    productName,
    unit,
    pricePerUnit,
    availableQuantity
  } = product;

  if (
    !productName?.trim() ||
    !unit?.trim() ||
    Number(pricePerUnit) <= 0 ||
    Number(availableQuantity) < 0
  ) {
    return "Enter a valid product name, unit, price and quantity";
  }

  return null;
}

const getProducts = async (req, res, next) => {
  try {
    const result = await pool.query(`
      SELECT
        products.id,
        products.product_name,
        products.category,
        products.unit,
        products.price_per_unit,
        products.available_quantity,
        users.full_name AS farmer_name
      FROM products
      INNER JOIN users ON users.id = products.farmer_id
      WHERE products.available_quantity > 0
      ORDER BY products.created_at DESC
    `);

    res.status(200).json({
      count: result.rows.length,
      products: result.rows
    });
  } catch (error) {
    next(error);
  }
};

const getMyProducts = async (req, res, next) => {
  try {
    const result = await pool.query(
      `
        SELECT
          id,
          product_name,
          category,
          unit,
          price_per_unit,
          available_quantity,
          created_at,
          updated_at
        FROM products
        WHERE farmer_id = $1
        ORDER BY created_at DESC
      `,
      [req.user.userId]
    );

    res.status(200).json({ products: result.rows });
  } catch (error) {
    next(error);
  }
};

const createProduct = async (req, res, next) => {
  try {
    const validationMessage = validateProductInput(req.body);

    if (validationMessage) {
      return res.status(400).json({ message: validationMessage });
    }

    const result = await pool.query(
      `
        INSERT INTO products (
          farmer_id,
          product_name,
          category,
          unit,
          price_per_unit,
          available_quantity
        )
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *
      `,
      [
        req.user.userId,
        req.body.productName.trim(),
        req.body.category?.trim() || null,
        req.body.unit.trim(),
        Number(req.body.pricePerUnit),
        Number(req.body.availableQuantity)
      ]
    );

    res.status(201).json({
      message: "Product created successfully",
      product: result.rows[0]
    });
  } catch (error) {
    next(error);
  }
};

const updateProduct = async (req, res, next) => {
  try {
    const productId = Number(req.params.productId);
    const validationMessage = validateProductInput(req.body);

    if (validationMessage) {
      return res.status(400).json({ message: validationMessage });
    }

    const result = await pool.query(
      `
        UPDATE products
        SET
          product_name = $1,
          category = $2,
          unit = $3,
          price_per_unit = $4,
          available_quantity = $5,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $6
          AND farmer_id = $7
        RETURNING *
      `,
      [
        req.body.productName.trim(),
        req.body.category?.trim() || null,
        req.body.unit.trim(),
        Number(req.body.pricePerUnit),
        Number(req.body.availableQuantity),
        productId,
        req.user.userId
      ]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        message: "Product was not found or does not belong to you"
      });
    }

    res.status(200).json({
      message: "Product updated successfully",
      product: result.rows[0]
    });
  } catch (error) {
    next(error);
  }
};

const deleteProduct = async (req, res, next) => {
  try {
    const productId = Number(req.params.productId);

    const orderCheck = await pool.query(
      `SELECT id FROM order_items WHERE product_id = $1 LIMIT 1`,
      [productId]
    );

    if (orderCheck.rowCount > 0) {
      return res.status(400).json({
        message: "This product has order history and cannot be deleted"
      });
    }

    const result = await pool.query(
      `
        DELETE FROM products
        WHERE id = $1
          AND farmer_id = $2
        RETURNING id
      `,
      [productId, req.user.userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        message: "Product was not found or does not belong to you"
      });
    }

    res.status(200).json({
      message: "Product deleted successfully"
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getProducts,
  getMyProducts,
  createProduct,
  updateProduct,
  deleteProduct
};