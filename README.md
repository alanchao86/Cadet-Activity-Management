# Cadet Activity Management

- Deplyed Live Site: [here](https://cadet-activity-management-7ed1c42c26df.herokuapp.com/).
- Code Climate Report: [here](https://codeclimate.com/github/jwonnyleaf/Cadet-Activity-Management).

# Development

## Docker Local Setup (Recommended)

This project now supports one-command local startup with Docker.

### Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose plugin)

### Quick Start

1. Create local env file:

```bash
cp .env.example .env
```

2. Configure `.env` values:

```bash
ENABLE_LOCAL_AUTH=true
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
```

`ENABLE_LOCAL_AUTH=true` enables username/password demo login (recommended for local testing).
Google values are optional unless you want to test Google OAuth.

3. Start app + database:

```bash
docker compose up --build
```

4. Initialize database (first time only):

```bash
docker compose run --rm web bin/rails db:create db:migrate db:seed
```

5. Open:

```text
http://localhost:3000
```

The web container startup is intentionally kept fast and stable; DB setup is explicit via the command above.
If you change source code, rebuild with `docker compose up --build`.

### Useful Docker Commands

```bash
# Start in background
docker compose up -d --build

# Stop services
docker compose down

# Stop + remove database volume (full DB reset)
docker compose down -v

# Open Rails console in container
docker compose exec web bin/rails console

# Seed data manually (recommended once after first boot)
docker compose exec web bin/rails db:seed

# Run test suite in container
docker compose exec web bundle exec rspec
docker compose exec web bin/rails cucumber
```

### Notes

- Without OAuth env vars, the app still boots but Google login will not work.
- Local DB runs in Docker Postgres and is connected via `DATABASE_URL`.
- Local username/password auth defaults to enabled outside production unless `ENABLE_LOCAL_AUTH=false`.

### Demo Test Accounts (Seeded)

After `db:seed`, these local tester accounts are available:

| Role | Username | Password | Purpose |
| --- | --- | --- | --- |
| Admin | `demo_admin` | `DemoPass123!` | Access Admin page, manage users, impersonate |
| Submitter | `demo_submitter` | `DemoPass123!` | Create and edit training activities |
| Minor Approver | `demo_minor` | `DemoPass123!` | Approve/reject at minor level |
| Major Approver | `demo_major` | `DemoPass123!` | Approve/reject at major level |
| CMDT Approver | `demo_cmdt` | `DemoPass123!` | Final approval/testing commandant flow |

Security note: these credentials are for local/demo/test use only. Do not use in production.

## First Time Setup

### Cloning Repository

```
sudo apt update && sudo apt upgrade -y && sudo apt install libpq-dev -y
git clone git@github.com:jwonnyleaf/Cadet-Activity-Management.git
cd Cadet-Activity-Management
git checkout dev
git pull
bundle install
npm install
```

Next, follow

1. [Setup Google OAuth On Google's End](#setup-google-oauth-on-googles-end)
2. [Add OAuth ID and Secret to Rails Credentials](#add-oauth-id-and-secret-to-rails-credentials)
3. [Database](#local-database)
4. To run & test, see [Routine](#routine)

### Setup Google OAuth On Google's End

Courtesy: Course Resources - [Google-Auth-Ruby-By-JD](https://github.com/tamu-edu-students/Google-Auth-Ruby-By-JD.git)

This section walks you through setting up Google OAuth for your application in the Google Developer Console. This is required for validating aunthentication over tamu.edu domain:

#### Step 1: Create a New Project in Google Developer Console

1. Go to the [Google Developer Console](https://console.developers.google.com/).
1. Select or create a project for your application, giving it a name like "Google-OAuth-Rails."

#### Step 2: Set Up OAuth Consent Screen

1. In your project, navigate to "APIs & Services" and click on "OAuth consent screen."
1. Set the user type to "Internal" for only @tamu.edu accounts.
1. Fill out the required information on the consent screen. You need to provide the app name, user support email, and developer contact information.
1. Save your changes.

#### Step 3: Add Scopes

1. Add `userinfo.email` and `userinfo.profile`
1. Click "Save and Continue."

#### (Optional) Step 4: Add Test Users

You can add test users who are allowed to log in to your application. This means that only the email addresses you add here can access your application.
If you choose to add test users, do so on this page and click "Save and Continue."

#### Step 5: Create OAuth Client ID

1. On the dashboard, click on "Credentials," then "Create Credentials."
1. Select "OAuth client ID" and choose "Web application" as the application type.
1. Give your application a name.
1. Under "Authorized redirect URIs," add the following:
   - `http://localhost:3000/auth/google_oauth2/callback`
   - `http://127.0.0.1:3000/auth/google_oauth2/callback`
1. Click "Create."
1. You will receive a client ID and client secret. **Save this information.**
1. Ensure that your client ID is enabled.

By following these steps, you have set up the necessary configurations in the Google Developer Console to enable Google OAuth for your application. This allows your app to authenticate users using their Google accounts.

### Add OAuth ID and Secret to Rails Credentials

#### Edit the Credentials

```bash
  EDITOR=nano rails credentials:edit
```

Note: if the previous step fails, you may need to delete `config/credentials.yml.enc` and `config/master.key`.

The credentials file will open in the editor.

Add your Google OAuth credentials to the file in the following format. Make sure to maintain the correct indentation and spacing as shown. There should be 2 spaces before `client_id` and `client_secret`, and a space after the colon:

```yaml
google:
  client_id: your_client_id
  client_secret: your_client_secret
```

_Note: Replace `your_client_id` and `your_client_secret` with your own Google OAuth credentials. Do not include any quotes around the actual credentials._

After adding your credentials, save the changes and exit the editor.

Now, your Google OAuth credentials are securely stored in the Rails credentials file and your application will be able to use them for authentication. Make sure to keep your credentials safe and secret.

## Local Database

```
sudo apt install postgresql
sudo service postgresql start
sudo -u postgres -i
psql
CREATE USER yourusername SUPERUSER;
ALTER ROLE "yourusername" WITH LOGIN;
exit # exit postgresql terminal
exit # exit bash terminal for user postgres
rake db:create # This will fail if you haven't set up credentials
bin/rails db:migrate
bin/rails db:seed
```

OPTIONAL: To read in the corp of cadet's current database, put the `Overhead - Master Cadet Roster.csv` file in `lib/assets/corpsRoster.csv` and run

```
rails runner lib/ingest_roster_file.rb
```


## Admin Account

To set an admin as a developer:

1. Access database:

```
heroku login
heroku pg:psql cadet-activity-management
```

2. Set admin_flag of desired user to true

```
UPDATE users SET admin_flag=true WHERE id=<user-id>;
```

To set an admin from an admin account:

1. Click "Admin" tab once logged-in to an admin account
2. Select eye icon next to desired user
3. Click "Edit"
4. Check "Make Admin"
5. Click "Update"

## Routine

```
git pull && bundle install && npm install && rails db:migrate
rails cucumber
rspec
rubocop
rails server
```

## Official Development Links

Currently Deployed to Heroku. <br>
[Heroku Dashboard](https://dashboard.heroku.com/apps/cadet-activity-management) - https://dashboard.heroku.com/apps/cadet-activity-management <br>
[Heroku App](https://cadet-activity-management-7ed1c42c26df.herokuapp.com/) - https://cadet-activity-management-7ed1c42c26df.herokuapp.com/ <br>
[Code Climate](https://codeclimate.com/github/jwonnyleaf/Cadet-Activity-Management) - https://codeclimate.com/github/jwonnyleaf/Cadet-Activity-Management

## First Time Deployment

To deploy the app, please follow the steps below...

1. Visit [Heroku](https://dashboard.heroku.com/apps) and create a new app
2. Visit the Resources tab of your newly created app and install the Heroku Postgres add-on.
3. Visit the Settings tab of your app and...

- Add `heroku/nodejs` buildpack
- Add `heroku/ruby` buildpack

4. Set Rails Master Key to the previously generated master.key [here](#edit-the-credentials)
   - `heroku config:set RAILS_MASTER_KEY=<key>`
5. Push the branch to Heroku to be deployed via `git push heroku <yourbranch>:master`

## Heroku Information/Setup

Install Heroku CLI https://devcenter.heroku.com/articles/heroku-cli

```
heroku login
heroku git:remote -a cadet-activity-management
```

### Heroku Commands

- Logs: `heroku logs --app cadet-activity-management`

- Deploy: `git push heroku <yourbranch>:master`
  - Auto-deploy is enabled for 'main' branch.
- Run a command on a one-off dyno: `heroku run bash --type=worker`

## JavaScript & CSS Information

- https://stackoverflow.com/questions/36602764/how-to-use-npm-packages-in-rails

# Contact Information

If you have inquiries or concerns, please reach out to the project maintainers (as of 2024):

- Johnny Le jwonnyleaf@tamu.edu
- Evan Korhn evanpk@tamu.edu
- Alan Cho alanchao8669@tamu.edu
- Nathan Skouby nathanskouby@tamu.edu
- Manas Sahu manas.sahu@tamu.edu
- Dev Garg dev.garg@tamu.edu
