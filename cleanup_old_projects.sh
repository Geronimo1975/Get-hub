#!/bin/bash

# Cleanup Script for Old Projects
# CAUTION: This will remove old project directories and containers
# n8n directories and containers will be preserved

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}========================================${NC}"
echo -e "${RED}WARNING: Old Project Cleanup${NC}"
echo -e "${RED}========================================${NC}"
echo ""
echo -e "${YELLOW}This script will:${NC}"
echo -e "  1. Stop and remove old Docker containers"
echo -e "  2. Remove old project directories"
echo -e "  3. Clean up unused Docker networks"
echo -e "  4. Clean up unused Docker volumes"
echo ""
echo -e "${GREEN}PRESERVED:${NC}"
echo -e "  - n8n (all directories and containers)"
echo -e "  - PostgreSQL (postgres_db)"
echo -e "  - pgAdmin"
echo -e "  - Portainer"
echo ""
echo -e "${RED}TO BE REMOVED:${NC}"
echo -e "  - Cleosdeco (directory + containers)"
echo -e "  - GTI-Europe (directory + containers)"
echo -e "  - med-hr.com (directory + containers)"
echo -e "  - odoo (directory + containers)"
echo -e "  - qdrant (directory + containers)"
echo -e "  - PG-admin, pgsetup directories"
echo ""

read -p "$(echo -e ${RED}Are you ABSOLUTELY SURE you want to proceed? ${NC}[yes/NO]: )" response
if [[ ! "$response" =~ ^[yY][eE][sS]$ ]]; then
    echo -e "${YELLOW}Cleanup cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Starting cleanup...${NC}"
echo ""

# Stop and remove old containers
echo -e "${YELLOW}[1/5] Stopping and removing old containers...${NC}"

OLD_CONTAINERS=(
    "cleosdeco-web-1"
    "cleosdeco-db-1"
    "gti-europe-web-1"
    "gti-europe-db-1"
    "med-hrcom-web-1"
    "med-hrcom-db-1"
    "odoo-web-1"
    "odoo-db-1"
    "qdrant"
)

for container in "${OLD_CONTAINERS[@]}"; do
    if docker ps -a --format "{{.Names}}" | grep -q "^${container}$"; then
        echo -e "${BLUE}  → Removing container: $container${NC}"
        docker rm -f "$container" 2>/dev/null || true
    fi
done

echo -e "${GREEN}✓${NC} Old containers removed"
echo ""

# Remove old project directories
echo -e "${YELLOW}[2/5] Removing old project directories...${NC}"

cd ~

OLD_DIRS=(
    "Cleosdeco"
    "GTI-Europe"
    "med-hr.com"
    "odoo"
    "qdrant"
    "PG-admin"
    "pgsetup"
    "qdrant_data"
)

for dir in "${OLD_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${BLUE}  → Removing directory: $dir${NC}"
        sudo rm -rf "$dir" 2>/dev/null || rm -rf "$dir" 2>/dev/null || true
    fi
done

# Remove old docker-compose.yml in home directory (keeping n8n specific ones)
if [ -f ~/docker-compose.yml ]; then
    echo -e "${BLUE}  → Removing ~/docker-compose.yml (old qdrant config)${NC}"
    rm -f ~/docker-compose.yml
fi

echo -e "${GREEN}✓${NC} Old directories removed"
echo ""

# Clean unused Docker networks
echo -e "${YELLOW}[3/5] Cleaning unused Docker networks...${NC}"

OLD_NETWORKS=(
    "cleosdeco_default"
    "gti-europe_default"
    "med-hrcom_default"
    "odoo_default"
    "qdrant_default"
    "pg-admin_default"
)

for network in "${OLD_NETWORKS[@]}"; do
    if docker network ls --format "{{.Name}}" | grep -q "^${network}$"; then
        echo -e "${BLUE}  → Removing network: $network${NC}"
        docker network rm "$network" 2>/dev/null || true
    fi
done

echo -e "${GREEN}✓${NC} Old networks cleaned"
echo ""

# Clean unused Docker volumes
echo -e "${YELLOW}[4/5] Cleaning unused Docker volumes...${NC}"
echo -e "${BLUE}  → Removing dangling volumes...${NC}"
docker volume prune -f

echo -e "${GREEN}✓${NC} Unused volumes cleaned"
echo ""

# Clean Docker system
echo -e "${YELLOW}[5/5] Final Docker cleanup...${NC}"
read -p "$(echo -e ${YELLOW}Do you want to clean unused Docker images? ${NC}[y/N]: )" clean_images
if [[ "$clean_images" =~ ^[yY]$ ]]; then
    docker system prune -f
    echo -e "${GREEN}✓${NC} Docker system cleaned"
else
    echo -e "${YELLOW}⚠${NC} Skipped image cleanup"
fi
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cleanup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Remaining containers:${NC}"
docker ps --format "  - {{.Names}}: {{.Status}}"
echo ""
echo -e "${BLUE}Remaining directories in home:${NC}"
ls -d ~/n8n* ~/production 2>/dev/null | sed 's|^|  - |' || echo "  (relevant directories)"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo -e "  - Run verification: ${BLUE}./verify_production_setup.sh${NC}"
echo -e "  - Check disk space: ${BLUE}df -h${NC}"
echo ""
