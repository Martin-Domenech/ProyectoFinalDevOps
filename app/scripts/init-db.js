const { pool } = require('../src/db');

const initQuery = `
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
`;

async function main() {
  try {
    console.log('Initializing database schema for users table');
    await pool.query(initQuery);
    console.log('users table is ready');
  } catch (error) {
    console.error('Database initialization failed', {
      message: error.message,
      code: error.code,
      detail: error.detail,
      hint: error.hint,
    });
    process.exit(1);
  } finally {
    try {
      await pool.end();
      console.log('Database pool closed');
    } catch (closeError) {
      console.error('Failed to close database pool', {
        message: closeError.message,
      });
    }
  }
}

main();
