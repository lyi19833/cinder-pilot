require('dotenv').config();
const http = require('http');
const WebSocket = require('ws');
const messageRouter = require('./messageRouter');
const store = require('./store');

const PORT = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200);
    res.end('OK');
  } else {
    res.writeHead(404);
    res.end('Not Found');
  }
});

const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
  console.log('Client connected');

  ws.on('message', (raw) => {
    try {
      const msg = JSON.parse(raw);
      messageRouter.handle(ws, msg);
    } catch (e) {
      console.error('Message parse error:', e);
      ws.send(JSON.stringify({
        type: 'error',
        payload: { code: 'PARSE_ERROR', message: e.message },
      }));
    }
  });

  ws.on('close', () => {
    if (ws.deviceId) {
      console.log('Client disconnected:', ws.deviceId);
      store.connections.delete(ws.deviceId);

      const pairedId = store.pairings.get(ws.deviceId);
      if (pairedId) {
        const pairedWs = store.connections.get(pairedId);
        if (pairedWs?.readyState === 1) {
          pairedWs.send(JSON.stringify({
            type: 'peer_disconnected',
            payload: {},
          }));
        }
      }
    }
  });

  ws.on('error', (err) => {
    console.error('WebSocket error:', err);
  });
});

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
