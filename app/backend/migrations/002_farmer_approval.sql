ALTER TABLE users
ADD COLUMN IF NOT EXISTS account_status VARCHAR(20);

-- Existing demo users remain active after introducing this feature.
UPDATE users
SET account_status = 'APPROVED'
WHERE account_status IS NULL;

ALTER TABLE users
ALTER COLUMN account_status SET DEFAULT 'PENDING';

ALTER TABLE users
ALTER COLUMN account_status SET NOT NULL;

ALTER TABLE users
ADD CONSTRAINT users_account_status_check
CHECK (account_status IN ('PENDING', 'APPROVED', 'SUSPENDED'));