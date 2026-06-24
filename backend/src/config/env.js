'use strict';

require('dotenv').config();

/** Parse a comma-separated origins list; '*' means allow all. */
function parseOrigins(raw) {
  if (!raw || raw.trim() === '' || raw.trim() === '*') return '*';
  return raw
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
}

const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '4100', 10),

  // Blank => in-memory MongoDB (see config/db.js).
  mongoUri: process.env.MONGODB_URI || '',

  clinicTz: process.env.CLINIC_TZ || 'Asia/Kolkata',

  jwtSecret: process.env.JWT_SECRET || 'dev-insecure-secret-change-me',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '30d',
  bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS || '12', 10),

  otp: {
    ttlMinutes: parseInt(process.env.OTP_TTL_MINUTES || '10', 10),
    demoCode: process.env.DEMO_OTP || '1234',
  },

  corsOrigins: parseOrigins(process.env.CORS_ORIGINS),

  seed: {
    demoName: process.env.DEMO_PATIENT_NAME || 'Demo Patient',
    demoPhone: process.env.DEMO_PATIENT_PHONE || '9999999999',
    demoPass: process.env.DEMO_PATIENT_PASS || 'demo1234',
  },
};

env.isProd = env.nodeEnv === 'production';
env.isTest = env.nodeEnv === 'test';

// In non-production, the fixed DEMO_OTP is always accepted (parity with the
// Flutter demo). In production it is rejected — only real, requested codes work.
env.allowDemoOtp = !env.isProd;

// Fail fast in production if the JWT secret was never set.
if (env.isProd && env.jwtSecret === 'dev-insecure-secret-change-me') {
  throw new Error('JWT_SECRET must be set in production.');
}

module.exports = env;
