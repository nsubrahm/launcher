# Installation Guide

This guide provides detailed information about installing Maintenance Mitra using our automated installer.

## Table of Contents
- [Installation Guide](#installation-guide)
  - [Prerequisites](#prerequisites)
  - [Installation Process](#installation-process)
  - [Installation Phases](#installation-phases)
  - [Configuration Options](#configuration-options)
  - [Troubleshooting](#troubleshooting)
  - [Rollback Procedures](#rollback-procedures)

## Prerequisites

### System Requirements
- Windows Server 2019+ (recommended) or 2016+ (minimum)
- 8GB RAM (recommended) or 4GB RAM (minimum)
- 4 CPU cores (recommended) or 2 CPU cores (minimum)
- 100GB storage (recommended) or 50GB storage (minimum)
- Docker Engine 20.10.0+
- Internet connection for downloading components

### Required Ports
- 80: HTTP interface
- 1883: MQTT broker
- 9092: Kafka broker
- Additional ports as specified in configuration

### Required Access
- Administrator privileges
- Docker Hub access
- GitHub Container Registry (ghcr.io) access

## Installation Process

1. **Download and Extract**
   ```powershell
   # Download the latest release
   $MTMT_VERSION = "0.0.0"
   Invoke-WebRequest -Uri "https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher-v${MTMT_VERSION}.zip" -OutFile "mtmt.zip"
   Expand-Archive mtmt.zip
   cd launcher-v${MTMT_VERSION}
   ```

2. **Configure GitHub Container Registry**
   ```powershell
   $env:CR_PAT = "your_token"
   $env:CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
   ```

3. **Run Installer**
   ```powershell
   cd install
   .\install.ps1
   ```

## Installation Phases

### 1. System Check
- Validates hardware requirements
- Verifies Docker installation
- Checks port availability
- Creates installation logs

### 2. Configuration
- Backs up existing configuration
- Generates new configuration files
- Validates configuration
- Sets up environment variables

### 3. Docker Setup
- Pulls required Docker images
- Creates Docker networks
- Prepares volumes
- Validates Docker setup

### 4. Service Deployment
The deployment follows a specific sequence:

1. **Platform Services**
   - Kafka brokers
   - ksqlDB server
   - MySQL database
   - MQTT broker

2. **Base Components**
   - HTTP input handler
   - MQTT input handler
   - Limits service

3. **Initialization**
   - Database tables
   - Kafka topics
   - Initial queries

4. **Applications**
   - Data persistence services
   - Event streaming
   - Alarm processing
   - Alert generation

### 5. Final Verification
- Checks service health
- Validates endpoints
- Verifies configurations
- Tests connectivity

## Configuration Options

### Environment Variables
- `MACHINE_ID`: Unique identifier for the installation
- `TZ`: Timezone setting
- Network configurations
- Service-specific settings

### Port Configuration
Default ports can be modified in the configuration:
- HTTP: 80
- MQTT: 1883
- Kafka: 9092

### Custom Settings
- Machine parameters
- Alert thresholds
- Data retention
- Network settings

## Troubleshooting

### Common Issues

1. **Port Conflicts**
   - Symptom: Installation fails during port check
   - Solution: Choose alternative ports or stop conflicting services

2. **Docker Issues**
   - Symptom: Container health checks fail
   - Solution: Check Docker logs and service status

3. **Network Issues**
   - Symptom: Services can't communicate
   - Solution: Verify network configuration and firewall settings

### Logs Location
- Installation logs: `install/logs/`
- Service logs: Available through Docker

## Rollback Procedures

### Manual Rollback
```powershell
.\install.ps1 -Phase full-rollback
```

### Phase-specific Rollback
```powershell
.\install.ps1 -Phase config-rollback    # Configuration rollback
.\install.ps1 -Phase docker-rollback    # Docker setup rollback
.\install.ps1 -Phase deploy-rollback    # Deployment rollback
```

### Backup Restoration
- Configuration backups: `install/backups/`
- Database backups: If configured
