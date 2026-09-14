# Appnea

Freediving school platform — course catalog, schedule booking, admin CMS.

See [PLAN.md](PLAN.md) for the architecture and roadmap.

## Stack

| Layer | Tech |
|---|---|
| API | Rails 8.1 (API-only), Ruby 3.3.12 |
| Admin | Avo 4 mounted at `/avo` |
| Web | Express + React 19 + TypeScript + Vite (SSR) |
| Database | PostgreSQL 16 |

Express holds no business logic. It server-renders React and proxies `/api/*`
to Rails, translating an httpOnly session cookie into an `Authorization` header
so the browser never holds the JWT.

## Prerequisites

- [mise](https://mise.jdx.dev) — pins Ruby 3.3.12 via `mise.toml`
- Node 24+
- PostgreSQL 16 running locally, with a role matching your OS user
- libvips, for image variants: `sudo apt-get install -y libvips42 libvips-tools`

Docker is not used; services run natively.

## Setup

```bash
cd backend
mise exec -- bundle install
mise exec -- bin/rails db:create db:migrate db:seed
cp .env.example .env

cd ../web && npm install
```

## Run

```bash
bin/dev
```

- Web (SSR): http://localhost:5173
- API: http://localhost:3000/api/health
- Admin: http://localhost:3000/avo — sign in at `/admin/login` with an admin account

Seeded logins, both `changeme123`:
- `admin@appnea.test` — reaches the admin panel
- `student@appnea.test` — books courses on the public site

Or run each side on its own:

```bash
cd backend && mise exec -- bin/rails server -p 3000
cd web && npm run dev
```

## API

| Endpoint | Returns |
|---|---|
| `GET /api/courses` | published courses (index view) |
| `GET /api/courses/:slug` | one course with its bookable schedules |
| `GET /api/schedules?course_id=&from=` | upcoming open schedules, course embedded |
| `GET /api/instructors` | instructors in display order |
| `GET /api/trips`, `/api/trips/:slug` | published upcoming trips |
| `GET /api/articles?category=`, `/api/articles/:slug` | published articles |
| `POST /api/auth/signup`, `POST /api/auth/login` | issue a JWT |
| `GET /api/auth/me` | the current user (requires a token) |
| `GET/POST/DELETE /api/bookings` | the caller's own bookings |
| `GET /api/schedules/:id` | one schedule, course embedded |
| `GET /api/search?q=` | courses and articles, ranked |

Responses are camelCase. Unpublished records 404 rather than render.

### Languages

Every read endpoint honours `?locale=en|id`, falling back to `Accept-Language`
and then English. Course, trip and article text is translated in the database
via a `translations` jsonb column; anything untranslated falls back to English
per field, so a partly translated record still renders completely.

### Auth

Rails issues a JWT. Express intercepts `/api/auth/login` and `/api/auth/signup`,
stores the token in an httpOnly `sameSite=lax` cookie, and returns only the user,
so client JavaScript never holds a credential. Every other `/api/*` call is
proxied with the cookie translated into an `Authorization` header.

Emails are written to `backend/tmp/mails` in development rather than sent.

## Test

```bash
cd backend && mise exec -- bundle exec rspec    # 154 examples
cd backend && mise exec -- bundle exec rubocop
cd web && npm run typecheck
cd web && npm run build                         # production SSR build
```

## Layout

```
backend/   Rails API + Avo admin
web/       Express SSR + React client
bin/dev    runs both
```
