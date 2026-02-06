.PHONY: help install-deps install-local install-vps validate check clean

help: ## Mostrar ayuda
	@echo "================================================"
	@echo "🚀 Dokploy Infrastructure - Makefile"
	@echo "================================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo "================================================"

install-deps: ## Instalar dependencias Ansible
	@echo "Installing Ansible collections..."
	@ansible-galaxy collection install -r ansible/requirements.yml
	@echo "✓ Dependencies installed"

install-local: ## Ejecutar playbook en localhost (WSL/local)
	@cd ansible && ansible-playbook -i inventory/local.ini playbooks/setup.yml --ask-become-pass

install-vps: ## Ejecutar playbook en VPS remoto
	@cd ansible && ansible-playbook -i inventory/vps.ini playbooks/setup.yml --ask-become-pass

validate: ## Solo validar instalación existente
	@cd ansible && ansible-playbook -i inventory/local.ini playbooks/setup.yml --tags validation

check: ## Dry-run del playbook (sin cambios)
	@cd ansible && ansible-playbook -i inventory/local.ini playbooks/setup.yml --check

lint: ## Verificar syntax del playbook
	@cd ansible && ansible-playbook playbooks/setup.yml --syntax-check
	@echo "✓ Syntax OK"

list-tasks: ## Listar todas las tareas
	@cd ansible && ansible-playbook -i inventory/local.ini playbooks/setup.yml --list-tasks

list-tags: ## Listar todos los tags
	@cd ansible && ansible-playbook -i inventory/local.ini playbooks/setup.yml --list-tags

docker-only: ## Solo instalar Docker
	@cd ansible && ansible-playbook -i inventory/local.ini playbooks/setup.yml --tags docker

dokploy-only: ## Solo instalar Dokploy
	@cd ansible && ansible-playbook -i inventory/local.ini playbooks/setup.yml --tags dokploy

firewall-only: ## Solo configurar firewall
	@cd ansible && ansible-playbook -i inventory/local.ini playbooks/setup.yml --tags firewall

clean: ## Limpiar facts cache
	@rm -rf /tmp/ansible_facts
	@echo "✓ Cache cleaned"

status: ## Ver estado de Dokploy
	@systemctl status dokploy --no-pager

logs: ## Ver logs de Dokploy
	@journalctl -u dokploy -f

restart: ## Reiniciar Dokploy
	@sudo systemctl restart dokploy
	@echo "✓ Dokploy restarted"

stop: ## Detener Dokploy
	@sudo systemctl stop dokploy
	@echo "✓ Dokploy stopped"

start: ## Iniciar Dokploy
	@sudo systemctl start dokploy
	@echo "✓ Dokploy started"

remove: ## Eliminar servicio Dokploy (mantiene instalación)
	@sudo systemctl stop dokploy || true
	@sudo systemctl disable dokploy || true
	@sudo rm -f /etc/systemd/system/dokploy.service
	@sudo systemctl daemon-reload
	@echo "✓ Dokploy service removed (files preserved in /opt/dokploy)"

purge: ## Eliminar Dokploy completamente
	@sudo systemctl stop dokploy || true
	@sudo systemctl disable dokploy || true
	@sudo rm -f /etc/systemd/system/dokploy.service
	@sudo systemctl daemon-reload
	@docker network rm dokploy_net || true
	@sudo rm -rf /opt/dokploy
	@sudo userdel dokploy || true
	@echo "⚠️  Dokploy purged completely"

info: ## Información del sistema
	@echo "System: $$(uname -a)"
	@echo "Docker: $$(docker --version)"
	@echo "Compose: $$(docker compose version)"
	@echo "Node.js: $$(node --version)"
	@echo "pnpm: $$(pnpm --version)"
	@echo "Ansible: $$(ansible --version | head -n1)"
	@echo "Dokploy: systemctl status dokploy"
