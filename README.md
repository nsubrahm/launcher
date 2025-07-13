# Introduction

Maintenance Mitra is a modular, containerized application for real-time machine data monitoring, alerting, and dashboarding. The system is orchestrated using Docker Compose, with configuration managed via environment templates and stack files.

- [Introduction](#introduction)
  - [Overview](#overview)
  - [Directory Structure](#directory-structure)
  - [Installation](#installation)
    - [1. Pre-requisites](#1-pre-requisites)
    - [2. Configuration Management](#2-configuration-management)
    - [3. Launching the Application](#3-launching-the-application)
    - [4. Batch set-up](#4-batch-set-up)
    - [5. License Management](#5-license-management)
  - [Usage](#usage)

## Overview

The launch process is managed through a set of templates and configuration files, allowing you to tailor deployments for different environments and machine setups.

**Key Features:**
- Modular Docker Compose stacks for core services, machine-specific apps, and supporting infrastructure.
- Configuration driven by environment variable templates (`.tmpl` files) and generated `.env` files.
- Easy customization for machine IDs, database schemas, partitioning, and more.
- Supports both quick-start and advanced, multi-machine scenarios.

## Directory Structure

- `launch/templates/` – Environment variable templates (`.tmpl`) for all services.
- `launch/stacks/` – Docker Compose YAML files for each stack (core, base, apps, etc).
- `docs/` – Additional documentation.

## Installation

### 1. Pre-requisites

- 64-bit Windows or Linux server with at least 1 CPU core and 8GB RAM.
- Docker and Docker Compose installed.
- Internet access during installation.

> The commands in this page is for a Linux machine.

### 2. Configuration Management

All configuration is managed via environment variable files. Templates in `launch/templates/` are rendered via scripts to produce `.env` files in `launch/conf/`. These `.env` files are referenced by the Docker Compose stack files in `launch/stacks/`. There are two categories of environment variables - general and machine. The general environment variables should be generated once to launch the environment. The machine specific environment variables may be generated for as many machines as required.

To generate configuration, run the following steps.

1. Clone the repository.

```bash
git clone https://github.com/nsubrahm/launcher
cd launcher
```

2. Generate general configuration. To edit defaults in `config.json`, see [configuration](./docs/configuration.md).

```bash
mkdir -p launch/conf/general
python scripts/main.py -f configs/config.json
```

3. Generate configuration for a machine. To edit defaults in `config.json`, see [configuration](./docs/configuration.md).

```bash
mkdir -p launch/conf/m001
tools/config-gen.sh m001
python scripts/main.py -f configs/m001.json -m m001
```

### 3. Launching the Application

1. Launch the infra-structure. This step is to be run once.

```bash
export CONF_DIR=general
source launch/conf/${CONF_DIR}/core.env && docker compose --env-file launch/conf/${CONF_DIR}/core.env -f launch/stacks/core.yaml up -d
source launch/conf/${CONF_DIR}/machines.env && docker compose --env-file launch/conf/${CONF_DIR}/machines.env -f launch/stacks/machines.yaml up -d
source launch/conf/${CONF_DIR}/base.env && docker compose --env-file launch/conf/${CONF_DIR}/base.env -f launch/stacks/base.yaml up -d
source launch/conf/${CONF_DIR}/gateway.env && docker compose --env-file launch/conf/${CONF_DIR}/gateway.env -f launch/stacks/gateway.yaml up -d
```

2. Launch applications for a machine. This step maybe run as many times as required. Ensure that the configuration was generated for the specfied machine. See [Configuration management](#2-configuration-management) above.

```bash
export CONF_DIR=m001
source launch/conf/${CONF_DIR}/init.env && docker compose --env-file launch/conf/${CONF_DIR}/init.env -f launch/stacks/init.yaml up -d
source launch/conf/${CONF_DIR}/apps.env && docker compose --env-file launch/conf/${CONF_DIR}/apps.env -f launch/stacks/apps.yaml up -d
```

### 4. Batch set-up

1. Set-up logs folder.

```bash
mkdir -p launch/batch/logs
```

2. Add the following `cron` entry for as many machines that were launched.

```bash
0 */8 * * * $HOME/launcher/launch/batch/mljobs.sh m001 stable
```

### 5. License Management

The application uses a license key for rate-limiting and feature control.  
- The default license is in `conf/license.env`.
- To upgrade, replace the key in this file.

## Usage

- **Data Ingestion:** Send POST requests to `/data` endpoint. See [payload structure](./docs/payload.md) for more details.
- **Dashboard:** Access `/ui` in your browser.
- Access the dashboard at `http://localhost:80/ui`. The default credentials are `admin/admin`.

See `docs/` for payload formats and advanced usage.

