# Introduction

Maintenance Mitra is an application to display machine parameters, detect alert conditions and duration in near real-time from one machine to one user at a time. The application is launched as a Docker Compose stack. This application is available for free with default [license](#license).

Typical use cases include capturing of data from CNC machines with FANUC, Mitsubishi, etc. controllers for discrete manufacturing to monitor the running condition of equipment. Or, MODBUS, OPC UA server, etc. in case of process manufacturing to monitor process efficiency.

![Screen-shot](./png/dashboard.png)

# Quick Installation Guide

1. **Download and Extract**
   ```powershell
   # Download the latest release
   $MTMT_VERSION = "0.0.0"
   Invoke-WebRequest -Uri "https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher-v${MTMT_VERSION}.zip" -OutFile "mtmt.zip"
   Expand-Archive mtmt.zip
   cd launcher-v${MTMT_VERSION}
   ```

2. **Run Installer**
   ```powershell
   cd install
   .\install.ps1
   ```

The installer will guide you through the process with clear prompts and status updates. For detailed installation options, see our [Installation Guide](docs/installation.md).

# System Requirements

## Recommended
- Windows Server 2019+ (64-bit)
- 8GB RAM
- 4 CPU cores
- 100GB storage
- Docker Desktop
- Internet connection

## Minimum
- Windows Server 2016+ (64-bit)
- 4GB RAM
- 2 CPU cores
- 50GB storage
- Docker Engine 20.10.0+
- Internet connection

# Installation Process

The installation is handled through an interactive installer that:

1. **System Check**
   - Validates hardware requirements
   - Verifies Docker installation
   - Checks port availability

2. **Configuration**
   - Sets up environment variables
   - Configures system settings
   - Validates configuration

3. **Docker Setup**
   - Pulls required images
   - Creates networks
   - Prepares volumes

4. **Service Deployment**
   - Platform services (Kafka, ksqlDB, MQTT)
   - Base components
   - System initialization
   - Application services

5. **Verification**
   - Health checks
   - Endpoint verification
   - System validation

# Architecture

![on-premise](png/on-premise.png)

The application exposes three main endpoints:
1. `/data` - Equipment data ingestion
2. `/ui` - Dashboard access
3. `/limits` - Parameter limits configuration

# License

By default, this application implements rate-limiting such that, a maximum of `3600` requests can be sent in a time window of `1 hour` - whichever is earlier. For example, if a machine publishes data every second, then the machine can keep publishing continuously upto a maximum of `3600` requests (`1*3600=3600`) for upto `1 hour`. The rate limit is applied even if the number of requests exceed `3600` _within_ the time window of `1 hour`.

To upgrade, contact us for a new license key. Edit `conf/license.env` with the new license key.
