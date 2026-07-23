const express = require('express');
const client = require('prom-client');
const usersRouter = require('./routes/users');
const db = require('./db');

const app = express();
app.use(express.json());

client.collectDefaultMetrics();

app.get('/', (req, res) => {
  res.json({ message: 'Bienvenido a la API mínima de DevOps' });
});

app.get('/health', async (req, res) => {
  try {
    await db.query('SELECT 1');
    return res.json({ status: 'ok', database: 'connected' });
  } catch (error) {
    console.error('Health check database error', {
      message: error.message,
      code: error.code,
      detail: error.detail,
      hint: error.hint,
    });

    return res.status(503).json({ status: 'error', database: 'unavailable' });
  }
});

app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.use('/users', usersRouter);

module.exports = app;
