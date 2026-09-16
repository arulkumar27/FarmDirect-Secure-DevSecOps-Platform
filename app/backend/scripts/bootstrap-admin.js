const bcrypt = require("bcryptjs");
const pool = require("../config/database");

const email = process.env.ADMIN_EMAIL?.trim().toLowerCase();
const password = process.env.ADMIN_PASSWORD;
const fullName = process.env.ADMIN_FULL_NAME?.trim() || "FarmDirect Administrator";

async function bootstrapAdmin() {
  if (!email || !password) {
    throw new Error("ADMIN_EMAIL and ADMIN_PASSWORD are required");
  }

  if (password.length < 12) {
    throw new Error("ADMIN_PASSWORD must contain at least 12 characters");
  }

  const existingUser = await pool.query(
    "SELECT id, email, role FROM users WHERE email = $1",
    [email]
  );

  if (existingUser.rowCount > 0) {
    const user = existingUser.rows[0];

    if (user.role !== "ADMIN") {
      throw new Error("This email already belongs to a non-admin account");
    }

    console.log(`Admin account already exists: ${user.email}`);
    return;
  }

  const passwordHash = await bcrypt.hash(password, 12);

  const result = await pool.query(
    `
      INSERT INTO users (
        full_name,
        email,
        password_hash,
        role,
        account_status
      )
      VALUES ($1, $2, $3, 'ADMIN', 'APPROVED')
      RETURNING id, full_name, email, role, account_status
    `,
    [fullName, email, passwordHash]
  );

  console.log("Admin account created:", result.rows[0]);
}

bootstrapAdmin()
  .catch((error) => {
    console.error("Admin bootstrap failed:", error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await pool.end();
  });