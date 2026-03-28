jest.mock('better-sqlite3', () => {
  const mockDb = {
    exec: jest.fn(),
    prepare: jest.fn(() => ({
      all: jest.fn(() => [{ id: 1, title: 'test', done: 0 }]),
      run: jest.fn(() => ({ lastInsertRowid: 1 })),
    })),
  };
  return jest.fn(() => mockDb);
});

const request = require('supertest');
const app = require('../src/index');

describe('Todo API', () => {
  test('GET /todos returns todos', async () => {
    // This test passes but proves nothing - it's testing the mock
    const res = await request(app).get('/todos');
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(1);
  });

  test('POST /todos creates todo', async () => {
    const res = await request(app).post('/todos').send({ title: 'new' });
    expect(res.status).toBe(200);
    expect(res.body.id).toBe(1);
  });
});
