# Installation Steps

Step-by-step instructions for installing and launching Maintenance Mitra using the new configuration management approach.

- [Installation Steps](#installation-steps)
  - [Login to Container Registry](#login-to-container-registry)
  - [Download Application](#download-application)
  - [Configuration Management](#configuration-management)
  - [Launching Stacks](#launching-stacks)
  - [Next Steps](#next-steps)

## Login to Container Registry

Authenticate with `ghcr.io` to pull required images.

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

## Download Application

Download and extract the launcher package.

**Linux:**
```bash
mkdir launcher && cd launcher
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

## Configuration Management

1. Edit template files in `launch/templates/` as needed (e.g., set `MACHINE_ID`, `SCHEMA_NAME`, etc).
2. Render templates to `.env` files in `launch/conf/` (manually or using a script):

```bash
mkdir -p launch/conf
python scripts/main.py
```

See [Configuration Guide](configuration.md) for details.

## Launching Stacks

Start each stack using its `.env` and YAML file:

```bash
docker compose --env-file launch/conf/core.env -f launch/stacks/core.yaml up -d
docker compose --env-file launch/conf/machines.env -f launch/stacks/machines.yaml up -d
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml up -d
docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml up -d
```

For each machine, repeat configuration and launch for `init.yaml`, `apps.yaml`, etc.

## Next Steps

- [Verify your installation](verification.md)
- [Customize configuration](configuration.md)
- [Troubleshoot issues](troubleshooting.md)
This is a one-time activity.

```bash
source launch/conf/core.env && docker compose --env-file launch/conf/core.env -f launch/stacks/core.yaml up -d
source launch/conf/machines.env && docker compose --env-file launch/conf/machines.env -f launch/stacks/machines.yaml up -d
source launch/conf/base.env && docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml up -d
source launch/conf/gateway.env && docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml up -d
```

### Launch Applications

This step needs to be run as many times as machines are added. Before adding a new machine, generate configuration as described in [Configuration](configuration.md).

```bash
source launch/conf/init.env && docker compose --env-file launch/conf/init.env -f launch/stacks/init.yaml up -d
source launch/conf/apps.env && docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml up -d
source launch/conf/db.env && docker compose --env-file launch/conf/db.env -f launch/stacks/db.yaml up -d
```

Verify all containers are running with `docker ps`.

## Next Steps

After successful installation:
- [Verify your installation](verification.md)
- [Configure the system](configuration.md)
- [Troubleshoot common issues](troubleshooting.md)
