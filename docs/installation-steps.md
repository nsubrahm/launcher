# Installation Steps

Detailed step-by-step installation instructions for Maintenance Mitra.

- [Installation Steps](#installation-steps)
  - [Login to GHCR](#login-to-ghcr)
    - [Linux](#linux)
    - [Windows PowerShell](#windows-powershell)
  - [Download](#download)
    - [Linux](#linux-1)
    - [Windows PowerShell](#windows-powershell-1)
  - [Configuration](#configuration)
  - [Launch](#launch)
    - [Launch Platform](#launch-platform)
    - [Launch Applications](#launch-applications)
  - [Next Steps](#next-steps)

## Login to GHCR

1. Log in to `ghcr.io` container registry.

> Contact us for value of `CR_PAT`.

### Linux

```bash
export CR_PAT=
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

### Windows PowerShell

```shell
$env:CR_PAT = "your_token"
$env:CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

## Download

Download and unzip application archive.

### Linux

```bash
mkdir launcher && cd launcher
export MTMT_VERSION=0.0.0
wget -q https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher-v${MTMT_VERSION}.tar.gz
tar -xzf launcher-v${MTMT_VERSION}.tar.gz
```

### Windows PowerShell

```shell
$env:MTMT_VERSION = "0.0.0"
wget -q https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher-v${MTMT_VERSION}.tar.gz
tar -xzf launcher-v${MTMT_VERSION}.tar.gz
```

## Configuration

> Skip this section if [Configuration file](configuration.md) defaults are to be used.

1. Modify `config.json` if required. See [Configuration file](configuration.md) for details.
2. Generate environment variables files with the commands below.

```bash
mkdir launch/conf
python scripts/main.py
```

## Launch

The launch process involves several steps to set up different components of the system.

### Launch Platform

This is a one-time activity.

```bash
docker compose --env-file launch/conf/platform.env -f launch/stacks/platform.yaml up -d
docker compose --env-file launch/conf/machines.env -f launch/stacks/machines.yaml up -d
docker compose --env-file launch/conf/base.env     -f launch/stacks/base.yaml up -d
docker compose --env-file launch/conf/gateway.env  -f launch/stacks/gateway.yaml up -d
```

### Launch Applications

This step needs to be run as many times as machines are added. Before adding a new machine, generate configuration as described in [Configuration](configuration.md).

```bash
docker compose --env-file launch/conf/init.env -f launch/stacks/init.yaml up -d
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml up -d
docker compose --env-file launch/conf/db.env   -f launch/stacks/db.yaml up -d
```

Verify all containers are running with `docker ps`.

## Next Steps

After successful installation:
- [Verify your installation](verification.md)
- [Configure the system](configuration.md)
- [Troubleshoot common issues](troubleshooting.md)
