# Installation Steps

Step-by-step instructions for installing and launching Maintenance Mitra.

- [Installation Steps](#installation-steps)
  - [1. Clone the repository](#1-clone-the-repository)
  - [2. Generate configuration](#2-generate-configuration)
  - [3. Launch the application](#3-launch-the-application)
  - [4. Batch set-up (optional)](#4-batch-set-up-optional)
  - [5. License Management](#5-license-management)
  - [Next Steps](#next-steps)

## 1. Clone the repository

```bash
git clone https://github.com/nsubrahm/launcher
cd launcher
```

## 2. Generate configuration

Edit `config.json` as needed.  
Generate general configuration:

```bash
mkdir -p launch/conf/general
python scripts/main.py -f config.json
```

Generate configuration for a machine:

```bash
mkdir -p launch/conf/m001
python scripts/main.py -f config.json -m m001
```

## 3. Launch the application

Launch infrastructure (run once):

```bash
export CONF_DIR=general
source launch/conf/${CONF_DIR}/core.env && docker compose --env-file launch/conf/${CONF_DIR}/core.env -f launch/stacks/core.yaml up -d
source launch/conf/${CONF_DIR}/machines.env && docker compose --env-file launch/conf/${CONF_DIR}/machines.env -f launch/stacks/machines.yaml up -d
source launch/conf/${CONF_DIR}/base.env && docker compose --env-file launch/conf/${CONF_DIR}/base.env -f launch/stacks/base.yaml up -d
source launch/conf/${CONF_DIR}/gateway.env && docker compose --env-file launch/conf/${CONF_DIR}/gateway.env -f launch/stacks/gateway.yaml up -d
```

Launch applications for a machine:

```bash
export CONF_DIR=m001
source launch/conf/${CONF_DIR}/init.env && docker compose --env-file launch/conf/${CONF_DIR}/init.env -f launch/stacks/init.yaml up -d
source launch/conf/${CONF_DIR}/apps.env && docker compose --env-file launch/conf/${CONF_DIR}/apps.env -f launch/stacks/apps.yaml up -d
```

## 4. Batch set-up (optional)

Create logs folder:

```bash
mkdir -p launch/batch/logs
```

Add cron entry for ML jobs:

```bash
0 */8 * * * $HOME/launcher/launch/batch/mljobs.sh m001 stable
```

## 5. License Management

The default license is in `conf/license.env`.  
To upgrade, replace the key in this file.

## Next Steps

- [Verify your installation](verification.md)
- [Customize configuration](configuration.md)
- [Troubleshoot issues](troubleshooting.md)
