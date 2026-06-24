# Aarvy — Patient Appointment Booking (Flutter demo)

A polished, patient-friendly healthcare app for discovering doctors and booking
appointments. Clean green-and-white medical theme, smooth animations, and a
fully working flow powered entirely by **mock data — no backend required**.

> This is a front-end demo. OTP, payments, "SMS", and persistence are simulated
> locally so the whole experience is explorable offline.

## Run it

```bash
flutter pub get
flutter run        # on a connected device / emulator
```

A pre-built debug APK is also produced at
`build/app/outputs/flutter-apk/app-debug.apk` after `flutter build apk --debug`.

## Demo credentials

| Field    | Value          |
|----------|----------------|
| Phone    | `9999999999`   |
| Password | `demo1234`     |
| OTP      | `1234` (any OTP prompt — sign-up, password reset) |

Or create a new account from the **Sign Up** screen (the OTP is always `1234`).

## Features

1. **Auth** — animated splash, sign up with real-time validation + password
   strength meter, OTP verification, sign in with "remember me", forgot-password
   (OTP) reset. Sessions persist via `shared_preferences`.
2. **Home / discovery** — greeting header, search, specialty categories, top
   doctors rail, "available today", health-tip banner.
3. **Find doctors** — live search + filter & sort (specialty, rating,
   availability, fee, experience) via a bottom sheet.
4. **Doctor detail & booking** — full profile, stats, reviews; calendar +
   time-slot picker (booked slots disabled); mock payment (UPI / card / wallet)
   with bill summary; animated confirmation ticket saved to *My Appointments*.
5. **Ratings & reviews** — aggregate rating + distribution, review list, and a
   write-review flow unlocked after a visit is marked completed.
6. **Hospitals** — list + rich detail (gallery, departments, facilities, a
   hand-painted map mock, affiliated doctors).
7. **My Appointments** — Upcoming / Completed / Cancelled tabs with cancel,
   "mark visited", book-again and review actions.
8. **Profile** — patient header, stats, settings menu, sign out.

## Architecture

```
lib/
  theme/      design system (colors, typography, ThemeData + tokens)
  models/     Doctor, Hospital, Appointment, Review, AppUser, Specialty
  data/       mock_data.dart — doctors, hospitals, reviews
  state/      ChangeNotifier providers (auth, appointments, discovery, reviews)
  utils/      validators, formatters, slot generator
  widgets/    reusable UI (buttons, fields, cards, avatar, OTP, ...)
  screens/    feature screens grouped by area
```

- **State management:** `provider` (`ChangeNotifier`).
- **Fonts:** `google_fonts` (Poppins + Inter) with graceful offline fallback.
- **Images:** network photos (randomuser / picsum) that fall back to tinted
  initials / placeholders, so layouts never break offline.
