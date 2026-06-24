'use strict';

const Specialty = require('../models/Specialty');
const asyncHandler = require('../utils/asyncHandler');

// GET /api/specialties — canonical list (id + name). Clients map id -> icon/color
// via the app's Specialties.byId(id).
const specialties = asyncHandler(async (_req, res) => {
  const docs = await Specialty.find().sort({ name: 1 }).lean();
  res.json({ data: docs.map((d) => ({ id: d._id, name: d.name })) });
});

module.exports = { specialties };
