# Get-hub - Django CMS Platform

A complete Django-based Content Management System with admin dashboard, blog, portfolio, services, and more.

## Overview

Get-hub is a full-featured CMS built with Django for managing business websites. It includes:

- Custom admin dashboard with analytics
- Blog system with categories and rich text editor
- Project portfolio management
- Services showcase
- Contact forms and inquiry management
- Dynamic page builder
- Newsletter and marketing tools
- SEO optimization features
- User authentication and profiles
- Menu and navigation management

## Technology Stack

**Backend:**
- Python 3.11+
- Django 4.2+
- PostgreSQL 15
- Gunicorn (WSGI server)

**Frontend:**
- HTML5, CSS3, JavaScript
- Bootstrap-based dashboard theme
- CKEditor for rich text
- Responsive design

**DevOps:**
- Docker & Docker Compose
- Nginx reverse proxy
- WhiteNoise for static files

**Key Libraries:**
- django-ckeditor - Rich text editing
- Pillow - Image processing
- psycopg2-binary - PostgreSQL adapter
- whitenoise - Static file serving
- Twilio - SMS integration (optional)
- PyJWT - JWT authentication

## Quick Start

### Local Development

```bash
# 1. Create virtual environment
python3 -m venv venv
source venv/bin/activate

# 2. Install dependencies
pip install -r requirements/local.txt

# 3. Copy environment file
cp .env.example .env

# 4. Run migrations
python manage.py migrate

# 5. Create superuser
python manage.py createsuperuser

# 6. Run server
python manage.py runserver
```

Visit http://localhost:8000

### Production Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete deployment instructions.

## Project Structure

```
Get-hub/
├── apps/                      # Django applications
│   ├── about/                # About page app
│   ├── accounts/             # User auth & profiles
│   ├── adminapp/             # Admin dashboard
│   ├── analytics/            # Analytics tracking
│   ├── blog/                 # Blog system
│   ├── contact/              # Contact forms
│   ├── custompage/           # Dynamic pages
│   ├── home/                 # Homepage
│   ├── legal/                # Legal pages
│   ├── marketing/            # Marketing tools
│   ├── menus/                # Menu management
│   ├── pricing/              # Pricing plans
│   ├── project/              # Portfolio
│   ├── service/              # Services
│   └── settings/             # Site settings
├── core/                      # Django project settings
│   ├── settings.py           # Main settings
│   ├── urls.py               # URL configuration
│   ├── wsgi.py               # WSGI config
│   ├── context_processors.py # Template context
│   └── middleware/           # Custom middleware
├── static/                    # Static files (CSS, JS, images)
│   └── dashboard/            # Admin dashboard assets
├── templates/                 # HTML templates
│   ├── dashboard/            # Admin templates
│   └── authenticate/         # Auth templates
├── media/                     # User uploads
├── requirements/              # Python dependencies
│   ├── base.txt
│   ├── local.txt
│   └── live.txt
├── nginx/                     # Nginx configuration
├── Dockerfile                 # Docker build
├── docker-compose.yml         # Docker orchestration
├── manage.py                  # Django management
└── .env                       # Environment variables
```

## Features

### Admin Dashboard
- Modern, responsive interface
- Analytics and statistics
- Content management
- User management
- Settings configuration

### Blog System
- Create and manage blog posts
- Categories and tags
- Rich text editor (CKEditor)
- Featured images
- SEO optimization
- Draft and publish workflow

### Project Portfolio
- Showcase projects
- Project categories
- Image galleries
- Client information
- Project details and descriptions

### Services Management
- Service listings
- Service categories
- Detailed descriptions
- Pricing information
- Call-to-action buttons

### Contact System
- Contact forms
- Inquiry management
- Email notifications
- Form validation
- Admin moderation

### Custom Pages
- Dynamic page creation
- Custom URLs
- Rich content editing
- Template selection
- SEO settings per page

### User Management
- User registration
- Login/logout
- Password reset
- Profile management
- Role-based access

### Marketing Tools
- Newsletter subscription
- Email campaigns
- Subscriber management
- Marketing analytics

### SEO Features
- XML sitemap generation
- Meta tags management
- OpenGraph tags
- Structured data
- SEO-friendly URLs

## Environment Configuration

Create `.env` file with these settings:

```env
# Core
DEBUG=False
ALLOWED_HOSTS=your-domain.com
TIME_ZONE=UTC
DEMO_MODE=False
WHITENOISE_CONFIG=True

# Database (PostgreSQL)
POSTGRE_DB=True
MYSQL_DB=False
DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_HOST=localhost
DB_PORT=5432

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@example.com
EMAIL_HOST_PASSWORD=your-password

# Media
MEDIA_ROOT=media
```

## Admin Access

### Django Admin
URL: `/secure-admin-portal/`
- Full Django admin interface
- Model management
- User administration

### Custom Dashboard
URL: `/dashboard/`
- User-friendly CMS interface
- Content management
- Analytics and reporting

## Database Support

The project supports multiple databases:

- **PostgreSQL** (Recommended for production)
- **MySQL** (Alternative)
- **SQLite** (Development only)

Configure in `.env`:
```env
POSTGRE_DB=True  # or MYSQL_DB=True, or both False for SQLite
```

## Static Files

Static files are handled by:
- **Development**: Django's staticfiles app
- **Production**: WhiteNoise (when WHITENOISE_CONFIG=True)

Collect static files:
```bash
python manage.py collectstatic
```

## Media Files

User uploads are stored in the `media/` directory. Configure path in `.env`:
```env
MEDIA_ROOT=media
```

## API Endpoints

The application includes custom URL patterns for:
- `/` - Homepage
- `/about/` - About page
- `/services/` - Services listing
- `/projects/` - Project portfolio
- `/blog/` - Blog listing
- `/contact/` - Contact page
- `/dashboard/` - Admin dashboard
- `/secure-admin-portal/` - Django admin

## Development

### Creating New Apps

```bash
# Create app in apps/ directory
python manage.py startapp newapp apps/newapp

# Add to INSTALLED_APPS in core/settings.py
INSTALLED_APPS = [
    # ...
    'apps.newapp',
]

# Create URLs in newapp/urls.py
# Include in core/urls.py
path('', include('apps.newapp.urls')),
```

### Database Migrations

```bash
# Create migrations
python manage.py makemigrations

# View migration SQL
python manage.py sqlmigrate appname 0001

# Apply migrations
python manage.py migrate

# Show migration status
python manage.py showmigrations
```

### Testing

```bash
# Run all tests
python manage.py test

# Run specific app tests
python manage.py test apps.blog

# Run with coverage
coverage run --source='.' manage.py test
coverage report
```

## Production Checklist

- [ ] Set DEBUG=False
- [ ] Configure ALLOWED_HOSTS
- [ ] Use strong SECRET_KEY
- [ ] Set up PostgreSQL database
- [ ] Configure email settings
- [ ] Collect static files
- [ ] Set up Nginx/Apache
- [ ] Configure SSL certificate
- [ ] Set up automated backups
- [ ] Configure logging
- [ ] Set up monitoring
- [ ] Enable CSRF protection
- [ ] Configure CORS if needed
- [ ] Set up error tracking (Sentry)
- [ ] Configure CDN for static files (optional)

## Maintenance

### Backup Database

```bash
# PostgreSQL
pg_dump -U username dbname > backup.sql

# With Docker
docker exec container_name pg_dump -U username dbname > backup.sql
```

### Update Dependencies

```bash
# Check outdated packages
pip list --outdated

# Update requirements
pip install --upgrade -r requirements/live.txt

# Freeze new versions
pip freeze > requirements/live.txt
```

### Clear Cache

```bash
# Clear Django cache
python manage.py clear_cache

# Clear sessions
python manage.py clearsessions
```

## Troubleshooting

### Common Issues

**Static files not loading**
```bash
python manage.py collectstatic --clear
```

**Database connection error**
- Check PostgreSQL is running
- Verify credentials in .env
- Check DB_HOST and DB_PORT

**Import errors**
```bash
# Reinstall dependencies
pip install -r requirements/live.txt
```

**Migration conflicts**
```bash
# Reset migrations (development only!)
python manage.py migrate appname zero
python manage.py migrate
```

## Security

- Uses Django's built-in security features
- CSRF protection enabled
- XSS protection
- SQL injection prevention
- Password hashing with PBKDF2
- Session security
- Secure cookie settings in production

## Performance

- Database query optimization
- Static file caching
- Gzip compression (Nginx)
- Database connection pooling
- Lazy loading of images
- Minified CSS/JS in production

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

[Add your license information]

## Support

For deployment help, see [DEPLOYMENT.md](DEPLOYMENT.md)

For server setup scripts:
- `verify_production_setup.sh` - Verify server setup
- `setup_production.sh` - Set up production environment
- `cleanup_old_projects.sh` - Clean old projects

## Credits

Built with Django and modern web technologies.
