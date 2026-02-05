# Dokploy Infrastructure - Ansible Automation

Infraestructura completa para desplegar Dokploy con Docker en WSL2 o servidores Linux.

## 🎯 Características

- ✅ Instalación idempotente de Docker + Docker Compose v2
- ✅ Compatibilidad total con WSL2 y Linux servers
- ✅ Detección automática de systemd y distro
- ✅ Configuración de firewall (UFW) solo cuando aplica
- ✅ Despliegue de Dokploy en Docker (método correcto)
- ✅ Validaciones completas post-instalación
- ✅ Usuario agregado al grupo docker automáticamente
- ✅ Red Docker dedicada para Dokploy

## 📋 Requisitos

### Sistema
- Ubuntu 20.04+ / Debian 11+ / WSL2 Ubuntu
- 2GB RAM mínimo (recomendado 4GB)
- 20GB espacio en disco
- Acceso sudo

### Control Node (tu máquina)
```bash
pip install ansible
ansible-galaxy collection install community.docker
```

## 🚀 Uso Rápido

### 1. Instalación Local (WSL2)
```bash
cd dokploy-infra/ansible
ansible-playbook -i inventory/local.ini playbooks/setup.yml
```

### 2. Instalación en VPS
```bash
# Editar inventory/vps.ini con tu IP y usuario
ansible-playbook -i inventory/vps.ini playbooks/setup.yml --ask-become-pass
```

### 3. Verificar solo
```bash
ansible-playbook -i inventory/local.ini playbooks/setup.yml --tags validation
```

## 📂 Estructura

```
ansible/
├── ansible.cfg              # Configuración Ansible
├── inventory/
│   ├── local.ini           # Para WSL/localhost
│   └── vps.ini             # Para servidores remotos
├── playbooks/
│   └── setup.yml           # Playbook principal
├── roles/
│   ├── system_detection/   # Detecta WSL, systemd, distro
│   ├── docker/             # Instala Docker + Compose v2
│   ├── firewall/           # Configura UFW (solo si aplica)
│   ├── dokploy/            # Despliega Dokploy container
│   └── validation/         # Valida instalación completa
└── vars/
    └── main.yml            # Variables globales
```

## 🔧 Variables Principales

Edita [vars/main.yml](ansible/vars/main.yml):

```yaml
dokploy_port: 3000              # Puerto de Dokploy
dokploy_network: "dokploy_net"  # Red Docker
firewall_enabled: true          # false en WSL
allowed_ports:                  # Puertos UFW
  - { port: 22, proto: "tcp" }
  - { port: 80, proto: "tcp" }
  - { port: 443, proto: "tcp" }
  - { port: 3000, proto: "tcp" }
```

## ✅ Validaciones Automáticas

El playbook verifica:
- ✓ Docker service activo
- ✓ Docker Compose v2 instalado
- ✓ Usuario en grupo docker
- ✓ `docker ps` funciona sin sudo
- ✓ Red dokploy_net creada
- ✓ Container Dokploy corriendo
- ✓ Puerto 3000 accesible

## 🎯 Comandos Útiles

```bash
# Ver logs de Dokploy
docker logs dokploy

# Estado de contenedores
docker ps

# Reiniciar Dokploy
docker restart dokploy

# Ver redes Docker
docker network ls

# Acceder a Dokploy
http://localhost:3000  # (o tu IP)
```

## 🛠️ Troubleshooting

### "docker: permission denied"
```bash
# Cerrar sesión y volver a entrar
exit
# O forzar reload del grupo
newgrp docker
```

### Dokploy no responde
```bash
systemctl status dokploy      # Ver estado
journalctl -u dokploy -f      # Ver logs
sudo systemctl restart dokploy # Reiniciar
```

### UFW bloqueando puertos
```bash
sudo ufw allow 3000/tcp
sudo ufw reload
```

### WSL sin systemd
Edita `/etc/wsl.conf`:
```ini
[boot]
systemd=true
```
Luego `wsl --shutdown` desde PowerShell.

## 🔒 Seguridad

- Firewall configurado automáticamente (excepto WSL)
- Solo puertos necesarios expuestos
- Dokploy en red Docker aislada
- Docker socket montado (requerido por Dokploy)

## 📦 Extensiones

### Agregar Node.js (opcional)
Si necesitas Node.js en el host (no requerido para Dokploy):

```yaml
# En setup.yml, agregar:
roles:
  - node  # Antes de dokploy
```

## 🤝 Contribuir

1. Fork el repo
2. Crea feature branch
3. Testea en WSL y Linux
4. Pull request

## 📝 Notas

- **No usar Docker-in-Docker** - Dokploy se ejecuta directamente en Docker del host
- **Idempotente** - Puedes ejecutar el playbook múltiples veces sin romper nada
- **WSL friendly** - Detecta WSL y ajusta configuración automáticamente
- **Production ready** - Incluye handlers, validaciones y rollback capabilities

## 📄 Licencia

MIT

---

**Desarrollado para producción local y servidores** 🚀
