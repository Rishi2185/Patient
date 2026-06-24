'use strict';

const express = require('express');
const { optionalAuth } = require('../middleware/auth');
const ctrl = require('../controllers/hospitalController');

const router = express.Router();

// Public reads.
router.get('/', optionalAuth, ctrl.list);
router.get('/:id', optionalAuth, ctrl.getById);
router.get('/:id/doctors', optionalAuth, ctrl.doctors);

module.exports = router;
