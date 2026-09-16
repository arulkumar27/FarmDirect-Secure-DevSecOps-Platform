const jwt = require("jsonwebtoken");

const authenticateToken = (req, res, next) => {
  const authorizationHeader = req.headers.authorization;

  if (!authorizationHeader?.startsWith("Bearer ")) {
    return res.status(401).json({
      message: "Authentication token is required"
    });
  }

  const token = authorizationHeader.split(" ")[1];

  try {
    const decodedToken = jwt.verify(token, process.env.JWT_SECRET);

    req.user = decodedToken;
    next();
  } catch (error) {
    console.warn(`JWT validation failed: ${error.name}`);

    return res.status(401).json({
      message: "Invalid or expired token"
    });
  }
};

const authorizeRoles = (...allowedRoles) => {
  return (req, res, next) => {
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        message: "You do not have permission for this action"
      });
    }

    next();
  };
};

module.exports = {
  authenticateToken,
  authorizeRoles
};