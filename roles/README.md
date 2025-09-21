# Ansible Roles Directory

This directory is reserved for custom Ansible roles.

## Structure
```
roles/
├── role-name/
│   ├── tasks/
│   │   └── main.yml
│   ├── handlers/
│   │   └── main.yml
│   ├── templates/
│   ├── files/
│   ├── vars/
│   │   └── main.yml
│   ├── defaults/
│   │   └── main.yml
│   ├── meta/
│   │   └── main.yml
│   └── README.md
```

## Usage
Create roles using:
```bash
ansible-galaxy init role-name
```