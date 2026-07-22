const path = require('path');
const dotenv = require('dotenv');

const dotenvPath = path.resolve(__dirname, '../.env');
const dotenvResult = dotenv.config({ path: dotenvPath });
console.log('server dotenv load', {
  path: dotenvPath,
  error: dotenvResult.error ? dotenvResult.error.message : undefined,
  parsed: dotenvResult.parsed ? Object.keys(dotenvResult.parsed) : undefined,
});

const app = require('./app');

const port = Number(process.env.PORT || 3000);
console.log('server env sources', {
  PORT: process.env.PORT,
  DB_HOST: process.env.DB_HOST,
  DB_PORT: process.env.DB_PORT,
  DB_NAME: process.env.DB_NAME,
  DB_USER: process.env.DB_USER,
});

app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`);
});
