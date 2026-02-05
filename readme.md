## Requisitos
- Ubuntu 22.04+
- Ansible
- SSH

## Instalación en WSL
ansible-playbook -i inventory/local.ini playbooks/setup.yml

## Instalación en VPS
ansible-playbook -i inventory/vps.ini playbooks/setup.yml
