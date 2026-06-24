'use strict';

const Patient = require('../src/models/Patient');
const Doctor = require('../src/models/Doctor');
const Hospital = require('../src/models/Hospital');
const env = require('../src/config/env');
const { signToken } = require('../src/middleware/auth');
const { dayKey } = require('../src/utils/dayKey');

let counter = 0;

/** Create a patient and return a signed JWT for it. */
async function patientToken(overrides = {}) {
  counter += 1;
  const patient = await Patient.create({
    username: overrides.username || `Patient ${counter}`,
    phone: overrides.phone || `90000000${String(counter).padStart(2, '0')}`,
    passwordHash: await Patient.hashPassword(overrides.password || 'pw123456', env.bcryptRounds),
    ...('avatarUrl' in overrides ? { avatarUrl: overrides.avatarUrl } : {}),
  });
  return { token: signToken(patient), patient };
}

const bearer = (token) => `Bearer ${token}`;

/** Seed a doctor (defaults are valid for booking). */
async function makeDoctor(overrides = {}) {
  return Doctor.create({
    _id: overrides._id || 'd1',
    name: 'Dr. Test',
    specialtyId: 'cardiology',
    specialtyName: 'Cardiology',
    qualifications: 'MBBS',
    experienceYears: 5,
    rating: 4.5,
    reviewCount: 10,
    consultationFee: 500,
    photoUrl: 'http://x/p.jpg',
    hospitalId: 'h1',
    hospitalName: 'Test Hospital',
    availableToday: true,
    availableDays: ['Mon', 'Tue'],
    active: true,
    ...overrides,
  });
}

/** Seed a hospital. */
async function makeHospital(overrides = {}) {
  return Hospital.create({
    _id: overrides._id || 'h1',
    name: 'Test Hospital',
    city: 'Mumbai',
    rating: 4.6,
    ...overrides,
  });
}

/** A Date a given number of days from now (UTC ~11:30 IST — safe day bucketing). */
function daysFromNow(n) {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() + n);
  d.setUTCHours(6, 0, 0, 0);
  return d;
}

module.exports = { patientToken, bearer, makeDoctor, makeHospital, daysFromNow, dayKey };
