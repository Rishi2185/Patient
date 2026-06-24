'use strict';

const { z } = require('zod');
const { OTP_PURPOSE } = require('../constants');

// Mirrors the patient app's Validators (frontend/lib/utils/validators.dart):
//   phone -> exactly 10 digits, username -> >= 3 chars, password -> >= 8 chars.
const phone = z
  .string()
  .trim()
  .regex(/^\d{10}$/, 'Enter a valid 10-digit mobile number');

const username = z.string().trim().min(3, 'Username must be at least 3 characters');
const password = z.string().min(8, 'Use at least 8 characters');
const otp = z.string().trim().min(1, 'Code is required');
const purpose = z.enum([OTP_PURPOSE.SIGNUP, OTP_PURPOSE.RESET]);

// POST /auth/signup — create an account (an OTP must have been requested first).
const signupSchema = z
  .object({ username, phone, password, otp })
  .strict();

// POST /auth/login
const loginSchema = z
  .object({
    phone,
    password: z.string().min(1, 'password is required'),
  })
  .strict();

// POST /auth/otp/request
const requestOtpSchema = z.object({ phone, purpose }).strict();

// POST /auth/otp/verify — optional standalone check (mirrors app verifyOtp).
const verifyOtpSchema = z.object({ phone, purpose, code: otp }).strict();

// POST /auth/reset-password
const resetPasswordSchema = z
  .object({ phone, otp, newPassword: password })
  .strict();

// GET /auth/check-phone?phone=
const checkPhoneQuerySchema = z.object({ phone }).strip();

module.exports = {
  signupSchema,
  loginSchema,
  requestOtpSchema,
  verifyOtpSchema,
  resetPasswordSchema,
  checkPhoneQuerySchema,
};
