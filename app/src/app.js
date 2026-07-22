const express = require('express');
const usersRouter = require('./routes/users');
const db = require('./db');

const app = express();
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Bienvenido a la API mínima de DevOps' });
});

app.get('/health', async (req, res) => {
  try {
    await db.query('SELECT 1');
    return res.json({ status: 'ok', database: 'connected' });
  } catch (error) {
    return res.status(503).json({ status: 'error', database: 'unavailable' });
  }
});

app.use('/users', usersRouter);

module.exports = app;
