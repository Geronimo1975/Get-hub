# Get-hub Django CMS Deployment Guide

Complete Django CMS/Business Website with Dashboard, Blog, Projects, Services, and more.

## Project Overview

This is a full-featured Django CMS application with:

### Features
- **User Authentication** - Login, registration, password reset
- **Admin Dashboard** - Custom admin interface with analytics
- **Blog System** - Full blog with categories, posts, and CKEditor
- **Services Management** - Service listings and details
- **Project Portfolio** - Project showcase
- **Contact System** - Contact forms and inquiries
- **Custom Pages** - Dynamic page creation
- **Marketing Tools** - Newsletter, subscribers
- **Legal Pages** - Terms, privacy policy, etc.
- **Menu Management** - Dynamic menu system
- **SEO Features** - Sitemap, meta tags, SEO settings
- **Analytics Integration** - Built-in analytics

### Apps Structure
```
apps/
├── about/          - About page management
├── accounts/       - User authentication & profiles
├── adminapp/       - Custom admin dashboard
├── analytics/      - Analytics tracking
├── blog/           - Blog with categories
├── contact/        - Contact forms
├── custompage/     - Dynamic custom pages
├── home/           - Homepage management
├── legal/          - Legal pages (terms, privacy)
├── marketing/      - Newsletter & marketing
├── menus/          - Menu management
├── pricing/        - Pricing plans
├── project/        - Project portfolio
├── service/        - Services management
└── settings/       - Site-wide settings
```

## Prerequisites

- Docker and Docker Compose
- SSH access to server (already configured)
- PostgreSQL database (already running on server)

## Quick Start - Local Development

### 1. Install Dependencies

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install packages
pip install -r requirements/local.txt
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env for local development
nano .env
```

Local development `.env`:
```env
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
TIME_ZONE=UTC
DEMO_MODE=False
WHITENOISE_CONFIG=False

# Use SQLite for local development
POSTGRE_DB=False
MYSQL_DB=False

# Email (optional for local)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=test@example.com
EMAIL_HOST_PASSWORD=password

MEDIA_ROOT=media
```

### 3. Run Migrations

```bash
python manage.py migrate
```

### 4. Create Superuser

```bash
python manage.py createsuperuser
```

### 5. Load Initial Data (Optional)

```bash
# If you have the data.sql file
python manage.py dbshell < data.sql
```

### 6. Run Development Server

```bash
python manage.py runserver
```

Access:
- Frontend: http://localhost:8000
- Admin Dashboard: http://localhost:8000/dashboard/
- Django Admin: http://localhost:8000/secure-admin-portal/

## Production Deployment on Server

### Method 1: Docker Compose (Recommended)

#### 1. Upload Project to Server

```bash
# From your local machine
scp -r /Users/sudo_ai/Get-hub n8n:~/
```

Or use git:
```bash
# On server
cd ~
git clone <your-repo-url> Get-hub
cd Get-hub
```

#### 2. Configure Production Environment

```bash
# On server
cd ~/Get-hub
cp .env.production .env

# Edit production settings
nano .env
```

Update these values:
```env
DEBUG=False
ALLOWED_HOSTS=80.134.74.61,your-domain.com
DB_PASSWORD=your_secure_password
EMAIL_HOST_USER=your-real-email@example.com
EMAIL_HOST_PASSWORD=your-email-password
```

#### 3. Build and Run with Docker Compose

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# Check logs
docker-compose logs -f web
```

#### 4. Access Application

- Frontend: http://80.134.74.61
- Admin Dashboard: http://80.134.74.61/dashboard/
- Django Admin: http://80.134.74.61/secure-admin-portal/

Default superuser (created by entrypoint.sh):
- Username: `admin`
- Password: `admin123`
- **IMPORTANT**: Change this immediately after first login!

### Method 2: Manual Deployment (Without Docker)

#### 1. Set Up Python Environment

```bash
# On server
cd ~/Get-hub
python3 -m venv venv
source venv/bin/activate
pip install -r requirements/live.txt
```

#### 2. Configure for Production

```bash
cp .env.production .env
nano .env
```

#### 3. Database Setup

The PostgreSQL database is already running. Configure `.env`:
```env
POSTGRE_DB=True
DB_NAME=django_dev
DB_USER=django_user
DB_PASSWORD=django_pass
DB_HOST=localhost
DB_PORT=5432
```

#### 4. Collect Static Files

```bash
python manage.py collectstatic --noinput
```

#### 5. Run Migrations

```bash
python manage.py migrate
```

#### 6. Create Superuser

```bash
python manage.py createsuperuser
```

#### 7. Run with Gunicorn

```bash
gunicorn core.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 3 \
    --timeout 120 \
    --daemon \
    --access-logfile access.log \
    --error-logfile error.log
```

## Nginx Configuration

If using existing nginx container, update configuration:

```nginx
server {
    listen 80;
    server_name 80.134.74.61;

    location /static/ {
        alias /home/n8n/Get-hub/assets/;
    }

    location /media/ {
        alias /home/n8n/Get-hub/media/;
    }

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## Database Management

### Backup Database

```bash
# Using docker
docker exec gethub_postgres pg_dump -U django_user django_dev > backup.sql

# Or directly
pg_dump -U django_user -h localhost django_dev > backup.sql
```

### Restore Database

```bash
# Using docker
cat backup.sql | docker exec -i gethub_postgres psql -U django_user django_dev

# Or directly
psql -U django_user -h localhost django_dev < backup.sql
```

### Import Initial Data

```bash
# If using the provided data.sql
python manage.py dbshell < data.sql
```

## Common Django Commands

```bash
# Make migrations
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Collect static files
python manage.py collectstatic

# Run development server
python manage.py runserver

# Django shell
python manage.py shell

# Database shell
python manage.py dbshell

# Clear sessions
python manage.py clearsessions

# Check for issues
python manage.py check
```

## Application Management

### Admin Dashboard Access

1. Go to `http://your-server/dashboard/`
2. Login with your superuser credentials
3. Access all CMS features

### Managing Content

**Blog Posts**
- Dashboard → Blog → Create Post
- Supports categories, tags, featured images
- Rich text editor (CKEditor)

**Services**
- Dashboard → Services → Add Service
- Service listings with descriptions

**Projects**
- Dashboard → Projects → Add Project
- Portfolio showcase

**Custom Pages**
- Dashboard → Pages → Create Page
- Dynamic page creation with custom URLs

**Settings**
- Dashboard → Settings
- Site title, logo, SEO, social links

## Monitoring

### View Logs

```bash
# Docker logs
docker-compose logs -f web
docker-compose logs -f nginx

# Application logs (if running manually)
tail -f error.log
tail -f access.log
```

### Check Container Status

```bash
docker-compose ps
```

### Restart Services

```bash
# Restart web application
docker-compose restart web

# Restart all services
docker-compose restart

# Stop and start
docker-compose down
docker-compose up -d
```

## Troubleshooting

### Static Files Not Loading

```bash
# Collect static files
python manage.py collectstatic --noinput

# Check STATIC_ROOT in settings
# Check nginx configuration for /static/ location
```

### Database Connection Error

```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Test connection
docker exec gethub_postgres psql -U django_user -d django_dev -c "SELECT 1;"

# Check .env DATABASE settings
```

### Permission Errors

```bash
# Fix media directory permissions
chmod -R 755 media/
chown -R n8n:n8n media/

# Fix static directory permissions
chmod -R 755 assets/
chown -R n8n:n8n assets/
```

### Application Won't Start

```bash
# Check logs
docker-compose logs web

# Verify environment variables
docker-compose config

# Check migrations
python manage.py showmigrations

# Try running migrations
python manage.py migrate
```

## Security Checklist

- [ ] Change default admin password
- [ ] Set DEBUG=False in production
- [ ] Use strong SECRET_KEY
- [ ] Configure ALLOWED_HOSTS properly
- [ ] Use HTTPS (SSL certificate)
- [ ] Set up firewall rules
- [ ] Regular database backups
- [ ] Keep dependencies updated
- [ ] Use environment variables for secrets
- [ ] Enable CSRF protection
- [ ] Configure proper file upload limits

## Updating the Application

```bash
# Pull latest code
cd ~/Get-hub
git pull

# Rebuild Docker images
docker-compose build

# Apply migrations
docker-compose run web python manage.py migrate

# Collect static files
docker-compose run web python manage.py collectstatic --noinput

# Restart services
docker-compose restart
```

## Performance Optimization

### Enable Redis Caching (Optional)

Add to `docker-compose.yml`:
```yaml
  redis:
    image: redis:alpine
    container_name: gethub_redis
    networks:
      - gethub_network
```

Configure in Django settings:
```python
CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.redis.RedisCache",
        "LOCATION": "redis://redis:6379",
    }
}
```

### Database Optimization

```bash
# Run ANALYZE on PostgreSQL
docker exec gethub_postgres psql -U django_user -d django_dev -c "ANALYZE;"

# Check for missing indexes
python manage.py inspectdb
```

## Support

For issues:
1. Check logs: `docker-compose logs -f`
2. Verify environment: `docker-compose config`
3. Check database: `docker exec gethub_postgres pg_isready`
4. Review Django settings: `python manage.py check`

## Next Steps

1. ✅ Set up production environment
2. ✅ Configure database
3. ✅ Deploy application
4. Change admin password
5. Configure email settings
6. Set up SSL certificate
7. Configure domain name
8. Set up automated backups
9. Configure monitoring
10. Add your content

## Project Structure Reference

```
Get-hub/
├── apps/                   # Django applications
├── core/                   # Project settings
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── static/                 # Static files (CSS, JS)
├── templates/             # HTML templates
├── media/                 # User uploads
├── requirements/          # Python dependencies
├── nginx/                 # Nginx configuration
├── Dockerfile             # Docker build file
├── docker-compose.yml     # Docker orchestration
├── entrypoint.sh          # Container startup script
├── manage.py              # Django management
└── .env                   # Environment variables
```
