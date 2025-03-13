# Installation Steps

Detailed step-by-step installation instructions for Maintenance Mitra.

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

## Generate Environment Variables Files

> Skip this section if [Configuration file](configuration.md) defaults are to be used.

1. Modify `config.json` if required. See [Configuration file](configuration.md) for details.
2. Generate environment variables files with the commands below.

```bash
mkdir launch/conf
python scripts/main.py
```

## Launch

The launch process involves several steps to set up different components of the system.

### 1. Launch Platform

```bash
docker compose --env-file launch/conf/platform.env -f launch/stacks/platform.yaml up -d
docker compose --env-file launch/conf/machines.env -f launch/stacks/machines.yaml up -d
docker compose --env-file launch/conf/base.env     -f launch/stacks/base.yaml up -d
docker compose --env-file launch/conf/gateway.env  -f launch/stacks/gateway.yaml up -d
```

### 2. Initialize and Launch Applications

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
