const request = require('supertest');
const usersRouter = require('../src/routes/users');
const express = require('express');
const db = require('../src/db');

jest.mock('../src/db');

describe('Users routes', () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use('/users', usersRouter);
  });

  afterEach(() => {
    jest.resetAllMocks();
  });

  it('POST /users crea un usuario válido', async () => {
    const newUser = { id: 1, name: 'Martín', email: 'martin@example.com', created_at: '2026-07-22T00:00:00.000Z' };
    db.query.mockResolvedValue({ rows: [newUser] });

    const response = await request(app)
      .post('/users')
      .send({ name: newUser.name, email: newUser.email });

    expect(response.statusCode).toBe(201);
    expect(response.body).toEqual(newUser);
    expect(db.query).toHaveBeenCalledWith(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, name, email, created_at',
      [newUser.name, newUser.email]
    );
  });

  it('POST /users responde 400 si falta email', async () => {
    const response = await request(app).post('/users').send({ name: 'Martín' });
    expect(response.statusCode).toBe(400);
    expect(response.body).toEqual({ error: 'name and email are required' });
  });

  it('POST /users responde 400 si email inválido', async () => {
    const response = await request(app).post('/users').send({ name: 'Martín', email: 'invalid' });
    expect(response.statusCode).toBe(400);
    expect(response.body).toEqual({ error: 'invalid email' });
  });

  it('POST /users responde 409 si email existe', async () => {
    const error = new Error('duplicate key value violates unique constraint');
    error.code = '23505';
    db.query.mockRejectedValue(error);

    const response = await request(app)
      .post('/users')
      .send({ name: 'Martín', email: 'martin@example.com' });

    expect(response.statusCode).toBe(409);
    expect(response.body).toEqual({ error: 'email already exists' });
  });

  it('GET /users devuelve lista ordenada', async () => {
    const users = [
      { id: 1, name: 'Martín', email: 'martin@example.com', created_at: '2026-07-22T00:00:00.000Z' },
      { id: 2, name: 'Ana', email: 'ana@example.com', created_at: '2026-07-22T00:01:00.000Z' },
    ];
    db.query.mockResolvedValue({ rows: users });

    const response = await request(app).get('/users');

    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual(users);
    expect(db.query).toHaveBeenCalledWith('SELECT id, name, email, created_at FROM users ORDER BY id ASC');
  });

  it('DELETE /users/:id elimina usuario existente', async () => {
    db.query.mockResolvedValue({ rowCount: 1, rows: [{ id: 1 }] });

    const response = await request(app).delete('/users/1');

    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({ deleted: true });
    expect(db.query).toHaveBeenCalledWith('DELETE FROM users WHERE id = $1 RETURNING id', [1]);
  });

  it('DELETE /users/:id responde 404 si no existe', async () => {
    db.query.mockResolvedValue({ rowCount: 0, rows: [] });

    const response = await request(app).delete('/users/100');

    expect(response.statusCode).toBe(404);
    expect(response.body).toEqual({ error: 'user not found' });
  });

  it('DELETE /users/:id responde 400 si id inválido', async () => {
    const response = await request(app).delete('/users/abc');
    expect(response.statusCode).toBe(400);
    expect(response.body).toEqual({ error: 'invalid id' });
  });
});
