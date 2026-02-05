# 🚀 Guía Rápida - Instalación en WSL2 Desde Cero

## ⏱️ Tiempo estimado: 15-20 minutos

---

## ✅ Pre-requisitos

1. **WSL2 con Ubuntu** instalado
2. **Systemd habilitado** en WSL
3. Acceso a Internet

---

## 🔧 Paso 1: Habilitar Systemd en WSL2 (si no está)

```bash
# Dentro de WSL Ubuntu
sudo nano /etc/wsl.conf
```

Agregar:
```ini
[boot]
systemd=true

[network]
generateResolvConf=true
```

Guardar (`Ctrl+O`, `Enter`, `Ctrl+X`)

**Desde PowerShell (Windows):**
```powershell
wsl --shutdown
```

Volver a abrir WSL Ubuntu.

**Verificar systemd:**
```bash
ps --no-headers -o comm 1
# Debe mostrar: systemd
```

---

## 📦 Paso 2: Instalar Ansible

```bash
# Actualizar sistema
sudo apt update

# Instalar dependencias
sudo apt install -y software-properties-common

# Agregar repositorio Ansible
sudo apt-add-repository --yes --update ppa:ansible/ansible

# Instalar Ansible
sudo apt install -y ansible

# Verificar
ansible --version
```

---

## 📥 Paso 3: Clonar el Repositorio

```bash
# Ir a tu directorio de trabajo
cd ~

# Clonar repo
git clone https://github.com/LaboratorioInnovacion/ansibleDockerDokploy.git

# Entrar al directorio
cd ansibleDockerDokploy/dokploy-infra
```

---

## 🔑 Paso 4: Instalar Collections de Ansible

```bash
cd ansible

# Instalar collections necesarias
ansible-galaxy collection install community.docker ansible.posix

# Verificar instalación
ansible-galaxy collection list | grep -E "community.docker|ansible.posix"
```

---

## ⚡ Paso 5: Ejecutar la Instalación

```bash
# Desde: ~/ansibleDockerDokploy/dokploy-infra/ansible

# Opción 1: Con ansible-playbook directo
ansible-playbook -i inventory/local.ini playbooks/setup.yml

# Opción 2: Con Makefile (si prefieres)
cd ..
make install-local
```

**Esto instalará:**
- ✅ Docker + Docker Compose v2
- ✅ Node.js 20 + pnpm
- ✅ Dokploy (nativo, en /opt/dokploy)
- ✅ Servicio systemd para Dokploy
- ✅ Red Docker dokploy_net
- ✅ Firewall deshabilitado (WSL)

---

## 🎯 Paso 6: Verificar Instalación

```bash
# Test rápido
cd ~/ansibleDockerDokploy/dokploy-infra/scripts
chmod +x test-installation.sh
./test-installation.sh
```

**Debería mostrar:**
```
✓ Docker service
✓ Docker Compose v2
✓ User in docker group
✓ Docker without sudo
✓ Node.js installed
✓ pnpm installed
✓ Dokploy network
✓ Dokploy service
✓ Dokploy directory
✓ Dokploy responding
```

---

## 🌐 Paso 7: Acceder a Dokploy

Abre tu navegador:
```
http://localhost:3000
```

O desde Windows:
```
http://<IP-WSL>:3000
```

Para saber tu IP de WSL:
```bash
ip addr show eth0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
```

---

## 📊 Comandos Útiles Post-Instalación

```bash
# Ver estado del servicio
systemctl status dokploy

# Ver logs en tiempo real
journalctl -u dokploy -f

# Reiniciar Dokploy
sudo systemctl restart dokploy

# Detener Dokploy
sudo systemctl stop dokploy

# Iniciar Dokploy
sudo systemctl start dokploy

# Ver containers Docker (gestión de Dokploy)
docker ps

# Test Docker sin sudo
docker ps
# Si falla: logout y login de nuevo
```

---

## 🐛 Troubleshooting Común

### "docker: permission denied"
```bash
# Cerrar y reabrir WSL
exit
# Volver a entrar a WSL

# O forzar cambio de grupo
newgrp docker
```

### Dokploy no inicia
```bash
# Ver logs detallados
journalctl -u dokploy -n 100

# Verificar instalación
ls -la /opt/dokploy

# Verificar usuario
sudo su - dokploy -s /bin/bash
docker ps
exit
```

### Rebuild Dokploy
```bash
cd /opt/dokploy
sudo -u dokploy pnpm install
sudo -u dokploy pnpm run build
sudo systemctl restart dokploy
```

---

## 📝 Estructura Instalada

```
/opt/dokploy/                    # Instalación Dokploy
  ├── .git/
  ├── node_modules/
  ├── dist/                      # Build compilado
  ├── database/                  # SQLite DB
  └── package.json

/etc/systemd/system/
  └── dokploy.service            # Servicio systemd

Docker containers:               # Gestionados por Dokploy
  └── (tus aplicaciones)
```

---

## ✅ Checklist Final

- [ ] Systemd habilitado en WSL
- [ ] Ansible instalado
- [ ] Collections instaladas
- [ ] Playbook ejecutado sin errores
- [ ] Tests pasados
- [ ] Dokploy accesible en http://localhost:3000
- [ ] `docker ps` funciona sin sudo
- [ ] `systemctl status dokploy` muestra "active (running)"

---

## 🎓 Siguientes Pasos

1. **Configurar Dokploy:**
   - Acceder a http://localhost:3000
   - Crear usuario admin
   - Configurar settings

2. **Desplegar primera app:**
   - Conectar repositorio Git
   - Configurar build
   - Deploy automático

3. **Gestión:**
   - Logs: `journalctl -u dokploy -f`
   - Restart: `sudo systemctl restart dokploy`
   - Status: `systemctl status dokploy`

---

## 📚 Documentación Adicional

- [NATIVE_INSTALLATION.md](NATIVE_INSTALLATION.md) - Arquitectura detallada
- [README.md](README.md) - Guía completa
- [ARCHITECTURE.md](ARCHITECTURE.md) - Decisiones técnicas

---

## 🆘 Ayuda

Si algo falla:
```bash
# Diagnóstico completo
cd ~/ansibleDockerDokploy/dokploy-infra/scripts
chmod +x troubleshoot.sh
./troubleshoot.sh
```

---

**¡Listo! Dokploy instalado nativamente en WSL2 sin conflictos con Docker.** 🚀

## 📊 Resumen Comando a Comando

```bash
# 1. Habilitar systemd
sudo nano /etc/wsl.conf  # Agregar [boot] systemd=true
# Desde PowerShell: wsl --shutdown
# Reabrir WSL

# 2. Instalar Ansible
sudo apt update
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# 3. Clonar repo
cd ~
git clone https://github.com/LaboratorioInnovacion/ansibleDockerDokploy.git
cd ansibleDockerDokploy/dokploy-infra/ansible

# 4. Instalar collections
ansible-galaxy collection install community.docker ansible.posix

# 5. Ejecutar instalación
ansible-playbook -i inventory/local.ini playbooks/setup.yml

# 6. Verificar
systemctl status dokploy
journalctl -u dokploy -f

# 7. Acceder
# http://localhost:3000
```

**Tiempo total: 15-20 minutos** ⏱️
