# Production Server Setup Scripts

These scripts help you set up and maintain a professional production environment on your n8n server for Django backend development.

## Files Created

1. **verify_production_setup.sh** - Verifies current setup and checks all services
2. **setup_production.sh** - Sets up complete production environment
3. **cleanup_old_projects.sh** - Removes old projects and containers (preserves n8n)

## Current Server Status

Based on analysis, your server has:
- ✅ PostgreSQL running (container: postgres_db, port 5432)
- ✅ pgAdmin running (port 8080)
- ✅ Portainer running (port 9443)
- ✅ n8n running (port 5678)
- ⚠️ Multiple old/stopped projects: Cleosdeco, GTI-Europe, med-hr.com, odoo, qdrant

## Quick Start

### Step 1: Upload Scripts to Server

```bash
# From your local machine
scp verify_production_setup.sh n8n:~/
scp setup_production.sh n8n:~/
scp cleanup_old_projects.sh n8n:~/
```

### Step 2: Make Scripts Executable

```bash
# On the server
ssh n8n
chmod +x verify_production_setup.sh setup_production.sh cleanup_old_projects.sh
```

### Step 3: Run Verification

```bash
# Check current setup
./verify_production_setup.sh
```

This will show you:
- Docker and Docker Compose status
- PostgreSQL status and databases
- pgAdmin access information
- Portainer access information
- Python/Django environment
- System resources
- Stopped containers

### Step 4: Clean Up Old Projects (Optional but Recommended)

```bash
# CAUTION: This removes old projects (preserves n8n)
./cleanup_old_projects.sh
```

This will:
- Stop and remove containers from old projects
- Delete old project directories (Cleosdeco, GTI-Europe, med-hr.com, odoo, etc.)
- Clean up unused Docker networks and volumes
- **Preserve**: n8n, PostgreSQL, pgAdmin, Portainer

### Step 5: Set Up Production Environment

```bash
# Run the setup script
./setup_production.sh
```

This will:
- Create organized directory structure (`~/production/`)
- Set up PostgreSQL with Django database
- Configure pgAdmin
- Configure Portainer
- Set up Python virtual environment with Django
- Create Docker Compose configuration
- Create helpful aliases and scripts

## Production Directory Structure

After setup:

```
~/production/
├── django_projects/        # Your Django projects
│   ├── venv/              # Python virtual environment
│   ├── templates/         # Shared templates
│   └── static/            # Static files
├── databases/             # Database data and configs
│   ├── postgres_data/
│   ├── pgadmin_data/
│   └── django_db_credentials.txt
├── docker_configs/        # Docker Compose files
│   ├── docker-compose.yml
│   └── .env.example
├── backups/              # Database backups
├── scripts/              # Helper scripts
│   └── aliases.sh
└── logs/                 # Application logs
```

## Access URLs

After setup, access your services:

- **pgAdmin**: http://YOUR_SERVER_IP:8080
- **Portainer**: https://YOUR_SERVER_IP:9443
- **PostgreSQL**: YOUR_SERVER_IP:5432
- **n8n**: http://YOUR_SERVER_IP:5678

## Helpful Aliases

The setup script creates aliases in `~/production/scripts/aliases.sh`:

```bash
# Load aliases
source ~/production/scripts/aliases.sh

# Or add to .bashrc permanently
echo 'source ~/production/scripts/aliases.sh' >> ~/.bashrc
```

Available aliases:
- `prod-start` - Start all production services
- `prod-stop` - Stop all production services
- `prod-restart` - Restart all services
- `prod-logs` - View logs
- `prod-ps` - List running containers
- `django-activate` - Activate Django virtual environment
- `django-new` - Create new Django project
- `pg-shell` - Access PostgreSQL shell
- `pg-backup` - Backup all PostgreSQL databases
- `cleanup-docker` - Clean Docker system

## Creating a Django Project

```bash
# Activate virtual environment
cd ~/production/django_projects
source venv/bin/activate

# Create new project
django-admin startproject myproject
cd myproject

# Configure database in settings.py
# Use credentials from: ~/production/databases/django_db_credentials.txt

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Run development server
python manage.py runserver 0.0.0.0:8001
```

## Django Database Configuration

Your `settings.py` should include:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'django_dev',
        'USER': 'django_user',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',  # or 'postgres_db' if running in Docker
        'PORT': '5432',
    }
}
```

## Production Deployment with Docker

For production Django apps, create a `Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Run with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "myproject.wsgi:application"]
```

Add to `docker-compose.yml`:

```yaml
  django_app:
    build: ./django_projects/myproject
    container_name: django_app
    restart: unless-stopped
    environment:
      - DATABASE_URL=postgresql://django_user:django_pass@postgres_db:5432/django_dev
    ports:
      - "8001:8000"
    networks:
      - production_network
    depends_on:
      - postgres
```

## Backup and Maintenance

### Backup PostgreSQL

```bash
# Full backup
pg-backup

# Or manually
docker exec postgres_db pg_dumpall -U postgres > backup_$(date +%Y%m%d).sql
```

### Restore PostgreSQL

```bash
cat backup_20251012.sql | docker exec -i postgres_db psql -U postgres
```

### Monitor Resources

```bash
# Check disk space
df -h

# Check memory
free -h

# Check Docker stats
docker stats

# View container logs
docker logs -f container_name
```

## Security Recommendations

1. **Change default passwords** for PostgreSQL, pgAdmin
2. **Use strong passwords** for production databases
3. **Set up firewall** rules (ufw)
4. **Use SSL/TLS** for web services (certbot for Let's Encrypt)
5. **Regular backups** to external storage
6. **Keep Docker images updated**
7. **Use environment variables** for sensitive data (never commit to git)

## Troubleshooting

### Container won't start
```bash
docker logs container_name
docker-compose logs -f
```

### PostgreSQL connection refused
```bash
# Check if running
docker ps | grep postgres

# Check PostgreSQL is ready
docker exec postgres_db pg_isready -U postgres

# View logs
docker logs postgres_db
```

### Port already in use
```bash
# Find what's using the port
sudo lsof -i :5432
sudo netstat -tulpn | grep :5432
```

### Reset everything
```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove volumes (CAUTION: deletes data)
docker volume prune -a
```

## Support

For issues with:
- **n8n**: Check n8n documentation
- **Django**: Check Django documentation
- **Docker**: Check Docker documentation
- **PostgreSQL**: Check PostgreSQL documentation

## Notes

- All services use Docker for easy management and isolation
- n8n is preserved during cleanup operations
- Virtual environment keeps Python dependencies isolated
- Use `.env` files for configuration (never commit to git)
- Regular backups are essential for production
