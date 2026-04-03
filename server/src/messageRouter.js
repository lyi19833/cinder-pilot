const store = require('./store');
const auth = require('./auth');

function handleAuth(ws, msg) {
  const { deviceId, token } = msg.payload;

  let verified = false;
  if (token) {
    const decoded = auth.verifyToken(token);
    verified = decoded && decoded.deviceId === deviceId;
  }

  if (!verified) {
    ws.send(JSON.stringify({
      type: 'auth_response',
      payload: { success: false, error: 'Invalid token' },
    }));
    return;
  }

  ws.deviceId = deviceId;
  store.connections.set(deviceId, ws);

  const newToken = auth.generateToken(deviceId);
  const sessionId = `${deviceId}-${Date.now()}`;

  ws.send(JSON.stringify({
    type: 'auth_response',
    payload: { success: true, sessionId, token: newToken },
  }));

  // Notify paired device
  const pairedId = store.pairings.get(deviceId);
  if (pairedId) {
    const pairedWs = store.connections.get(pairedId);
    if (pairedWs?.readyState === 1) {
      pairedWs.send(JSON.stringify({
        type: 'peer_connected',
        payload: {},
      }));
    }
  }
}

function handlePairQr(ws, msg) {
  const { deviceId } = msg.payload;
  const tempToken = auth.generateTempToken(deviceId);
  const qrData = JSON.stringify({ deviceId, tempToken });

  ws.send(JSON.stringify({
    type: 'pair_qr',
    payload: { qrData },
  }));
}

function handlePairConfirm(ws, msg) {
  const { peerDeviceId, tempToken } = msg.payload;
  const verifiedId = auth.verifyTempToken(tempToken);

  if (!verifiedId || verifiedId !== peerDeviceId) {
    ws.send(JSON.stringify({
      type: 'error',
      payload: { code: 'INVALID_PAIR_TOKEN', message: 'Invalid pairing token' },
    }));
    return;
  }

  const myId = ws.deviceId;
  store.pairings.set(myId, peerDeviceId);
  store.pairings.set(peerDeviceId, myId);

  ws.send(JSON.stringify({
    type: 'pair_confirm',
    payload: { success: true, peerDeviceId },
  }));

  const peerWs = store.connections.get(peerDeviceId);
  if (peerWs?.readyState === 1) {
    peerWs.send(JSON.stringify({
      type: 'pair_confirm',
      payload: { success: true, peerDeviceId: myId },
    }));
  }
}

function relay(ws, msg) {
  const peerId = store.pairings.get(ws.deviceId);
  if (!peerId) {
    ws.send(JSON.stringify({
      type: 'error',
      payload: { code: 'NOT_PAIRED', message: 'Device not paired' },
    }));
    return;
  }

  const peerWs = store.connections.get(peerId);
  if (!peerWs || peerWs.readyState !== 1) {
    ws.send(JSON.stringify({
      type: 'error',
      payload: { code: 'PEER_OFFLINE', message: 'Peer device offline' },
    }));
    return;
  }

  peerWs.send(JSON.stringify(msg));
}

function handle(ws, msg) {
  switch (msg.type) {
    case 'auth_request':
      return handleAuth(ws, msg);
    case 'pair_qr':
      return handlePairQr(ws, msg);
    case 'pair_confirm':
      return handlePairConfirm(ws, msg);
    case 'screen_frame':
    case 'touch_event':
    case 'key_event':
      return relay(ws, msg);
    default:
      console.log('Unknown message type:', msg.type);
  }
}

module.exports = { handle };
