# Aarvy — Patient

The patient side of the Aarvy healthcare system, organized as two projects:

```
Patient/
  frontend/   Flutter patient app — discover doctors, book appointments, reviews
  backend/    Node.js + MongoDB + Express API for the patient app
```

- **[frontend/](frontend/)** — the Flutter app. Runs standalone on local mock
  data (no backend required). See [frontend/README.md](frontend/README.md).
- **[backend/](backend/)** — the patient API. Boots with zero setup against an
  in-memory MongoDB and auto-seeds the same demo roster the app shows. It mirrors
  the hospital-side backend (`../Employees/backend`) and is schema-compatible, so
  both can share one database. See [backend/README.md](backend/README.md).

## Run

```bash
# Backend (http://localhost:4100/api)
cd backend && npm install && npm run dev

# Frontend (Flutter)
cd frontend && flutter pub get && flutter run
```

The Flutter app currently uses its bundled mock data; the backend is a faithful,
drop-in match for that data contract, so wiring the app to the API later is a
mechanical change (swap the providers' data source for an HTTP client).

Demo login (app + backend): phone `9999999999`, password `demo1234`, OTP `1234`.
