# Installation Verification

This guide helps you verify that your Maintenance Mitra deployment (using launch/configuration management) is running correctly.

- [Installation Verification](#installation-verification)
  - [Check Container Status](#check-container-status)
  - [Expected Containers](#expected-containers)
  - [Accessing the Web Interface](#accessing-the-web-interface)
  - [Health Checks](#health-checks)
  - [Troubleshooting](#troubleshooting)
  - [Next Steps](#next-steps)

## Check Container Status

After launching all stacks, verify that containers are running and healthy:

```bash
docker ps
```

You should see containers with names like:
- `mitra-core-*`
- `mitra-base-*`
- `mitra-apps-*`
- `mitra-gateway`

All containers should show "healthy" status after initialization.

## Expected Containers

| Stack      | Example Containers                                               |
| ---------- | --------------------------------------------------------------- |
| Core       | mitra-core-broker, mitra-core-ksqldb, mitra-core-tscaledb, ...  |
| Base       | mitra-base-configs                                              |
| Apps       | mitra-apps-httpin, mitra-apps-alarms, mitra-apps-alerts, ...    |
| Gateway    | mitra-gateway-gateway                                           |

## Accessing the Web Interface

- Open a browser and go to `http://localhost` or your server's IP.
- The Maintenance Mitra dashboard should be visible.

## Health Checks

You can check service health via HTTP endpoints (if exposed):

```bash
curl http://localhost/health
```

Or use Docker health status:

```bash
docker inspect <container-name> | grep Health
```

## Troubleshooting

- If containers are missing or unhealthy, check logs:
  ```bash
  docker logs <container-name>
  ```
- Ensure all `.env` files are present and correct.
- See [Troubleshooting Guide](troubleshooting.md) for more help.

## Next Steps

- Configure machine parameters and limits.
- Begin monitoring your equipment.
- See [Configuration Guide](configuration.md) for details.
   - Verify gateway container is running
   - Check if port 80 is accessible and not blocked by firewall
   - Check gateway logs for any routing issues

## Next Steps

After verifying your installation:
- Configure user accounts
- Set up machine parameters
- Begin monitoring your equipment

For configuration details, see the [Configuration Guide](configuration.md).
