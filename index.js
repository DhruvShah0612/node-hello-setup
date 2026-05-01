const http = require('http');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  const msg = 'Hello FRESH DEPLOY BY DHRUV SHAH v7\n'
  res.end(msg);
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Server running on port ${port}`);
});
