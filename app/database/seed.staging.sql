INSERT INTO users (full_name, email, password_hash, role)
VALUES (
  'Staging Green Farm',
  'staging.farmer@farmdirect.local',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
  'FARMER'
)
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (
  farmer_id,
  product_name,
  category,
  unit,
  price_per_unit,
  available_quantity
)
SELECT
  id,
  'Organic Tomato',
  'Vegetables',
  'kg',
  45,
  150
FROM users
WHERE email = 'staging.farmer@farmdirect.local';

INSERT INTO products (
  farmer_id,
  product_name,
  category,
  unit,
  price_per_unit,
  available_quantity
)
SELECT
  id,
  'Fresh Carrot',
  'Vegetables',
  'kg',
  55,
  80
FROM users
WHERE email = 'staging.farmer@farmdirect.local';