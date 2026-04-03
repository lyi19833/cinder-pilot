const store = {
  connections: new Map(),      // deviceId -> WebSocket
  pairings: new Map(),         // deviceId -> pairedDeviceId
  sessions: new Map(),         // sessionId -> { deviceId, createdAt }
  tempTokens: new Map(),       // tempToken -> { deviceId, expiresAt }
};

module.exports = store;
