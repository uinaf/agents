const http = require('http');

test('health endpoint returns ok', (done) => {
  const app = require('../src/index');
  const server = app.listen(0, () => {
    const port = server.address().port;
    http.get(`http://localhost:${port}/health`, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        expect(JSON.parse(data).status).toBe('ok');
        server.close(done);
      });
    });
  });
});
