const pool = require("../config/database");

const createOrder = async (req, res, next) => {
  const client = await pool.connect();

  try {
    const { items } = req.body;

    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        message: "Order must contain at least one item"
      });
    }

    await client.query("BEGIN");

    let totalAmount = 0;
    const validatedItems = [];

    for (const item of items) {
      const productId = Number(item.productId);
      const quantity = Number(item.quantity);

      if (!productId || quantity <= 0) {
        const error = new Error(
          "Each item requires a valid product and quantity"
        );
        error.statusCode = 400;
        throw error;
      }

      const productResult = await client.query(
        `
          SELECT id, product_name, price_per_unit, available_quantity
          FROM products
          WHERE id = $1
          FOR UPDATE
        `,
        [productId]
      );

      const product = productResult.rows[0];

      if (!product) {
        const error = new Error("Selected product was not found");
        error.statusCode = 404;
        throw error;
      }

      if (product.available_quantity < quantity) {
        const error = new Error(
          `Insufficient stock for ${product.product_name}. Available: ${product.available_quantity}`
        );
        error.statusCode = 400;
        throw error;
      }

      totalAmount += Number(product.price_per_unit) * quantity;

      validatedItems.push({
        productId: product.id,
        quantity,
        pricePerUnit: product.price_per_unit
      });
    }

    const orderResult = await client.query(
      `
        INSERT INTO orders (retailer_id, total_amount)
        VALUES ($1, $2)
        RETURNING *
      `,
      [req.user.userId, totalAmount]
    );

    const order = orderResult.rows[0];

    for (const item of validatedItems) {
      await client.query(
        `
          INSERT INTO order_items (order_id, product_id, quantity, price_per_unit)
          VALUES ($1, $2, $3, $4)
        `,
        [order.id, item.productId, item.quantity, item.pricePerUnit]
      );

      await client.query(
        `
          UPDATE products
          SET
            available_quantity = available_quantity - $1,
            updated_at = CURRENT_TIMESTAMP
          WHERE id = $2
        `,
        [item.quantity, item.productId]
      );
    }

    await client.query(
      `
        INSERT INTO audit_logs (user_id, action, entity_type, entity_id)
        VALUES ($1, 'ORDER_CREATED', 'ORDER', $2)
      `,
      [req.user.userId, order.id]
    );

    await client.query("COMMIT");

    res.status(201).json({
      message: "Order created successfully",
      order
    });
  } catch (error) {
    await client.query("ROLLBACK");
    res.status(error.statusCode || 500).json({
      message: error.message || "Unable to create order"
    });
  } finally {
    client.release();
  }
};

const getMyOrders = async (req, res, next) => {
  try {
    const result = await pool.query(
      `
        SELECT
          orders.id,
          orders.status,
          orders.total_amount,
          orders.created_at,
          COALESCE(
            json_agg(
              json_build_object(
                'productName', products.product_name,
                'quantity', order_items.quantity,
                'unit', products.unit,
                'pricePerUnit', order_items.price_per_unit
              )
            ) FILTER (WHERE order_items.id IS NOT NULL),
            '[]'::json
          ) AS items
        FROM orders
        LEFT JOIN order_items ON order_items.order_id = orders.id
        LEFT JOIN products ON products.id = order_items.product_id
        WHERE orders.retailer_id = $1
        GROUP BY orders.id
        ORDER BY orders.created_at DESC
      `,
      [req.user.userId]
    );

    res.status(200).json({
      orders: result.rows
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createOrder,
  getMyOrders
};