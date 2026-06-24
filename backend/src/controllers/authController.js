'use strict';

const authService = require('../services/authService');
const asyncHandler = require('../utils/asyncHandler');
const env = require('../config/env');

// POST /api/auth/otp/request  { phone, purpose }
const requestOtp = asyncHandler(async (req, res) => {
  const { phone, purpose } = req.body;
  const { code, expiresInMinutes } = await authService.requestOtp(phone, purpose);

  const body = { sent: true, expiresInMinutes };
  // In non-production, surface the code so the demo/tests don't need real SMS.
  if (!env.isProd) body.devCode = code;
  res.json(body);
});

// POST /api/auth/otp/verify  { phone, purpose, code }
const verifyOtp = asyncHandler(async (req, res) => {
  const { phone, purpose, code } = req.body;
  const valid = await authService.verifyOtp(phone, purpose, code);
  res.json({ valid });
});

// POST /api/auth/signup  { username, phone, password, otp }
const signup = asyncHandler(async (req, res) => {
  const { token, patient } = await authService.signup(req.body);
  res.status(201).json({ token, user: patient.toJSON() });
});

// POST /api/auth/login  { phone, password }
const login = asyncHandler(async (req, res) => {
  const { token, patient } = await authService.login(req.body);
  res.json({ token, user: patient.toJSON() });
});

// POST /api/auth/reset-password  { phone, otp, newPassword }
const resetPassword = asyncHandler(async (req, res) => {
  await authService.resetPassword(req.body);
  res.json({ reset: true });
});

// GET /api/auth/check-phone?phone=
const checkPhone = asyncHandler(async (req, res) => {
  const exists = await authService.phoneExists(req.validatedQuery.phone);
  res.json({ exists });
});

// GET /api/auth/me
const me = asyncHandler(async (req, res) => {
  res.json({ id: req.user.id, username: req.user.name, phone: req.user.phone });
});

module.exports = {
  requestOtp,
  verifyOtp,
  signup,
  login,
  resetPassword,
  checkPhone,
  me,
};
