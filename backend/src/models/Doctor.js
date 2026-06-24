'use strict';

const crypto = require('crypto');
const mongoose = require('mongoose');

/**
 * Doctor profile — the roster shown to patients. Identical in shape to the
 * hospital backend's `Doctor` so the two services share the same `doctors`
 * collection cleanly. Ported field-for-field from the patient app's `Doctor`
 * model with two structural changes:
 *   - `specialty` (a UI object) becomes `specialtyId` + `specialtyName` strings;
 *     the icon/color are resolved client-side via `Specialties.byId(id)`.
 *   - `hospitalName` is denormalized so booking is a single read (no $lookup).
 *
 * `_id` keeps the patient app's stable string ids ("d1".."d12").
 */
const doctorSchema = new mongoose.Schema(
  {
    _id: { type: String, default: () => `doc_${crypto.randomUUID()}` },
    name: { type: String, required: true },

    specialtyId: { type: String, required: true, index: true },
    specialtyName: { type: String, required: true },

    qualifications: { type: String, default: '' },
    experienceYears: { type: Number, default: 0 },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    reviewCount: { type: Number, default: 0 },
    consultationFee: { type: Number, default: 0 }, // INR
    about: { type: String, default: '' },
    photoUrl: { type: String, default: '' },

    hospitalId: { type: String },
    hospitalName: { type: String, default: '' }, // denormalized

    languages: { type: [String], default: [] },
    patientsServed: { type: Number, default: 0 },

    // Opaque display strings ("09:00"). Not parsed into real time windows.
    consultStart: { type: String, default: '09:00' },
    consultEnd: { type: String, default: '17:00' },
    availableDays: { type: [String], default: [] }, // ["Mon","Tue",...]

    // "Doctor is in today" toggle the patient app filters on directly.
    availableToday: { type: Boolean, default: false },

    // Soft-delete: a removed doctor stays in the collection (active=false) so
    // historical appointments keep resolving the name.
    active: { type: Boolean, default: true, index: true },
  },
  { _id: false, timestamps: true }
);

module.exports = mongoose.model('Doctor', doctorSchema);
