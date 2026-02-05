#!/bin/bash
set -e

echo "================================================"
echo "🚀 WSL Bootstrap for Dokploy Infrastructure"
echo "================================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on WSL
if ! grep -qi microsoft /proc/version; then
    echo -e "${RED}❌ This script is for WSL only${NC}"
    exit 1
fi

echo -e "${GREEN}✓ WSL detected${NC}"

# Check systemd
if ! ps --no-headers -o comm 1 | grep -q systemd; then
    echo -e "${YELLOW}⚠️  Systemd not detected. Configuring...${NC}"
    
    sudo tee /etc/wsl.conf > /dev/null <<EOF
[boot]
systemd=true

[network]
generateResolvConf=true
EOF
    
    echo -e "${YELLOW}⚠️  Systemd configured. Please restart WSL:${NC}"
    echo -e "${YELLOW}   Run in PowerShell: wsl --shutdown${NC}"
    echo -e "${YELLOW}   Then restart WSL and run this script again${NC}"
    exit 0
fi

echo -e "${GREEN}✓ Systemd is active${NC}"

# Update system
echo "Updating system packages..."
sudo apt update -qq

# Install prerequisites
echo "Installing prerequisites..."
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    python3 \
    python3-pip \
    software-properties-common

# Install Ansible
echo "Installing Ansible..."
if ! command -v ansible &> /dev/null; then
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
fi

ANSIBLE_VERSION=$(ansible --version | head -n1)
echo -e "${GREEN}✓ ${ANSIBLE_VERSION}${NC}"

# Install Ansible collections
echo "Installing Ansible collections..."
ansible-galaxy collection install community.docker ansible.posix

echo ""
echo "================================================"
echo -e "${GREEN}✓ Bootstrap completed successfully${NC}"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. cd dokploy-infra/ansible"
echo "2. ansible-playbook -i inventory/local.ini playbooks/setup.yml"
echo ""
echo "================================================"
