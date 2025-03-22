# Configuration Guide

This document explains the configuration options for Maintenance Mitra.
- [Configuration Guide](#configuration-guide)
  - [Configuration File](#configuration-file)
    - [Example Configuration](#example-configuration)
    - [Configuration Parameters](#configuration-parameters)
  - [Environment Variables Files](#environment-variables-files)
    - [Generating Environment Files](#generating-environment-files)

## Configuration File

The main configuration file is `config.json`. This file contains settings that control how the application is deployed.

### Example Configuration

```json
{
  "PROJECT_NAME": "MITRA",
  "MACHINE_ID_CAPS": "M001",
  "MACHINE_ID": "m001",
  "NUM_PARAMETERS": 5,
  "NUM_MACHINES": 3,
  "templateDir": "launch/templates",
  "outputDir": "launch/conf"
}
```

### Configuration Parameters

| Parameter         | Description                                                                |
| ----------------- | -------------------------------------------------------------------------- |
| `PROJECT_NAME`    | Machine ID in upper case to distinguish deployments for multiple machines. |
| `MACHINE_ID_CAPS` | Machine ID in upper case typically used for application IDs, etc.          |
| `MACHINE_ID`      | Machine ID in lower case typically used for topic names, etc.              |
| `NUM_PARAMETERS`  | Number of parameters of the machine.                                       |
| `templateDir`     | A folder to copy templated files.                                          |
| `outputDir`       | A folder to save generated environment variable files.                     |

## Environment Variables Files

The configuration process generates several environment variable files that are used by different components of the system:

1. `platform.env` - Environment variables for the platform components
2. `machines.env` - Environment variables for machine initialization
3. `base.env` - Environment variables for base components
4. `init.env` - Environment variables for initialization components
5. `apps.env` - Environment variables for application components
6. `db.env` - Environment variables for database components
7. `gateway.env` - Environment variables for gateway components

### Generating Environment Files

To generate the environment variable files:

```bash
mkdir -p launch/conf
python scripts/main.py
```

This script reads the `config.json` file and generates the necessary environment files in the `outputDir` specified in the configuration.
