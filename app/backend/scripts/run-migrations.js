const fs = require("node:fs");
const path = require("node:path");
const pool = require("../config/database");

const migrationsDirectory = path.join(__dirname, "..", "migrations");

async function runMigrations() {
  const client = await pool.connect();

  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version VARCHAR(100) PRIMARY KEY,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    const migrationFiles = fs
      .readdirSync(migrationsDirectory)
      .filter((file) => file.endsWith(".sql"))
      .sort();

    for (const file of migrationFiles) {
      const version = path.basename(file, ".sql");

      const appliedMigration = await client.query(
        "SELECT version FROM schema_migrations WHERE version = $1",
        [version]
      );

      if (appliedMigration.rowCount > 0) {
        console.log(`Migration already applied: ${version}`);
        continue;
      }

      const migrationSql = fs.readFileSync(
        path.join(migrationsDirectory, file),
        "utf8"
      );

      await client.query("BEGIN");

      try {
        await client.query(migrationSql);

        await client.query(
          "INSERT INTO schema_migrations (version) VALUES ($1)",
          [version]
        );

        await client.query("COMMIT");
        console.log(`Migration completed: ${version}`);
      } catch (error) {
        await client.query("ROLLBACK");
        throw error;
      }
    }
  } catch (error) {
    console.error("Migration failed:", error);
    process.exitCode = 1;
  } finally {
    client.release();
    await pool.end();
  }
}

runMigrations();