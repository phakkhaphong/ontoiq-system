#!/bin/bash
# Ontoiq System - Disaster Recovery Setup Script
# Run this script on a fresh VPS to restore the system

set -e

echo "=== Ontoiq System - Disaster Recovery Setup ==="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Update system
echo "[1/7] Updating system packages..."
apt-get update && apt-get upgrade -y

# Install required packages
echo "[2/7] Installing required packages..."
apt-get install -y docker.io docker-compose git acl curl wget

# Start Docker
echo "[3/7] Starting Docker..."
systemctl start docker
systemctl enable docker

# Clone repository (if not already cloned)
if [ ! -d "/opt/ontoiq-system" ]; then
    echo "[4/7] Cloning repository..."
    git clone https://github.com/phakkhaphong/ontoiq-system.git /opt/ontoiq-system
    cd /opt/ontoiq-system
else
    echo "[4/7] Repository already exists, pulling latest..."
    cd /opt/ontoiq-system
    git pull
fi

# Setup environment
echo "[5/7] Setting up environment..."
if [ ! -f ".env" ]; then
    echo "Creating .env from template..."
    cp .env.example .env
    echo "WARNING: Please edit .env with your actual values before starting services!"
    echo "Run: nano /opt/ontoiq-system/.env"
fi

# Setup OpenClaw workspace
echo "[6/7] Setting up OpenClaw workspace..."
if [ ! -d "openclaw-workspace" ]; then
    mkdir -p openclaw-workspace/memory
    mkdir -p openclaw-workspace/skills
    
    # Create symlinks to vault
    ln -sf /opt/ontoiq-system/ontoiq-vault/01-Raw-Content openclaw-workspace/staging
    ln -sf /opt/ontoiq-system/ontoiq-vault/02-Extracts openclaw-workspace/output
fi

# Setup permissions
echo "[7/7] Setting up permissions..."
setfacl -R -m u:1000:rwx ontoiq-vault/ 2>/dev/null || true
setfacl -d -R -m u:1000:rwx ontoiq-vault/ 2>/dev/null || true

# Create data directories
mkdir -p n8n/data
mkdir -p postgres/data
mkdir -p postgres/init
mkdir -p qdrant/storage
mkdir -p qdrant/snapshots
chown -R 1000:1000 n8n/data/

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Edit .env with your actual values: nano /opt/ontoiq-system/.env"
echo "2. Start services: docker compose --env-file .env up -d"
echo "3. Check status: docker ps"
echo "4. Setup OpenClaw config: openclaw setup --workspace /opt/ontoiq-system/openclaw-workspace"
echo ""
echo "For Windows sync, setup Mutagen on your local machine."
