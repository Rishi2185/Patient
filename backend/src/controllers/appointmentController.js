'use strict';

const appointmentService = require('../services/appointmentService');
const ApiError = require('../utils/apiError');
const asyncHandler = require('../utils/asyncHandler');

// GET /api/appointments — the signed-in patient's own appointments.
const list = asyncHandler(async (req, res) => {
  res.json(await appointmentService.listForPatient(req.user.id, req.validatedQuery));
});

// GET /api/appointments/:id
const getById = asyncHandler(async (req, res) => {
  const doc = await appointmentService.getOwned(req.params.id, req.user.id);
  if (!doc) throw ApiError.notFound('Appointment not found');
  res.json(doc.toJSON());
});

// POST /api/appointments — book a slot.
const create = asyncHandler(async (req, res) => {
  const appt = await appointmentService.create(req.body, {
    id: req.user.id,
    name: req.user.name,
    phone: req.user.phone,
  });
  res.status(201).json(appt);
});

// PATCH /api/appointments/:id — cancel / mark visited / mark reviewed.
const patch = asyncHandler(async (req, res) => {
  const doc = await appointmentService.patchOwned(req.params.id, req.user.id, req.body);
  if (!doc) throw ApiError.notFound('Appointment not found');
  res.json(doc);
});

module.exports = { list, getById, create, patch };
