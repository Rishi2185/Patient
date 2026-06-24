'use strict';

const express = require('express');
const validate = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');
const { authLimiter, otpLimiter } = require('../middleware/rateLimiters');
const {
  signupSchema,
  loginSchema,
  requestOtpSchema,
  verifyOtpSchema,
  resetPasswordSchema,
  checkPhoneQuerySchema,
} = require('../validators/authValidators');
const ctrl = require('../controllers/authController');

const router = express.Router();

// OTP (phone verification) — tighter rate limit.
router.post('/otp/request', otpLimiter, validate(requestOtpSchema), ctrl.requestOtp);
router.post('/otp/verify', otpLimiter, validate(verifyOtpSchema), ctrl.verifyOtp);

// Account lifecycle.
router.post('/signup', authLimiter, validate(signupSchema), ctrl.signup);
router.post('/login', authLimiter, validate(loginSchema), ctrl.login);
router.post('/reset-password', authLimiter, validate(resetPasswordSchema), ctrl.resetPassword);

// Helpers.
router.get('/check-phone', validate(checkPhoneQuerySchema, 'query'), ctrl.checkPhone);
router.get('/me', requireAuth, ctrl.me);

module.exports = router;
