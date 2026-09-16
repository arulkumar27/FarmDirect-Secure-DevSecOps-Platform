process.env.JWT_SECRET = "test-only-jwt-secret";

const request = require("supertest");
const jwt = require("jsonwebtoken");
const app = require("../app");

describe("Admin endpoint security", () => {
  test("Retailer cannot view admin orders", async () => {
    const retailerToken = jwt.sign(
      {
        userId: 2,
        role: "RETAILER"
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "1h"
      }
    );

    const response = await request(app)
      .get("/api/admin/orders")
      .set("Authorization", `Bearer ${retailerToken}`);

    expect(response.statusCode).toBe(403);
    expect(response.body.message).toBe(
      "You do not have permission for this action"
    );
  });
});