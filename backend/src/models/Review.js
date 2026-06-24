'use strict';

const crypto = require('crypto');
const mongoose = require('mongoose');

/**
 * A patient review on a doctor profile. Mirrors the patient app's `Review` model
 * (frontend/lib/models/review.dart): doctorId, patientName, rating, comment,
 * date, optional patientAvatarUrl.
 *
 * The doctor's headline `rating`/`reviewCount` are kept in sync on write (see
 * reviewService) using the same blended-average the app's `ReviewProvider`
 * computes, so the roster reflects new reviews without a $lookup on reads.
 */
const reviewSchema = new mongoose.Schema(
  {
    // Seeded reviews keep their app ids ("r1".."r10"); new ones get a uuid.
    _id: { type: String, default: () => `rev_${crypto.randomUUID()}` },

    doctorId: { type: String, required: true, index: true },

    patientId: { type: String, index: true }, // null for seeded reviews
    patientName: { type: String, required: true },
    patientAvatarUrl: { type: String, default: '' },

    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String, default: '' },

    // When the review was written (clinic-agnostic instant).
    date: { type: Date, default: () => new Date() },
  },
  { _id: false, timestamps: true }
);

// Doctor review lists are sorted newest-first.
reviewSchema.index({ doctorId: 1, date: -1 });

reviewSchema.set('toJSON', {
  transform(_doc, ret) {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Review', reviewSchema);
