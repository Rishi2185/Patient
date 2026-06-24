'use strict';

const request = require('supertest');
const createApp = require('../src/app');
const { makeDoctor, makeHospital } = require('./helpers');

const app = createApp();

describe('hospitals (public)', () => {
  beforeEach(async () => {
    await makeHospital({
      _id: 'h1',
      name: 'Aarvy Multispeciality Hospital',
      galleryUrls: ['http://x/1.jpg'],
      facilities: [{ label: 'ICU', icon: 'icu' }],
      departments: ['Cardiology'],
      latitude: 19.05,
      longitude: 72.82,
      distanceKm: 2.4,
    });
    await makeHospital({ _id: 'h2', name: 'GreenLeaf Heart & Care Centre' });
    await makeDoctor({ _id: 'd1', hospitalId: 'h1', hospitalName: 'Aarvy Multispeciality Hospital' });
    await makeDoctor({ _id: 'd2', hospitalId: 'h2', hospitalName: 'GreenLeaf Heart & Care Centre' });
  });

  test('list returns hospitals with the full patient shape', async () => {
    const res = await request(app).get('/api/hospitals');
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(2);
    const h1 = res.body.data.find((h) => h.id === 'h1');
    expect(h1).toHaveProperty('galleryUrls');
    expect(h1).toHaveProperty('facilities');
    expect(h1.facilities[0]).toEqual({ label: 'ICU', icon: 'icu' });
    expect(h1).toHaveProperty('latitude', 19.05);
  });

  test('getById returns a hospital; unknown -> 404', async () => {
    const ok = await request(app).get('/api/hospitals/h1');
    expect(ok.status).toBe(200);
    expect(ok.body.id).toBe('h1');
    const missing = await request(app).get('/api/hospitals/h9');
    expect(missing.status).toBe(404);
  });

  test('affiliated doctors are returned per hospital', async () => {
    const res = await request(app).get('/api/hospitals/h1/doctors');
    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(1);
    expect(res.body.data[0].id).toBe('d1');
  });
});
