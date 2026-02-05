# 🚀 Dokploy Infrastructure - Ansible Automation (Native Installation)

> Infraestructura completa para desplegar **Docker + Dokploy NATIVO** en WSL2 o servidores Linux usando Ansible.

[![Ansible](https://img.shields.io/badge/ansible-%3E%3D2.14-blue.svg)](https://www.ansible.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![WSL](https://img.shields.io/badge/WSL-2-orange.svg)](https://docs.microsoft.com/windows/wsl/)

---

## ⚡ **Inicio Rápido WSL2**

**¿Primera vez en WSL2?** → Lee [GUIA_RAPIDA_WSL2.md](GUIA_RAPIDA_WSL2.md) (15 min)

```bash
# Resumen ultra-rápido
cd ~
git clone https://github.com/LaboratorioInnovacion/ansibleDockerDokploy.git
cd ansibleDockerDokploy/dokploy-infra/ansible
ansible-galaxy collection install community.docker ansible.posix
ansible-playbook -i inventory/local.ini playbooks/setup.yml
# Acceder: http://localhost:3000
```

---

## ✨ Características

- ✅ **Dokploy Nativo** - Se instala directamente en el sistema (NO en Docker)
- ✅ **100% Idempotente** - Ejecuta N veces sin romper nada
- ✅ **WSL2 Compatible** - Detección automática y configuración adaptativa
- ✅ **Docker + Compose v2** - Instalación robusta para que Dokploy lo gestione
- ✅ **Node.js 20 + pnpm** - Runtime necesario instalado automáticamente
- ✅ **Servicio systemd** - Arranque automático y gestión con systemctl
- ✅ **Firewall Inteligente** - UFW configurado solo cuando aplica
- ✅ **Validaciones** - Tests automáticos post-instalación
- ✅ **Production Ready** - Sin pasos manuales posteriores

## 📋 Requisitos

### Sistema
- **Ubuntu 20.04+** / Debian 11+ / WSL2 Ubuntu
- 2GB RAM mínimo (4GB recomendado)
- 20GB espacio en disco
- Acceso sudo
- **Systemd** (requerido para servicio Dokploy)

### Control Node
```bash
# Instalar Ansible
pip install ansible

# Instalar collections
ansible-galaxy collection install community.docker ansible.posix
```

## 🎯 Diferencia Clave: Instalación Nativa

**Este setup instala Dokploy NATIVAMENTE en el sistema:**

- ✅ Dokploy corre como **servicio systemd**
- ✅ **No conflictos** entre Dokploy y Docker
- ✅ Dokploy **gestiona** contenedores Docker, pero no corre en uno
- ✅ Node.js 20 instalado en el host
- ✅ Mayor control y debugging más fácil

## 🚀 Instalación Rápida

### Opción 1: Makefile (Recomendado)
```bash
cd dokploy-infra

# Ver comandos disponibles
make help

# Instalar dependencias
make install-deps

# Ejecutar en local (WSL)
make install-local

# Ejecutar en VPS remoto
make install-vps
```

### Opción 2: Ansible Directo

#### WSL / Localhost
```bash
cd dokploy-infra/ansible
ansible-playbook -i inventory/local.ini playbooks/setup.yml
```

#### VPS Remoto
```bash
# 1. Editar inventory/vps.ini con tu IP
# 2. Ejecutar
cd dokploy-infra/ansible
ansible-playbook -i inventory/vps.ini playbooks/setup.yml --ask-become-pass
```

### Opción 3: Bootstrap WSL (Primera vez)
```bash
# Si es tu primera vez en WSL
cd dokploy-infra/scripts
chmod +x wsl-bootstrap.sh
./wsl-bootstrap.sh

# Luego ejecutar playbook normal
cd ../ansible
ansible-playbook -i inventory/local.ini playbooks/setup.yml
```

## 📂 Estructura del Proyecto

```
ansibleDockerDokploy/
├── readme.md                    # Este archivo
└── dokploy-infra/               # Directorio principal
    ├── README.md                # Documentación detallada
    ├── ARCHITECTURE.md          # Análisis técnico y decisiones
    ├── CHANGELOG.md             # Resumen de cambios
    ├── Makefile                 # Comandos útiles
    ├── requirements.txt         # Dependencias Python
    ├── ansible/
    │   ├── ansible.cfg          # Config Ansible
    │   ├── requirements.yml     # Collections
    │   ├── inventory/
    │   │   ├── local.ini        # Para WSL
    │   │   └── vps.ini          # Para servers
    │   ├── playbooks/
    │   │   └── setup.yml        # Playbook principal
    │   ├── roles/
    │   │   ├── system_detection/  # WSL/systemd detection
    │   │   ├── docker/            # Docker + Compose v2
    │   │   ├── firewall/          # UFW condicional
    │   │   ├── dokploy/           # Deploy Dokploy
    │   │   └── validation/        # Tests post-install
    │   └── vars/
    │       └── main.yml         # Variables globales
    └── scripts/
        ├── wsl-bootstrap.sh     # Setup inicial WSL
        ├── test-installation.sh # Tests rápidos
        └── troubleshoot.sh      # Diagnóstico

```

## 🎯 ¿Qué hace el playbook?

1. **Detecta el entorno** (WSL/Linux, systemd, distro)
2. **Instala Docker** correctamente según la distro
3. **Configura Docker Compose v2**
4. **Agrega usuario al grupo docker**
5. **Instala Node.js 20 + pnpm**
6. **Configura firewall** (UFW) solo si aplica
7. **Clona y compila Dokploy** en /opt/dokploy
8. **Crea servicio systemd** para Dokploy
9. **Valida todo** y genera reporte

**Resultado:** Dokploy corriendo nativamente como servicio en `http://localhost:3000` o `http://TU_IP:3000`

## 🔧 Comandos Útiles

```bash
# Ver estado de Dokploy
systemctl status dokploy

# Ver logs en tiempo real
journalctl -u dokploy -f

# Reiniciar Dokploy
sudo systemctl restart dokploy

# O usar Makefile
make status
make logs
make restart

# Solo validar (sin instalar)
make validate

# Dry-run (sin cambios)
make check

# Tests rápidos
./scripts/test-installation.sh

# Diagnóstico completo
./scripts/troubleshoot.sh
```

## 📖 Documentación Completa

- **[README.md](dokploy-infra/README.md)** - Guía completa de uso
- **[ARCHITECTURE.md](dokploy-infra/ARCHITECTURE.md)** - Decisiones técnicas y mejoras
- **[CHANGELOG.md](dokploy-infra/CHANGELOG.md)** - Resumen de implementación

## 🐛 Troubleshooting

### "docker: permission denied"
```bash
# Opción 1: Re-login
exit  # Cerrar sesión WSL/SSH
# Volver a entrar

# Opción 2: Forzar grupo
newgrp docker
```

### WSL sin systemd
```bash
# Editar /etc/wsl.conf
sudo nano /etc/wsl.conf

# Agregar:
[boot]
systemd=true

# Desde PowerShell:
systemctl status dokploy      # Ver estado
journalctl -u dokploy -f      # Ver logs
sudo systemctl restart dokploy # Reiniciar
```

### Reconstruir Dokploy
```bash
cd /opt/dokploy
sudo -u dokploy pnpm install
sudo -u dokploy pnpm run build
sudo systemctl restart dokploy
```

### Dokploy no responde
```bash
systemctl status dokploy      # Ver estado
journalctl -u dokploy -f      # Ver logs
sudo systemctl restart dokploy # Reiniciar
```

### Firewall bloqueando
```bash
sudo ufw allow 3000/tcp
sudo ufw reload
```

## 🔒 Seguridad

- ✅ Firewall habilitado por defecto (excepto WSL)
- ✅ Puertos mínimos expuestos: 22, 80, 443, 3000
- ✅ Dokploy en red Docker aislada
- ✅ Usuario sin privilegios root para Docker
- ✅ Secrets NO en código (usar Ansible Vault si necesario)

## 🎓 Casos de Uso

### Desarrollo Local (WSL)
```bash
make install-local
# Dokploy en http://localhost:3000
```

### Servidor de Staging
```bash
# Editar inventory/vps.ini
make install-vps
# Dokploy en http://TU_IP:3000
```

### CI/CD
```bash
# En pipeline
ansible-playbook -i inventory/production.ini playbooks/setup.yml
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea un branch (`git checkout -b feature/mejora`)
3. Commit cambios (`git commit -am 'Add: nueva feature'`)
4. Push al branch (`git push origin feature/mejora`)
5. Abre un Pull Request

## 📝 Licencia

MIT License - Ver [LICENSE](LICENSE) para más detalles

## 👤 Autor

**Laboratorio de Innovación**

---

**¿Problemas?** Abre un [issue](../../issues) o ejecuta `./scripts/troubleshoot.sh`

**¿Dudas técnicas?** Lee [ARCHITECTURE.md](dokploy-infra/ARCHITECTURE.md)

---

⭐ Si te fue útil, deja una estrella en el repo
