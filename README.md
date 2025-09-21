# HomeLab Ansible Configuration

**Automated infrastructure management for a local Kubernetes-based homelab environment.**

## 🏠 Overview

This repository contains Ansible playbooks and configurations for managing a complete homelab infrastructure including:

- **K3s Kubernetes cluster** with ingress routing
- **SMB file sharing** with user management  
- **Nginx reverse proxy** with Wake-on-LAN integration for Ollama API
- **Bonjour/mDNS services** for easy service discovery
- **UFW firewall** configuration for security
- **Network services** and monitoring

## 📁 Repository Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── playbooks/              # Main automation playbooks
│   ├── local.yaml          # Master playbook (imports all others)
│   ├── firewall.yaml       # UFW firewall configuration
│   ├── bonjour.yaml        # mDNS/Bonjour service discovery
│   ├── smb.yaml            # Samba file sharing setup
│   ├── nginx-ollama-proxy.yaml # Nginx proxy with WoL
│   ├── k3s.yaml            # Kubernetes cluster setup
│   └── helm.yaml           # Helm package management
├── inventory/              # Ansible inventory and host configs
│   ├── inventory.yaml      # Main inventory file
│   ├── group_vars/         # Group-specific variables
│   └── host_vars/          # Host-specific variables
├── templates/              # Jinja2 templates for configs
│   └── bonjour/           # Service discovery templates
├── files/                  # Static files for deployment
├── roles/                  # Custom Ansible roles
└── README.md              # This file
```

## 🚀 Quick Start

### Prerequisites
- Ubuntu 20.04+ target system
- Ansible 2.9+ installed
- SSH key-based authentication configured
- User with sudo privileges

### Initial Setup
1. Clone this repository:
   ```bash
   git clone <your-repo-url>
   cd homelab-ansible
   ```

2. Update inventory with your target hosts:
   ```bash
   cp inventory/inventory.yaml.example inventory/inventory.yaml
   vim inventory/inventory.yaml
   ```

3. Run the complete setup:
   ```bash
   ansible-playbook -i inventory/inventory.yaml playbooks/local.yaml
   ```

## 📋 Available Playbooks

### 🔥 `firewall.yaml`
Configures UFW firewall with secure defaults:
- SSH access from local network only
- K3s API and ingress ports
- SMB sharing ports
- Custom service ports

**Usage:**
```bash
ansible-playbook playbooks/firewall.yaml
```

### 🌐 `bonjour.yaml` 
Sets up mDNS service discovery:
- SSH/SFTP services
- SMB file shares
- K3s ingress services
- Ollama proxy services

**Usage:**
```bash
ansible-playbook playbooks/bonjour.yaml
```

### 📁 `smb.yaml`
Configures Samba file sharing:
- `/opt/shared` directory setup
- User-based authentication
- macOS compatibility (VFS fruit)
- Proper permissions and security

**Usage:**
```bash
ansible-playbook playbooks/smb.yaml
# Add users: sudo smbpasswd -a <username>
```

### 🔄 `nginx-ollama-proxy.yaml`
Nginx reverse proxy with Wake-on-LAN:
- Proxies requests to GamingPC Ollama API
- Automatically wakes sleeping systems
- Health checks and monitoring
- Lua-based intelligent routing

**Usage:**
```bash
ansible-playbook playbooks/nginx-ollama-proxy.yaml
```

### ☸️ `k3s.yaml`
Kubernetes cluster setup:
- Single-node K3s installation
- Ingress controller configuration
- Storage and networking setup

### 📦 `helm.yaml`
Helm package manager setup:
- Helm v3 installation
- Common chart repositories
- Package management tools

## 🔧 Configuration

### Network Settings
Update these variables in `inventory/group_vars/local.yml`:

```yaml
# Network configuration
local_network: "192.168.4.0/24"
gaming_pc_ip: "192.168.4.56"
gaming_pc_mac: "D8:5E:D3:0C:CF:5C"

# Service ports
ssh_port: 22
k3s_api_port: 6443
k3s_ingress_port: 8080
ollama_port: 11434
```

### SMB Configuration
```yaml
smb_workgroup: "WORKGROUP"
smb_shared_directory: "/opt/shared"
smb_valid_users: "@users"
```

## 🛠 Management Commands

### Deploy Everything
```bash
ansible-playbook -i inventory/inventory.yaml playbooks/local.yaml
```

### Deploy Specific Service
```bash
ansible-playbook playbooks/smb.yaml
ansible-playbook playbooks/firewall.yaml
ansible-playbook playbooks/nginx-ollama-proxy.yaml
```

### Check Status
```bash
# Check firewall status
ansible all -m shell -a "sudo ufw status numbered"

# Check services
ansible all -m shell -a "systemctl status smbd nginx k3s"

# Check mDNS services
ansible all -m shell -a "avahi-browse -a -t"
```

## 🔍 Service Discovery

After deployment, services are discoverable via:

- **SSH**: `ssh://hostname.local:22`
- **SMB**: `smb://hostname.local/shared`
- **K3s Web**: `http://hostname.local:8080`
- **Ollama Proxy**: `http://hostname.local:11434`

## 📊 Monitoring & Logs

### Service Logs
```bash
# Nginx proxy logs
sudo tail -f /var/log/nginx/error.log

# SMB logs  
sudo tail -f /var/log/samba/log.*

# Firewall logs
sudo tail -f /var/log/ufw.log

# Ansible logs
tail -f logs/ansible.log
```

### Health Checks
```bash
# Test Ollama proxy
curl http://hostname.local:11434/api/version

# Test SMB access
smbclient -L //hostname.local -N

# Test mDNS resolution
avahi-resolve -n hostname.local
```

## 🚨 Troubleshooting

### Common Issues

**SMB Access Denied:**
```bash
# Add user to SMB
sudo smbpasswd -a username
sudo usermod -a -G users username
```

**Wake-on-LAN Not Working:**
- Check BIOS/UEFI WoL settings
- Verify network adapter WoL support
- Check MAC address in configuration

**Firewall Blocking Services:**
```bash
# Check UFW status
sudo ufw status numbered
# Add rules as needed
sudo ufw allow from 192.168.4.0/24 to any port 11434
```

**mDNS Resolution Issues:**
```bash
# Restart avahi
sudo systemctl restart avahi-daemon
# Check NSS configuration
grep mdns /etc/nsswitch.conf
```

## 🔄 Updating from GitHub

To sync changes from the repository:

```bash
# Pull latest changes
git pull origin main

# Re-run playbooks
ansible-playbook -i inventory/inventory.yaml playbooks/local.yaml
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

MIT License - see LICENSE file for details.

## 🆘 Support

For issues and questions:
- Check the troubleshooting section above
- Review service logs
- Open an issue in the repository

---

**🏠 Built for HomeLab environments with ❤️**