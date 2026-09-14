# Appnea — Implementation Plan

Freediving school platform. Course catalog, schedule booking, admin CMS.
Reference: https://www.apneabali.com/

---

## 1. Architecture

```
Browser
  └─ Express (Node 24 + TS) — SSR React, session cookie, proxy /api/*
        └─ Rails 8 (API-only) — business logic, auth, admin
              └─ PostgreSQL 16
```

**Express has zero business logic.** It renders React on the server and forwards
API calls to Rails. This keeps one source of truth (Rails) while still giving us
server-rendered HTML for SEO — which matters because most traffic will arrive via
search ("freediving course bali").

**Auth boundary:** Rails issues a JWT. Express stores it in an httpOnly cookie and
injects it as an `Authorization` header when proxying. The browser never holds the
token, so XSS cannot exfiltrate it.

---

## 2. Repo layout

```
appnea/
├── backend/            Rails 8 API-only
│   ├── app/
│   ├── config/
│   └── spec/
├── web/                Express SSR + React 19 + TS + Vite
│   ├── src/
│   │   ├── client/     browser entry, pages, components
│   │   ├── server/     Express app, SSR render, API proxy
│   │   └── shared/     types mirrored from Rails serializers
│   └── vite.config.ts
├── PLAN.md
└── CLAUDE.md
```

---

## 3. Environment

Docker is not available on this machine, so we run services natively.

| Tool | Version | Source |
|---|---|---|
| Ruby | 3.3.12 | mise, pinned in `mise.toml` |
| Rails | 8.x | bundler |
| Node | 24.18.1 | already installed |
| PostgreSQL | 16.15 | already running on `/var/run/postgresql:5432` |

Ports: Rails `3000`, Express `5173`.

---

## 4. Data model

| Model | Fields |
|---|---|
| `User` | email, password_digest, name, role (guest/student/instructor/admin) |
| `Instructor` | user_id (nullable), name, bio, certifications[], photo, display_order |
| `Course` | slug, title, agency (AIDA/SSI/Molchanovs), level, depth_target_m, duration_days, price_cents, currency, summary, description, published |
| `Schedule` | course_id, instructor_id, start_date, end_date, capacity, seats_taken, status (open/full/cancelled/done) |
| `Booking` | user_id, schedule_id, participants, status (pending/confirmed/cancelled), total_cents, notes, payment_ref (nullable) |
| `Trip` | slug, title, destination, start_date, end_date, capacity, price_cents, description, published |
| `Article` | slug, title, excerpt, body, category, published_at |
| `Media` | ActiveStorage attachment, polymorphic owner |

**Overbooking guard:** `seats_taken` is only ever mutated inside
`schedule.with_lock { ... }`. Two concurrent bookings for the last seat must
serialize at the DB row level — an application-level check alone will let both
through.

**Payment hook:** `Booking#payment_ref` is nullable and unused in MVP. It exists
so adding Midtrans/Xendit later is an integration, not a migration of live data.

---

## 5. Phases

### Phase 0 — Scaffold ✅ done
- [x] Ruby 3.3.12 via mise, pinned per-project in `mise.toml`
- [x] `rails new backend --api -d postgresql -T` (module `Appnea`)
- [x] Gems: `rspec-rails`, `factory_bot_rails`, `blueprinter`, `rack-cors`, `bcrypt`, `jwt`, `avo`, `propshaft`
- [x] Cookie/session/flash middleware added back so Avo can run inside an API-only app
- [x] `web/`: Vite + React 19 + TS, Express SSR, `/api/*` proxy with httpOnly-cookie to Bearer translation
- [x] `appnea_development` + `appnea_test` created; `/api/health` verified end to end through Express
- [x] `bin/dev` runs both servers; root `README.md` written

Deviations from the original plan: Ruby 3.3.12 instead of 3.4 (3.3 was already
installed and Rails 8 supports it), and no Docker (not installed on this machine).

### Phase 1 — Domain + Admin ✅ done
- [x] Migrations for every model in §4, with DB-level check constraints
- [x] Model validations, associations, enums, scopes
- [x] `Bookings::Create` / `Bookings::Cancel` — seat claims under a row lock
- [x] Avo: CRUD for Course, Schedule, Instructor, Trip, Article, User; read-only Booking with Confirm/Cancel actions
- [x] HTTP Basic guard on `/avo` (interim; replaced in Phase 3 by a session login)
- [x] Idempotent seeds: 4 courses, 2 instructors, 12 schedules, 2 trips, 3 articles
- [x] 50 specs green, rubocop clean

Avo is chosen over a hand-built React admin because the admin surface is pure CRUD
and building it by hand buys nothing.

Notes from the build:
- `ransack` had to be added explicitly. Avo 4 treats it as optional but its search
  blocks depend on it, and Avo 4.2.3 masks the resulting error behind an
  `ArgumentError: missing keyword: :label` in its own error handler.
- The overbooking spec was verified by removing the row lock: 8 concurrent
  bookings then land on a 4-seat schedule. The DB check constraint does not catch
  this on its own, because each thread reads `seats_taken` as 0 and writes 1 —
  a lost update that never exceeds capacity. The lock is what makes it safe.
- Instructors carry their own `name` and their `user` is nullable, so a profile
  can exist for someone who never logs in.

### Phase 2 — Public API + catalog ✅ done
- [x] `GET /api/courses`, `/api/courses/:slug`
- [x] `GET /api/schedules?course_id=&from=`
- [x] `GET /api/trips`, `/api/trips/:slug`
- [x] `GET /api/articles`, `/api/articles/:slug`, `GET /api/instructors`
- [x] Blueprinter serializers with a camelCase transformer, index/detail views
- [x] React pages: home, courses, course detail, instructors, trips, trip detail, blog, article
- [x] SSR loads data on the server and hydrates from it; per-page title, description, OpenGraph
- [x] SSR status codes match the page (a missing or draft record renders 404, not 200)
- [x] 75 backend specs green, rubocop clean, `tsc --noEmit` clean, production build verified

Notes from the build:
- Blueprinter's transformer API rewrites keys centrally, so blueprints stay in
  snake_case Ruby while the wire format is camelCase for the TypeScript client.
- The SSR payload is escaped before it goes into the bootstrap `<script>`:
  `</script>` inside any record (a course description, say) would otherwise close
  the tag early, and U+2028/U+2029 are valid JSON but illegal in a JS string.
- Unpublished courses and draft articles 404 rather than render, so an admin
  writing a draft cannot leak it by sharing the URL.
- Client-side navigation refetches through the Express proxy; only the first
  page load is served from SSR data.

### Phase 3 — Auth + Booking ✅ done
- [x] `Auth::Token` — HS256 JWT, key derived from secret_key_base, 7-day expiry
- [x] `POST /api/auth/signup`, `POST /api/auth/login`, `GET /api/auth/me`
- [x] `GET/POST/DELETE /api/bookings`, `GET /api/schedules/:id`
- [x] Express holds the token in an httpOnly cookie and returns only the user
- [x] SSR redirects an anonymous visitor away from authenticated routes
- [x] Booking flow: pick a date, enter participants, submit, status `pending`
- [x] Admin confirms in Avo, which sends the confirmation email
- [x] `BookingMailer#received` and `#confirmed`, both rendered under test
- [x] Avo moved off the interim HTTP Basic guard onto a real session login at
      `/admin/login`, restricted to accounts with the `admin` role
- [x] 119 backend specs green, rubocop clean, tsc clean, production build verified

Security decisions, and why:
- The token never reaches client JavaScript. Express intercepts the two
  endpoints that issue one, stores it in an httpOnly cookie, and strips it from
  the response body — so an XSS bug cannot read a credential that is not there.
- The cookie is `sameSite=lax`, which is what stops another origin from riding
  it on a cross-site POST. That is the CSRF defence for the booking endpoints.
- Login returns byte-identical responses for an unknown email and a wrong
  password, so the endpoint cannot be used to enumerate accounts. There is a
  spec asserting the two responses are equal.
- `role` is not permitted in the signup params; otherwise a caller could sign
  up as an admin by adding one field.
- Cancel is scoped to `current_user.bookings`, so guessing another guest's
  booking id returns 404 rather than cancelling it.
- Signed-in pages are sent with `Cache-Control: private, no-store` plus a
  `noindex` meta tag, so a shared cache cannot serve one visitor's bookings to
  someone else.
- Login is rate limited to 10 attempts per 3 minutes per IP (Rails 8's built-in
  `rate_limit`, backed by Solid Cache).
- The receipt email is sent after the seat-claim transaction commits, never
  inside it — a rolled back booking must not produce a confirmation.
- The admin login calls `reset_session` before storing the user id, so a session
  fixated before login cannot be reused after it.
- Admin login is CSRF protected (`protect_from_forgery with: :exception`), and
  its `?next=` parameter only accepts same-origin paths, so it cannot bounce an
  admin to another site after signing in.
- A correct password on a non-admin account is refused with the same status and
  the same wording as a wrong password, so the form cannot be used to work out
  which accounts are admins.

### Phase 4 — Polish (next)
- i18n EN/ID (tourists + local market)
- Postgres full-text search over courses and articles (Elasticsearch is overkill here)
- Image variants via ActiveStorage
- Real seed content

---

## 6. Decisions made

- **Rails 8 API-only**, not full-stack — the frontend is React
- **Blueprinter** for serialization
- **Avo** for admin
- **Postgres FTS** for search
- **JWT** to Rails, httpOnly cookie at Express
- **No Docker** — not installed; native services instead
- **Payment deferred** — schema hook only

## 7. Out of scope (MVP)

Payment gateway, realtime chat, mobile app, multi-tenant / multi-school support.
