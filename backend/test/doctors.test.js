'use strict';

const request = require('supertest');
const createApp = require('../src/app');
const { makeDoctor, daysFromNow, dayKey } = require('./helpers');
const Appointment = require('../src/models/Appointment');

const app = createApp();

describe('doctors (public discovery)', () => {
  beforeEach(async () => {
    await makeDoctor({ _id: 'd1', name: 'Dr. Ananya Sharma', specialtyId: 'cardiology', specialtyName: 'Cardiology', rating: 4.9, consultationFee: 800, experienceYears: 14, availableToday: true });
    await makeDoctor({ _id: 'd2', name: 'Dr. Rohan Mehta', specialtyId: 'dermatology', specialtyName: 'Dermatology', rating: 4.7, consultationFee: 600, experienceYears: 9, availableToday: false });
    await makeDoctor({ _id: 'd3', name: 'Dr. Gone', specialtyId: 'general', specialtyName: 'General', rating: 4.0, active: false });
  });

  test('list returns only active doctors with the standard envelope', async () => {
    const res = await request(app).get('/api/doctors');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('data');
    expect(res.body).toHaveProperty('total', 2); // d3 is inactive
    expect(res.body.data.every((d) => d.id !== 'd3')).toBe(true);
    expect(res.body.data[0]).toHaveProperty('id');
    expect(res.body.data[0]).not.toHaveProperty('_id');
  });

  test('filter by specialty', async () => {
    const res = await request(app).get('/api/doctors?specialtyId=dermatology');
    expect(res.body.total).toBe(1);
    expect(res.body.data[0].id).toBe('d2');
  });

  test('availableToday filter', async () => {
    const res = await request(app).get('/api/doctors?availableToday=true');
    expect(res.body.data.every((d) => d.availableToday)).toBe(true);
  });

  test('text search across name / specialty', async () => {
    const res = await request(app).get('/api/doctors?q=ananya');
    expect(res.body.total).toBe(1);
    expect(res.body.data[0].id).toBe('d1');
  });

  test('sort by feeLow / feeHigh', async () => {
    const low = await request(app).get('/api/doctors?sort=feeLow');
    expect(low.body.data[0].consultationFee).toBeLessThanOrEqual(low.body.data[1].consultationFee);
    const high = await request(app).get('/api/doctors?sort=feeHigh');
    expect(high.body.data[0].consultationFee).toBeGreaterThanOrEqual(high.body.data[1].consultationFee);
  });

  test('top returns highest-rated first', async () => {
    const res = await request(app).get('/api/doctors/top?limit=2');
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(2);
    expect(res.body.data[0].id).toBe('d1'); // 4.9
  });

  test('getById returns the doctor; unknown -> 404', async () => {
    const ok = await request(app).get('/api/doctors/d1');
    expect(ok.status).toBe(200);
    expect(ok.body.id).toBe('d1');
    const missing = await request(app).get('/api/doctors/nope');
    expect(missing.status).toBe(404);
  });

  test('availability returns booked slots + generated bands for a day', async () => {
    const when = daysFromNow(1);
    await Appointment.create({
      _id: 'apt_booked',
      doctorId: 'd1',
      doctorName: 'Dr. Ananya Sharma',
      dateTime: when,
      slotLabel: '09:30 AM',
      dayKey: dayKey(when),
      status: 0,
    });
    const res = await request(app).get(`/api/doctors/d1/availability?date=${dayKey(when)}`);
    expect(res.status).toBe(200);
    expect(res.body.bookedSlots).toContain('09:30 AM');
    expect(res.body.slots).toHaveProperty('morning');
    // The booked slot must not appear among the offered slots.
    const offered = [
      ...res.body.slots.morning,
      ...res.body.slots.afternoon,
      ...res.body.slots.evening,
    ];
    expect(offered).not.toContain('09:30 AM');
  });

  test('availability rejects a malformed date', async () => {
    const res = await request(app).get('/api/doctors/d1/availability?date=2026-13-99');
    expect(res.status).toBe(400);
  });
});
