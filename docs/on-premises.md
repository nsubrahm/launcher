# On-premises install instructions

This page documents steps to install the application on an on-premise instance.

- [On-premises install instructions](#on-premises-install-instructions)
  - [Pre-requisites](#pre-requisites)
  - [Installation](#installation)
    - [Login to GHCR](#login-to-ghcr)
    - [Download](#download)
    - [Generate environment variables files](#generate-environment-variables-files)
    - [Launch](#launch)
    - [Clean-up](#clean-up)
  - [Configuration file](#configuration-file)

## Pre-requisites

The pre-requisites for installation are as follows:

1. A 64-bit Windows or a Linux server with minimum 1 core CPU and 4GB RAM to spare.
2. Docker and Docker Compose are pre-installed.
3. (_Optional, but recommended_) Python 3.x is installed.
4. Internet connection should be available for the duration of installation (typically, 15 mins).

## Installation

The following steps will install Maintenance Mitra.

### Login to GHCR

1. Log in to `ghcr.io` container registry.

> Contact us for value of `CR_PAT`.

On a Linux machine.

```bash
export CR_PAT=
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

On a Windows Power Shell terminal.

```shell
$env:CR_PAT = "your_token"
$env:CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

### Download

2. Download and unzip application archive.

On a Linux machine.

```bash
export MTMT_VERSION=0.0.0
wget -q https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher-v${MTMT_VERSION}.tar.gz
tar -xzf launcher-v${MTMT_VERSION}.tar.gz
```

On a Windows Power Shell terminal.

```shell
$env:MTMT_VERSION = "0.0.0"
wget -q https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher-v${MTMT_VERSION}.tar.gz
tar -xzf launcher-v${MTMT_VERSION}.tar.gz
```

### Generate environment variables files

> Skip this section. Go to [Launch](#launch).

The instructions in this section are are required only if defaults in [Configuration file](#configuration-file) are to be changed.

3. Modify `config.json` if required. See [Configuration file](#configuration-file) for details.
4. Generate environment variables files with the commands below.

On a Windows Power Shell and Linux terminals.

```bash
mkdir launch/conf
python scripts/main.py
```

### Launch

5. Launch platform.

```bash
docker compose --env-file launch/conf/platform.env -f launch/platform.yaml up -d
```

Run `docker ps` to see the containers `mitra-platform-kafka`, `mitra-platform-ksqldb` and `mitra-platform-mqtt` running in healthy status as shown below. It might take around 10 seconds or so for containers to appear healthy.

```bash
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS                            PORTS                 NAMES
0360319462e3   confluentinc/ksqldb-server:latest   "/usr/bin/docker/run"    25 seconds ago   Up 3 seconds (healthy)                                  mitra-platform-ksqldb
14ce6e95c1a4   confluentinc/cp-kafka:7.7.0         "/etc/confluent/dock…"   25 seconds ago   Up 24 seconds (healthy)           9092/tcp              mitra-platform-broker
f3e50fd1f547   ghcr.io/nsubrahm/mysql:latest       "docker-entrypoint.s…"   25 seconds ago   Up 24 seconds                     3306/tcp, 33060/tcp   mitra-platform-mysql
dd277840b7e2   ghcr.io/nsubrahm/mosquitto:latest   "/docker-entrypoint.…"   25 seconds ago   Up 24 seconds                     1883/tcp              mitra-platform-mqtt
```

6. Launch base components.

```bash
docker compose --env-file launch/conf/base.env -f launch/base.yaml up -d
```

Check the list of containers running succesfully.

```bash
CONTAINER ID   IMAGE                                  COMMAND                  CREATED          STATUS                            PORTS                              NAMES
fcfd9fb58062   ghcr.io/nsubrahm/dashboard:latest      "./entrypoint.sh"        11 seconds ago   Up 9 seconds (health: starting)   1880/tcp, 0.0.0.0:8080->8080/tcp   mitra-base-output
a355dafecb86   ghcr.io/nsubrahm/payload:latest        "./application"          11 seconds ago   Up 9 seconds (healthy)            8080/tcp, 0.0.0.0:8084->8084/tcp   mitra-base-inputs
30b760242f85   ghcr.io/nsubrahm/limits:latest         "./application"          11 seconds ago   Up 9 seconds                      0.0.0.0:8083->8083/tcp             mitra-base-limits
420f5ef933dd   ghcr.io/nsubrahm/mqtt-payload:latest   "./application"          11 seconds ago   Up 9 seconds                                                         mitra-base-mqttpd
0360319462e3   confluentinc/ksqldb-server:latest      "/usr/bin/docker/run"    9 minutes ago    Up 8 minutes (healthy)                                            mitra-platform-ksqldb
14ce6e95c1a4   confluentinc/cp-kafka:7.7.0            "/etc/confluent/dock…"   9 minutes ago    Up 9 minutes (healthy)            9092/tcp                           mitra-platform-broker
f3e50fd1f547   ghcr.io/nsubrahm/mysql:latest          "docker-entrypoint.s…"   9 minutes ago    Up 9 minutes                      3306/tcp, 33060/tcp                mitra-platform-mysql
dd277840b7e2   ghcr.io/nsubrahm/mosquitto:latest      "/docker-entrypoint.…"   9 minutes ago    Up 9 minutes                      1883/tcp                           mitra-platform-mqtt
```

7. Initialize applications.

```bash
docker compose --env-file launch/conf/init.env -f launch/init.yaml up -d
```

The containers launched by the above command starts the following containers. These containers stop after running. To see stopped containers, use `docker ps -a`. The following containers will be seen.

```bash
CONTAINER ID   IMAGE                                  COMMAND                  CREATED              STATUS                          PORTS                              NAMES
cf0e0e1e4893   ghcr.io/nsubrahm/queries:latest        "/bin/sh -c 'curl -X…"   About a minute ago   Exited (0) 39 seconds ago                                          mitra-m001-init-queris
be1935d9eeac   ghcr.io/nsubrahm/kafka-tools:latest    "/__cacert_entrypoin…"   About a minute ago   Exited (0) 42 seconds ago                                          mitra-m001-init-topics
c61357f3dbf9   ghcr.io/nsubrahm/tables:latest         "docker-entrypoint.s…"   About a minute ago   Exited (0) About a minute ago                                      mitra-m001-init-tables
```

8. Launch applications.

```bash
docker compose --env-file launch/conf/apps.env -f launch/apps.yaml up -d
```

9. Launch final services.

```bash
docker compose --env-file launch/conf/gateway.env -f launch/gateway.yaml up -d
```

10. Check running containers with `docker ps`.

```bash
CONTAINER ID   IMAGE                                  COMMAND                  CREATED              STATUS                          PORTS
           NAMES
7050fca3806e   ghcr.io/nsubrahm/persist:latest        "./application"          About a minute ago   Up About a minute (unhealthy)
           mitra-m001-apps-persistd-2
5331053c73d5   ghcr.io/nsubrahm/persist:latest        "./application"          About a minute ago   Up About a minute (unhealthy)
           mitra-m001-apps-persistr-2
e342f18fb585   ghcr.io/nsubrahm/persist:latest        "./application"          About a minute ago   Up About a minute (unhealthy)
           mitra-m001-apps-persistr-1
959b0779ab81   ghcr.io/nsubrahm/persist:latest        "./application"          About a minute ago   Up About a minute (unhealthy)
           mitra-m001-apps-persistm-1
a4241bc13b09   ghcr.io/nsubrahm/persist:latest        "./application"          About a minute ago   Up About a minute (unhealthy)
           mitra-m001-apps-persistd-3
b5257f92d18a   ghcr.io/nsubrahm/persist:latest        "./application"          About a minute ago   Up About a minute (unhealthy)
           mitra-m001-apps-persistd-1
943181cd75b0   ghcr.io/nsubrahm/persist:latest        "./application"          About a minute ago   Up About a minute (unhealthy)
           mitra-m001-apps-persistm-3
de97b5b546df   ghcr.io/nsubrahm/persist:latest        "./application"          About a minute ago   Up About a minute (unhealthy)
           mitra-m001-apps-persistr-3
6e25b245e8b4   ghcr.io/nsubrahm/persist:latest        "./application"          About a minute ago   Up About a minute (unhealthy)
           mitra-m001-apps-persistm-2
d3ae46fa40c5   ghcr.io/nsubrahm/streamer:latest       "./application -Dqua…"   About a minute ago   Up About a minute (healthy)     8080/tcp
           mitra-m001-apps-events
55e6beed79bd   ghcr.io/nsubrahm/alarms:latest         "./application -Dqua…"   About a minute ago   Up About a minute (healthy)     8080/tcp
           mitra-m001-apps-alarms
b6fa39d561c7   ghcr.io/nsubrahm/alerts:latest         "./application -Dqua…"   About a minute ago   Up About a minute (healthy)     8080/tcp
           mitra-m001-apps-alerts
fcfd9fb58062   ghcr.io/nsubrahm/dashboard:latest      "./entrypoint.sh"        17 minutes ago       Up 17 minutes (healthy)         1880/tcp, 0.0.0.0:8080->8080/tcp   mitra-base-output
a355dafecb86   ghcr.io/nsubrahm/payload:latest        "./application"          17 minutes ago       Up 17 minutes (healthy)         8080/tcp, 0.0.0.0:8084->8084/tcp   mitra-base-inputs
30b760242f85   ghcr.io/nsubrahm/limits:latest         "./application"          17 minutes ago       Up 17 minutes                   0.0.0.0:8083->8083/tcp             mitra-base-limits
420f5ef933dd   ghcr.io/nsubrahm/mqtt-payload:latest   "./application"          17 minutes ago       Up 17 minutes
           mitra-base-mqttpd
0360319462e3   confluentinc/ksqldb-server:latest      "/usr/bin/docker/run"    26 minutes ago       Up 26 minutes (healthy)
           mitra-platform-ksqldb
14ce6e95c1a4   confluentinc/cp-kafka:7.7.0            "/etc/confluent/dock…"   26 minutes ago       Up 26 minutes (healthy)         9092/tcp
           mitra-platform-broker
f3e50fd1f547   ghcr.io/nsubrahm/mysql:latest          "docker-entrypoint.s…"   26 minutes ago       Up 26 minutes                   3306/tcp, 33060/tcp                mitra-platform-mysql
dd277840b7e2   ghcr.io/nsubrahm/mosquitto:latest      "/docker-entrypoint.…"   26 minutes ago       Up 26 minutes                   1883/tcp
           mitra-platform-mqtt
```

If any of the containers appear as `Unhealthy` in the list above, then shut down the applications and start again using the following commands.

```bash
docker compose --env-file launch/conf/apps.env -f launch/apps.yaml down
docker compose --env-file launch/conf/apps.env -f launch/apps.yaml up -d
```

### Clean-up

9. _(Optional)_ Shut down the complete deployment.

```bash
cd ${PROJECT_HOME}
docker compose --env-file launch/conf/apps.env -f launch/apps.yaml down
docker compose --env-file launch/conf/platform.env -f launch/platform.yaml down
```

## Configuration file

The following configuration file can be set-up to generate environment variables and to control overall installation. It is **strongly recommended** to not change values of any of the parameters.

```json
{
  "PROJECT_NAME": "M001",
  "MACHINE_ID_CAPS": "M001",
  "MACHINE_ID": "m001",
  "sourceDir": "launch/config",
  "templateDir" : "launch/templates",
  "outputDir": "launch/conf"
}
```

| Key               | Description                                                                |
| ----------------- | -------------------------------------------------------------------------- |
| `PROJECT_NAME`    | Machine ID in upper case to distinguish deployments for multiple machines. |
| `MACHINE_ID_CAPS` | Machine ID in upper case typically used for application IDs, etc.          |
| `MACHINE_ID`      | Machine ID in lower case typically used for topic names, etc.              |
| `sourceDir`       | A folder to copy non-templated files.                                      |
| `templateDir`     | A folder to copy templated files.                                          |
| `outputDir`       | A folder to save generated environment variable files.                     |
