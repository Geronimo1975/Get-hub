#!/bin/bash

# Production Environment Setup Script
# For: PostgreSQL, pgAdmin, Portainer, Django Development
# Date: 2025-10-12
# CAUTION: This script will clean up old projects (except n8n) and set up a fresh environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Production Environment Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to prompt for confirmation
confirm() {
    read -p "$(echo -e ${YELLOW}$1 ${NC}[y/N]: )" response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Create directory structure
echo -e "${YELLOW}[1/7] Setting up directory structure...${NC}"
cd ~

# Create main production directories
mkdir -p ~/production/{django_projects,databases,backups,scripts,logs}
mkdir -p ~/production/django_projects/templates
mkdir -p ~/production/django_projects/static
mkdir -p ~/production/databases/{postgres_data,pgadmin_data}
mkdir -p ~/production/docker_configs

echo -e "${GREEN}✓${NC} Directory structure created"
echo ""

# Clean up old projects (except n8n)
echo -e "${YELLOW}[2/7] Cleaning up old project directories...${NC}"

CLEANUP_DIRS=("Cleosdeco" "GTI-Europe" "med-hr.com" "odoo" "PG-admin" "pgsetup" "qdrant")

if confirm "Do you want to stop and remove containers from old projects?"; then
    echo -e "${BLUE}  → Stopping containers from old projects...${NC}"

    # Stop specific old containers
    OLD_CONTAINERS="cleosdeco-web-1 cleosdeco-db-1 gti-europe-web-1 gti-europe-db-1 med-hrcom-web-1 med-hrcom-db-1 odoo-web-1 odoo-db-1"
    for container in $OLD_CONTAINERS; do
        if docker ps -a --format "{{.Names}}" | grep -q "^${container}$"; then
            echo -e "${BLUE}    Removing container: $container${NC}"
            docker rm -f $container 2>/dev/null || true
        fi
    done
fi

if confirm "Do you want to delete old project directories (Cleosdeco, GTI-Europe, med-hr.com, odoo, etc.)?"; then
    for dir in "${CLEANUP_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo -e "${BLUE}  → Removing directory: $dir${NC}"
            rm -rf "$dir"
        fi
    done
    echo -e "${GREEN}✓${NC} Old directories removed"
else
    echo -e "${YELLOW}⚠${NC} Skipped directory cleanup"
fi
echo ""

# Setup PostgreSQL
echo -e "${YELLOW}[3/7] Setting up PostgreSQL...${NC}"

# Check if postgres_db already exists
if docker ps -a --format "{{.Names}}" | grep -q "^postgres_db$"; then
    echo -e "${GREEN}✓${NC} PostgreSQL container already exists"

    if ! docker ps --format "{{.Names}}" | grep -q "^postgres_db$"; then
        echo -e "${BLUE}  → Starting existing PostgreSQL container...${NC}"
        docker start postgres_db
    fi
else
    # Create new PostgreSQL container
    echo -e "${BLUE}  → Creating new PostgreSQL container...${NC}"

    read -p "Enter PostgreSQL password for 'postgres' user [default: postgres]: " PG_PASSWORD
    PG_PASSWORD=${PG_PASSWORD:-postgres}

    docker run -d \
        --name postgres_db \
        --restart unless-stopped \
        -e POSTGRES_PASSWORD=$PG_PASSWORD \
        -e POSTGRES_USER=postgres \
        -v ~/production/databases/postgres_data:/var/lib/postgresql/data \
        -p 5432:5432 \
        postgres:15

    echo -e "${GREEN}✓${NC} PostgreSQL container created"

    # Wait for PostgreSQL to start
    echo -e "${BLUE}  → Waiting for PostgreSQL to be ready...${NC}"
    sleep 5
    docker exec postgres_db pg_isready -U postgres
fi

# Create Django development database
if confirm "Create a database for Django development (django_dev)?"; then
    read -p "Enter database name [default: django_dev]: " DB_NAME
    DB_NAME=${DB_NAME:-django_dev}

    read -p "Enter database user [default: django_user]: " DB_USER
    DB_USER=${DB_USER:-django_user}

    read -p "Enter database password [default: django_pass]: " DB_PASS
    DB_PASS=${DB_PASS:-django_pass}

    docker exec postgres_db psql -U postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || echo "Database may already exist"
    docker exec postgres_db psql -U postgres -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';" 2>/dev/null || echo "User may already exist"
    docker exec postgres_db psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 2>/dev/null
    docker exec postgres_db psql -U postgres -c "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;" 2>/dev/null

    echo -e "${GREEN}✓${NC} Django database created: $DB_NAME"

    # Save credentials to file
    cat > ~/production/databases/django_db_credentials.txt <<EOF
Database: $DB_NAME
User: $DB_USER
Password: $DB_PASS
Host: localhost (or postgres_db from Docker network)
Port: 5432

Django settings.py configuration:
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': '$DB_NAME',
        'USER': '$DB_USER',
        'PASSWORD': '$DB_PASS',
        'HOST': 'postgres_db',  # Use 'localhost' if Django runs on host
        'PORT': '5432',
    }
}
EOF
    echo -e "${BLUE}  → Credentials saved to: ~/production/databases/django_db_credentials.txt${NC}"
fi
echo ""

# Setup pgAdmin
echo -e "${YELLOW}[4/7] Setting up pgAdmin...${NC}"

if docker ps -a --format "{{.Names}}" | grep -q "^pgadmin$"; then
    echo -e "${GREEN}✓${NC} pgAdmin container already exists"

    if ! docker ps --format "{{.Names}}" | grep -q "^pgadmin$"; then
        echo -e "${BLUE}  → Starting existing pgAdmin container...${NC}"
        docker start pgadmin
    fi
else
    read -p "Enter pgAdmin email [default: admin@localhost.com]: " PGADMIN_EMAIL
    PGADMIN_EMAIL=${PGADMIN_EMAIL:-admin@localhost.com}

    read -p "Enter pgAdmin password [default: admin]: " PGADMIN_PASSWORD
    PGADMIN_PASSWORD=${PGADMIN_PASSWORD:-admin}

    docker run -d \
        --name pgadmin \
        --restart unless-stopped \
        -e PGADMIN_DEFAULT_EMAIL=$PGADMIN_EMAIL \
        -e PGADMIN_DEFAULT_PASSWORD=$PGADMIN_PASSWORD \
        -v ~/production/databases/pgadmin_data:/var/lib/pgadmin \
        -p 8080:80 \
        dpage/pgadmin4:latest

    echo -e "${GREEN}✓${NC} pgAdmin container created"
    echo -e "${BLUE}  → Access URL: http://$(hostname -I | awk '{print $1}'):8080${NC}"
    echo -e "${BLUE}  → Email: $PGADMIN_EMAIL${NC}"
fi
echo ""

# Setup Portainer
echo -e "${YELLOW}[5/7] Setting up Portainer...${NC}"

if docker ps -a --format "{{.Names}}" | grep -q "^portainer$"; then
    echo -e "${GREEN}✓${NC} Portainer container already exists"

    if ! docker ps --format "{{.Names}}" | grep -q "^portainer$"; then
        echo -e "${BLUE}  → Starting existing Portainer container...${NC}"
        docker start portainer
    fi
else
    docker volume create portainer_data 2>/dev/null || true

    docker run -d \
        --name portainer \
        --restart unless-stopped \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        -p 9443:9443 \
        portainer/portainer-ce:latest

    echo -e "${GREEN}✓${NC} Portainer container created"
    echo -e "${BLUE}  → Access URL: https://$(hostname -I | awk '{print $1}'):9443${NC}"
fi
echo ""

# Setup Python/Django environment
echo -e "${YELLOW}[6/7] Setting up Python/Django environment...${NC}"

if command -v python3 >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Python3 is installed: $(python3 --version)"

    # Install pip if not present
    if ! command -v pip3 >/dev/null 2>&1; then
        echo -e "${BLUE}  → Installing pip...${NC}"
        sudo apt-get update && sudo apt-get install -y python3-pip
    fi

    # Install virtualenv
    if ! command -v virtualenv >/dev/null 2>&1; then
        echo -e "${BLUE}  → Installing virtualenv...${NC}"
        pip3 install virtualenv
    fi

    # Create virtual environment for Django projects
    if [ ! -d ~/production/django_projects/venv ]; then
        echo -e "${BLUE}  → Creating virtual environment...${NC}"
        cd ~/production/django_projects
        python3 -m venv venv
        echo -e "${GREEN}✓${NC} Virtual environment created"
    fi

    # Install Django and common packages
    if confirm "Install Django and common packages in virtual environment?"; then
        echo -e "${BLUE}  → Installing packages...${NC}"
        cd ~/production/django_projects
        source venv/bin/activate
        pip install --upgrade pip
        pip install django psycopg2-binary djangorestframework django-cors-headers gunicorn python-decouple pillow
        deactivate
        echo -e "${GREEN}✓${NC} Packages installed"
    fi
else
    echo -e "${YELLOW}⚠${NC} Python3 is not installed. Install with: sudo apt-get install python3 python3-pip"
fi
echo ""

# Create docker-compose for full stack
echo -e "${YELLOW}[7/7] Creating docker-compose configuration...${NC}"

cat > ~/production/docker_configs/docker-compose.yml <<'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: postgres_db
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - production_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: pgadmin
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL:-admin@localhost.com}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD:-admin}
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    ports:
      - "8080:80"
    networks:
      - production_network
    depends_on:
      - postgres

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    ports:
      - "9443:9443"
    networks:
      - production_network

volumes:
  postgres_data:
    driver: local
  pgadmin_data:
    driver: local
  portainer_data:
    driver: local

networks:
  production_network:
    driver: bridge
EOF

# Create .env template
cat > ~/production/docker_configs/.env.example <<'EOF'
# PostgreSQL Configuration
POSTGRES_PASSWORD=postgres
POSTGRES_USER=postgres

# pgAdmin Configuration
PGADMIN_EMAIL=admin@localhost.com
PGADMIN_PASSWORD=admin

# Django Configuration (for your Django projects)
DJANGO_SECRET_KEY=your-secret-key-here
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1
DATABASE_URL=postgresql://django_user:django_pass@postgres_db:5432/django_dev
EOF

echo -e "${GREEN}✓${NC} Docker Compose configuration created"
echo -e "${BLUE}  → Location: ~/production/docker_configs/docker-compose.yml${NC}"
echo -e "${BLUE}  → Copy .env.example to .env and configure your settings${NC}"
echo ""

# Create helpful aliases
cat > ~/production/scripts/aliases.sh <<'EOF'
# Production Environment Aliases

alias prod-start='cd ~/production/docker_configs && docker-compose up -d'
alias prod-stop='cd ~/production/docker_configs && docker-compose stop'
alias prod-restart='cd ~/production/docker_configs && docker-compose restart'
alias prod-logs='cd ~/production/docker_configs && docker-compose logs -f'
alias prod-ps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

alias django-activate='cd ~/production/django_projects && source venv/bin/activate'
alias django-new='cd ~/production/django_projects && source venv/bin/activate && django-admin startproject'

alias pg-shell='docker exec -it postgres_db psql -U postgres'
alias pg-backup='docker exec postgres_db pg_dumpall -U postgres > ~/production/backups/postgres_backup_$(date +%Y%m%d_%H%M%S).sql'

alias cleanup-docker='docker system prune -a --volumes'
EOF

echo -e "${GREEN}✓${NC} Helper scripts created"
echo -e "${BLUE}  → Add to .bashrc: echo 'source ~/production/scripts/aliases.sh' >> ~/.bashrc${NC}"
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Services Status:${NC}"
docker ps --format "  - {{.Names}}: {{.Status}}"
echo ""
echo -e "${GREEN}Access URLs:${NC}"
SERVER_IP=$(hostname -I | awk '{print $1}')
echo -e "  - pgAdmin: ${BLUE}http://$SERVER_IP:8080${NC}"
echo -e "  - Portainer: ${BLUE}https://$SERVER_IP:9443${NC}"
echo -e "  - PostgreSQL: ${BLUE}$SERVER_IP:5432${NC}"
if docker ps --format "{{.Names}}" | grep -q "^n8n$"; then
    echo -e "  - n8n: ${BLUE}http://$SERVER_IP:5678${NC}"
fi
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo -e "  1. Load aliases: ${BLUE}source ~/production/scripts/aliases.sh${NC}"
echo -e "  2. Configure .env: ${BLUE}cp ~/production/docker_configs/.env.example ~/production/docker_configs/.env${NC}"
echo -e "  3. Check credentials: ${BLUE}cat ~/production/databases/django_db_credentials.txt${NC}"
echo -e "  4. Create Django project: ${BLUE}django-activate && cd ~/production/django_projects && django-admin startproject myproject${NC}"
echo -e "  5. Run verification: ${BLUE}./verify_production_setup.sh${NC}"
echo ""
