'use strict';

const doctorService = require('../services/doctorService');
const ApiError = require('../utils/apiError');
const asyncHandler = require('../utils/asyncHandler');
const { normalizeDayKey } = require('../utils/dayKey');

// GET /api/doctors
const list = asyncHandler(async (req, res) => {
  res.json(await doctorService.list(req.validatedQuery));
});

// GET /api/doctors/top  — home "Top Doctors" rail (top 6 by rating)
const top = asyncHandler(async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit, 10) || 6, 20);
  res.json({ data: await doctorService.topRated(limit) });
});

// GET /api/doctors/:id
const getById = asyncHandler(async (req, res) => {
  const doc = await doctorService.getById(req.params.id);
  if (!doc) throw ApiError.notFound('Doctor not found');
  res.json(doc);
});

// GET /api/doctors/:id/reviews — delegated to the reviews controller in routes.

// GET /api/doctors/:id/availability?date=YYYY-MM-DD
const availability = asyncHandler(async (req, res) => {
  const dayKey = req.query.date ? normalizeDayKey(req.query.date) : null;
  if (req.query.date && !dayKey) throw ApiError.badRequest('date must be YYYY-MM-DD');
  const result = await doctorService.availability(req.params.id, dayKey);
  if (!result) throw ApiError.notFound('Doctor not found');
  res.json(result);
});

module.exports = { list, top, getById, availability };
