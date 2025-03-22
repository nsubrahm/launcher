# Troubleshooting Guide

This document provides solutions for common issues encountered during installation and operation of Maintenance Mitra.

- [Troubleshooting Guide](#troubleshooting-guide)
  - [Common Installation Issues](#common-installation-issues)
    - [Container Registry Login Issues](#container-registry-login-issues)
    - [Container Startup Failures](#container-startup-failures)
    - [Environment Variable Issues](#environment-variable-issues)
  - [Checking Container Status](#checking-container-status)
  - [Restarting Components](#restarting-components)
  - [Common Error Messages](#common-error-messages)
  - [Getting Help](#getting-help)

## Common Installation Issues

### Container Registry Login Issues

**Problem**: Unable to login to container registry.

**Solution**:
- Verify that you have the correct `CR_PAT` value
- Check your internet connection
- Ensure Docker is running properly

### Container Startup Failures

**Problem**: Containers fail to start or show "unhealthy" status.

**Solution**:
- Check container logs: `docker logs <container-name>`
- Verify that all required ports are available
- Ensure sufficient system resources (CPU, memory)

### Environment Variable Issues

**Problem**: Environment variable files not generating correctly.

**Solution**:
- Verify `config.json` format is correct
- Ensure Python 3.x is installed
- Check for permissions to write to the output directory

## Checking Container Status

Use these commands to check the status of your containers:

```bash
# View all running containers
docker ps

# View all containers (including stopped ones)
docker ps -a

# View logs for a specific container
docker logs <container-name>
```

## Restarting Components

If you need to restart specific components:

```bash
# Restart platform components
docker compose --env-file launch/conf/platform.env -f launch/stacks/platform.yaml restart

# Restart base components
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml restart

# Restart application components
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml restart
```

## Common Error Messages

| Error Message                                    | Possible Cause                                         | Solution                                                     |
| ------------------------------------------------ | ------------------------------------------------------ | ------------------------------------------------------------ |
| `Error response from daemon: pull access denied` | Invalid or expired container registry credentials      | Re-login to container registry                               |
| `Error: No such container`                       | Container name is incorrect or container doesn't exist | Verify container name with `docker ps -a`                    |
| `Error: Bind for 0.0.0.0:80: unexpected error`   | Port 80 is already in use                              | Stop other services using port 80 or change the port mapping |

## Getting Help

If you continue to experience issues after trying these troubleshooting steps, please contact support with the following information:
- Error messages
- Container logs
- System specifications
- Steps you've already taken to resolve the issue
