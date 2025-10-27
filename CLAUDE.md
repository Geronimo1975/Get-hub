# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Get-hub is a full-featured Django CMS (Content Management System) for business websites with an admin dashboard, blog, portfolio, services, and more. Built with Django 4.2+, PostgreSQL, and designed for Docker deployment.

## Technology Stack

- **Backend**: Python 3.11+, Django 4.2+
- **Database**: PostgreSQL 15 (production), SQLite (development)
- **Frontend**: HTML5, CSS3, JavaScript, Bootstrap
- **Deployment**: Docker, Docker Compose, Nginx, Gunicorn
- **Rich Text**: CKEditor
- **Static Files**: WhiteNoise (production)

## Project Structure

```
Get-hub/
├── apps/                   # Django applications (modular apps)
│   ├── accounts/          # User authentication & profiles
│   ├── adminapp/          # Custom admin dashboard
│   ├── blog/              # Blog with categories
│   ├── project/           # Portfolio showcase
│   ├── service/           # Services management
│   ├── contact/           # Contact forms
│   └── [11 other apps]    # See PROJECT_README.md
├── core/                   # Django project settings
│   ├── settings.py        # Main configuration
│   ├── urls.py            # URL routing
│   └── middleware/        # Custom middleware
├── static/                 # Static assets (CSS, JS, images)
├── templates/             # HTML templates
├── media/                 # User uploads
├── requirements/          # Python dependencies
├── nginx/                 # Nginx configuration
├── Install/               # Original project (reference only)
└── docker-compose.yml     # Docker configuration
```

### Install Directory
The `Install/` directory contains the original project setup with MySQL configuration and sample data (`data.sql`). This is kept for reference only - the current deployed project uses PostgreSQL and Docker.

## Key Commands

### Development

```bash
# Setup virtual environment
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements/local.txt  # Development (includes base.txt)
pip install -r requirements/live.txt   # Production (includes base.txt)

# Database
python manage.py migrate              # Run migrations
python manage.py makemigrations       # Create migrations
python manage.py createsuperuser      # Create admin user

# Run development server
python manage.py runserver

# Static files
python manage.py collectstatic        # Collect static files

# Database shell
python manage.py dbshell              # SQL shell
python manage.py shell                # Python shell
```

### Docker Deployment

```bash
# Build and start
docker-compose build
docker-compose up -d

# Logs
docker-compose logs -f web

# Stop
docker-compose down

# Restart specific service
docker-compose restart web

# Execute Django commands in container
docker-compose exec web python manage.py [command]
```

**Important**: The docker-compose setup uses an external network `pg-admin_default` to connect to the existing PostgreSQL container. The entrypoint script automatically runs migrations and collects static files on startup.

### Deployment to Server

```bash
# Quick deploy
./deploy_to_server.sh

# Manual steps
scp -r . n8n:~/Get-hub/
ssh n8n "cd Get-hub && docker-compose up -d"

# Health check (server must be running)
ssh n8n "curl -s -o /dev/null -w '%{http_code}' http://localhost:8001/ 2>&1"
```

## Architecture Overview

### Django Apps Structure
Each app in `apps/` is self-contained with its own:
- `models.py` - Database models
- `views.py` - View logic
- `urls.py` - URL patterns
- `admin.py` - Admin interface
- `templates/` - App-specific templates

### Settings Configuration
- Uses `.env` file for environment variables
- Supports PostgreSQL, MySQL, and SQLite
- `DEBUG` mode toggle
- `WHITENOISE_CONFIG` for static files in production
- Conditional middleware loading

### URL Routing
- Main URLs in `core/urls.py`
- Admin dashboard: `/dashboard/` (redirects to apps.adminapp)
- Django admin: `/secure-admin-portal/` (NOT `/admin/` - security measure)
- All apps included via `include('apps.appname.urls')`
- Sitemap auto-generated at `/sitemap.xml`
- Custom 404 handler: `apps.accounts.views.error_404`
- Custom 500 handler: `apps.adminapp.views.error_500`

### Database Support
Configure via `.env`:
```env
POSTGRE_DB=True    # Use PostgreSQL
MYSQL_DB=True      # Use MySQL
# Both False = SQLite
```

### Static Files Handling
- Development: Django's staticfiles app
- Production: WhiteNoise (when `WHITENOISE_CONFIG=True`)
- Static files collected to `assets/`
- Media files uploaded to `media/`

### Custom Features
- **Custom context processors** in `core/context_processors.py`:
  - `website_settings_context` - Site settings
  - `seo_settings_context` - SEO metadata
  - `header_footer_context` - Header/footer data
  - `menu_data` - Navigation menus
  - `user_profile_context` - User profiles
  - `service_context` - Services data
  - `project_context` - Projects data
  - `subscriber_form_title_context` - Newsletter forms
  - `demo_mode_enabled` - Demo mode flag
- Demo mode middleware (optional, enabled via `.env`)
- Custom user model: `apps.accounts.User`
- SEO sitemap generation
- Analytics integration via `apps.analytics`

## Common Development Tasks

### Adding New App
```bash
# Create app in apps/ directory
python manage.py startapp newapp apps/newapp

# Add to INSTALLED_APPS in core/settings.py:58
INSTALLED_APPS = [
    # ...
    'apps.newapp',
]

# Create urls.py in apps/newapp/
# Include in core/urls.py:
urlpatterns = [
    # ...
    path('', include('apps.newapp.urls')),
]
```

### Database Changes
```bash
# After modifying models.py
python manage.py makemigrations
python manage.py migrate

# Check migration status
python manage.py showmigrations

# For Docker deployment, migrations run automatically on container start
```

### Working with Templates
- Base templates in `templates/`
- App-specific templates in `apps/appname/templates/`
- Dashboard templates in `templates/dashboard/`
- Authentication templates in `templates/authenticate/`
- Use `{% extends "base.html" %}` pattern
- Context processors automatically inject data into all templates

### Static Files
- Development: Files served from `static/` directories
- Production: Run `collectstatic`, served by WhiteNoise/Nginx
- Dashboard assets in `static/dashboard/assets/`
- Collected to `assets/` directory (STATIC_ROOT)

## Important Files

### Configuration
- `.env` - Environment variables (not committed)
- `.env.example` - Template for environment file
- `.env.production` - Production environment template
- `core/settings.py` - Django settings

### Deployment
- `Dockerfile` - Docker image definition (Python 3.11-slim base)
- `docker-compose.yml` - Multi-container orchestration (web + nginx)
- `entrypoint.sh` - Container startup script (auto-runs migrations, collectstatic, then starts Gunicorn)
- `nginx/get-hub.conf` - Nginx reverse proxy configuration
- `deploy_to_server.sh` - Automated deployment script

### Documentation
- `DEPLOYMENT.md` - Complete deployment guide
- `PROJECT_README.md` - Project overview and features
- `README.md` - Server setup scripts documentation

### Requirements
- `requirements/base.txt` - Core dependencies for all environments
- `requirements/local.txt` - Development dependencies (includes base.txt)
- `requirements/live.txt` - Production dependencies (includes base.txt)

### Database
- `data.sql` - Initial database dump (optional, located in Install/ directory)

## Environment Variables

Key variables in `.env`:

```env
DEBUG=False                          # Debug mode
ALLOWED_HOSTS=domain.com            # Allowed hosts
TIME_ZONE=UTC                       # Timezone
DEMO_MODE=False                     # Demo mode toggle
WHITENOISE_CONFIG=True              # Static file serving

# Database
POSTGRE_DB=True                     # Use PostgreSQL
DB_NAME=django_dev
DB_USER=django_user
DB_PASSWORD=secure_password
DB_HOST=postgres_db                 # Container name in Docker
DB_PORT=5432

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=email@example.com
EMAIL_HOST_PASSWORD=password

# Media
MEDIA_ROOT=media
```

## Security Considerations

- SECRET_KEY should be changed for production
- DEBUG must be False in production
- Use strong database passwords
- Configure ALLOWED_HOSTS properly
- CSRF protection enabled by default
- Secure admin URL (`/secure-admin-portal/` not `/admin/`)
- Change default superuser password immediately

## Testing

```bash
# Run all tests
python manage.py test

# Run specific app tests
python manage.py test apps.blog

# Check for issues
python manage.py check
```

## Troubleshooting

### Common Issues

**Static files not loading:**
```bash
python manage.py collectstatic --clear
# Check STATIC_ROOT and STATIC_URL in settings
```

**Database connection errors:**
- Verify PostgreSQL is running
- Check credentials in `.env`
- Ensure `DB_HOST` matches container name in Docker

**Migration conflicts:**
```bash
python manage.py showmigrations
python manage.py migrate --fake appname 0001
```

**Import errors:**
- Check virtual environment is activated
- Reinstall requirements: `pip install -r requirements/local.txt`

## Docker Network Architecture

The project uses an **external network** called `pg-admin_default` to connect to the existing PostgreSQL container on the server:

```yaml
networks:
  pg-admin_default:
    external: true
```

This means:
- The web container connects to the existing `postgres_db` container
- PostgreSQL must be running before starting this application
- DB_HOST in `.env` should be `postgres_db` (container name) when using Docker
- DB_HOST should be `localhost` when running outside Docker

## Entrypoint Script Behavior

When the Docker container starts (`entrypoint.sh`):
1. Waits 5 seconds for PostgreSQL to be ready
2. Runs `python manage.py migrate --noinput` (auto-applies database migrations)
3. Runs `python manage.py collectstatic --noinput` (collects static files)
4. Starts Gunicorn with 3 workers on port 8000

**Important**: This means migrations are automatically applied on every container restart. Be careful with destructive migrations in production.

## Helpful Scripts

- `deploy_to_server.sh` - Deploy project to server
- `verify_production_setup.sh` - Verify server setup
- `setup_production.sh` - Set up production environment
- `cleanup_old_projects.sh` - Clean old projects on server

## Server Connection

SSH configured with key-based auth:
```bash
ssh n8n  # Connects to n8n@80.134.74.61
```

## Services on Server

- PostgreSQL: port 5432
- pgAdmin: port 8080
- Portainer: port 9443
- n8n: port 5678
- Get-hub (when deployed): port 80/8000

## Important Notes

- **Custom user model**: `apps.accounts.User` - standard Django authentication but with custom model
- **Two admin interfaces**: Custom dashboard at `/dashboard/` and Django admin at `/secure-admin-portal/`
- **Rich text editing**: CKEditor integrated for blog posts and custom pages
- **Automatic sitemap**: Generated at `/sitemap.xml` via `core.sitemaps.generate_sitemap`
- **Custom error pages**: 404 handler in `apps.accounts.views`, 500 handler in `apps.adminapp.views`
- **Static files**: WhiteNoise serves in production (when `WHITENOISE_CONFIG=True`)
- **WSGI server**: Gunicorn with 3 workers, 120s timeout
- **Context processors**: Templates have access to site settings, SEO data, menus, services, projects automatically
- **Demo mode**: Optional middleware that can be enabled for demonstrations

## Current Deployment Status

**Deployed to:** n8n server (80.134.74.61)
**Status:** ✅ Live and running
**Port:** 8001
**Container:** gethub_web

**Access URLs:**
- Homepage: http://80.134.74.61:8001/
- Dashboard: http://80.134.74.61:8001/dashboard/
- Django Admin: http://80.134.74.61:8001/secure-admin-portal/

**Login Credentials:**
- Username: `admin`
- Password: `admin123`
- ⚠️ CHANGE PASSWORD IMMEDIATELY

**Database:**
- Type: PostgreSQL 15
- Container: postgres_db (existing, shared)
- Database: database
- User: george.cucuiet

**Quick Commands:**
```bash
# View logs
ssh n8n "cd ~/Get-hub && docker-compose logs -f web"

# Restart
ssh n8n "cd ~/Get-hub && docker-compose restart web"

# Shell access
ssh n8n "cd ~/Get-hub && docker-compose exec web python manage.py shell"

# Create superuser
ssh n8n "cd ~/Get-hub && docker-compose exec web python manage.py createsuperuser"
```
