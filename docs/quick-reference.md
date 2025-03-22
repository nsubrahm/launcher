# Quick Reference Guide

This document provides a quick reference for common commands and operations for Maintenance Mitra.

- [Quick Reference Guide](#quick-reference-guide)
  - [Installation Commands](#installation-commands)
  - [Launch Commands](#launch-commands)
  - [Docker Commands](#docker-commands)
  - [Troubleshooting Commands](#troubleshooting-commands)
  - [Service Access](#service-access)
  - [Common Container Names](#common-container-names)

## Installation Commands

| Operation                             | Command                                                                                                                                                                                            |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Login to Container Registry (Linux)   | `export CR_PAT=<token>`<br>`echo $CR_PAT \| docker login ghcr.io -u USERNAME --password-stdin`                                                                                                     |
| Login to Container Registry (Windows) | `$env:CR_PAT = "<token>"`<br>`$env:CR_PAT \| docker login ghcr.io -u USERNAME --password-stdin`                                                                                                    |
| Download (Linux)                      | `export MTMT_VERSION=0.0.0`<br>`wget -q https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher-v${MTMT_VERSION}.tar.gz`<br>`tar -xzf launcher-v${MTMT_VERSION}.tar.gz`   |
| Download (Windows)                    | `$env:MTMT_VERSION = "0.0.0"`<br>`wget -q https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher-v${MTMT_VERSION}.tar.gz`<br>`tar -xzf launcher-v${MTMT_VERSION}.tar.gz` |
| Generate Environment Files            | `mkdir launch/conf`<br>`python scripts/main.py`                                                                                                                                                    |

## Launch Commands

| Component              | Command                                                                                                                                                                |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Platform               | `docker compose --env-file launch/conf/platform.env -f launch/stacks/platform.yaml up -d`                                                                              |
| Machine Initialization | `docker compose --env-file launch/conf/machines.env -f launch/stacks/machines.yaml up -d`                                                                              |
| Base Components        | `docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml up -d`                                                                                      |
| Init & Apps            | `docker compose --env-file launch/conf/init.env -f launch/stacks/init.yaml up -d`<br>`docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml up -d` |
| Database               | `docker compose --env-file launch/conf/db.env -f launch/stacks/db.yaml up -d`                                                                                          |
| Gateway                | `docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml up -d`                                                                                |

## Docker Commands

| Operation               | Command                           |
| ----------------------- | --------------------------------- |
| List Running Containers | `docker ps`                       |
| List All Containers     | `docker ps -a`                    |
| View Container Logs     | `docker logs <container-name>`    |
| Stop Container          | `docker stop <container-name>`    |
| Start Container         | `docker start <container-name>`   |
| Restart Container       | `docker restart <container-name>` |
| Remove Container        | `docker rm <container-name>`      |
| List Images             | `docker images`                   |
| Remove Image            | `docker rmi <image-id>`           |

## Troubleshooting Commands

| Operation                  | Command                                          |
| -------------------------- | ------------------------------------------------ |
| Check Container Health     | `docker inspect <container-name> \| grep Health` |
| View Container Details     | `docker inspect <container-name>`                |
| Check Network Connectivity | `docker network inspect bridge`                  |
| Check Docker Disk Usage    | `docker system df`                               |
| Clean Docker Resources     | `docker system prune`                            |

## Service Access

| Service       | URL                                     |
| ------------- | --------------------------------------- |
| Web Interface | `http://localhost` or server IP address |
| API Endpoints | `http://localhost/api/...`              |
| Health Check  | `http://localhost/health`               |

## Common Container Names

| Component    | Container Names                                                                        |
| ------------ | -------------------------------------------------------------------------------------- |
| Platform     | mitra-platform-kafka, mitra-platform-ksqldb, mitra-platform-mqtt, mitra-platform-mysql |
| Base         | mitra-base-limits, mitra-base-httpin, mitra-base-mqttin                                |
| Applications | mitra-m001-apps-events, mitra-m001-apps-alarms, mitra-m001-apps-alerts                 |
| Persisters   | mitra-m001-apps-persistd-*, mitra-m001-apps-persistm-*, mitra-m001-apps-persistr-*     |
| Gateway      | mitra-final-gateway                                                                    |
