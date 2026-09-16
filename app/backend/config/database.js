const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,

  // Local Docker PostgreSQL: false
  // AWS RDS PostgreSQL: true
  ssl:
    process.env.DB_SSL === "true"
      ? { rejectUnauthorized: false }
      : false
});

pool.on("error", (error) => {
  console.error("Unexpected PostgreSQL connection error:", error);
});

module.exports = pool;