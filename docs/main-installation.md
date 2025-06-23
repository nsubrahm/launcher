# Main Installation Guide

This guide provides a concise overview for installing and launching Maintenance Mitra using the new configuration management approach.

- [Main Installation Guide](#main-installation-guide)
  - [Prerequisites](#prerequisites)
  - [Installation Workflow](#installation-workflow)
  - [Configuration Management](#configuration-management)
  - [Launching Stacks](#launching-stacks)
  - [Next Steps](#next-steps)

## Prerequisites

- 64-bit Windows or Linux server (1+ CPU core, 4GB+ RAM)
- Docker and Docker Compose
- Python 3.x (for configuration rendering)
- Internet connection during installation

## Installation Workflow

1. **Login to Container Registry**  
   Authenticate with `ghcr.io` to pull images.

2. **Download Application**  
   Download and extract the launcher package.

3. **Configure Environment**  
   Edit template files in `launch/templates/` as needed, then render to `.env` files in `launch/conf/`.

4. **Launch Services**  
   Use Docker Compose stack files in `launch/stacks/` with the generated `.env` files.

5. **Verify Installation**  
   Check that all containers are running and healthy.

## Configuration Management

- All configuration is managed via environment variable templates (`.tmpl` files).
- Render templates to `.env` files in `launch/conf/` (manually or via script).
- Adjust machine-specific or environment-specific settings in the templates before rendering.

See [Configuration Guide](configuration.md) for details.

## Launching Stacks

Launch each stack using its corresponding `.env` and YAML file. Example:

```bash
docker compose --env-file launch/conf/core.env -f launch/stacks/core.yaml up -d
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml up -d
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml up -d
```

Repeat for additional machines or components as needed.

## Next Steps

- [Verify your installation](verification.md)
- [Customize configuration](configuration.md)
- [Troubleshoot issues](troubleshooting.md)
- [Reference commands](quick-reference.md)
