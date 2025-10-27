#!/bin/bash

# Deploy Get-hub Django CMS to Production Server
# This script uploads the project and sets up the application

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SERVER="n8n"
SERVER_IP="80.134.74.61"
PROJECT_DIR="Get-hub"
REMOTE_DIR="/home/n8n/$PROJECT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Get-hub Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "manage.py" ]; then
    echo -e "${RED}Error: Not in Get-hub directory${NC}"
    echo "Please run this script from the Get-hub project root"
    exit 1
fi

# Confirm deployment
read -p "$(echo -e ${YELLOW}Deploy to $SERVER ($SERVER_IP)? ${NC}[y/N]: )" confirm
if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

echo -e "${YELLOW}[1/6] Creating deployment archive...${NC}"
# Exclude unnecessary files
tar -czf /tmp/gethub-deploy.tar.gz \
    --exclude='Update' \
    --exclude='*.pyc' \
    --exclude='__pycache__' \
    --exclude='.git' \
    --exclude='*.sqlite3' \
    --exclude='venv' \
    --exclude='env' \
    --exclude='db.sqlite3' \
    --exclude='assets' \
    --exclude='.env' \
    .

echo -e "${GREEN}✓${NC} Archive created"
echo ""

echo -e "${YELLOW}[2/6] Uploading to server...${NC}"
scp /tmp/gethub-deploy.tar.gz $SERVER:/tmp/
echo -e "${GREEN}✓${NC} Upload complete"
echo ""

echo -e "${YELLOW}[3/6] Extracting on server...${NC}"
ssh $SERVER << 'ENDSSH'
    set -e

    # Create directory if it doesn't exist
    mkdir -p ~/Get-hub

    # Extract archive
    cd ~/Get-hub
    tar -xzf /tmp/gethub-deploy.tar.gz

    # Clean up
    rm /tmp/gethub-deploy.tar.gz

    echo "Files extracted successfully"
ENDSSH
echo -e "${GREEN}✓${NC} Extraction complete"
echo ""

echo -e "${YELLOW}[4/6] Setting up environment...${NC}"
ssh $SERVER << 'ENDSSH'
    set -e
    cd ~/Get-hub

    # Copy production env if .env doesn't exist
    if [ ! -f .env ]; then
        cp .env.production .env
        echo "Created .env from .env.production"
    else
        echo ".env already exists, keeping existing configuration"
    fi

    # Make scripts executable
    chmod +x entrypoint.sh
    chmod +x *.sh

    echo "Environment setup complete"
ENDSSH
echo -e "${GREEN}✓${NC} Environment ready"
echo ""

echo -e "${YELLOW}[5/6] Building Docker containers...${NC}"
ssh $SERVER << 'ENDSSH'
    set -e
    cd ~/Get-hub

    # Build containers
    docker-compose build

    echo "Docker build complete"
ENDSSH
echo -e "${GREEN}✓${NC} Build complete"
echo ""

echo -e "${YELLOW}[6/6] Starting application...${NC}"
read -p "$(echo -e ${YELLOW}Start the application now? ${NC}[y/N]: )" start_now
if [[ "$start_now" =~ ^[yY]$ ]]; then
    ssh $SERVER << 'ENDSSH'
        set -e
        cd ~/Get-hub

        # Start services
        docker-compose up -d

        # Wait a bit
        sleep 5

        # Show status
        echo ""
        echo "Container status:"
        docker-compose ps

        echo ""
        echo "Application logs (last 20 lines):"
        docker-compose logs --tail=20 web
ENDSSH
    echo -e "${GREEN}✓${NC} Application started"
else
    echo -e "${YELLOW}⚠${NC} Application not started. Start manually with:"
    echo "  ssh $SERVER"
    echo "  cd ~/Get-hub"
    echo "  docker-compose up -d"
fi

# Clean up local temp file
rm /tmp/gethub-deploy.tar.gz

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Access URLs:${NC}"
echo -e "  Frontend:  ${BLUE}http://$SERVER_IP${NC}"
echo -e "  Dashboard: ${BLUE}http://$SERVER_IP/dashboard/${NC}"
echo -e "  Admin:     ${BLUE}http://$SERVER_IP/secure-admin-portal/${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. SSH to server: ${BLUE}ssh $SERVER${NC}"
echo "  2. Edit config: ${BLUE}cd ~/Get-hub && nano .env${NC}"
echo "  3. View logs: ${BLUE}cd ~/Get-hub && docker-compose logs -f web${NC}"
echo "  4. Check status: ${BLUE}cd ~/Get-hub && docker-compose ps${NC}"
echo ""
echo -e "${YELLOW}Default superuser:${NC}"
echo "  Username: admin"
echo "  Password: admin123"
echo "  ${RED}CHANGE THIS IMMEDIATELY!${NC}"
echo ""
