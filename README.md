# Cadet Activity Management

Local development is supported via Docker only.

## Local Docker Setup

### Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose plugin)

### Quick Start

1. Clone and enter the repository:

```bash
git clone https://github.com/alanchao86/Cadet-Activity-Management.git
cd Cadet-Activity-Management
git checkout main
```

2. Create local env file:

```bash
cp .env.example .env
```

3. Configure `.env`:

```bash
ENABLE_LOCAL_AUTH=true
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
```

Notes:
- `ENABLE_LOCAL_AUTH=true` enables username/password login for local testing.
- Google OAuth env vars are optional unless you want to test Google login.

4. Start services:

```bash
docker compose up -d --build
```

5. Initialize database (first run):

```bash
docker compose run --rm web bin/rails db:create db:migrate db:seed
```

6. Open:

```text
http://localhost:3000
```

## Dual Login Testing

The home page supports both:
- Local username/password login
- Login with Google (only if Google OAuth env vars are configured)

## Demo Test Accounts (Seeded)

After `db:seed`, these local test accounts are available:

| Role | Username | Password | Purpose |
| --- | --- | --- | --- |
| Admin | `demo_admin` | `DemoPass123!` | Access Admin page, manage users, impersonate |
| Submitter | `demo_submitter` | `DemoPass123!` | Create and edit training activities |
| Minor Approver | `demo_minor` | `DemoPass123!` | Approve/reject at minor level |
| Major Approver | `demo_major` | `DemoPass123!` | Approve/reject at major level |
| CMDT Approver | `demo_cmdt` | `DemoPass123!` | Final approval/testing commandant flow |

Security note: demo credentials are for local/demo/test environments only. Never use them in production.

## Useful Docker Commands

```bash
# Start services
docker compose up -d --build

# Stop services
docker compose down

# Stop and remove database volume (full reset)
docker compose down -v

# Rails console
docker compose exec web bin/rails console

# Re-run seed data
docker compose exec web bin/rails db:seed

# Run tests
docker compose exec web bundle exec rspec
docker compose exec web bin/rails cucumber
```

## Troubleshooting

- If local login is hidden, verify `.env` has `ENABLE_LOCAL_AUTH=true`.
- If Google login fails, verify OAuth callback URL:
  - `http://localhost:3000/auth/google_oauth2/callback`
- If DB issues occur, run:

```bash
docker compose down -v
docker compose up -d --build
docker compose run --rm web bin/rails db:create db:migrate db:seed
```

## Contact

For inquiries: `alanchao8669@gmail.com`
