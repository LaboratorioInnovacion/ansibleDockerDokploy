# Rol Node.js - REQUERIDO para Dokploy

## ✅ Este rol ES necesario

Dokploy instalado nativamente **requiere Node.js 20+** y **pnpm** para funcionar.

## Qué instala

- Node.js {{ node_version }} (LTS)
- npm (incluido con Node.js)
- pnpm (gestor de paquetes rápido)

## Cómo funciona

1. Detecta si Node.js ya está instalado
2. Usa NodeSource repository para versión específica
3. Instala pnpm globalmente
4. Idempotente: No reinstala si ya existe

## Versiones

Configurable en `vars/main.yml`:
```yaml
node_version: "20"  # LTS
pnpm_version: "8"
```

---

**Requerido por:** Dokploy nativo
