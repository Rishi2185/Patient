'use strict';

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

/**
 * A patient account — the person who signs in to the app and books appointments.
 * Mirrors the Flutter `AppUser` ({username, phone}) plus the credentials needed
 * for real auth. The phone number is the login identifier (unique), matching the
 * app's phone-based sign-in.
 *
 * This is a DIFFERENT collection from the hospital backend's staff `users`
 * (admin/reception, who log in by username + role), so the two services can
 * share a database without their accounts colliding.
 */
const patientSchema = new mongoose.Schema(
  {
    // Display name shown in the app (the app calls this "username").
    username: { type: String, required: true, trim: true },

    // 10-digit mobile number — the login id. Stored digits-only.
    phone: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },

    passwordHash: { type: String, required: true },

    avatarUrl: { type: String, default: '' },
    active: { type: Boolean, default: true },
  },
  { timestamps: true }
);

patientSchema.methods.verifyPassword = function verifyPassword(plain) {
  return bcrypt.compare(plain, this.passwordHash);
};

/** Hash a plaintext password with the configured cost. */
patientSchema.statics.hashPassword = function hashPassword(plain, rounds) {
  return bcrypt.hash(plain, rounds);
};

// Public shape sent to clients: `id`, `username`, `phone` (the app's AppUser is
// {username, phone}). Never leak the hash.
patientSchema.set('toJSON', {
  transform(_doc, ret) {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    delete ret.passwordHash;
    return ret;
  },
});

module.exports = mongoose.model('Patient', patientSchema);
