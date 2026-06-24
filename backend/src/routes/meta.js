'use strict';

const express = require('express');
const { optionalAuth } = require('../middleware/auth');
const ctrl = require('../controllers/metaController');

const router = express.Router();

router.get('/specialties', optionalAuth, ctrl.specialties);

module.exports = router;
