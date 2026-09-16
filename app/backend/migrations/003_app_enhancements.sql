ALTER TABLE users
ADD COLUMN IF NOT EXISTS account_status VARCHAR(20) DEFAULT 'APPROVED';

UPDATE users
SET account_status = 'APPROVED'
WHERE account_status IS NULL;

ALTER TABLE users
ALTER COLUMN account_status SET NOT NULL;

DO $$
DECLARE
  existing_constraint TEXT;
BEGIN
  SELECT conname
  INTO existing_constraint
  FROM pg_constraint
  WHERE conrelid = 'users'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) ILIKE '%account_status%'
  LIMIT 1;

  IF existing_constraint IS NOT NULL THEN
    EXECUTE format(
      'ALTER TABLE users DROP CONSTRAINT %I',
      existing_constraint
    );
  END IF;
END $$;

ALTER TABLE users
ADD CONSTRAINT users_account_status_check
CHECK (account_status IN ('PENDING', 'APPROVED', 'SUSPENDED'));

CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(150) NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS notifications_user_created_index
ON notifications (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS orders_retailer_created_index
ON orders (retailer_id, created_at DESC);

CREATE INDEX IF NOT EXISTS products_farmer_created_index
ON products (farmer_id, created_at DESC);