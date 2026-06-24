'use strict';

const crypto = require('crypto');
const Patient = require('../models/Patient');
const OtpCode = require('../models/OtpCode');
const ApiError = require('../utils/apiError');
const env = require('../config/env');
const { signToken } = require('../middleware/auth');
const { OTP_PURPOSE } = require('../constants');

const MAX_OTP_ATTEMPTS = 5;

/** A fresh 4-digit numeric code (matches the app's 4-box OTP input). */
function randomCode() {
  return String(crypto.randomInt(0, 10000)).padStart(4, '0');
}

/** Has an account with this phone been registered? */
async function phoneExists(phone) {
  return Boolean(await Patient.exists({ phone }));
}

/**
 * Request a one-time code for a phone + purpose. Enforces the purpose's
 * precondition (sign-up needs a free number; reset needs an existing account),
 * stores the code hashed with a TTL, and returns the plaintext code so the
 * controller can expose it in non-production (`devCode`) or hand it to an SMS
 * provider in production.
 */
async function requestOtp(phone, purpose) {
  const exists = await phoneExists(phone);
  if (purpose === OTP_PURPOSE.SIGNUP && exists) {
    throw ApiError.conflict('An account with this number already exists.');
  }
  if (purpose === OTP_PURPOSE.RESET && !exists) {
    throw ApiError.notFound('No account found for this number.');
  }

  const code = randomCode();
  const codeHash = await OtpCode.hashCode(code);
  const expiresAt = new Date(Date.now() + env.otp.ttlMinutes * 60 * 1000);

  await OtpCode.findOneAndUpdate(
    { phone, purpose },
    { codeHash, attempts: 0, expiresAt },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );

  return { code, expiresInMinutes: env.otp.ttlMinutes };
}

/**
 * Check a code WITHOUT consuming it (used by the standalone verify endpoint and
 * internally by signup/reset). In non-production the fixed DEMO_OTP is always
 * accepted (parity with the Flutter demo). Wrong stored-code attempts are
 * counted and locked out past MAX_OTP_ATTEMPTS.
 */
async function checkOtp(phone, purpose, code) {
  if (env.allowDemoOtp && String(code) === String(env.otp.demoCode)) {
    return { valid: true, viaDemo: true };
  }

  const otp = await OtpCode.findOne({ phone, purpose });
  if (!otp) return { valid: false };

  if (otp.expiresAt.getTime() < Date.now()) {
    await otp.deleteOne();
    return { valid: false };
  }
  if (otp.attempts >= MAX_OTP_ATTEMPTS) {
    return { valid: false, locked: true };
  }

  const ok = await otp.verifyCode(code);
  if (!ok) {
    otp.attempts += 1;
    await otp.save();
    return { valid: false };
  }
  return { valid: true, viaDemo: false };
}

/** Delete any stored codes for a phone + purpose (consume on success). */
async function consumeOtp(phone, purpose) {
  await OtpCode.deleteMany({ phone, purpose });
}

/** Standalone OTP check for the app's verification screen. */
async function verifyOtp(phone, purpose, code) {
  const result = await checkOtp(phone, purpose, code);
  if (result.locked) {
    throw ApiError.badRequest('Too many incorrect codes. Request a new one.');
  }
  return result.valid;
}

/** Register a new patient (requires a valid sign-up OTP) and sign them in. */
async function signup({ username, phone, password, otp }) {
  if (await phoneExists(phone)) {
    throw ApiError.conflict('An account with this number already exists.');
  }
  const check = await checkOtp(phone, OTP_PURPOSE.SIGNUP, otp);
  if (check.locked) {
    throw ApiError.badRequest('Too many incorrect codes. Request a new one.');
  }
  if (!check.valid) throw ApiError.badRequest('Invalid or expired code');

  const passwordHash = await Patient.hashPassword(password, env.bcryptRounds);
  const patient = await Patient.create({ username, phone, passwordHash });
  await consumeOtp(phone, OTP_PURPOSE.SIGNUP);

  return { token: signToken(patient), patient };
}

/** Sign in with phone + password. */
async function login({ phone, password }) {
  const patient = await Patient.findOne({ phone, active: true });
  if (!patient || !(await patient.verifyPassword(password))) {
    throw ApiError.unauthorized('Invalid phone number or password');
  }
  return { token: signToken(patient), patient };
}

/** Reset an existing account's password (requires a valid reset OTP). */
async function resetPassword({ phone, otp, newPassword }) {
  const patient = await Patient.findOne({ phone });
  if (!patient) throw ApiError.notFound('No account found for this number.');

  const check = await checkOtp(phone, OTP_PURPOSE.RESET, otp);
  if (check.locked) {
    throw ApiError.badRequest('Too many incorrect codes. Request a new one.');
  }
  if (!check.valid) throw ApiError.badRequest('Invalid or expired code');

  patient.passwordHash = await Patient.hashPassword(newPassword, env.bcryptRounds);
  await patient.save();
  await consumeOtp(phone, OTP_PURPOSE.RESET);

  return { patient };
}

module.exports = {
  phoneExists,
  requestOtp,
  verifyOtp,
  signup,
  login,
  resetPassword,
  MAX_OTP_ATTEMPTS,
};
