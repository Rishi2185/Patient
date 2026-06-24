'use strict';

const jwt = require('jsonwebtoken');
const env = require('../config/env');
const ApiError = require('../utils/apiError');
const { ROLES } = require('../constants');

/**
 * Sign a session JWT for a patient. No sensitive PII beyond what's needed:
 * id, role, display name, phone (the app's AppUser is {username, phone}).
 */
function signToken(patient) {
  return jwt.sign(
    {
      sub: String(patient._id),
      role: ROLES.PATIENT,
      name: patient.username,
      phone: patient.phone,
    },
    env.jwtSecret,
    { expiresIn: env.jwtExpiresIn }
  );
}

/** Extract and verify the Bearer token; attach `req.user`. Throws 401 on fail. */
function requireAuth(req, _res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) {
    return next(ApiError.unauthorized('Missing or malformed Authorization header'));
  }
  try {
    const payload = jwt.verify(token, env.jwtSecret);
    req.user = {
      id: payload.sub,
      role: payload.role,
      name: payload.name,
      phone: payload.phone,
    };
    return next();
  } catch (_err) {
    return next(ApiError.unauthorized('Invalid or expired token'));
  }
}

/**
 * Attach `req.user` if a valid token is present, but don't require it. Lets
 * public reads (doctors, hospitals) still recognize an authenticated caller.
 */
function optionalAuth(req, _res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');
  if (scheme === 'Bearer' && token) {
    try {
      const payload = jwt.verify(token, env.jwtSecret);
      req.user = {
        id: payload.sub,
        role: payload.role,
        name: payload.name,
        phone: payload.phone,
      };
    } catch (_err) {
      /* ignore — treated as anonymous */
    }
  }
  return next();
}

module.exports = { signToken, requireAuth, optionalAuth };
