# 🔄 Refactorización: Instalación Nativa de Dokploy

## ✅ Cambio Implementado

**Antes**: Dokploy se instalaba como contenedor Docker  
**Ahora**: Dokploy se instala **nativamente** en el sistema como servicio systemd

---

## 🎯 Por qué este cambio

### Problema Original
Instalar Dokploy dentro de Docker creaba conflictos:
- Dokploy necesita Docker para gestionar contenedores
- Docker-in-Docker es complejo y problemático
- Conflictos de permisos con socket Docker
- Debugging más difícil

### Solución: Instalación Nativa
- Dokploy corre directamente en el SO
- Usa Docker del host (sin conflictos)
- Servicio systemd estándar
- Logs con journalctl
- Sin capas innecesarias

---

## 📊 Arquitectura Nueva

```
┌─────────────────────────────────────────┐
│         Sistema Operativo                │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │   Docker Engine                    │ │
│  │   - Gestiona containers            │ │
│  │   - Usado POR Dokploy              │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │   Dokploy (Servicio systemd)       │ │
│  │   - Instalado en /opt/dokploy      │ │
│  │   - Node.js 20 + pnpm              │ │
│  │   - Puerto 3000                    │ │
│  │   - GESTIONA Docker (no corre en él)│ │
│  └────────────────────────────────────┘ │
│                                          │
│  Usuario dokploy ∈ grupo docker         │
└─────────────────────────────────────────┘
```

---

## 🔧 Qué Cambió en el Código

### 1. Variables (vars/main.yml)
```yaml
# Antes
dokploy_container_name: "dokploy"
dokploy_data_dir: "/opt/dokploy"

# Ahora
dokploy_install_dir: "/opt/dokploy"
dokploy_user: "dokploy"
dokploy_version: "v0.8.0"
node_version: "20"
pnpm_version: "8"
```

### 2. Rol Node (REQUERIDO ahora)
**Antes**: Deprecado, no se usaba  
**Ahora**: OBLIGATORIO
- Instala Node.js 20 LTS
- Instala pnpm globalmente
- Verifica versiones

### 3. Rol Dokploy (Refactorizado completo)
**Antes:**
```yaml
- name: Deploy Dokploy container
  docker_container:
    name: "dokploy"
    image: "dokploy/dokploy:latest"
```

**Ahora:**
```yaml
- name: Clone Dokploy repository
  git:
    repo: "{{ dokploy_repo }}"
    dest: "{{ dokploy_install_dir }}"
    version: "{{ dokploy_version }}"

- name: Build Dokploy
  command: pnpm run build

- name: Create systemd service
  template:
    src: dokploy.service.j2
    dest: /etc/systemd/system/dokploy.service
```

### 4. Template Systemd
**Nuevo archivo**: `roles/dokploy/templates/dokploy.service.j2`
```ini
[Service]
Type=simple
User=dokploy
WorkingDirectory=/opt/dokploy
ExecStart=/usr/bin/pnpm run start
Restart=always
```

### 5. Validaciones Actualizadas
**Antes:**
- Verificaba container Docker
- `docker ps --filter name=dokploy`

**Ahora:**
- Verifica servicio systemd
- `systemctl is-active dokploy`
- Verifica Node.js y pnpm
- Verifica directorio /opt/dokploy

### 6. Playbook (setup.yml)
**Agregado**:
```yaml
roles:
  - role: node  # ← AHORA INCLUIDO
    tags: ['node', 'runtime']
```

---

## 🎓 Gestión del Servicio

### Comandos systemd
```bash
# Estado
systemctl status dokploy

# Logs
journalctl -u dokploy -f

# Reiniciar
sudo systemctl restart dokploy

# Detener
sudo systemctl stop dokploy

# Iniciar
sudo systemctl start dokploy

# Deshabilitar autostart
sudo systemctl disable dokploy
```

### Makefile actualizado
```bash
make status   # systemctl status dokploy
make logs     # journalctl -u dokploy -f
make restart  # systemctl restart dokploy
```

---

## ✅ Ventajas de la Instalación Nativa

| Aspecto | Containerizado | Nativo |
|---------|---------------|--------|
| Conflictos Docker | ⚠️ Docker-in-Docker | ✅ Sin conflictos |
| Debugging | ❌ Difícil | ✅ journalctl estándar |
| Performance | ⚠️ Overhead adicional | ✅ Directo en SO |
| Gestión | ❌ `docker logs` | ✅ systemctl |
| Permisos | ⚠️ Socket mounting | ✅ Usuario en grupo |
| Updates | ❌ Re-pull imagen | ✅ Git pull + rebuild |
| Startup | ❌ Docker restart | ✅ systemd automático |

---

## 🔒 Sin Conflictos

### Docker NO conflictúa con Dokploy
- **Docker Engine**: Corre como daemon del sistema
- **Dokploy**: Aplicación Node.js que usa Docker CLI
- **Usuario dokploy**: Parte del grupo `docker`
- **Socket**: `/var/run/docker.sock` accesible para el usuario

```
Dokploy (Node.js app)
    ↓ usa
Docker CLI
    ↓ comunica via
Docker Socket (/var/run/docker.sock)
    ↓ conecta con
Docker Daemon (dockerd)
    ↓ gestiona
Containers de aplicaciones desplegadas
```

---

## 📦 Estructura de Archivos

```
/opt/dokploy/              # Instalación Dokploy
├── .git/                  # Repo git
├── node_modules/          # Dependencias
├── dist/                  # Build compilado
├── package.json
├── pnpm-lock.yaml
└── database/              # SQLite DB

/etc/systemd/system/
└── dokploy.service        # Servicio systemd

/var/log/journal/
└── dokploy logs           # Logs del servicio
```

---

## 🚀 Proceso de Instalación

1. **System Detection** → Detecta WSL, systemd
2. **Docker** → Instala Docker Engine
3. **Node.js** → Instala Node 20 + pnpm
4. **Firewall** → Configura UFW (si aplica)
5. **Dokploy** → Clone → Build → Service
6. **Validation** → Tests completos

**Tiempo estimado**: 5-10 minutos

---

## 🐛 Troubleshooting Específico

### "pnpm: command not found"
```bash
npm install -g pnpm
# O re-ejecutar playbook con --tags node
```

### "Failed to start dokploy.service"
```bash
journalctl -u dokploy -n 50
# Ver logs de error
```

### Rebuild manual
```bash
cd /opt/dokploy
sudo -u dokploy pnpm install
sudo -u dokploy pnpm run build
sudo systemctl restart dokploy
```

### Actualizar Dokploy
```bash
cd /opt/dokploy
sudo -u dokploy git pull origin v0.8.0
sudo -u dokploy pnpm install
sudo -u dokploy pnpm run build
sudo systemctl restart dokploy
```

---

## ✨ Resultado Final

**Después de ejecutar el playbook:**

✅ Docker instalado y funcionando  
✅ Node.js 20 + pnpm instalados  
✅ Dokploy clonado en /opt/dokploy  
✅ Dokploy compilado y corriendo  
✅ Servicio systemd activo  
✅ Puerto 3000 accesible  
✅ Usuario dokploy con permisos Docker  
✅ Sin conflictos entre componentes  
✅ Logs centralizados en journalctl  
✅ Arranque automático configurado  

**Acceso:** http://localhost:3000  
**Gestión:** systemctl & journalctl  
**Sin pasos manuales adicionales** 🚀

---

## 📝 Migración desde Containerizado

Si ya tenías la versión containerizada:

```bash
# 1. Detener container viejo
docker stop dokploy
docker rm dokploy

# 2. Backup datos (si aplica)
docker cp dokploy:/app/data /backup/dokploy-data

# 3. Re-ejecutar playbook
cd dokploy-infra/ansible
ansible-playbook -i inventory/local.ini playbooks/setup.yml

# 4. Restaurar datos (si necesario)
sudo cp -r /backup/dokploy-data/* /opt/dokploy/database/
```

---

**Instalación nativa = Mayor control + Sin conflictos + Debugging fácil** 🎯
