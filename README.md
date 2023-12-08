# Playground GitOps

## 1. Usage

To use this workspace, update the `inventory` file with the hosts, update the roles and playbooks as needed, and run Ansible with the `-i` option pointing to the `inventory` file.

Tasks:

```bash
ansible-playbook -i internal/inventory/inventory.ini internal/playbooks/setup-environment.yml
```
