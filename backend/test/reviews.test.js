'use strict';

const request = require('supertest');
const createApp = require('../src/app');
const Review = require('../src/models/Review');
const { patientToken, bearer, makeDoctor, daysFromNow } = require('./helpers');

const app = createApp();

describe('reviews', () => {
  beforeEach(async () => {
    await makeDoctor({ _id: 'd1', rating: 4.0, reviewCount: 1 });
    await Review.create({
      _id: 'r1',
      doctorId: 'd1',
      patientName: 'Seed User',
      rating: 4,
      comment: 'Seeded review',
      date: new Date('2026-01-01'),
    });
  });

  test('list returns a doctor reviews + aggregate', async () => {
    const res = await request(app).get('/api/reviews?doctorId=d1');
    expect(res.status).toBe(200);
    expect(res.body.total).toBe(1);
    expect(res.body.aggregate).toEqual({ rating: 4, count: 1 });
    expect(res.body.data[0]).toHaveProperty('id', 'r1');
  });

  test('nested doctor reviews route works too', async () => {
    const res = await request(app).get('/api/doctors/d1/reviews');
    expect(res.status).toBe(200);
    expect(res.body.data[0].id).toBe('r1');
  });

  test('posting a review requires auth', async () => {
    const res = await request(app)
      .post('/api/reviews')
      .send({ doctorId: 'd1', rating: 5, comment: 'Great' });
    expect(res.status).toBe(401);
  });

  test('a signed-in patient can post a review; doctor aggregate updates', async () => {
    const { token } = await patientToken();
    const res = await request(app)
      .post('/api/reviews')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', rating: 5, comment: 'Excellent care' });

    expect(res.status).toBe(201);
    expect(res.body.review.rating).toBe(5);
    // Blended: (4.0*1 + 5) / 2 = 4.5, count 2.
    expect(res.body.aggregate).toEqual({ rating: 4.5, count: 2 });

    const list = await request(app).get('/api/reviews?doctorId=d1');
    expect(list.body.total).toBe(2);
    expect(list.body.aggregate.count).toBe(2);
  });

  test('posting a review with an appointmentId marks that appointment reviewed', async () => {
    const { token } = await patientToken();
    const booked = await request(app)
      .post('/api/appointments')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', dateTime: daysFromNow(1).toISOString(), slotLabel: '10:00 AM' });
    expect(booked.body.reviewed).toBe(false);

    await request(app)
      .post('/api/reviews')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', rating: 5, comment: 'Thanks', appointmentId: booked.body.id });

    const appt = await request(app)
      .get(`/api/appointments/${booked.body.id}`)
      .set('Authorization', bearer(token));
    expect(appt.body.reviewed).toBe(true);
  });

  test('rating out of range is rejected', async () => {
    const { token } = await patientToken();
    const res = await request(app)
      .post('/api/reviews')
      .set('Authorization', bearer(token))
      .send({ doctorId: 'd1', rating: 9 });
    expect(res.status).toBe(400);
  });
});
