'use strict';

const { z } = require('zod');
const { APPOINTMENT_STATUS, PAYMENT_METHOD } = require('../constants');

const statusInt = z.coerce
  .number()
  .int()
  .refine((v) => Object.values(APPOINTMENT_STATUS).includes(v), {
    message: 'status must be 0 (upcoming), 1 (completed) or 2 (cancelled)',
  });

const paymentInt = z.coerce
  .number()
  .int()
  .refine((v) => Object.values(PAYMENT_METHOD).includes(v), {
    message: 'paymentMethod must be 0 (card), 1 (upi) or 2 (wallet)',
  });

// POST /appointments — a signed-in patient books a slot. Denormalized doctor
// fields (name/photo/specialty/hospital) and the patient's identity are derived
// server-side from the doctor record and the JWT, so they're NOT taken from the
// body. `.strip()` tolerates extra keys from the app's Appointment.toJson()
// (doctorName, status, reviewed, ...) if the full object is ever posted.
const bookingSchema = z
  .object({
    id: z.string().trim().min(1).optional(), // accept a client-supplied id
    doctorId: z.string().trim().min(1),
    dateTime: z.coerce.date(),
    slotLabel: z.string().trim().min(1),
    fee: z.number().int().min(0).optional(),
    paymentMethod: paymentInt.optional(),
    patientName: z.string().trim().optional(),
    patientAge: z.number().int().min(0).max(130).optional(),
    patientBloodGroup: z.string().trim().optional(),
    patientType: z.enum(['ipd', 'opd']).optional(),
    paymentStatus: z.string().trim().optional(),
  })
  .strip();

// PATCH /appointments/:id — the owner cancels, marks visited, or marks reviewed.
const patchSchema = z
  .object({
    status: statusInt.optional(),
    reviewed: z.boolean().optional(),
  })
  .strict()
  .refine((o) => Object.keys(o).length > 0, {
    message: 'At least one of status, reviewed must be provided',
  });

// GET /appointments — the patient's own list, optionally filtered by status.
const listQuerySchema = z
  .object({
    status: statusInt.optional(),
    page: z.coerce.number().int().min(1).optional(),
    limit: z.coerce.number().int().min(1).max(100).optional(),
  })
  .strip();

module.exports = { bookingSchema, patchSchema, listQuerySchema };
