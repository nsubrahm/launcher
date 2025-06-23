# Configuration Guide

This guide explains how to manage configuration for Maintenance Mitra using templates and environment files.

- [Configuration Guide](#configuration-guide)
  - [Templates and Environment Files](#templates-and-environment-files)
  - [Configuration Parameters](#configuration-parameters)
  - [Generating Environment Files](#generating-environment-files)

## Templates and Environment Files

- All configuration is managed via environment variable templates (`.tmpl` files) in `launch/templates/`.
- Templates are rendered (manually or via script) to produce `.env` files in `launch/conf/`.
- Each stack YAML file in `launch/stacks/` references one or more `.env` files.

## Configuration Parameters

The main configuration file (for automated rendering) is `config.json`. Example:

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

| Parameter         | Description                                                                |
| ----------------- | -------------------------------------------------------------------------- |
| `PROJECT_NAME`    | Project or deployment name.                                                |
| `MACHINE_ID_CAPS` | Machine ID in upper case (for app IDs, etc).                              |
| `MACHINE_ID`      | Machine ID in lower case (for topic names, etc).                           |
| `NUM_PARAMETERS`  | Number of machine parameters.                                              |
| `NUM_MACHINES`    | Number of machines (for multi-machine setups).                             |
| `templateDir`     | Directory containing template files.                                       |
| `outputDir`       | Directory for generated `.env` files.                                      |

## Generating Environment Files

To generate `.env` files from templates:

```bash
mkdir -p launch/conf
python scripts/main.py
```

This will read `config.json` and render all templates in `templateDir` to `.env` files in `outputDir`.

Edit the templates or `config.json` as needed for your deployment.
To generate the environment variable files:

```bash
mkdir -p launch/conf
python scripts/main.py
```

This script reads the `config.json` file and generates the necessary environment files in the `outputDir` specified in the configuration.
