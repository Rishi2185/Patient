'use strict';

const express = require('express');
const validate = require('../middleware/validate');
const { requireAuth, optionalAuth } = require('../middleware/auth');
const { listQuerySchema, createSchema } = require('../validators/reviewValidators');
const ctrl = require('../controllers/reviewController');

const router = express.Router();

// Public: read a doctor's reviews + aggregate.
router.get('/', optionalAuth, validate(listQuerySchema, 'query'), ctrl.list);

// Auth: a signed-in patient posts a review.
router.post('/', requireAuth, validate(createSchema), ctrl.create);

module.exports = router;
