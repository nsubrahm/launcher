# Quick Reference Guide

A summary of common commands for launching and managing Maintenance Mitra using configuration management.

- [Quick Reference Guide](#quick-reference-guide)
  - [Registry Login](#registry-login)
  - [Download & Extract](#download--extract)
  - [Configuration Generation](#configuration-generation)
  - [Launching Stacks](#launching-stacks)
  - [Docker Commands](#docker-commands)
  - [Troubleshooting](#troubleshooting)
  - [Service Access](#service-access)
  - [Container Names](#container-names)

## Registry Login

**Linux:**
```bash
export CR_PAT=<token>
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```
**Windows PowerShell:**
```powershell
$env:CR_PAT = "<token>"
$env:CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

## Download & Extract

**Linux:**
```bash
export MTMT_VERSION=0.0.0
wget -q https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher-v${MTMT_VERSION}.tar.gz
tar -xzf launcher-v${MTMT_VERSION}.tar.gz
```
**Windows PowerShell:**
```powershell
$env:MTMT_VERSION = "0.0.0"
wget -q https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher-v${MTMT_VERSION}.tar.gz
tar -xzf launcher-v${MTMT_VERSION}.tar.gz
```

## Configuration Generation

```bash
mkdir -p launch/conf
python scripts/main.py
```

## Launching Stacks

```bash
docker compose --env-file launch/conf/core.env -f launch/stacks/core.yaml up -d
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml up -d
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml up -d
docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml up -d
```

## Docker Commands

| Operation               | Command                           |
| ----------------------- | --------------------------------- |
| List Running Containers | `docker ps`                       |
| View Logs               | `docker logs <container-name>`    |
| Stop Container          | `docker stop <container-name>`    |
| Restart Container       | `docker restart <container-name>` |
| Remove Container        | `docker rm <container-name>`      |

## Troubleshooting

- Check health: `docker inspect <container-name> | grep Health`
- View logs: `docker logs <container-name>`
- See [Troubleshooting Guide](troubleshooting.md) for more.

## Service Access

| Service       | URL                                     |
| ------------- | --------------------------------------- |
| Web Interface | `http://localhost` or server IP address |
| Health Check  | `http://localhost/health`               |

## Container Names

| Stack      | Example Containers                                               |
| ---------- | --------------------------------------------------------------- |
| Core       | mitra-core-broker, mitra-core-ksqldb, ...                       |
| Base       | mitra-base-configs                                              |
| Apps       | mitra-apps-httpin, mitra-apps-alarms, mitra-apps-alerts, mitra-apps-collector, mitra-apps-persist, mitra-apps-analytics |
| Gateway    | mitra-gateway-gateway                                           |
