'use strict';

const request = require('supertest');
const createApp = require('../src/app');
const { patientToken, bearer, makeDoctor, daysFromNow } = require('./helpers');

const app = createApp();

describe('appointments (patient-owned)', () => {
  beforeEach(async () => {
    await makeDoctor({ _id: 'd1', consultationFee: 500, photoUrl: 'http://x/p.jpg' });
  });

  test('requires authentication', async () => {
    const res = await request(app).get('/api/appointments');
    expect(res.status).toBe(401);
  });

  test('book creates an appointment owned by the caller', async () => {
    const { token } = await patientToken();
    const res = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', dateTime: daysFromNow(1).toISOString(), slotLabel: '10:00 AM', fee: 549, paymentMethod: 1 });

    expect(res.status).toBe(201);
    expect(res.body.doctorName).toBe('Dr. Test');
    expect(res.body.status).toBe(0);
    expect(res.body.fee).toBe(549);
  });

  test('booking defaults fee to the doctor consultation fee', async () => {
    const { token } = await patientToken();
    const res = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', dateTime: daysFromNow(2).toISOString(), slotLabel: '11:00 AM' });
    expect(res.body.fee).toBe(500);
  });

  test("list returns only the caller's own appointments", async () => {
    const a = await patientToken();
    const b = await patientToken();
    await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(a.token))
      .send({ doctorId: 'd1', dateTime: daysFromNow(1).toISOString(), slotLabel: '10:00 AM' });

    const listA = await request(app).get('/api/appointments').set('Authorization', bearer(a.token));
    expect(listA.body.total).toBe(1);

    const listB = await request(app).get('/api/appointments').set('Authorization', bearer(b.token));
    expect(listB.body.total).toBe(0);
  });

  test("a patient cannot read another patient's appointment", async () => {
    const a = await patientToken();
    const b = await patientToken();
    const booked = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(a.token))
      .send({ doctorId: 'd1', dateTime: daysFromNow(1).toISOString(), slotLabel: '10:00 AM' });

    const res = await request(app)
      .get(`/api/appointments/${booked.body.id}`)
      .set('Authorization', bearer(b.token));
    expect(res.status).toBe(404);
  });

  test('PATCH can cancel an owned appointment', async () => {
    const { token } = await patientToken();
    const booked = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', dateTime: daysFromNow(1).toISOString(), slotLabel: '10:00 AM' });

    const res = await request(app)
      .patch(`/api/appointments/${booked.body.id}`)
      .set('Authorization', bearer(token))
      .send({ status: 2 });
    expect(res.status).toBe(200);
    expect(res.body.status).toBe(2);
  });

  test('double-booking the same slot is rejected with 409', async () => {
    const a = await patientToken();
    const b = await patientToken();
    const when = daysFromNow(1).toISOString();
    const first = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(a.token))
      .send({ doctorId: 'd1', dateTime: when, slotLabel: '10:00 AM' });
    expect(first.status).toBe(201);

    const second = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(b.token))
      .send({ doctorId: 'd1', dateTime: when, slotLabel: '10:00 AM' });
    expect(second.status).toBe(409);
  });

  test('cancelling frees the slot for re-booking', async () => {
    const { token } = await patientToken();
    const when = daysFromNow(1).toISOString();
    const first = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', dateTime: when, slotLabel: '10:00 AM' });
    await request(app)
      .patch(`/api/appointments/${first.body.id}`)
      .set('Authorization', bearer(token))
      .send({ status: 2 });

    const rebook = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', dateTime: when, slotLabel: '10:00 AM' });
    expect(rebook.status).toBe(201);
  });

  test('a past-dated booking is rejected', async () => {
    const { token } = await patientToken();
    const res = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', dateTime: daysFromNow(-2).toISOString(), slotLabel: '10:00 AM' });
    expect(res.status).toBe(400);
  });

  test('booking an unknown doctor is rejected', async () => {
    const { token } = await patientToken();
    const res = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'ghost', dateTime: daysFromNow(1).toISOString(), slotLabel: '10:00 AM' });
    expect(res.status).toBe(400);
  });

  test('status filter narrows the list', async () => {
    const { token } = await patientToken();
    const u = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', dateTime: daysFromNow(1).toISOString(), slotLabel: '10:00 AM' });
    await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', dateTime: daysFromNow(2).toISOString(), slotLabel: '11:00 AM' });
    await request(app)
      .patch(`/api/appointments/${u.body.id}`)
      .set('Authorization', bearer(token))
      .send({ status: 2 });

    const cancelled = await request(app)
      .get('/api/appointments?status=2')
      .set('Authorization', bearer(token));
    expect(cancelled.body.total).toBe(1);
    const upcoming = await request(app)
      .get('/api/appointments?status=0')
      .set('Authorization', bearer(token));
    expect(upcoming.body.total).toBe(1);
  });
});
