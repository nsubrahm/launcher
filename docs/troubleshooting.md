# Troubleshooting Guide

This guide provides solutions for common issues when launching and managing Maintenance Mitra with the new configuration management approach.

- [Troubleshooting Guide](#troubleshooting-guide)
  - [Common Issues](#common-issues)
    - [Container Startup Failures](#container-startup-failures)
    - [Environment File Issues](#environment-file-issues)
    - [Port Conflicts](#port-conflicts)
  - [Checking Container Status](#checking-container-status)
  - [Restarting Services](#restarting-services)
  - [Common Error Messages](#common-error-messages)
  - [Getting Help](#getting-help)

## Common Issues

### Container Startup Failures

- Check logs: `docker logs <container-name>`
- Ensure all required `.env` files are present and correct.
- Verify system resources (CPU, memory).

### Environment File Issues

- Ensure templates in `launch/templates/` are rendered to `.env` files in `launch/conf/`.
- Check for typos or missing variables in `.env` files.
- If using a script, verify `config.json` is valid JSON.

### Port Conflicts

- If a service fails to start due to port conflicts, stop other services using the same port or change the port mapping in the stack YAML.

## Checking Container Status

```bash
docker ps
docker ps -a
docker logs <container-name>
```

## Restarting Services

Restart a stack or service as needed:

```bash
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml restart
```

## Common Error Messages

| Error Message                                    | Possible Cause                        | Solution                                  |
| ------------------------------------------------ | ------------------------------------- | ------------------------------------------ |
| `pull access denied`                             | Not logged in to registry             | Login to `ghcr.io`                        |
| `No such container`                             | Wrong container name                  | Check with `docker ps -a`                 |
| `Bind for 0.0.0.0:80: ...`                      | Port 80 already in use                | Free the port or change mapping           |

## Getting Help

If issues persist, provide:
- Error messages
- Container logs
- System specs
- Steps already taken

Contact support for further assistance.
