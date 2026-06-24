'use strict';

const rateLimit = require('express-rate-limit');
const env = require('../config/env');

// Disable limiting under test so the suite isn't throttled / flaky.
const noop = (_req, _res, next) => next();

const authLimiter = env.isTest
  ? noop
  : rateLimit({
      windowMs: 15 * 60 * 1000,
      max: 30, // login / signup / reset attempts per IP per window
      standardHeaders: true,
      legacyHeaders: false,
      message: { error: 'Too many attempts, please try again later' },
    });

// OTP requests are extra-sensitive (each one would send an SMS in production), so
// they get a tighter budget than ordinary auth calls.
const otpLimiter = env.isTest
  ? noop
  : rateLimit({
      windowMs: 15 * 60 * 1000,
      max: 10,
      standardHeaders: true,
      legacyHeaders: false,
      message: { error: 'Too many code requests, please try again later' },
    });

const globalLimiter = env.isTest
  ? noop
  : rateLimit({
      windowMs: 60 * 1000,
      max: 300,
      standardHeaders: true,
      legacyHeaders: false,
    });

module.exports = { authLimiter, otpLimiter, globalLimiter };
