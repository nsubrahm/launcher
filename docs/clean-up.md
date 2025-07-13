# Clean-up Guide

Instructions for stopping and removing Maintenance Mitra components managed via launch/configuration stacks.

- [Clean-up Guide](#clean-up-guide)
  - [Stopping Services](#stopping-services)
  - [Verification](#verification)

## Stopping Services

1. Stop all running applications.

```bash
for i in $(seq -w 1 ${NUM_MACHINES}); do
  export CONF_DIR=m0$i
  source launch/conf/${CONF_DIR}/init.env && docker compose --env-file launch/conf/${CONF_DIR}/init.env -f launch/stacks/init.yaml down
  source launch/conf/${CONF_DIR}/apps.env && docker compose --env-file launch/conf/${CONF_DIR}/apps.env -f launch/stacks/apps.yaml down
done
```

2. Shut-down infra-structure.

```bash
export CONF_DIR=general
source launch/conf/${CONF_DIR}/core.env && docker compose --env-file launch/conf/${CONF_DIR}/core.env -f launch/stacks/core.yaml down
source launch/conf/${CONF_DIR}/machines.env && docker compose --env-file launch/conf/${CONF_DIR}/machines.env -f launch/stacks/machines.yaml down
source launch/conf/${CONF_DIR}/base.env && docker compose --env-file launch/conf/${CONF_DIR}/base.env -f launch/stacks/base.yaml down
source launch/conf/${CONF_DIR}/gateway.env && docker compose --env-file launch/conf/${CONF_DIR}/gateway.env -f launch/stacks/gateway.yaml down
# Remove network
docker network rm mitra
```

3. Remove all container images.

```bash
docker image prune -a -f
```

## Verification

Check for remaining containers, volumes, or networks:

```bash
docker ps
docker ps -a | grep mitra
docker volume ls | grep mitra
docker network ls | grep mitra
```
