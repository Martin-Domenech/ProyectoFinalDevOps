const express = require('express');
const db = require('../db');

const router = express.Router();
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function isValidEmail(email) {
  return typeof email === 'string' && emailRegex.test(email);
}

router.post('/', async (req, res) => {
  const { name, email } = req.body;

  if (!name || !email || typeof name !== 'string' || typeof email !== 'string') {
    return res.status(400).json({ error: 'name and email are required' });
  }

  if (!isValidEmail(email)) {
    return res.status(400).json({ error: 'invalid email' });
  }

  try {
    const result = await db.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, name, email, created_at',
      [name, email]
    );

    return res.status(201).json(result.rows[0]);
  } catch (error) {
    if (error.code === '23505') {
      return res.status(409).json({ error: 'email already exists' });
    }

    console.error('POST /users error:', error);
    return res.status(500).json({ error: 'database error' });
  }
});

router.get('/', async (_req, res) => {
  try {
    const result = await db.query(
      'SELECT id, name, email, created_at FROM users ORDER BY id ASC'
    );
    return res.status(200).json(result.rows);
  } catch (error) {
    console.error('GET /users error:', error);
    return res.status(500).json({ error: 'database error' });
  }
});

router.delete('/:id', async (req, res) => {
  const id = Number(req.params.id);

  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: 'invalid id' });
  }

  try {
    const result = await db.query('DELETE FROM users WHERE id = $1 RETURNING id', [id]);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'user not found' });
    }

    return res.status(200).json({ deleted: true });
  } catch (error) {
    console.error('DELETE /users/:id error:', error);
    return res.status(500).json({ error: 'database error' });
  }
});

module.exports = router;
