'use strict';

const express = require('express');
const validate = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');
const {
  bookingSchema,
  patchSchema,
  listQuerySchema,
} = require('../validators/appointmentValidators');
const ctrl = require('../controllers/appointmentController');

const router = express.Router();

// Every appointment route is scoped to the signed-in patient.
router.use(requireAuth);

router.get('/', validate(listQuerySchema, 'query'), ctrl.list);
router.post('/', validate(bookingSchema), ctrl.create);
router.get('/:id', ctrl.getById);
router.patch('/:id', validate(patchSchema), ctrl.patch);

module.exports = router;
