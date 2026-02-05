#!/bin/bash
# Quick test script for validating Dokploy native installation

set -e

echo "🧪 Testing Dokploy Native Installation..."
echo "===================================="

# Test 1: Docker is running
echo -n "1. Docker service... "
if systemctl is-active --quiet docker 2>/dev/null || service docker status >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 2: Docker Compose v2
echo -n "2. Docker Compose v2... "
if docker compose version >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 3: User in docker group
echo -n "3. User in docker group... "
if groups | grep -q docker; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 4: Docker without sudo
echo -n "4. Docker without sudo... "
if docker ps >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗ FAILED (try: newgrp docker)"
    exit 1
fi

# Test 5: Node.js installed
echo -n "5. Node.js installed... "
if command -v node >/dev/null 2>&1; then
    echo "✓ ($(node --version))"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 6: pnpm installed
echo -n "6. pnpm installed... "
if command -v pnpm >/dev/null 2>&1; then
    echo "✓ ($(pnpm --version))"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 7: Dokploy network
echo -n "7. Dokploy network... "
if docker network inspect dokploy_net >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 8: Dokploy service
echo -n "8. Dokploy service... "
if systemctl is-active --quiet dokploy 2>/dev/null; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 9: Dokploy directory
echo -n "9. Dokploy directory... "
if [ -d "/opt/dokploy" ]; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 10: Dokploy port
echo -n "10. Dokploy responding... "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
    echo "✓"
else
    echo "⚠️  WARNING (service running but not responding yet)"
fi

echo "===================================="
echo "✅ All critical tests passed!"
echo ""
echo "Access Dokploy at: http://localhost:3000"
echo "Logs: journalctl -u dokploy -f"
