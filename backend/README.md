# Aarvy Patient Backend

The Node.js + MongoDB backend for the **patient side** of the Aarvy healthcare
system. It serves the Flutter patient app (`../frontend`) the exact data it shows
today as mock data: doctor discovery, hospital detail, slot availability,
bookings, reviews, and phone-based patient auth.

It mirrors the conventions of the hospital-side backend
(`../../Employees/backend`) and is **schema-compatible** with it: the `doctors`,
`appointments` and `specialties` collections share the same shapes and ids, so
both services can point at one MongoDB and interoperate — a patient booking
shows up at reception, and an admin-managed doctor shows up in the patient app.

## Architecture — what this service owns

| Collection | Written by | Read by | Notes |
|-----------|-----------|---------|-------|
| `patients` | this service (sign-up) | this service | phone + password accounts; distinct from staff `users` |
| `doctors` | hospital admin | patient + reception + admin | shared roster; ids `d1`..`d12` |
| `hospitals` | seed/admin | patient app | **full** shape (gallery, facilities, map coords) — a superset of the hospital backend's trimmed hospital |
| `appointments` | patient app + reception | patient + reception + admin | rolling window (today + future); `patientId` scopes "My Appointments" |
| `reviews` | patient app | patient app | folds into each doctor's headline rating |
| `specialties` | seed | patient app | id + name; icon/color resolved client-side |
| `otpcodes` | this service | this service | hashed, short-lived sign-up / reset codes (TTL) |

```
Patient app ──browse──▶ doctors / hospitals / specialties / reviews  (public reads)
     │                                                   ▲
   sign in ──▶ patients (phone + password, OTP verify)   │ reads doctor + reviews
     │                                                    │
   book ──────▶ appointments (own, today + future) ───────┘
   review ────▶ reviews ──updates──▶ doctor.rating / reviewCount
```

**Privacy / size:** appointments are bounded to today + future (a TTL index is a
backstop); the hospital backend's end-of-day job summarizes and purges past days.
Denormalized doctor/specialty/hospital names avoid `$lookup` on hot paths, which
keeps it comfortable on the Atlas free tier (M0).

## Quick start (zero secrets)

```bash
npm install
npm run dev
```

With no `MONGODB_URI` set, the server boots an **in-memory MongoDB** and
auto-seeds demo data. API base: `http://localhost:4100/api`.

> The in-memory DB is **ephemeral per process** — `npm run seed` in a separate
> process won't share it. For persistence, set `MONGODB_URI` (local mongod or an
> Atlas free-tier URI) in `.env`, then `npm run seed` once.

```bash
cp .env.example .env          # then edit MONGODB_URI / secrets
npm run seed                  # seed a persistent DB
npm start                     # production-style start
npm test                      # Jest + supertest (own in-memory Mongo)
npm run lint
```

### Demo credentials (match the Flutter app)

| Field | Value |
|-------|-------|
| Phone | `9999999999` |
| Password | `demo1234` |
| OTP (sign-up & reset, non-prod) | `1234` (any code; the fixed demo code is always accepted) |

## API

All routes are under `/api`. Auth is `Authorization: Bearer <jwt>`. List
endpoints return `{ data, page, limit, total }`.

### Auth (`patients`)
- `POST /auth/otp/request` `{phone, purpose}` — `purpose` is `signup` | `reset`.
  Returns `{sent, expiresInMinutes}` (+ `devCode` in non-prod). Rate-limited.
- `POST /auth/otp/verify` `{phone, purpose, code}` → `{valid}` (app's OTP screen)
- `POST /auth/signup` `{username, phone, password, otp}` → `{token, user}`
- `POST /auth/login` `{phone, password}` → `{token, user}`
- `POST /auth/reset-password` `{phone, otp, newPassword}` → `{reset:true}`
- `GET /auth/check-phone?phone=` → `{exists}` (app's `phoneExists`)
- `GET /auth/me` → `{id, username, phone}`

OTP codes are stored **hashed** with a TTL; at most one active code per
phone+purpose; wrong attempts are capped. In production the fixed demo code is
**rejected** — only real requested codes work, and `devCode` is not returned.

### Doctors (public — `DoctorProvider` parity)
- `GET /doctors` — query: `q`, `specialtyId`, `availableToday`, `minRating`,
  `sort` (`relevance|ratingHigh|feeLow|feeHigh|experience`), `page`, `limit`
- `GET /doctors/top?limit=6` — home "Top Doctors" rail
- `GET /doctors/:id`
- `GET /doctors/:id/availability?date=YYYY-MM-DD` → window + days + `bookedSlots`
  + generated `slots` (morning/afternoon/evening, booked removed)
- `GET /doctors/:id/reviews`

### Hospitals (public)
- `GET /hospitals` · `GET /hospitals/:id` (full shape: gallery, facilities,
  departments, rating, `distanceKm`, lat/long)
- `GET /hospitals/:id/doctors` — affiliated doctors

### Appointments (auth — owned by the caller)
- `GET /appointments?status=0|1|2` — the patient's own list, newest first
- `POST /appointments` `{doctorId, dateTime, slotLabel, fee?, paymentMethod?}` —
  derives doctor fields + identity server-side; rejects past days; the slot is
  guarded by a partial-unique index (one upcoming booking per doctor+day+slot)
- `GET /appointments/:id` (404 if not the caller's)
- `PATCH /appointments/:id` `{status?, reviewed?}` — cancel / mark visited / mark reviewed

### Reviews
- `GET /reviews?doctorId=` → `{data, page, limit, total, aggregate:{rating,count}}`
- `POST /reviews` `{doctorId, rating, comment?, appointmentId?}` (auth) — creates
  the review, folds it into the doctor's headline rating, and marks the linked
  appointment reviewed if `appointmentId` is given

### Reference / health
- `GET /specialties` · `GET /health`

## Patient-app compatibility contract

The `appointments` documents are a **non-breaking superset** of the patient app's
`Appointment` model (`../frontend/lib/models/appointment.dart`):

- `status` and `paymentMethod` are stored and emitted as the patient enum's
  **integer index** (`status`: 0 upcoming / 1 completed / 2 cancelled;
  `paymentMethod`: 0 card / 1 upi / 2 wallet). **Never** emit a 4th status — the
  app reconstructs via `Enum.values[index]` and would crash.
- The patient-facing keys (`id`, `doctorId`, `doctorName`, `doctorPhotoUrl`,
  `specialtyName`, `hospitalName`, `dateTime` ISO, `slotLabel`, `fee`,
  `paymentMethod`, `status`, `reviewed`) are preserved verbatim. Extra fields
  (`statusLabel`, `patientName`, `source`, …) are ignored by the app's strict
  `fromJson`.
- Doctors expose `specialtyId` + `specialtyName`; the icon/color mapping stays
  client-side via `Specialties.byId(id)`. Doctor/hospital ids (`d1`…/`h1`…) are
  preserved.

`test/contract.test.js` round-trips a live booking through the patient model's
`fromJson` expectations to guard against drift.

## Project layout

```
src/
  config/      env.js, db.js (Atlas / in-memory fallback)
  models/      Patient, Specialty, Hospital, Doctor, Appointment, Review, OtpCode
  validators/  zod schemas (strict; block mass-assignment)
  middleware/  auth (JWT), validate, errorHandler, rateLimiters
  services/    auth/otp, doctor, hospital, appointment, review (logic lives here)
  controllers/ thin HTTP handlers
  routes/      auth, doctors, hospitals, appointments, reviews, meta, health
  utils/       dayKey (TZ-aware), slots (SlotGenerator mirror), apiError,
               asyncHandler, pagination
  seed/        data.js (ported roster + reviews) + seed.js (CLI + auto-seed)
  app.js       express app factory       server.js  bootstrap + auto-seed
test/          jest suites + in-memory Mongo harness
```

## Notes / next phase

- The Flutter app still runs on local mock data. Wiring it to this API (an HTTP
  client + swapping the providers' data source) is a separate, opt-in step; this
  backend is a faithful, drop-in match for the app's data contract so that change
  is mechanical.
- Sharing a database with the hospital backend: set the same `MONGODB_URI` and
  `CLINIC_TZ` in both. Seed **one** of them (the patient seed writes the richer
  hospital docs, a superset both apps read happily).
