'use strict';

const { z } = require('zod');

const SORTS = ['relevance', 'ratingHigh', 'feeLow', 'feeHigh', 'experience'];

// GET /doctors — mirrors the patient app's DoctorProvider params exactly.
const listQuerySchema = z
  .object({
    q: z.string().trim().optional(),
    specialtyId: z.string().trim().optional(),
    availableToday: z
      .enum(['true', 'false'])
      .optional()
      .transform((v) => (v === undefined ? undefined : v === 'true')),
    minRating: z.coerce.number().min(0).max(5).optional(),
    sort: z.enum(SORTS).optional().default('relevance'),
    page: z.coerce.number().int().min(1).optional(),
    limit: z.coerce.number().int().min(1).max(100).optional(),
  })
  .strip();

// GET /doctors/:id/availability?date=YYYY-MM-DD
const availabilityQuerySchema = z
  .object({
    date: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/, 'expected YYYY-MM-DD')
      .optional(),
  })
  .strip();

module.exports = { listQuerySchema, availabilityQuerySchema, SORTS };
