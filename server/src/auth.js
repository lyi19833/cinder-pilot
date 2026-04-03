const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const store = require('./store');

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret';

function generateToken(deviceId) {
  return jwt.sign({ deviceId }, JWT_SECRET, { expiresIn: '30d' });
}

function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (e) {
    return null;
  }
}

function generateTempToken(deviceId) {
  const token = uuidv4();
  store.tempTokens.set(token, {
    deviceId,
    expiresAt: Date.now() + 5 * 60 * 1000, // 5 min
  });
  return token;
}

function verifyTempToken(token) {
  const entry = store.tempTokens.get(token);
  if (!entry || entry.expiresAt < Date.now()) {
    store.tempTokens.delete(token);
    return null;
  }
  return entry.deviceId;
}

module.exports = {
  generateToken,
  verifyToken,
  generateTempToken,
  verifyTempToken,
};
