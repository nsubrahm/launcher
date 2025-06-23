# Clean-up Guide

Instructions for stopping and removing Maintenance Mitra components managed via launch/configuration stacks.

- [Clean-up Guide](#clean-up-guide)
  - [Stopping Services](#stopping-services)
  - [Removing Containers](#removing-containers)
  - [Full Cleanup](#full-cleanup)
  - [Removing Docker Images](#removing-docker-images)
  - [Verification](#verification)

## Stopping Services

Stop services for each stack:

```bash
docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml stop
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml stop
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml stop
docker compose --env-file launch/conf/core.env -f launch/stacks/core.yaml stop
```

## Removing Containers

Remove containers (preserving volumes):

```bash
docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml down
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml down
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml down
docker compose --env-file launch/conf/core.env -f launch/stacks/core.yaml down
```

## Full Cleanup

Remove all containers, networks, and volumes:

```bash
docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml down -v
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml down -v
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml down -v
docker compose --env-file launch/conf/core.env -f launch/stacks/core.yaml down -v

docker volume prune -f
docker network prune -f
```

## Removing Docker Images

List and remove images:

```bash
docker images | grep 'nsubrahm\|confluentinc'
docker rmi <image-id>
```

## Verification

Check for remaining containers, volumes, or networks:

```bash
docker ps
docker ps -a | grep mitra
docker volume ls | grep mitra
docker network ls | grep mitra
```
