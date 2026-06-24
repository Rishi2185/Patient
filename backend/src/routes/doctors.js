'use strict';

const express = require('express');
const validate = require('../middleware/validate');
const { optionalAuth } = require('../middleware/auth');
const { listQuerySchema } = require('../validators/doctorValidators');
const ctrl = require('../controllers/doctorController');
const reviewCtrl = require('../controllers/reviewController');

const router = express.Router();

// All doctor reads are public (the app browses before sign-in).
// `/top` is declared before `/:id` so it isn't captured as an id.
router.get('/top', optionalAuth, ctrl.top);
router.get('/', optionalAuth, validate(listQuerySchema, 'query'), ctrl.list);
router.get('/:id', optionalAuth, ctrl.getById);
router.get('/:id/availability', optionalAuth, ctrl.availability);
router.get('/:id/reviews', optionalAuth, reviewCtrl.listForDoctorParam);

module.exports = router;
