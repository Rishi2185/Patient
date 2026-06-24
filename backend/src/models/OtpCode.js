'use strict';

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const { OTP_PURPOSE } = require('../constants');

/**
 * A one-time code requested for a phone number, scoped to a purpose (sign-up or
 * password reset). The code is stored HASHED (never plaintext). A TTL index on
 * `expiresAt` lets MongoDB evict stale codes automatically.
 *
 * At most one active code per (phone, purpose): requesting a new code upserts and
 * resets the attempt counter, so an old code is invalidated by the new one.
 */
const otpSchema = new mongoose.Schema(
  {
    phone: { type: String, required: true, trim: true },
    purpose: {
      type: String,
      enum: Object.values(OTP_PURPOSE),
      required: true,
    },
    codeHash: { type: String, required: true },
    attempts: { type: Number, default: 0 }, // verify attempts, capped
    expiresAt: { type: Date, required: true },
  },
  { timestamps: true }
);

// One active code per phone+purpose.
otpSchema.index({ phone: 1, purpose: 1 }, { unique: true });
// TTL: remove the document once expiresAt passes.
otpSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

otpSchema.methods.verifyCode = function verifyCode(plain) {
  return bcrypt.compare(String(plain), this.codeHash);
};

otpSchema.statics.hashCode = function hashCode(plain) {
  // OTPs are short-lived and low-entropy; a low cost is fine and keeps requests
  // snappy. (Auth passwords use the configured BCRYPT_ROUNDS.)
  return bcrypt.hash(String(plain), 8);
};

module.exports = mongoose.model('OtpCode', otpSchema);
