# TCG Agency - Complete Project Structure Guide

## Overview

This is **TCG Agency v1.5** - A Django-based Creative Agency CMS with a custom dashboard. This document explains the complete project structure, the relationship between different directories, and how to work with the project.

## Product Information

- **Product Name**: TCG Agency
- **Version**: 1.5
- **Type**: Django Creative Agency with Custom Dashboard
- **Original Platform**: CodeCanyon (commercial product)
- **Technology**: Django 5.2.7, Python 3.11+, PostgreSQL/MySQL

## Directory Structure

```
Get-hub/
├── Documentation/              # HTML documentation (view in browser)
│   ├── index.html             # Documentation homepage
│   ├── docs-page.html         # Full documentation
│   └── assets/                # Documentation assets
│
├── How to update/             # Update instructions
│   └── index.html             # Step-by-step update guide
│
├── Install/                   # Clean installation files
│   ├── apps/                  # Django apps (original)
│   ├── core/                  # Core settings
│   ├── static/                # Frontend assets
│   ├── templates/             # HTML templates
│   ├── media/                 # Sample media files
│   ├── data.sql               # Sample database (MySQL)
│   ├── .env.example           # Environment template
│   └── requirements/          # Python dependencies
│
├── Update/                    # Update package (same as Install)
│   ├── apps/                  # Updated apps
│   ├── core/                  # Updated core
│   ├── static/                # Updated assets
│   ├── templates/             # Updated templates
│   └── ...                    # (Same structure as Install)
│
├── apps/                      # Active Django applications
│   ├── accounts/              # User authentication
│   ├── adminapp/              # Custom admin dashboard
│   ├── analytics/             # Analytics tracking
│   ├── blog/                  # Blog system
│   ├── contact/               # Contact forms
│   ├── custompage/            # Dynamic pages
│   ├── home/                  # Homepage
│   ├── legal/                 # Legal pages
│   ├── marketing/             # Marketing tools
│   ├── menus/                 # Menu management
│   ├── pricing/               # Pricing plans
│   ├── project/               # Portfolio
│   ├── service/               # Services
│   ├── settings/              # Site settings
│   └── about/                 # About page
│
├── core/                      # Django project core
│   ├── settings.py            # Main configuration
│   ├── urls.py                # URL routing
│   ├── wsgi.py                # WSGI config
│   └── middleware/            # Custom middleware
│
├── static/                    # Static assets
│   ├── dashboard/             # Admin dashboard assets
│   └── front/                 # Frontend assets
│
├── templates/                 # HTML templates
│   ├── dashboard/             # Admin templates
│   ├── front/                 # Frontend templates
│   ├── authenticate/          # Auth templates
│   ├── error/                 # Error pages
│   └── sitemap/               # Sitemap template
│
├── media/                     # User uploads
│
├── requirements/              # Python dependencies
│   ├── base.txt               # Base requirements
│   ├── local.txt              # Development
│   └── live.txt               # Production
│
├── nginx/                     # Nginx configuration
│   ├── nginx.conf             # Main nginx config
│   └── conf.d/                # Additional configs
│
├── Dockerfile                 # Docker image definition
├── docker-compose.yml         # Docker orchestration
├── entrypoint.sh             # Container startup script
├── manage.py                  # Django management
├── .env                       # Environment variables (active)
├── .env.production            # Production template
├── data.sql                   # Sample database
│
└── Documentation files:
    ├── CLAUDE.md              # AI assistant guide
    ├── PROJECT_README.md      # Project overview
    ├── DEPLOYMENT.md          # Deployment guide
    └── SETUP_COMPLETE.md      # Setup completion guide
```

## Understanding the Directories

### 1. Documentation/
Contains the official HTML documentation for TCG Agency. Open `index.html` in a browser to view:
- Installation guides
- Feature documentation
- Admin dashboard guide
- Front website overview
- Resources and credits

### 2. How to update/
Contains instructions for updating TCG Agency from one version to another. The process is:
1. Backup your `.env` and database
2. Upload and extract `Update.zip`
3. Run the update command: `python manage.py update`

### 3. Install/
The **original clean installation** of TCG Agency. This contains:
- Fresh Django apps without modifications
- Sample `data.sql` for MySQL
- `.env.example` template
- Complete static assets and templates

**Purpose**: Reference for fresh installations or comparing changes

### 4. Update/
The **update package** containing the latest version files. In this case:
- Update/ and Install/ are identical (both v1.5)
- Used when updating from older versions
- Contains the same structure as Install/

**Purpose**: Provides updated files when TCG Agency releases new versions

### 5. Root Directory (Current Active Project)
The **actual running Django project**. This is what's deployed and contains:
- All apps copied from Install/Update
- Modified `.env` for your specific setup
- Docker configuration for deployment
- Custom deployment scripts

## Relationship Between Directories

```
Install/          →    Reference (Clean v1.5)
   ↓
Update/           →    Latest Version Files (v1.5)
   ↓
Root Directory    →    Active Deployment (Modified for Docker/PostgreSQL)
```

### Key Differences:

| Directory | Purpose | Database | Deployment | Modified |
|-----------|---------|----------|------------|----------|
| **Install/** | Clean reference | MySQL (data.sql) | cPanel/Shared | No |
| **Update/** | Update package | MySQL | cPanel/Shared | No |
| **Root/** | Active project | PostgreSQL | Docker | Yes |

## Current Deployment Adaptations

The root directory has been adapted from the original Install/Update for Docker deployment:

### Changes Made:

1. **Database**: MySQL → PostgreSQL
   - Original: MySQL with `data.sql`
   - Current: PostgreSQL via Docker

2. **Deployment**: cPanel → Docker
   - Original: passenger_wsgi.py for shared hosting
   - Current: Gunicorn + Docker Compose

3. **Configuration Files Added**:
   - `Dockerfile` - Container image
   - `docker-compose.yml` - Orchestration
   - `entrypoint.sh` - Startup script
   - `nginx/` - Reverse proxy config

4. **Environment**:
   - Original `.env`: MySQL settings
   - Current `.env`: PostgreSQL settings

5. **Static Files**:
   - Original: Served by Apache/cPanel
   - Current: WhiteNoise + Nginx

## How to Use This Structure

### For Fresh Installation:
```bash
# Use Install/ directory
cp -r Install/* /path/to/project/
cd /path/to/project/
cp .env.example .env
# Edit .env
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### For Updating Existing Installation:
```bash
# Backup first!
cp .env .env.backup
mysqldump -u user -p database > backup.sql

# Extract Update.zip to project root
# Files from Update/ will overwrite existing files

# Run update command
python manage.py update
```

### For Docker Deployment (Current Setup):
```bash
# Already done - the current root directory
cd ~/Get-hub
docker-compose up -d
```

## Custom Management Commands

TCG Agency includes custom Django management commands:

### 1. Update Command
```bash
python manage.py update
```
**Purpose**: Updates the project to latest version
**Actions**:
- Runs makemigrations
- Runs migrate
- Collects static files

**Location**: `apps/adminapp/management/commands/update.py`

### 2. Deploy Command
```bash
python manage.py deploy
```
**Purpose**: Deployment tasks (check the file for details)

### 3. Clean Migrations
```bash
python manage.py cleanmigrations
```
**Purpose**: Clean migration files

## Version Information

- **Current Version**: 1.5
- **Product**: TCG Agency
- **Framework**: Django 5.2.7
- **Python**: 3.11+

## Documentation Resources

1. **HTML Documentation**: `Documentation/index.html`
2. **Update Guide**: `How to update/index.html`
3. **Installation**: See `Documentation/docs-page.html#section-2`
4. **Features**: See `Documentation/docs-page.html#section-3`
5. **Admin Guide**: See `Documentation/docs-page.html#section-4`

## Important Notes

1. **Install/ vs Update/**
   - Both contain the same files for v1.5
   - Install/ = clean installation
   - Update/ = files to replace when updating

2. **Root Directory**
   - This is your ACTIVE project
   - Contains modifications for Docker
   - Don't overwrite with Install/Update without backup!

3. **Sample Data**
   - `Install/data.sql` and `Update/data.sql` contain sample data
   - These are MySQL format (not PostgreSQL)
   - Current deployment uses empty database

4. **Documentation**
   - Open `Documentation/index.html` in browser
   - Contains complete feature documentation
   - Includes video tutorials

## Deployment Status

**Current Active Deployment**:
- Location: n8n server (80.134.74.61:8001)
- Database: PostgreSQL (existing postgres_db container)
- Container: gethub_web
- Status: ✅ Running
- Access: http://80.134.74.61:8001/

## For Future Updates

When TCG Agency releases v1.6 or later:

1. Download the new `Update.zip`
2. Backup your current setup
3. Extract Update.zip files
4. For Docker deployment, you'll need to:
   - Rebuild Docker image
   - Update database migrations
   - Restart containers

```bash
# Docker update process
docker-compose down
# Replace files from Update.zip
docker-compose build
docker-compose up -d
docker-compose exec web python manage.py update
```

## Support

- Original Product: [CodeCanyon](https://codecanyon.net/item/tcg-agency-django-agency-with-custom-dashboard/48260620)
- Documentation: `Documentation/index.html`
- Author: TheCodeGrammer
- Social: @thecodegrammer (Instagram, Facebook)

---

**Last Updated**: October 2025
**Deployment**: Docker with PostgreSQL
**Version**: 1.5
