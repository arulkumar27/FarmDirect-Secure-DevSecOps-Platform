const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const pool = require("../config/database");

const register = async (req, res, next) => {
  try {
    const { fullName, email, password, role } = req.body;

    if (!fullName || !email || !password || !role) {
      return res.status(400).json({
        message: "fullName, email, password and role are required"
      });
    }

    if (!["FARMER", "RETAILER"].includes(role)) {
      return res.status(400).json({
        message: "Only FARMER and RETAILER roles can self-register"
      });
    }

    if (password.length < 12) {
      return res.status(400).json({
        message: "Password must contain at least 12 characters"
      });
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const accountStatus = role === "FARMER" ? "PENDING" : "APPROVED";

    const result = await pool.query(
      `
        INSERT INTO users (
          full_name,
          email,
          password_hash,
          role,
          account_status
        )
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id, full_name, email, role, account_status, created_at
      `,
      [
        fullName,
        email.toLowerCase(),
        passwordHash,
        role,
        accountStatus
      ]
    );

    const message =
      role === "FARMER"
        ? "Farmer account created. Admin approval is required before sign in."
        : "Retailer account created successfully";

    res.status(201).json({
      message,
      user: result.rows[0]
    });
  } catch (error) {
    if (error.code === "23505") {
      return res.status(409).json({
        message: "Email is already registered"
      });
    }

    next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: "email and password are required"
      });
    }

    const result = await pool.query(
      `
        SELECT id, full_name, email, password_hash, role, account_status
        FROM users
        WHERE email = $1
      `,
      [email.toLowerCase()]
    );

    const user = result.rows[0];

    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({
        message: "Invalid email or password"
      });
    }

    if (user.account_status === "PENDING") {
      return res.status(403).json({
        message: "Farmer account is pending admin approval"
      });
    }

    if (user.account_status === "SUSPENDED") {
      return res.status(403).json({
        message: "This account has been suspended"
      });
    }

    const token = jwt.sign(
      {
        userId: user.id,
        role: user.role
      },
      process.env.JWT_SECRET,
      {
        expiresIn: process.env.JWT_EXPIRES_IN || "1h"
      }
    );

    res.status(200).json({
      message: "Login successful",
      token,
      user: {
        id: user.id,
        fullName: user.full_name,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login
};