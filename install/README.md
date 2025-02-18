# Maintenance Mitra Installer

This directory contains the installation scripts and configuration for Maintenance Mitra.

## Directory Structure

```
install/
├── install.ps1              # Main installation script
├── config/
│   └── install_config.yaml  # Installation configuration
├── logs/                    # Installation logs (created during install)
└── backups/                 # Backup files (created during install)
```

## Installation Steps

1. Download and extract the Maintenance Mitra release package
2. Open PowerShell as Administrator
3. Navigate to the installation directory
4. Run the installation script:
   ```powershell
   .\install.ps1
   ```

## Installation Phases

The installation process is divided into several phases:

1. **System Check** (`check`)
   - Validates system requirements
   - Checks Docker installation
   - Verifies port availability
   - Creates installation log

2. **Configuration Setup** (`config`)
   - Backs up existing config
   - Creates new configuration
   - Validates configuration

3. **Docker Setup** (`docker`)
   - Pulls required images
   - Creates networks
   - Sets up volumes

4. **Service Deployment** (`deploy`)
   - Starts containers
   - Runs initial setup
   - Verifies service health

5. **Final Verification** (`verify`)
   - Runs system tests
   - Checks all endpoints
   - Validates configurations

## Rollback Operations

To rollback any phase of the installation:

```powershell
.\install.ps1 -Phase <phase-name>-rollback
```

Available rollback operations:
- `config-rollback`: Restores original configuration
- `docker-rollback`: Removes Docker resources
- `deploy-rollback`: Stops and removes services
- `full-rollback`: Complete system rollback

## Logs

Installation logs are created in the `logs` directory with timestamp:
```
logs/install_YYYYMMDD_HHMMSS.log
```

## Support

For installation support, please contact our support team or raise an issue on GitHub.
