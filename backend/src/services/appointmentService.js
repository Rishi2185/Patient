'use strict';

const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');
const ApiError = require('../utils/apiError');
const { APPOINTMENT_STATUS, APPOINTMENT_SOURCE } = require('../constants');
const { dayKey, todayKey } = require('../utils/dayKey');
const { parsePaging, envelope } = require('../utils/pagination');

/**
 * The signed-in patient's own appointments, newest first (mirrors the app's
 * AppointmentProvider.all ordering). Optionally filtered by status.
 */
async function listForPatient(patientId, query) {
  const filter = { patientId };
  if (typeof query.status === 'number') filter.status = query.status;

  const paging = parsePaging(query);
  const [docs, total] = await Promise.all([
    Appointment.find(filter)
      .sort({ dateTime: -1 })
      .skip(paging.skip)
      .limit(paging.limit),
    Appointment.countDocuments(filter),
  ]);

  return envelope(docs.map((d) => d.toJSON()), paging, total);
}

/** A single appointment the patient owns (null if missing or not theirs). */
async function getOwned(id, patientId) {
  const doc = await Appointment.findById(id);
  if (!doc || doc.patientId !== patientId) return null;
  return doc;
}

/**
 * Book an appointment for a patient. Denormalized doctor fields come from the
 * source-of-truth Doctor record; identity comes from the account. Rejects
 * past-dated bookings (the store holds today + future only). The partial-unique
 * slot index is the real double-booking guard; we pre-check for a nicer error.
 */
async function create(payload, patient) {
  const doctor = await Doctor.findById(payload.doctorId).lean();
  if (!doctor) throw ApiError.badRequest('Unknown doctorId');
  if (doctor.active === false) throw ApiError.badRequest('Doctor is not active');

  const when = payload.dateTime;
  const key = dayKey(when);
  if (key < todayKey()) {
    throw ApiError.badRequest('Cannot book an appointment in a past day');
  }

  const doc = {
    doctorId: doctor._id,
    doctorName: doctor.name,
    doctorPhotoUrl: doctor.photoUrl,
    specialtyName: doctor.specialtyName,
    hospitalName: doctor.hospitalName,
    dateTime: when,
    slotLabel: payload.slotLabel,
    fee: payload.fee != null ? payload.fee : doctor.consultationFee,
    paymentMethod: payload.paymentMethod != null ? payload.paymentMethod : 1,
    status: APPOINTMENT_STATUS.UPCOMING,
    reviewed: false,
    patientId: patient.id,
    patientName: payload.patientName || patient.name,
    patientPhone: patient.phone,
    patientAge: payload.patientAge,
    patientBloodGroup: payload.patientBloodGroup,
    patientType: payload.patientType,
    paymentStatus: payload.paymentStatus || 'completed',
    source: APPOINTMENT_SOURCE.PATIENT_APP,
    dayKey: key,
  };
  if (payload.id) doc._id = payload.id;

  // Friendly pre-check (advisory). The unique index handles the race.
  const clash = await Appointment.findOne({
    doctorId: doc.doctorId,
    dayKey: key,
    slotLabel: doc.slotLabel,
    status: APPOINTMENT_STATUS.UPCOMING,
  }).lean();
  if (clash) {
    throw ApiError.conflict('That slot is already booked for this doctor', {
      doctorId: doc.doctorId,
      dayKey: key,
      slotLabel: doc.slotLabel,
    });
  }

  const created = await Appointment.create(doc);
  return created.toJSON();
}

/**
 * Patch an appointment the patient owns: cancel (status 2), mark visited
 * (status 1) or mark reviewed. Returns null if not found / not theirs.
 */
async function patchOwned(id, patientId, changes) {
  const doc = await getOwned(id, patientId);
  if (!doc) return null;
  if (changes.status !== undefined) doc.status = changes.status;
  if (changes.reviewed !== undefined) doc.reviewed = changes.reviewed;
  await doc.save();
  return doc.toJSON();
}

module.exports = { listForPatient, getOwned, create, patchOwned };
