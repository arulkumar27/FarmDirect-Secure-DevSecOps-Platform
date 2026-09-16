const pool = require("../config/database");
const { createNotification } = require("../services/notificationService");

const allowedOrderStatuses = new Set([
  "PENDING",
  "CONFIRMED",
  "PACKED",
  "OUT_FOR_DELIVERY",
  "DELIVERED",
  "CANCELLED"
]);

async function getDashboard(req, res, next) {
  try {
    const search = (req.query.search || "").trim();
    const status = req.query.status || "";

    const [metricsResult, farmersResult, ordersResult] = await Promise.all([
      pool.query(`
        SELECT
          COUNT(*) FILTER (
            WHERE role = 'FARMER' AND account_status = 'PENDING'
          ) AS pending_farmers,
          COUNT(*) FILTER (
            WHERE role = 'FARMER' AND account_status = 'APPROVED'
          ) AS approved_farmers,
          COUNT(*) FILTER (
            WHERE role = 'FARMER' AND account_status = 'SUSPENDED'
          ) AS suspended_farmers,
          (SELECT COUNT(*) FROM orders) AS total_orders,
          (SELECT COUNT(*) FROM orders WHERE status = 'PENDING') AS pending_orders
        FROM users
      `),

      pool.query(
        `
          SELECT id, full_name, email, account_status, created_at
          FROM users
          WHERE role = 'FARMER'
            AND (
              $1 = ''
              OR full_name ILIKE '%' || $1 || '%'
              OR email ILIKE '%' || $1 || '%'
            )
          ORDER BY
            CASE WHEN account_status = 'PENDING' THEN 0 ELSE 1 END,
            created_at DESC
        `,
        [search]
      ),

      pool.query(
        `
          SELECT
            orders.id,
            orders.status,
            orders.total_amount,
            orders.created_at,
            users.full_name AS retailer_name,
            users.email AS retailer_email
          FROM orders
          INNER JOIN users ON users.id = orders.retailer_id
          WHERE
            ($1 = '' OR orders.status = $1)
            AND (
              $2 = ''
              OR users.full_name ILIKE '%' || $2 || '%'
              OR users.email ILIKE '%' || $2 || '%'
              OR CAST(orders.id AS TEXT) ILIKE '%' || $2 || '%'
            )
          ORDER BY orders.created_at DESC
        `,
        [status, search]
      )
    ]);

    res.status(200).json({
      metrics: metricsResult.rows[0],
      farmers: farmersResult.rows,
      orders: ordersResult.rows
    });
  } catch (error) {
    next(error);
  }
}

async function getPendingFarmers(req, res, next) {
  try {
    const result = await pool.query(`
      SELECT id, full_name, email, created_at
      FROM users
      WHERE role = 'FARMER'
        AND account_status = 'PENDING'
      ORDER BY created_at ASC
    `);

    res.status(200).json({ farmers: result.rows });
  } catch (error) {
    next(error);
  }
}

async function approveFarmer(req, res, next) {
  try {
    const farmerId = Number(req.params.farmerId);

    const result = await pool.query(
      `
        UPDATE users
        SET account_status = 'APPROVED'
        WHERE id = $1
          AND role = 'FARMER'
          AND account_status = 'PENDING'
        RETURNING id, full_name, email, role, account_status
      `,
      [farmerId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        message: "Pending farmer account was not found"
      });
    }

    const farmer = result.rows[0];

    await createNotification({
      userId: farmer.id,
      email: farmer.email,
      type: "FARMER_APPROVED",
      title: "Your FarmDirect farmer account is approved",
      message: `Hello ${farmer.full_name}, your farmer account is approved. You can now add products.`
    });

    res.status(200).json({
      message: "Farmer account approved successfully",
      farmer
    });
  } catch (error) {
    next(error);
  }
}

async function suspendFarmer(req, res, next) {
  try {
    const farmerId = Number(req.params.farmerId);

    const result = await pool.query(
      `
        UPDATE users
        SET account_status = 'SUSPENDED'
        WHERE id = $1
          AND role = 'FARMER'
          AND account_status <> 'SUSPENDED'
        RETURNING id, full_name, email, account_status
      `,
      [farmerId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        message: "Active farmer account was not found"
      });
    }

    const farmer = result.rows[0];

    await createNotification({
      userId: farmer.id,
      email: farmer.email,
      type: "FARMER_SUSPENDED",
      title: "Your FarmDirect farmer account is suspended",
      message: "Your farmer account has been suspended. Contact FarmDirect support for assistance."
    });

    res.status(200).json({
      message: "Farmer account suspended",
      farmer
    });
  } catch (error) {
    next(error);
  }
}

async function getAllOrders(req, res, next) {
  try {
    const result = await pool.query(`
      SELECT
        orders.id,
        orders.status,
        orders.total_amount,
        orders.created_at,
        users.full_name AS retailer_name,
        users.email AS retailer_email
      FROM orders
      INNER JOIN users ON users.id = orders.retailer_id
      ORDER BY orders.created_at DESC
    `);

    res.status(200).json({ orders: result.rows });
  } catch (error) {
    next(error);
  }
}

async function updateOrderStatus(req, res, next) {
  try {
    const orderId = Number(req.params.orderId);
    const { status } = req.body;

    if (!allowedOrderStatuses.has(status)) {
      return res.status(400).json({
        message: "Invalid order status"
      });
    }

    const result = await pool.query(
      `
        WITH updated_order AS (
          UPDATE orders
          SET
            status = $1,
            updated_at = CURRENT_TIMESTAMP
          WHERE id = $2
          RETURNING *
        )
        SELECT
          updated_order.id,
          updated_order.status,
          updated_order.total_amount,
          users.id AS retailer_id,
          users.full_name AS retailer_name,
          users.email AS retailer_email
        FROM updated_order
        INNER JOIN users ON users.id = updated_order.retailer_id
      `,
      [status, orderId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        message: "Order was not found"
      });
    }

    const order = result.rows[0];

    await createNotification({
      userId: order.retailer_id,
      email: order.retailer_email,
      type: "ORDER_STATUS_UPDATED",
      title: `FarmDirect order #${order.id} update`,
      message: `Your order #${order.id} is now ${order.status.replaceAll("_", " ")}.`
    });

    res.status(200).json({
      message: `Order #${orderId} updated to ${status}`,
      order
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getDashboard,
  getPendingFarmers,
  approveFarmer,
  suspendFarmer,
  getAllOrders,
  updateOrderStatus
};