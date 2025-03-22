# Clean-up Guide

This document provides instructions for cleaning up and removing Maintenance Mitra components from your system.

- [Clean-up Guide](#clean-up-guide)
  - [Stopping Services](#stopping-services)
  - [Removing Containers](#removing-containers)
  - [Complete Cleanup](#complete-cleanup)
  - [Removing Docker Images](#removing-docker-images)
  - [Cleanup Verification](#cleanup-verification)

## Stopping Services

To stop all services without removing containers:

```bash
# Stop gateway services
docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml stop

# Stop database applications
docker compose --env-file launch/conf/db.env -f launch/stacks/db.yaml stop

# Stop applications
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml stop

# Stop initialization services
docker compose --env-file launch/conf/init.env -f launch/stacks/init.yaml stop

# Stop base components
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml stop

# Stop machine initialization
docker compose --env-file launch/conf/machines.env -f launch/stacks/machines.yaml stop

# Stop platform
docker compose --env-file launch/conf/platform.env -f launch/stacks/platform.yaml stop
```

## Removing Containers

To remove containers (but preserve volumes):

```bash
# Remove gateway services
docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml down

# Remove database applications
docker compose --env-file launch/conf/db.env -f launch/stacks/db.yaml down

# Remove applications
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml down

# Remove initialization services
docker compose --env-file launch/conf/init.env -f launch/stacks/init.yaml down

# Remove base components
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml down

# Remove machine initialization
docker compose --env-file launch/conf/machines.env -f launch/stacks/machines.yaml down

# Remove platform
docker compose --env-file launch/conf/platform.env -f launch/stacks/platform.yaml down
```

## Complete Cleanup

To completely remove all containers, networks, and volumes:

```bash
# Remove all containers with volumes
docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml down -v
docker compose --env-file launch/conf/db.env -f launch/stacks/db.yaml down -v
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml down -v
docker compose --env-file launch/conf/init.env -f launch/stacks/init.yaml down -v
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml down -v
docker compose --env-file launch/conf/machines.env -f launch/stacks/machines.yaml down -v
docker compose --env-file launch/conf/platform.env -f launch/stacks/platform.yaml down -v

# Remove unused Docker volumes
docker volume prune -f

# Remove unused Docker networks
docker network prune -f
```

## Removing Docker Images

To remove the Docker images used by Maintenance Mitra:

```bash
# List all images
docker images | grep 'nsubrahm\|confluentinc'

# Remove specific images
docker rmi <image-id>

# Or remove all images at once
docker images | grep 'nsubrahm\|confluentinc' | awk '{print $3}' | xargs docker rmi
```

## Cleanup Verification

To verify that all components have been removed:

```bash
# Check for running containers
docker ps

# Check for stopped containers
docker ps -a | grep mitra

# Check for volumes
docker volume ls | grep mitra

# Check for networks
docker network ls | grep mitra
```

If any components remain, you can remove them manually using the appropriate Docker commands.
