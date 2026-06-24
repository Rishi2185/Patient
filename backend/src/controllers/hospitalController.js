'use strict';

const hospitalService = require('../services/hospitalService');
const doctorService = require('../services/doctorService');
const ApiError = require('../utils/apiError');
const asyncHandler = require('../utils/asyncHandler');

// GET /api/hospitals
const list = asyncHandler(async (_req, res) => {
  res.json({ data: await hospitalService.list() });
});

// GET /api/hospitals/:id
const getById = asyncHandler(async (req, res) => {
  const doc = await hospitalService.getById(req.params.id);
  if (!doc) throw ApiError.notFound('Hospital not found');
  res.json(doc);
});

// GET /api/hospitals/:id/doctors — affiliated doctors (doctorsByHospital)
const doctors = asyncHandler(async (req, res) => {
  const hospital = await hospitalService.getById(req.params.id);
  if (!hospital) throw ApiError.notFound('Hospital not found');
  res.json({ data: await doctorService.listByHospital(req.params.id) });
});

module.exports = { list, getById, doctors };
