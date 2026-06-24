'use strict';

const { z } = require('zod');

// GET /reviews?doctorId=...
const listQuerySchema = z
  .object({
    doctorId: z.string().trim().min(1, 'doctorId is required'),
    page: z.coerce.number().int().min(1).optional(),
    limit: z.coerce.number().int().min(1).max(100).optional(),
  })
  .strip();

// POST /reviews — a signed-in patient rates a doctor. patientName/avatar come
// from the account; rating is 1..5 to match the app's star input.
const createSchema = z
  .object({
    doctorId: z.string().trim().min(1),
    rating: z.coerce.number().min(1).max(5),
    comment: z.string().trim().max(1000).optional().default(''),
    // Optional link to the visited appointment, so it can be marked reviewed.
    appointmentId: z.string().trim().min(1).optional(),
  })
  .strict();

module.exports = { listQuerySchema, createSchema };
