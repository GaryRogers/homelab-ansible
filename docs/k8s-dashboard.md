# Kubernetes Dashboard Playbook

## Overview

This playbook installs and configures the Kubernetes Dashboard web interface for your K3s cluster using Helm, providing a comprehensive web-based UI for managing Kubernetes resources.

## Features

- **Helm-based Installation**: Uses the official Kubernetes Dashboard Helm chart
- **Secure Authentication**: Creates admin user with cluster-admin privileges
- **Bearer Token Access**: Generates secure authentication tokens
- **Port Forwarding**: Provides secure HTTPS access via kubectl port-forward
- **mDNS Advertisement**: Automatically advertises the service via Avahi/Bonjour
- **Systemd Integration**: Optional persistent service for always-on access
- **Firewall Configuration**: Automatically opens required ports
- **Comprehensive Testing**: Includes validation playbook to verify installation

## Prerequisites

1. **K3s Cluster**: Running and accessible
2. **Helm**: Package manager installed
3. **kubectl**: Configured with cluster access
4. **Ansible Collections**: `kubernetes.core` collection available

## Installation

```bash
# Install the dashboard
ansible-playbook -i inventory/inventory.yaml playbooks/k8s-dashboard.yaml

# Test the installation
ansible-playbook -i inventory/inventory.yaml playbooks/tests/k8s-dashboard.yaml
```

## Access Methods

### Method 1: Convenience Script (Recommended)
```bash
# Start port-forward and display access information
/usr/local/bin/k8s-dashboard
```

### Method 2: Manual Port Forward
```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

### Method 3: Persistent Systemd Service
```bash
# Enable and start the service
sudo systemctl enable k8s-dashboard-proxy
sudo systemctl start k8s-dashboard-proxy

# Check status
sudo systemctl status k8s-dashboard-proxy
```

## Authentication

The dashboard requires Bearer Token authentication:

1. **Get Token**: 
   ```bash
   kubectl -n kubernetes-dashboard create token admin-user
   ```

2. **Login**: 
   - Open https://localhost:8443
   - Select "Token" authentication method
   - Paste the token and click "Sign in"

## Configuration Details

### Namespace and Resources
- **Namespace**: `kubernetes-dashboard`
- **Release Name**: `kubernetes-dashboard`
- **Service**: `kubernetes-dashboard-kong-proxy`
- **Port**: `8443` (HTTPS)

### Admin User
- **ServiceAccount**: `admin-user`
- **ClusterRoleBinding**: Grants `cluster-admin` privileges
- **Token Secret**: Long-lived token for authentication

### Security Features
- HTTPS-only access (certificates handled by Dashboard)
- Local access only via port-forward (no external exposure)
- Token-based authentication
- Kubernetes RBAC integration

## Troubleshooting

### Check Dashboard Status
```bash
# Check pods
kubectl -n kubernetes-dashboard get pods

# Check services
kubectl -n kubernetes-dashboard get svc

# Check logs
kubectl -n kubernetes-dashboard logs -l app.kubernetes.io/name=kubernetes-dashboard
```

### Common Issues

1. **Dashboard not accessible**
   - Verify K3s is running: `kubectl get nodes`
   - Check port-forward: `ps aux | grep port-forward`
   - Verify firewall: `sudo ufw status`

2. **Token authentication fails**
   - Generate new token: `kubectl -n kubernetes-dashboard create token admin-user`
   - Verify ServiceAccount exists: `kubectl -n kubernetes-dashboard get sa admin-user`
   - Check ClusterRoleBinding: `kubectl get clusterrolebinding admin-user`

3. **Installation fails**
   - Verify Helm is installed: `helm version`
   - Check Helm repositories: `helm repo list`
   - Update repositories: `helm repo update`

### Regenerate Components

```bash
# Reinstall dashboard
ansible-playbook playbooks/k8s-dashboard.yaml --tags dashboard,install

# Recreate admin user
ansible-playbook playbooks/k8s-dashboard.yaml --tags admin

# Update access scripts
ansible-playbook playbooks/k8s-dashboard.yaml --tags script,systemd
```

## Files Created

- `/opt/ansible/playbooks/k8s-dashboard.yaml` - Main installation playbook
- `/opt/ansible/playbooks/tests/k8s-dashboard.yaml` - Test and validation playbook
- `/opt/ansible/templates/bonjour/k8s-dashboard.service.j2` - Avahi service template
- `/usr/local/bin/k8s-dashboard` - Convenience access script
- `/etc/systemd/system/k8s-dashboard-proxy.service` - Systemd service
- `/etc/avahi/services/k8s-dashboard.service` - mDNS advertisement

## Integration with HomeLab

This dashboard integrates seamlessly with your existing HomeLab infrastructure:

- **Service Discovery**: Advertised via Avahi/mDNS as "Kubernetes Dashboard on hostname"
- **Firewall**: Automatically configures UFW rules for port 8443
- **Monitoring**: Can be monitored via the AI agents framework
- **Backup**: Configuration backed up in standard log format

## Dashboard Features

Once installed, the dashboard provides:

- **Cluster Overview**: Node status, resource utilization
- **Workload Management**: Deployments, ReplicaSets, StatefulSets, DaemonSets
- **Service & Networking**: Services, Ingresses, Network Policies
- **Storage**: PersistentVolumes, PersistentVolumeClaims
- **Configuration**: ConfigMaps, Secrets
- **RBAC**: ServiceAccounts, Roles, RoleBindings
- **Custom Resources**: CRDs and custom resources
- **Logs & Events**: Real-time log viewing and event monitoring

## Reference

- [Official Kubernetes Dashboard Documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
- [Dashboard GitHub Repository](https://github.com/kubernetes/dashboard)
- [Helm Chart](https://github.com/kubernetes/dashboard/tree/master/charts/kubernetes-dashboard)