'use strict';

const request = require('supertest');
const createApp = require('../src/app');
const { patientToken, bearer } = require('./helpers');

const app = createApp();

const DEMO_OTP = '1234'; // non-prod: always accepted (env.allowDemoOtp)

describe('patient auth', () => {
  test('OTP request for sign-up returns a dev code in non-production', async () => {
    const res = await request(app)
      .post('/api/auth/otp/request')
      .send({ phone: '9111111111', purpose: 'signup' });
    expect(res.status).toBe(200);
    expect(res.body.sent).toBe(true);
    expect(typeof res.body.devCode).toBe('string');
  });

  test('sign-up with a valid OTP creates an account and returns a token', async () => {
    const res = await request(app).post('/api/auth/signup').send({
      username: 'Asha Menon',
      phone: '9111111111',
      password: 'secret123',
      otp: DEMO_OTP,
    });
    expect(res.status).toBe(201);
    expect(res.body.token).toBeTruthy();
    expect(res.body.user.phone).toBe('9111111111');
    expect(res.body.user.passwordHash).toBeUndefined();
  });

  test('sign-up with an invalid OTP is rejected', async () => {
    const res = await request(app).post('/api/auth/signup').send({
      username: 'No Code',
      phone: '9222222222',
      password: 'secret123',
      otp: '9999', // not the demo code and nothing was requested
    });
    expect(res.status).toBe(400);
  });

  test('sign-up on an existing number returns 409', async () => {
    await request(app).post('/api/auth/signup').send({
      username: 'First',
      phone: '9333333333',
      password: 'secret123',
      otp: DEMO_OTP,
    });
    const res = await request(app).post('/api/auth/signup').send({
      username: 'Second',
      phone: '9333333333',
      password: 'secret123',
      otp: DEMO_OTP,
    });
    expect(res.status).toBe(409);
  });

  test('login succeeds with correct credentials and 401s on wrong password', async () => {
    await request(app).post('/api/auth/signup').send({
      username: 'Login User',
      phone: '9444444444',
      password: 'secret123',
      otp: DEMO_OTP,
    });

    const ok = await request(app)
      .post('/api/auth/login')
      .send({ phone: '9444444444', password: 'secret123' });
    expect(ok.status).toBe(200);
    expect(ok.body.token).toBeTruthy();

    const bad = await request(app)
      .post('/api/auth/login')
      .send({ phone: '9444444444', password: 'wrongpass' });
    expect(bad.status).toBe(401);
  });

  test('password reset with a valid OTP lets the user log in with the new password', async () => {
    await request(app).post('/api/auth/signup').send({
      username: 'Reset User',
      phone: '9555555555',
      password: 'oldpass123',
      otp: DEMO_OTP,
    });

    const reset = await request(app)
      .post('/api/auth/reset-password')
      .send({ phone: '9555555555', otp: DEMO_OTP, newPassword: 'newpass123' });
    expect(reset.status).toBe(200);

    const login = await request(app)
      .post('/api/auth/login')
      .send({ phone: '9555555555', password: 'newpass123' });
    expect(login.status).toBe(200);
  });

  test('reset on an unknown number returns 404', async () => {
    const res = await request(app)
      .post('/api/auth/reset-password')
      .send({ phone: '9000000009', otp: DEMO_OTP, newPassword: 'newpass123' });
    expect(res.status).toBe(404);
  });

  test('check-phone reports existence', async () => {
    await request(app).post('/api/auth/signup').send({
      username: 'Known User',
      phone: '9666666666',
      password: 'secret123',
      otp: DEMO_OTP,
    });
    const yes = await request(app).get('/api/auth/check-phone?phone=9666666666');
    expect(yes.body.exists).toBe(true);
    const no = await request(app).get('/api/auth/check-phone?phone=9000000001');
    expect(no.body.exists).toBe(false);
  });

  test('GET /me echoes the authenticated patient; missing token -> 401', async () => {
    const { token, patient } = await patientToken();
    const me = await request(app).get('/api/auth/me').set('Authorization', bearer(token));
    expect(me.status).toBe(200);
    expect(me.body.phone).toBe(patient.phone);

    const anon = await request(app).get('/api/auth/me');
    expect(anon.status).toBe(401);
  });

  test('OTP verify endpoint validates the demo code', async () => {
    const res = await request(app)
      .post('/api/auth/otp/verify')
      .send({ phone: '9111111111', purpose: 'signup', code: DEMO_OTP });
    expect(res.status).toBe(200);
    expect(res.body.valid).toBe(true);
  });

  test('signup validation rejects a short password / bad phone', async () => {
    const res = await request(app).post('/api/auth/signup').send({
      username: 'X',
      phone: '123',
      password: 'short',
      otp: DEMO_OTP,
    });
    expect(res.status).toBe(400);
  });
});
