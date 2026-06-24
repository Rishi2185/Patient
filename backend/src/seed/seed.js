'use strict';

const env = require('../config/env');
const { connect, disconnect } = require('../config/db');
const { dayKey, todayKey } = require('../utils/dayKey');

const Patient = require('../models/Patient');
const Specialty = require('../models/Specialty');
const Hospital = require('../models/Hospital');
const Doctor = require('../models/Doctor');
const Appointment = require('../models/Appointment');
const Review = require('../models/Review');

const { specialties, hospitals, doctors, reviews } = require('./data');
const { APPOINTMENT_STATUS, PAYMENT_METHOD, APPOINTMENT_SOURCE } = require('../constants');

// Build a Date for a given day offset at a UTC hour chosen to land in daytime
// for the default clinic TZ (Asia/Kolkata, UTC+5:30). dayKey is derived from the
// resulting instant so the stored day is always internally consistent.
function at(dayOffset, utcHour, utcMin = 0) {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() + dayOffset);
  d.setUTCHours(utcHour, utcMin, 0, 0);
  return d;
}

/**
 * Seed the database. Assumes a live Mongoose connection (caller owns it).
 * Clears the patient-owned collections first so it is safe to re-run.
 */
async function seedDatabase({ log = () => {} } = {}) {
  log('clearing collections...');
  await Promise.all([
    Patient.deleteMany({}),
    Specialty.deleteMany({}),
    Hospital.deleteMany({}),
    Doctor.deleteMany({}),
    Appointment.deleteMany({}),
    Review.deleteMany({}),
  ]);

  log('inserting specialties, hospitals, doctors, reviews...');
  await Specialty.insertMany(specialties);
  await Hospital.insertMany(hospitals);
  await Doctor.insertMany(doctors);
  await Review.insertMany(reviews);

  log('creating demo patient account...');
  const demo = await Patient.create({
    username: env.seed.demoName,
    phone: env.seed.demoPhone,
    passwordHash: await Patient.hashPassword(env.seed.demoPass, env.bcryptRounds),
  });

  log('inserting sample appointments for the demo patient (today + future)...');
  const byId = Object.fromEntries(doctors.map((d) => [d._id, d]));
  const appt = (doctorId, dateTime, slotLabel, status) => {
    const d = byId[doctorId];
    return {
      doctorId,
      doctorName: d.name,
      doctorPhotoUrl: d.photoUrl,
      specialtyName: d.specialtyName,
      hospitalName: d.hospitalName,
      dateTime,
      slotLabel,
      fee: d.consultationFee + 49, // consultation + platform fee (app's _total)
      paymentMethod: PAYMENT_METHOD.UPI,
      status,
      reviewed: false,
      patientId: String(demo._id),
      patientName: demo.username,
      patientPhone: demo.phone,
      source: APPOINTMENT_SOURCE.PATIENT_APP,
      dayKey: dayKey(dateTime),
    };
  };
  const sample = [
    appt('d1', at(0, 4, 0), '09:30 AM', APPOINTMENT_STATUS.COMPLETED),
    appt('d8', at(2, 7, 0), '12:30 PM', APPOINTMENT_STATUS.UPCOMING),
    appt('d11', at(4, 5, 30), '11:00 AM', APPOINTMENT_STATUS.UPCOMING),
  ];
  await Appointment.insertMany(sample);

  return {
    specialties: specialties.length,
    hospitals: hospitals.length,
    doctors: doctors.length,
    reviews: reviews.length,
    appointments: sample.length,
    demoPhone: demo.phone,
    today: todayKey(),
  };
}

// CLI entrypoint: `npm run seed`. Owns its own connection.
async function runCli() {
  await connect();
  const result = await seedDatabase({ log: (m) => console.log(`[seed] ${m}`) });
  console.log('\n[seed] done.');
  console.log(`  specialties:  ${result.specialties}`);
  console.log(`  hospitals:    ${result.hospitals}`);
  console.log(`  doctors:      ${result.doctors}`);
  console.log(`  reviews:      ${result.reviews}`);
  console.log(`  appointments: ${result.appointments}  (today=${result.today})`);
  console.log('\n  Demo login:');
  console.log(`    phone:    ${env.seed.demoPhone}`);
  console.log(`    password: ${env.seed.demoPass}`);
  console.log(`    OTP code: ${env.otp.demoCode}  (sign-up & password reset, non-prod)`);
  if (!env.mongoUri) {
    console.log(
      '\n  NOTE: No MONGODB_URI set, so this seeded an EPHEMERAL in-memory DB ' +
        'that is gone now. Set MONGODB_URI (local mongod or Atlas) to persist, ' +
        'or just run `npm run dev` — it auto-seeds an empty in-memory DB on boot.'
    );
  }
  await disconnect();
}

if (require.main === module) {
  runCli()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error('[seed] failed:', err);
      process.exit(1);
    });
}

module.exports = { seedDatabase };
