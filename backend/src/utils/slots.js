'use strict';

/**
 * Server-side mirror of the patient app's `SlotGenerator`
 * (frontend/lib/utils/slot_generator.dart). The three fixed bands are identical;
 * the per-day "available subset" is produced by a deterministic hash so the same
 * doctor+date always yields the same slots without storing anything.
 *
 * NOTE: Dart's `String.hashCode` is not portable to JS, so this subset is NOT
 * byte-identical to the app's — the app keeps generating its own slots. The only
 * authoritative field the availability endpoint returns is `bookedSlots` (real
 * upcoming appointments). These generated lists are a convenience for any client
 * that wants the bands ready-made.
 */

const MORNING = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM'];
const AFTERNOON = ['12:00 PM', '12:30 PM', '02:00 PM', '02:30 PM', '03:00 PM'];
const EVENING = ['04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM', '06:00 PM'];

/** Stable 32-bit FNV-1a hash of a string (portable, dependency-free). */
function fnv1a(str) {
  let h = 0x811c9dc5;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 0x01000193);
  }
  return h >>> 0;
}

/** Deterministically drop ~1 in 3 slots, seeded by doctorId + dayKey + band. */
function filterBand(slots, doctorId, dayKey, band) {
  const seed = fnv1a(`${doctorId}|${dayKey}|${band}`);
  const result = [];
  for (let i = 0; i < slots.length; i++) {
    if ((seed + i * 7) % 3 !== 0) result.push(slots[i]);
  }
  return result;
}

/**
 * Build the three slot bands for a doctor on a day, with already-booked slots
 * removed. `dayKey` is YYYY-MM-DD; `bookedSlots` is an array of slot labels.
 */
function slotsForDay(doctorId, dayKey, bookedSlots = []) {
  const booked = new Set(bookedSlots);
  const take = (band, idx) =>
    filterBand(band, doctorId, dayKey, idx).filter((s) => !booked.has(s));
  return {
    morning: take(MORNING, 0),
    afternoon: take(AFTERNOON, 1),
    evening: take(EVENING, 2),
  };
}

module.exports = { slotsForDay, MORNING, AFTERNOON, EVENING };
