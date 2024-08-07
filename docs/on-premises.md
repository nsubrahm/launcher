# On-premises install instructions

This page documents steps to install the application on an on-premise instance.

- [On-premises install instructions](#on-premises-install-instructions)
  - [Pre-requisites](#pre-requisites)
  - [Initialize](#initialize)
  - [Login to GHCR](#login-to-ghcr)
  - [Install](#install)
  - [Launch](#launch)
  - [Clean-up](#clean-up)

## Pre-requisites

The pre-requisites for installation are as follows:

1. A 64-bit Windows or a Linux server with minimum 1 core CPU and 4GB RAM to spare.
2. Docker and Docker Compose are pre-installed.
3. Internet connection should be available for the duration of installation (typically, 15 mins).

## Initialize

1. Set-up environment variables and initialize.

```bash
export MTMT_VERSION=0.0.0
echo "export MTMT_VERSION=0.0.0" >> .profile
```

## Login to GHCR

2. Log in to `ghcr.io` container registry.

> Contact us for value of `CR_PAT`.

```bash
export CR_PAT=
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

## Install

3. Download and unzip application archive.

```bash
cd $HOME
wget https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launch.tar.gz
tar -xzf launch.tar.gz
export PROJECT_HOME=$HOME/launch
echo "export PROJECT_HOME=$HOME/launch" >> .profile
```

## Launch

4. Launch platform.

```bash
cd ${PROJECT_HOME}
docker compose --env-file platform.env -f platform.yaml up -d
```

Run `docker ps` to see the containers `mitra-platform-kafka` and `mitra-platform-ksqldb` running in healthy status as shown below. It might take around 10 seconds or so for containers to appear healthy.

```bash
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS                    PORTS                    NAMES
24a2b806b4d6   confluentinc/ksqldb-server:latest   "/usr/bin/docker/run"    28 seconds ago   Up 16 seconds (healthy)   0.0.0.0:8088->8088/tcp   mitra-platform-ksqldb
d058aedd768f   confluentinc/cp-kafka:latest        "/etc/confluent/dock…"   28 seconds ago   Up 27 seconds (healthy)   0.0.0.0:9092->9092/tcp   mitra-platform-broker
```

5. Launch applications.

```bash
cd ${PROJECT_HOME}
docker compose --env-file apps.env -f apps.yaml up -d
```

6. Check running containers with `docker ps`.

```bash
CONTAINER ID  IMAGE                               COMMAND                  CREATED          STATUS                            PORTS                              NAMES
b8c838d6b903  ghcr.io/nsubrahm/dashboard:latest   "./entrypoint.sh"        53 seconds ago   Up 4 seconds (health: starting)   1880/tcp, 0.0.0.0:8080->8080/tcp   mitra-m001-output
3d150377b2ac  ghcr.io/nsubrahm/streamer:latest    "./application -Dqua…"   53 seconds ago   Up 10 seconds (healthy)           8080/tcp                           mitra-m001-events
445ce2eab588  ghcr.io/nsubrahm/payload:latest     "./application"          53 seconds ago   Up 10 seconds (healthy)           8080/tcp, 0.0.0.0:8084->8084/tcp   mitra-m001-inputs
c1464c886a2d  ghcr.io/nsubrahm/alarms:latest      "./application -Dqua…"   53 seconds ago   Up 16 seconds (healthy)           8080/tcp                           mitra-m001-alarms
3612d418d682  ghcr.io/nsubrahm/alerts:latest      "./application -Dqua…"   53 seconds ago   Up 16 seconds (healthy)           8080/tcp                           mitra-m001-alerts
3c00e581d9b0  ghcr.io/nsubrahm/limits:latest      "./application"          53 seconds ago   Up 27 seconds                     0.0.0.0:8083->8083/tcp             mitra-m001-limits
b25eccc7cb22  confluentinc/ksqldb-server:latest   "/usr/bin/docker/run"    2 minutes ago    Up 2 minutes (healthy)            0.0.0.0:8088->8088/tcp             mitra-platform-ksqldb
30675fa37b29  confluentinc/cp-kafka:latest        "/etc/confluent/dock…"   2 minutes ago    Up 2 minutes (healthy)            0.0.0.0:9092->9092/tcp             mitra-platform-broker
```

If any of the containers appear as `Unhealthy` in the list above, then shut down the applications and start again using the following commands.

```bash
docker compose --env-file apps.env -f apps.yaml down
docker compose --env-file apps.env -f apps.yaml up -d
```

As a result of launching applications, two containers would have started and exited successfully. These are `mitra-m001-topics` and `mitra-m001-queris`. These containers can be seen with `docker ps -a`.

## Clean-up

7. _(Optional)_ Shut down the complete deployment.

```bash
cd ${PROJECT_HOME}
docker compose --env-file apps.env -f apps.yaml down
docker compose --env-file project.env -f platform.yaml down
```
