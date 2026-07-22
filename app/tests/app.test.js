const request = require('supertest');
const app = require('../src/app');

jest.mock('../src/db', () => ({
  query: jest.fn(),
}));

const db = require('../src/db');

describe('API mínima de DevOps', () => {
  afterEach(() => {
    db.query.mockReset();
  });

  it('GET / debe devolver bienvenida', async () => {
    const response = await request(app).get('/');
    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({ message: 'Bienvenido a la API mínima de DevOps' });
  });

  it('GET /health debe devolver status ok cuando la DB responde', async () => {
    db.query.mockResolvedValue({ rows: [{ '?column?': 1 }] });
    const response = await request(app).get('/health');
    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({ status: 'ok', database: 'connected' });
    expect(db.query).toHaveBeenCalledWith('SELECT 1');
  });

  it('GET /health debe devolver error si la DB no responde', async () => {
    db.query.mockRejectedValue(new Error('db unavailable'));
    const response = await request(app).get('/health');
    expect(response.statusCode).toBe(503);
    expect(response.body).toEqual({ status: 'error', database: 'unavailable' });
    expect(db.query).toHaveBeenCalledWith('SELECT 1');
  });

  it('GET /health no expone detalles de error de la base', async () => {
    db.query.mockRejectedValue(new Error('db unavailable'));
    const response = await request(app).get('/health');
    expect(response.body).not.toHaveProperty('message');
    expect(response.body).not.toHaveProperty('code');
  });
});
