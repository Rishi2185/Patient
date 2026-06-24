'use strict';

const mongoose = require('mongoose');

/**
 * Hospital / clinic. This is the FULL shape the patient app's `Hospital` model
 * expects (gallery, facilities, rating, map coords), which is a superset of the
 * hospital backend's trimmed `Hospital`. Storing the superset keeps both
 * services happy on a shared `hospitals` collection — the hospital backend
 * simply ignores the extra fields.
 *
 * `distanceKm` is a demo/display value (there's no real geolocation here); a
 * production app would compute it from the device's location against
 * latitude/longitude.
 */
const facilitySchema = new mongoose.Schema(
  {
    label: { type: String, required: true }, // e.g. "24/7 Emergency"
    icon: { type: String, required: true }, // icon key resolved client-side
  },
  { _id: false }
);

const hospitalSchema = new mongoose.Schema(
  {
    _id: { type: String }, // "h1".."h5"
    name: { type: String, required: true },
    address: { type: String, default: '' },
    city: { type: String, default: '' },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    phone: { type: String, default: '' },
    imageUrl: { type: String, default: '' },
    galleryUrls: { type: [String], default: [] },
    departments: { type: [String], default: [] },
    facilities: { type: [facilitySchema], default: [] },
    about: { type: String, default: '' },
    openHours: { type: String, default: '' }, // e.g. "Open 24 hours"
    distanceKm: { type: Number, default: 0 },
    latitude: { type: Number, default: 0 },
    longitude: { type: Number, default: 0 },
  },
  { _id: false, timestamps: true }
);

module.exports = mongoose.model('Hospital', hospitalSchema);
