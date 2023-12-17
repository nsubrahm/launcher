# On-premises install instructions

This page documents steps to install the application on an on-premise instance.

- [On-premise install instructions](#on-premise-install-instructions)
  - [Initialize](#initialize)
  - [Login to GHCR](#login-to-ghcr)
  - [Install](#install)

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

4.  Launch platform.

```bash
cd ${PROJECT_HOME}
docker compose -f platform.yaml --env-file project.env up -d
```

5. Launch applications.

```bash
cd ${PROJECT_HOME}
docker compose -f apps.yaml --env-file project.env up -d
```

6. Check running containers with `docker ps`.

```bash
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS                    PORTS                              NAMES
1ce3f646b56f   ghcr.io/nsubrahm/dashboard:latest    "./entrypoint.sh"        17 minutes ago   Up 17 minutes (healthy)   1880/tcp, 0.0.0.0:8080->8080/tcp   mitra-m001-output
e6a3fbc5847f   ghcr.io/nsubrahm/payload:latest      "./application"          17 minutes ago   Up 17 minutes (healthy)   8080/tcp, 0.0.0.0:8081->8081/tcp   mitra-m001-inputs
4ce2110a7edb   ghcr.io/nsubrahm/streamer:latest     "./application -Dqua…"   17 minutes ago   Up 17 minutes (healthy)   8080/tcp                           mitra-m001-events
12ea72c009f2   ghcr.io/nsubrahm/merger:latest       "./application -Dqua…"   17 minutes ago   Up 17 minutes (healthy)   8080/tcp                           mitra-m001-merger
5ea1870d6488   ghcr.io/nsubrahm/alarms:latest       "./application -Dqua…"   17 minutes ago   Up 17 minutes (healthy)   8080/tcp                           mitra-m001-alarms
d0077ddfc9a1   ghcr.io/nsubrahm/alerts:latest       "./application -Dqua…"   17 minutes ago   Up 17 minutes (healthy)   8080/tcp                           mitra-m001-alerts
73cc66a6a8ac   confluentinc/cp-kafka:7.5.2          "/etc/confluent/dock…"   22 minutes ago   Up 22 minutes (healthy)   0.0.0.0:9092->9092/tcp             mitra-m001-broker
```

7. _(Optional)_ Shut down.

```bash
cd ${PROJECT_HOME}
docker compose -f apps.yaml --env-file apps.env down
docker compose -f platform.yaml --env-file project.env down
```
