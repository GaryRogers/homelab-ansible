#!/bin/bash
#===============================================================================
# HomeLab GitHub Deployment Script
#===============================================================================
# Description: Simple script to pull and deploy latest changes from GitHub
# Usage: ./deploy.sh [options]
# Options:
#   --no-backup     Skip creating backup
#   --no-execute    Skip running full playbook
#   --branch <name> Specify branch (default: main)
#===============================================================================

set -e  # Exit on any error

# Default configuration
BACKUP=true
EXECUTE=true
BRANCH="main"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ANSIBLE_DIR="/opt/ansible"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
HomeLab GitHub Deployment Script

Usage: $0 [options]

Options:
    --no-backup     Skip creating backup of current configuration
    --no-execute    Skip running the full playbook after sync
    --branch <name> Specify branch to deploy (default: main)
    --help          Show this help message

Examples:
    $0                          # Full deployment with backup
    $0 --no-backup              # Deploy without backup
    $0 --branch develop         # Deploy from develop branch
    $0 --no-execute --no-backup # Just sync files, no backup or execution

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-backup)
            BACKUP=false
            shift
            ;;
        --no-execute)
            EXECUTE=false
            shift
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main deployment logic
main() {
    log_info "Starting HomeLab GitHub deployment..."
    log_info "Configuration:"
    echo "  - Backup: $BACKUP"
    echo "  - Execute: $EXECUTE"
    echo "  - Branch: $BRANCH"
    echo "  - Ansible Directory: $ANSIBLE_DIR"
    echo ""

    # Check if we're in the right directory
    if [[ ! -f "$ANSIBLE_DIR/ansible.cfg" ]]; then
        log_error "Ansible configuration not found at $ANSIBLE_DIR"
        log_error "Please ensure you're running this from the correct location"
        exit 1
    fi

    # Check if ansible-playbook is available
    if ! command -v ansible-playbook &> /dev/null; then
        log_error "ansible-playbook command not found"
        log_error "Please ensure Ansible is installed"
        exit 1
    fi

    # Change to ansible directory
    cd "$ANSIBLE_DIR"

    # Build ansible-playbook command
    ANSIBLE_CMD="ansible-playbook -i inventory/inventory.yaml playbooks/deploy-from-github.yaml"
    
    # Add extra variables
    EXTRA_VARS="github_branch=$BRANCH create_backup=$BACKUP run_full_playbook=$EXECUTE"
    ANSIBLE_CMD="$ANSIBLE_CMD -e \"$EXTRA_VARS\""

    log_info "Running deployment playbook..."
    log_info "Command: $ANSIBLE_CMD"
    echo ""

    # Execute the deployment
    if eval $ANSIBLE_CMD; then
        log_success "Deployment completed successfully!"
        
        if [[ "$EXECUTE" == "true" ]]; then
            log_info "Full playbook was executed - services should be updated"
        else
            log_warning "Full playbook was skipped - you may need to restart services manually"
        fi
        
        if [[ "$BACKUP" == "true" ]]; then
            log_info "Backup was created in /opt/ansible-backups/"
        fi
        
        echo ""
        log_info "Check the deployment log for details:"
        log_info "  sudo find /var/log -name 'homelab-github-deploy-*' | tail -1 | xargs cat"
        
    else
        log_error "Deployment failed!"
        log_error "Check the ansible output above for details"
        exit 1
    fi
}

# Run main function
main "$@"