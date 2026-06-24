'use strict';

const Review = require('../models/Review');
const Doctor = require('../models/Doctor');
const ApiError = require('../utils/apiError');
const { parsePaging, envelope } = require('../utils/pagination');

/**
 * Reviews for a doctor, newest first, plus the aggregate the app's UI shows.
 * The aggregate is the doctor's current headline rating/count (which is kept in
 * sync as reviews are added), matching ReviewProvider.aggregateRating/Count.
 */
async function listForDoctor(doctorId, query) {
  const paging = parsePaging(query);
  const [docs, total, doctor] = await Promise.all([
    Review.find({ doctorId }).sort({ date: -1 }).skip(paging.skip).limit(paging.limit),
    Review.countDocuments({ doctorId }),
    Doctor.findById(doctorId).lean(),
  ]);

  const aggregate = doctor
    ? { rating: round1(doctor.rating), count: doctor.reviewCount }
    : computeAggregate(docs);

  return { ...envelope(docs.map((d) => d.toJSON()), paging, total), aggregate };
}

/**
 * Create a review and fold it into the doctor's headline rating/count using the
 * same blended average the app computes:
 *   newRating = (oldRating*oldCount + thisRating) / (oldCount + 1)
 */
async function create(payload, patient) {
  const doctor = await Doctor.findById(payload.doctorId);
  if (!doctor) throw ApiError.badRequest('Unknown doctorId');

  const review = await Review.create({
    doctorId: payload.doctorId,
    patientId: patient.id,
    patientName: patient.name,
    patientAvatarUrl: patient.avatarUrl || '',
    rating: payload.rating,
    comment: payload.comment || '',
    date: new Date(),
  });

  const oldCount = doctor.reviewCount || 0;
  const oldRating = doctor.rating || 0;
  const newCount = oldCount + 1;
  doctor.rating = round1((oldRating * oldCount + payload.rating) / newCount);
  doctor.reviewCount = newCount;
  await doctor.save();

  return {
    review: review.toJSON(),
    aggregate: { rating: doctor.rating, count: doctor.reviewCount },
  };
}

function computeAggregate(reviews) {
  if (!reviews.length) return { rating: 0, count: 0 };
  const sum = reviews.reduce((s, r) => s + r.rating, 0);
  return { rating: round1(sum / reviews.length), count: reviews.length };
}

/** One decimal place, matching the app's star displays. */
function round1(n) {
  return Math.round(n * 10) / 10;
}

module.exports = { listForDoctor, create };
