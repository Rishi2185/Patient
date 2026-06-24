'use strict';

const Hospital = require('../models/Hospital');

/** All hospitals, sorted by name. */
async function list() {
  const docs = await Hospital.find().sort({ name: 1 }).lean();
  return docs.map(withId);
}

async function getById(id) {
  const doc = await Hospital.findById(id).lean();
  return doc ? withId(doc) : null;
}

function withId(doc) {
  const { _id, __v, ...rest } = doc;
  return { id: _id, ...rest };
}

module.exports = { list, getById };
