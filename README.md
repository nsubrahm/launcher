# Maintenance Mitra: Launch & Configuration Management

Maintenance Mitra is a modular, containerized application for real-time machine data monitoring, alerting, and dashboarding. The system is orchestrated using Docker Compose, with configuration managed via environment templates and stack files.

## Overview

Maintenance Mitra is designed for rapid deployment and flexible configuration. The launch process is managed through a set of templates and configuration files, allowing you to tailor deployments for different environments and machine setups.

**Key Features:**
- Modular Docker Compose stacks for core services, machine-specific apps, and supporting infrastructure.
- Configuration driven by environment variable templates (`.tmpl` files) and generated `.env` files.
- Easy customization for machine IDs, database schemas, partitioning, and more.
- Supports both quick-start and advanced, multi-machine scenarios.

## Directory Structure

- `launch/templates/` – Environment variable templates (`.tmpl`) for all services.
- `launch/conf/` – Generated `.env` files for each service and stack.
- `launch/stacks/` – Docker Compose YAML files for each stack (core, base, apps, etc).
- `docs/` – Additional documentation.

## Installation & Launch

### 1. Pre-requisites

- 64-bit Windows or Linux server with at least 1 CPU core and 4GB RAM.
- Docker and Docker Compose installed.
- Internet access during installation.

### 2. Configuration Management

All configuration is managed via environment variable files. Templates in `launch/templates/` are rendered (manually or via scripts) to produce `.env` files in `launch/conf/`. These `.env` files are referenced by the Docker Compose stack files in `launch/stacks/`.

**Typical configuration steps:**
1. Copy and customize the relevant `.tmpl` files in `launch/templates/` for your deployment (e.g., set `MACHINE_ID`, `SCHEMA_NAME`, etc).
2. Render templates to `.env` files in `launch/conf/` (can be done manually or with a script).
3. Review and adjust stack YAML files in `launch/stacks/` if needed.

### 3. Launching the Application

Each stack can be launched independently or in sequence, depending on your use case.

**Example:**
```sh
cd launch/stacks
docker compose -f core.yaml up -d
docker compose -f base.yaml up -d
docker compose -f apps.yaml up -d
```
- `core.yaml` – Core infrastructure (Kafka, KSQL, DB, etc).
- `base.yaml` – Base configuration service.
- `apps.yaml` – Machine-specific application stack.

**For multi-machine setups:**  
Repeat the configuration and launch steps for each machine, customizing the templates and `.env` files as needed.

### 4. Customization

- To add or modify machines, adjust the relevant templates and regenerate `.env` files.
- To change partitioning, replication, or other Kafka/DB settings, edit the corresponding `.tmpl` and re-render.
- For advanced scenarios, compose or extend stack YAML files as required.

### 5. License Management

The application uses a license key for rate-limiting and feature control.  
- The default license is in `conf/license.env`.
- To upgrade, replace the key in this file.

## Usage

- **Data Ingestion:** Send POST requests to `/data` endpoint.
- **Dashboard:** Access `/ui` in your browser.
- **Limits Configuration:** Use `/limits` endpoint for parameter limits.

See `docs/` for payload formats and advanced usage.

## Troubleshooting & Support

- Check container logs for errors: `docker compose logs <service>`
- Ensure all `.env` files are present and correctly rendered.
- For further help, see `docs/troubleshooting.md`.

## License

By default, Maintenance Mitra is rate-limited to 3600 requests per hour.  
To upgrade, contact us for a new license key and update `conf/license.env`.

---
