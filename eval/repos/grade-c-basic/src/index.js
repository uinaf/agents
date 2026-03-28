const express = require('express');
const Database = require('better-sqlite3');

const app = express();
app.use(express.json());

const db = new Database(process.env.DATABASE_PATH || './data.db');
db.exec('CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY, title TEXT, done INTEGER DEFAULT 0)');

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.get('/todos', (req, res) => {
  const todos = db.prepare('SELECT * FROM todos').all();
  res.json(todos);
});

app.post('/todos', (req, res) => {
  const { title } = req.body;
  const result = db.prepare('INSERT INTO todos (title) VALUES (?)').run(title);
  res.json({ id: result.lastInsertRowid, title, done: false });
});

app.delete('/todos/:id', (req, res) => {
  db.prepare('DELETE FROM todos WHERE id = ?').run(req.params.id);
  res.json({ ok: true });
});

const PORT = process.env.PORT || 3456;
if (require.main === module) {
  app.listen(PORT, () => console.log(`running on ${PORT}`));
}
module.exports = app;
