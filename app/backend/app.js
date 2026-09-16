require("dotenv").config();

const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const client = require("prom-client");

const productRoutes = require("./routes/productRoutes");
const authRoutes = require("./routes/authRoutes");
const orderRoutes = require("./routes/orderRoutes");
const adminRoutes = require("./routes/adminRoutes");
const notificationRoutes = require("./routes/notificationRoutes");

const app = express();
app.disable("x-powered-by");

const CLIENT_ORIGIN = process.env.CLIENT_ORIGIN || "http://localhost:3000";

const metricsRegistry = new client.Registry();

client.collectDefaultMetrics({
  register: metricsRegistry,
  prefix: "farmdirect_"
});

const httpRequestsTotal = new client.Counter({
  name: "farmdirect_http_requests_total",
  help: "Total HTTP requests handled by FarmDirect",
  labelNames: ["method", "status_code"],
  registers: [metricsRegistry]
});

const httpRequestDurationSeconds = new client.Histogram({
  name: "farmdirect_http_request_duration_seconds",
  help: "FarmDirect HTTP request duration in seconds",
  labelNames: ["method", "status_code"],
  buckets: [0.05, 0.1, 0.25, 0.5, 1, 2, 5],
  registers: [metricsRegistry]
});

app.use(
  cors({
    origin: CLIENT_ORIGIN,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"]
  })
);

app.use(express.json());
app.use(morgan("combined"));

app.get("/metrics", async (req, res, next) => {
  try {
    res.set("Content-Type", metricsRegistry.contentType);
    res.end(await metricsRegistry.metrics());
  } catch (error) {
    next(error);
  }
});

app.use((req, res, next) => {
  const stopTimer = httpRequestDurationSeconds.startTimer();

  res.on("finish", () => {
    const labels = {
      method: req.method,
      status_code: String(res.statusCode)
    };

    httpRequestsTotal.inc(labels);
    stopTimer(labels);
  });

  next();
});

app.get("/api/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    service: "farmdirect-backend",
    timestamp: new Date().toISOString()
  });
});

app.use("/api/products", productRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/notifications", notificationRoutes);

app.use((req, res) => {
  res.status(404).json({
    message: "Route not found"
  });
});

app.use((error, req, res, next) => {
  console.error(error);

  res.status(500).json({
    message: "Internal server error"
  });
});

module.exports = app;