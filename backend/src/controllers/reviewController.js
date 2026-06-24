'use strict';

const reviewService = require('../services/reviewService');
const appointmentService = require('../services/appointmentService');
const asyncHandler = require('../utils/asyncHandler');

// GET /api/reviews?doctorId=...  (flat form, validated query)
const list = asyncHandler(async (req, res) => {
  const { doctorId, ...paging } = req.validatedQuery;
  res.json(await reviewService.listForDoctor(doctorId, paging));
});

// GET /api/doctors/:id/reviews  (nested form)
const listForDoctorParam = asyncHandler(async (req, res) => {
  res.json(await reviewService.listForDoctor(req.params.id, req.query));
});

// POST /api/reviews  { doctorId, rating, comment, appointmentId? }
const create = asyncHandler(async (req, res) => {
  const { appointmentId, ...payload } = req.body;
  // Patient reviews carry no avatar (parity with the app's ReviewProvider.addReview,
  // which omits it); reviewService defaults patientAvatarUrl to ''.
  const result = await reviewService.create(payload, {
    id: req.user.id,
    name: req.user.name,
  });

  // If the review came from a completed visit, mark that appointment reviewed
  // (best-effort; ignored if the id isn't the caller's appointment).
  if (appointmentId) {
    await appointmentService.patchOwned(appointmentId, req.user.id, { reviewed: true });
  }

  res.status(201).json(result);
});

module.exports = { list, listForDoctorParam, create };
