const path = require('path');
const dotenv = require('dotenv');
const { Pool } = require('pg');

const dotenvPath = path.resolve(__dirname, '../.env');
const dotenvResult = dotenv.config({ path: dotenvPath });
console.log('dotenv load', {
  path: dotenvPath,
  error: dotenvResult.error ? dotenvResult.error.message : undefined,
  parsed: dotenvResult.parsed ? Object.keys(dotenvResult.parsed) : undefined,
});

const poolConfig = {
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
};

const sslEnabled = Boolean(process.env.DB_SSL && process.env.DB_SSL !== 'false' && process.env.DB_SSL !== '0');
if (sslEnabled) {
  poolConfig.ssl = { rejectUnauthorized: false };
}

const poolLogConfig = {
  host: poolConfig.host,
  port: poolConfig.port,
  database: poolConfig.database,
  user: poolConfig.user,
  ssl: poolConfig.ssl || false,
};
console.log('PostgreSQL connection config', poolLogConfig);
console.log('PostgreSQL pool config final', poolLogConfig);

const pool = new Pool(poolConfig);

pool.on('error', (error) => {
  console.error('PostgreSQL pool error', {
    message: error.message,
    code: error.code,
    detail: error.detail,
    hint: error.hint,
  });
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
};
