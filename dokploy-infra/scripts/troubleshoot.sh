#!/bin/bash
# Troubleshooting script for common Dokploy issues

echo "🔧 Dokploy Troubleshooting Diagnostics"
echo "========================================"
echo ""

# System Info
echo "📊 SYSTEM INFORMATION"
echo "--------------------"
echo "OS: $(lsb_release -d | cut -f2-)"
echo "Kernel: $(uname -r)"
echo "WSL: $(grep -qi microsoft /proc/version && echo "Yes" || echo "No")"
echo "Init: $(ps --no-headers -o comm 1)"
echo ""

# Docker Info
echo "🐳 DOCKER STATUS"
echo "----------------"
echo "Version: $(docker --version 2>/dev/null || echo "NOT INSTALLED")"
echo "Compose: $(docker compose version 2>/dev/null || echo "NOT INSTALLED")"
echo "Service: $(systemctl is-active docker 2>/dev/null || service docker status 2>/dev/null | grep -o "running\|active" || echo "INACTIVE")"
echo "Socket: $(test -S /var/run/docker.sock && echo "OK" || echo "MISSING")"
echo ""

# User permissions
echo "👤 USER PERMISSIONS"
echo "-------------------"
echo "Current user: $(whoami)"
echo "Groups: $(groups)"
echo "Docker group: $(groups | grep -q docker && echo "✓ Member" || echo "✗ NOT MEMBER")"
echo "Sudo test: $(sudo -n true 2>/dev/null && echo "✓ Available" || echo "⚠️  Requires password")"
echo ""

# Docker resources
echo "📦 DOCKER RESOURCES"
echo "-------------------"
docker system df 2>/dev/null || echo "Cannot access Docker"
echo ""

# Dokploy specific
echo "🚀 DOKPLOY STATUS (NATIVE)"
echo "-----------------"
echo "Installation: $(test -d /opt/dokploy && echo "✓ Found" || echo "✗ Missing")"
echo "Service: $(systemctl is-active dokploy 2>/dev/null || echo "inactive")"
if systemctl is-active --quiet dokploy 2>/dev/null; then
    echo "Process: $(ps aux | grep -v grep | grep dokploy | wc -l) processes"
    echo "Port: $(ss -tlnp 2>/dev/null | grep :3000 || echo "Not listening")"
else
    echo "⚠️  Dokploy service not running"
fi
echo ""

# Network
echo "🌐 DOCKER NETWORKS"
echo "------------------"
docker network ls --filter name=dokploy --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" 2>/dev/null || echo "Cannot list networks"
echo ""

# Ports
echo "🔌 PORT USAGE"
echo "-------------"
echo "Port 3000: $(ss -tlnp 2>/dev/null | grep :3000 && echo "" || echo "Not in use")"
echo ""

# Logs preview
echo "📝 DOKPLOY LOGS (last 10 lines)"
echo "--------------------------------"
if systemctl is-active --quiet dokploy 2>/dev/null; then
    journalctl -u dokploy -n 10 --no-pager
else
    echo "⚠️  Dokploy not running"
fi
echo ""

# Firewall
echo "🔥 FIREWALL STATUS"
echo "------------------"
if command -v ufw >/dev/null 2>&1; then
    sudo ufw status | head -5
else
    echo "UFW not installed"
fi
echo ""

# Common fixes
echo "💡 COMMON FIXES (NATIVE INSTALLATION)"
echo "---------------"
echo "1. User not in docker group:"
echo "   sudo usermod -aG docker \$USER"
echo "   newgrp docker"
echo ""
echo "2. Docker not starting:"
echo "   sudo systemctl restart docker"
echo ""
echo "3. Dokploy not responding:"
echo "   sudo systemctl restart dokploy"
echo "   journalctl -u dokploy -f"
echo ""
echo "4. Dokploy service failed:"
echo "   sudo systemctl status dokploy"
echo "   journalctl -u dokploy -n 50"
echo ""
echo "5. Node.js/pnpm missing:"
echo "   Re-run ansible playbook with --tags node"
echo ""
echo "6. Rebuild Dokploy:"
echo "   cd /opt/dokploy"
echo "   sudo -u dokploy pnpm install"
echo "   sudo -u dokploy pnpm run build"
echo "   sudo systemctl restart dokploy"
echo ""
echo "7. WSL systemd not enabled:"
echo "   Edit /etc/wsl.conf and add:"
echo "   [boot]"
echo "   systemd=true"
echo "   Then: wsl --shutdown (from PowerShell)"
echo ""
echo "========================================"
