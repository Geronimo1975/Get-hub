#!/bin/bash

# Production Environment Verification Script
# For: PostgreSQL, pgAdmin, Portainer, and Django Development
# Date: 2025-10-12

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Production Environment Verification${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a port is listening
check_port() {
    local port=$1
    local service=$2
    if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${GREEN}✓${NC} $service is listening on port $port"
        return 0
    else
        echo -e "${RED}✗${NC} $service is NOT listening on port $port"
        return 1
    fi
}

# Check Docker
echo -e "${YELLOW}[1/8] Checking Docker...${NC}"
if command_exists docker; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓${NC} Docker installed: $DOCKER_VERSION"

    # Check if Docker daemon is running
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker daemon is running"
        RUNNING_CONTAINERS=$(docker ps --format "{{.Names}}" | wc -l)
        echo -e "${BLUE}  → Running containers: $RUNNING_CONTAINERS${NC}"
    else
        echo -e "${RED}✗${NC} Docker daemon is not running"
    fi
else
    echo -e "${RED}✗${NC} Docker is not installed"
fi
echo ""

# Check Docker Compose
echo -e "${YELLOW}[2/8] Checking Docker Compose...${NC}"
if command_exists docker-compose || docker compose version >/dev/null 2>&1; then
    COMPOSE_VERSION=$(docker-compose --version 2>/dev/null || docker compose version)
    echo -e "${GREEN}✓${NC} Docker Compose installed: $COMPOSE_VERSION"
else
    echo -e "${RED}✗${NC} Docker Compose is not installed"
fi
echo ""

# Check PostgreSQL Container
echo -e "${YELLOW}[3/8] Checking PostgreSQL...${NC}"
POSTGRES_CONTAINER=$(docker ps --filter "name=postgres" --format "{{.Names}}" | head -n 1)
if [ -n "$POSTGRES_CONTAINER" ]; then
    echo -e "${GREEN}✓${NC} PostgreSQL container running: $POSTGRES_CONTAINER"

    # Get PostgreSQL version
    PG_VERSION=$(docker exec $POSTGRES_CONTAINER psql --version 2>/dev/null)
    echo -e "${BLUE}  → Version: $PG_VERSION${NC}"

    # Check port
    check_port 5432 "PostgreSQL"

    # Check PostgreSQL is accepting connections
    if docker exec $POSTGRES_CONTAINER pg_isready -U postgres >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} PostgreSQL is accepting connections"
    else
        echo -e "${RED}✗${NC} PostgreSQL is not accepting connections"
    fi

    # List databases
    echo -e "${BLUE}  → Databases:${NC}"
    docker exec $POSTGRES_CONTAINER psql -U postgres -c "\l" 2>/dev/null | grep -E "^\s+\w+" | awk '{print "    - " $1}'
else
    echo -e "${RED}✗${NC} PostgreSQL container is not running"
fi
echo ""

# Check pgAdmin Container
echo -e "${YELLOW}[4/8] Checking pgAdmin...${NC}"
PGADMIN_CONTAINER=$(docker ps --filter "name=pgadmin" --format "{{.Names}}" | head -n 1)
if [ -n "$PGADMIN_CONTAINER" ]; then
    echo -e "${GREEN}✓${NC} pgAdmin container running: $PGADMIN_CONTAINER"
    check_port 8080 "pgAdmin"
    echo -e "${BLUE}  → Access URL: http://$(hostname -I | awk '{print $1}'):8080${NC}"
else
    echo -e "${RED}✗${NC} pgAdmin container is not running"
fi
echo ""

# Check Portainer Container
echo -e "${YELLOW}[5/8] Checking Portainer...${NC}"
PORTAINER_CONTAINER=$(docker ps --filter "name=portainer" --format "{{.Names}}" | head -n 1)
if [ -n "$PORTAINER_CONTAINER" ]; then
    echo -e "${GREEN}✓${NC} Portainer container running: $PORTAINER_CONTAINER"
    check_port 9443 "Portainer"
    echo -e "${BLUE}  → Access URL: https://$(hostname -I | awk '{print $1}'):9443${NC}"
else
    echo -e "${RED}✗${NC} Portainer container is not running"
fi
echo ""

# Check n8n Container
echo -e "${YELLOW}[6/8] Checking n8n...${NC}"
N8N_CONTAINER=$(docker ps --filter "name=n8n" --format "{{.Names}}" | head -n 1)
if [ -n "$N8N_CONTAINER" ]; then
    echo -e "${GREEN}✓${NC} n8n container running: $N8N_CONTAINER"
    check_port 5678 "n8n"
    echo -e "${BLUE}  → Access URL: http://$(hostname -I | awk '{print $1}'):5678${NC}"
else
    echo -e "${RED}✗${NC} n8n container is not running"
fi
echo ""

# Check Python for Django development
echo -e "${YELLOW}[7/8] Checking Python environment...${NC}"
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓${NC} Python installed: $PYTHON_VERSION"

    # Check pip
    if command_exists pip3; then
        PIP_VERSION=$(pip3 --version | awk '{print $2}')
        echo -e "${GREEN}✓${NC} pip installed: version $PIP_VERSION"
    else
        echo -e "${YELLOW}⚠${NC} pip3 is not installed"
    fi

    # Check for Django
    if python3 -c "import django" 2>/dev/null; then
        DJANGO_VERSION=$(python3 -c "import django; print(django.get_version())")
        echo -e "${GREEN}✓${NC} Django installed: version $DJANGO_VERSION"
    else
        echo -e "${YELLOW}⚠${NC} Django is not installed (install with: pip3 install django)"
    fi
else
    echo -e "${RED}✗${NC} Python3 is not installed"
fi
echo ""

# Check System Resources
echo -e "${YELLOW}[8/8] Checking System Resources...${NC}"
echo -e "${BLUE}  → Disk Usage:${NC}"
df -h / | tail -n 1 | awk '{print "    Total: "$2", Used: "$3" ("$5"), Available: "$4}'

echo -e "${BLUE}  → Memory Usage:${NC}"
free -h | grep Mem | awk '{print "    Total: "$2", Used: "$3", Available: "$7}'

echo -e "${BLUE}  → CPU Info:${NC}"
if [ -f /proc/cpuinfo ]; then
    CPU_COUNT=$(grep -c ^processor /proc/cpuinfo)
    echo "    CPU Cores: $CPU_COUNT"
fi
echo ""

# Summary of stopped containers
echo -e "${YELLOW}Stopped/Exited Containers:${NC}"
STOPPED=$(docker ps -a --filter "status=exited" --format "{{.Names}}" | wc -l)
if [ "$STOPPED" -gt 0 ]; then
    echo -e "${BLUE}  → $STOPPED containers are stopped:${NC}"
    docker ps -a --filter "status=exited" --format "    - {{.Names}} ({{.Status}})"
else
    echo -e "${GREEN}✓${NC} No stopped containers"
fi
echo ""

# Docker networks
echo -e "${YELLOW}Docker Networks:${NC}"
docker network ls --format "  - {{.Name}} ({{.Driver}})"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Verification Complete${NC}"
echo -e "${BLUE}========================================${NC}"
