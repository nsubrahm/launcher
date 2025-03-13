# Installation Verification

This document guides you through verifying that your Maintenance Mitra installation is working correctly.

## Container Status Verification

After completing all installation steps, verify that all containers are running properly:

```bash
docker ps
```

You should see containers with the following prefixes:
- `mitra-platform-*` - Platform components
- `mitra-base-*` - Base components
- `mitra-m001-apps-*` - Application components
- `mitra-final-*` - Final services

All containers should show either "healthy" status or "(healthy)" in their status column. Some containers like persister services may initially show as "(unhealthy)" but should become healthy after initialization.

## Expected Container List

| Container Type | Expected Containers |
|----------------|---------------------|
| Platform | mitra-platform-kafka, mitra-platform-ksqldb, mitra-platform-mqtt, mitra-platform-mysql |
| Base | mitra-base-limits, mitra-base-httpin, mitra-base-mqttin |
| Applications | mitra-m001-apps-events, mitra-m001-apps-alarms, mitra-m001-apps-alerts, mitra-m001-apps-persist* |
| Final | mitra-final-gateway |

## Accessing the Web Interface

Once all containers are running, you can access the web interface:

1. Open a web browser
2. Navigate to `http://localhost` or the IP address of your server
3. You should see the Maintenance Mitra login page

## Health Check Endpoints

You can verify the health of specific services using their health check endpoints:

```bash
# Check gateway health
curl http://localhost/health

# Check specific service health (if exposed)
curl http://localhost/api/health
```

## Common Verification Issues

If you encounter any of the following issues during verification:

1. **Missing Containers**: Some containers are not listed in `docker ps`
   - Check initialization logs with `docker logs <container-name>`
   - Verify that all installation steps were completed

2. **Unhealthy Containers**: Containers show "unhealthy" status
   - Wait a few minutes as some containers take time to initialize
   - Check container logs for specific errors

3. **Web Interface Not Accessible**:
   - Verify gateway container is running
   - Check if port 80 is accessible and not blocked by firewall
   - Check gateway logs for any routing issues

## Next Steps

After verifying your installation:
- Configure user accounts
- Set up machine parameters
- Begin monitoring your equipment

For configuration details, see the [Configuration Guide](configuration.md).
