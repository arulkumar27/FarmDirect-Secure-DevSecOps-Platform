const request = require("supertest");
const app = require("../app");

describe("FarmDirect Backend API", () => {
  it("returns healthy status", async () => {
    const response = await request(app).get("/api/health");

    expect(response.statusCode).toBe(200);
    expect(response.body.status).toBe("healthy");
    expect(response.body.service).toBe("farmdirect-backend");
    expect(response.body.timestamp).toBeDefined();
  });

  it("blocks product creation without a JWT token", async () => {
    const response = await request(app)
      .post("/api/products")
      .send({
        productName: "Tomato",
        unit: "kg",
        pricePerUnit: 40,
        availableQuantity: 100
      });

    expect(response.statusCode).toBe(401);
    expect(response.body.message).toBe("Authentication token is required");
  });

  it("rejects registration when required fields are missing", async () => {
    const response = await request(app)
      .post("/api/auth/register")
      .send({
        email: "farmer@farmdirect.local"
      });

    expect(response.statusCode).toBe(400);
    expect(response.body.message).toBe(
      "fullName, email, password and role are required"
    );
  });
});