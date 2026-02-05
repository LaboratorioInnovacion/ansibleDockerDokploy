# 🎯 Guía de Ejecución Paso a Paso

Esta guía te llevará desde cero hasta tener Dokploy funcionando.

## 📋 Checklist Pre-Ejecución

- [ ] Ubuntu 20.04+ / WSL2 Ubuntu
- [ ] Usuario con sudo
- [ ] 2GB+ RAM disponible
- [ ] 20GB+ disco disponible
- [ ] Internet accesible

## 🚀 Opción 1: Instalación en WSL (Recomendado para desarrollo)

### Paso 1: Habilitar Systemd en WSL (si no está habilitado)

```bash
# Verificar si systemd está activo
ps --no-headers -o comm 1

# Si no dice "systemd", configurarlo:
sudo nano /etc/wsl.conf

# Agregar:
[boot]
systemd=true

# Guardar (Ctrl+O, Enter, Ctrl+X)

# Desde PowerShell/CMD:
wsl --shutdown

# Volver a abrir WSL
```

### Paso 2: Ejecutar Bootstrap (Primera vez)

```bash
cd dokploy-infra/scripts
chmod +x wsl-bootstrap.sh
./wsl-bootstrap.sh

# Este script instalará:
# - Ansible
# - Collections necesarias
# - Python prerequisites
```

### Paso 3: Ejecutar Playbook

```bash
cd ../ansible
ansible-playbook -i inventory/local.ini playbooks/setup.yml

# Duración: 5-10 minutos
# Verás:
# - Instalación de Docker
# - Configuración de usuario
# - Despliegue de Dokploy
# - Validaciones
```

### Paso 4: Verificar Instalación

```bash
# Test rápido
cd ../scripts
chmod +x test-installation.sh
./test-installation.sh

# Acceder a Dokploy
# En tu navegador: http://localhost:3000
```

### Paso 5: Si algo falla

```bash
# Diagnóstico completo
cd dokploy-infra/scripts
chmod +x troubleshoot.sh
./troubleshoot.sh

# Ver logs de Dokploy
journalctl -u dokploy -f

# Reiniciar Dokploy
sudo systemctl restart dokploy
```

---

## 🌐 Opción 2: Instalación en VPS/Servidor

### Paso 1: Preparar Control Node (tu máquina)

```bash
# Instalar Ansible (si no lo tienes)
pip install ansible

# Clonar/descargar el repositorio
git clone <tu-repo>
cd ansibleDockerDokploy/dokploy-infra

# Instalar collections
ansible-galaxy collection install -r ansible/requirements.yml
```

### Paso 2: Configurar Inventory

```bash
# Editar inventory para VPS
nano ansible/inventory/vps.ini

# Actualizar:
[servers]
mi-vps ansible_host=TU_IP_REAL ansible_user=TU_USUARIO

# Guardar
```

### Paso 3: Probar Conectividad

```bash
cd ansible

# Test ping
ansible -i inventory/vps.ini servers -m ping

# Debe responder:
# mi-vps | SUCCESS => { "ping": "pong" }
```

### Paso 4: Ejecutar Playbook

```bash
# Ejecución con sudo password
ansible-playbook -i inventory/vps.ini playbooks/setup.yml --ask-become-pass

# Ingresar password de sudo cuando lo pida

# Duración: 5-10 minutos
```

### Paso 5: Verificar Acceso

```bash
# En tu navegador:
http://TU_IP:3000

# O desde terminal:
curl http://TU_IP:3000
```

---

## 🔧 Opción 3: Usando Makefile (Más Fácil)

### Setup Inicial

```bash
cd dokploy-infra

# Ver comandos disponibles
make help

# Instalar dependencies
make install-deps
```

### Ejecutar

```bash
# Para WSL/Local
make install-local

# Para VPS (después de configurar inventory/vps.ini)
make install-vps

# Solo validar
make validate

# Ver estado
make status

# Ver logs
make logs
```

---

## 📊 Qué Esperar Durante la Ejecución

### Fase 1: System Detection (30 segundos)
```
TASK [system_detection : Detect if running on WSL]
TASK [system_detection : Check systemd availability]
```
✓ Detecta entorno y capabilities

### Fase 2: Docker Installation (2-4 minutos)
```
TASK [docker : Install common packages]
TASK [docker : Add Docker repository]
TASK [docker : Install Docker packages]
```
✓ Instala Docker + Compose v2

### Fase 3: Firewall (30 segundos)
```
TASK [firewall : Check if UFW is installed]
TASK [firewall : Allow specified ports]
```
✓ Configura puertos (skip en WSL)

### Fase 4: Dokploy Deployment (2-3 minutos)
```
TASK [dokploy : Create Docker network]
TASK [dokploy : Pull Dokploy image]
TASK [dokploy : Deploy Dokploy container]
```
✓ Despliega Dokploy

### Fase 5: Validation (30 segundos)
```
TASK [validation : Validate Docker service]
TASK [validation : Check Dokploy container status]
```
✓ Verifica todo funciona

### Resultado Final
```
================================================
✓ SETUP COMPLETED SUCCESSFULLY
================================================
Dokploy is ready at: http://localhost:3000

Next steps:
1. Access Dokploy web interface
2. Complete initial configuration
3. Deploy your applications
================================================
```

---

## 🐛 Troubleshooting Común

### Error: "docker: permission denied"

**Causa:** Usuario no tiene permisos para Docker socket

**Solución:**
```bash
# Opción 1: Re-login
exit
# Volver a entrar

# Opción 2: Forzar grupo
newgrp docker

# Opción 3: Re-ejecutar playbook
cd dokploy-infra/ansible
ansible-playbook -i inventory/local.ini playbooks/setup.yml
```

### Error: "Failed to connect to bus"

**Causa:** Systemd no habilitado en WSL

**Solución:**
```bash
# Ver instrucciones Paso 1 de WSL
sudo nano /etc/wsl.conf
# Agregar systemd=true
# wsl --shutdown desde PowerShell
```

### Error: "Cannot connect to Docker daemon"

**Causa:** Docker service no está corriendo

**Solución:**
```bash
# Verificar estado
sudo systemctl status docker

# Iniciar manualmente
sudo systemctl start docker

# Habilitar en boot
sudo systemctl enable docker
```

### Dokploy no responde en puerto 3000

**Causa:** Container corriendo pero app no lista

**Solución:**
```bash
# Ver logs
docker logs dokploy

# Esperar 1-2 minutos adicionales
# La primera vez puede tardar

# Verificar health
docker inspect dokploy | grep -A5 Health
```

### Firewall bloqueando conexión

**Causa:** UFW configurado pero puerto no abierto

**Solución:**
```bash
# Ver reglas
sudo ufw status

# Abrir puerto manualmente
sudo ufw allow 3000/tcp
sudo ufw reload
```

---

## ✅ Verificación Post-Instalación

```bash
# 1. Docker funcionando
docker ps
# Debe mostrar contenedor 'dokploy' en estado 'Up'

# 2. Docker sin sudo
docker ps
# No debe pedir password ni dar error

# 3. Network creada
docker network ls | grep dokploy
# Debe mostrar 'dokploy_net'

# 4. Dokploy responde
curl -I http://localhost:3000
# Debe retornar HTTP 200

# 5. Test completo
cd dokploy-infra/scripts
./test-installation.sh
# Todos los tests deben pasar
```

---

## 🎓 Próximos Pasos

Una vez Dokploy está corriendo:

1. **Acceder a la UI**: `http://localhost:3000`
2. **Configurar cuenta inicial**: Sigue el wizard
3. **Conectar repositorios**: GitHub, GitLab, etc.
4. **Desplegar primera app**: Usa el dashboard
5. **Configurar dominio** (opcional): Traefik/Nginx

---

## 📚 Recursos Adicionales

- [Documentación Dokploy](https://docs.dokploy.com)
- [ARCHITECTURE.md](ARCHITECTURE.md) - Decisiones técnicas
- [Troubleshoot Script](scripts/troubleshoot.sh) - Diagnóstico
- [Makefile](Makefile) - Comandos útiles

---

## 🆘 Soporte

Si después de todos estos pasos sigues con problemas:

1. Ejecuta: `./scripts/troubleshoot.sh > diagnostic.txt`
2. Abre un issue en GitHub adjuntando `diagnostic.txt`
3. Incluye:
   - OS y versión
   - Output del error
   - Logs de `journalctl -u dokploy`

---

**¡Listo! Ahora tienes una infraestructura Dokploy production-ready.** 🚀
