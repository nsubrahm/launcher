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

> Skip this section if [Configuration file](#configuration-file) defaults are to be used.

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
docker compose --env-file launch/conf/platform.env -f launch/stacks/platform.yaml up -d
```

Run `docker ps` to see the containers `mitra-platform-kafka`, `mitra-platform-ksqldb` and `mitra-platform-mqtt` running in healthy status as shown below. It might take around 10 seconds or so for containers to appear healthy.

```bash
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS                    PORTS                 NAMES
1cc45bf9558a   confluentinc/ksqldb-server:latest   "/usr/bin/docker/run"    39 minutes ago   Up 39 minutes (healthy)                         mitra-platform-ksqldb
8337470867e2   confluentinc/cp-kafka:latest        "/etc/confluent/dock…"   39 minutes ago   Up 39 minutes (healthy)   9092/tcp              mitra-platform-broker
2e32877af715   ghcr.io/nsubrahm/mysql:latest       "docker-entrypoint.s…"   39 minutes ago   Up 39 minutes             3306/tcp, 33060/tcp   mitra-platform-mysql
b43a183bed5f   ghcr.io/nsubrahm/mosquitto:latest   "/docker-entrypoint.…"   39 minutes ago   Up 39 minutes             1883/tcp              mitra-platform-mqtt
```

6. Initialize applications.

```bash
docker compose --env-file launch/conf/init.env -f launch/stacks/init.yaml up -d
```

The containers launched by the above command starts the following containers. These containers exit after running. To see stopped containers, use `docker ps -a`. The following containers will be seen.

```bash
CONTAINER ID   IMAGE                                  COMMAND                  CREATED              STATUS                          PORTS                              NAMES
cf0e0e1e4893   ghcr.io/nsubrahm/queries:latest        "/bin/sh -c 'curl -X…"   About a minute ago   Exited (0) 39 seconds ago                                          mitra-m001-init-queris
be1935d9eeac   ghcr.io/nsubrahm/kafka-tools:latest    "/__cacert_entrypoin…"   About a minute ago   Exited (0) 42 seconds ago                                          mitra-m001-init-topics
c61357f3dbf9   ghcr.io/nsubrahm/tables:latest         "docker-entrypoint.s…"   About a minute ago   Exited (0) About a minute ago                                      mitra-m001-init-tables
```

7. Launch base components.

```bash
docker compose --env-file launch/conf/base.env -f launch/stacks/base.yaml up -d
```

Check the list of containers running succesfully.

```bash
CONTAINER ID   IMAGE                                 COMMAND                  CREATED          STATUS                    PORTS                 NAMES
c6a28db32350   ghcr.io/nsubrahm/limits:latest        "./application"          2 minutes ago    Up 2 minutes              8083/tcp              mitra-base-limits
ef82e2ccd659   ghcr.io/nsubrahm/http-inputs:latest   "./application -Dqua…"   2 minutes ago    Up 2 minutes              8080/tcp              mitra-base-httpin
e1961119d1c7   ghcr.io/nsubrahm/mqtt-inputs:latest   "./application -Dqua…"   2 minutes ago    Up 2 minutes              8080/tcp              mitra-base-mqttin
1cc45bf9558a   confluentinc/ksqldb-server:latest     "/usr/bin/docker/run"    50 minutes ago   Up 49 minutes (healthy)                         mitra-platform-ksqldb
8337470867e2   confluentinc/cp-kafka:latest          "/etc/confluent/dock…"   50 minutes ago   Up 50 minutes (healthy)   9092/tcp              mitra-platform-broker
2e32877af715   ghcr.io/nsubrahm/mysql:latest         "docker-entrypoint.s…"   50 minutes ago   Up 50 minutes             3306/tcp, 33060/tcp   mitra-platform-mysql
b43a183bed5f   ghcr.io/nsubrahm/mosquitto:latest     "/docker-entrypoint.…"   50 minutes ago   Up 50 minutes             1883/tcp              mitra-platform-mqtt
```

8. Launch applications.

```bash
docker compose --env-file launch/conf/apps.env -f launch/stacks/apps.yaml up -d
```

Check running containers with `docker ps`.

9. Launch database applications.

```bash
docker compose --env-file launch/conf/db.env -f launch/stacks/db.yaml up -d
```

10. Launch final services.

```bash
docker compose --env-file launch/conf/gateway.env -f launch/stacks/gateway.yaml up -d
```

Check running containers with `docker ps`.

```bash
CONTAINER ID   IMAGE                                 COMMAND                  CREATED              STATUS                            PORTS                 NAMES
be57028424a5   ghcr.io/nsubrahm/gateway:latest       "openresty -g 'daemo…"   13 seconds ago       Up 8 seconds (health: starting)   0.0.0.0:80->80/tcp    mitra-final-gateway
a95674c19b50   ghcr.io/nsubrahm/persistm:latest      "./application -Dqua…"   About a minute ago   Up 59 seconds (unhealthy)                               mitra-m001-apps-persistm-3
2eb384caac68   ghcr.io/nsubrahm/persistr:latest      "./application -Dqua…"   About a minute ago   Up 59 seconds (unhealthy)                               mitra-m001-apps-persistr-2
15b0f6eea18b   ghcr.io/nsubrahm/persistd:latest      "./application -Dqua…"   About a minute ago   Up 59 seconds (unhealthy)                               mitra-m001-apps-persistd-1
8f97946c308b   ghcr.io/nsubrahm/persistr:latest      "./application -Dqua…"   About a minute ago   Up 55 seconds (unhealthy)                               mitra-m001-apps-persistr-1
68cc538867d4   ghcr.io/nsubrahm/persistd:latest      "./application -Dqua…"   About a minute ago   Up 54 seconds (unhealthy)                               mitra-m001-apps-persistd-2
1f68097608e3   ghcr.io/nsubrahm/persistm:latest      "./application -Dqua…"   About a minute ago   Up 53 seconds (unhealthy)                               mitra-m001-apps-persistm-2
dbe5ff6d9648   ghcr.io/nsubrahm/persistd:latest      "./application -Dqua…"   About a minute ago   Up 47 seconds (unhealthy)                               mitra-m001-apps-persistd-3
d10cb85e4d72   ghcr.io/nsubrahm/streamer:latest      "./application -Dqua…"   About a minute ago   Up 59 seconds (healthy)           8080/tcp              mitra-m001-apps-events
f6af9c8cbc8e   ghcr.io/nsubrahm/persistm:latest      "./application -Dqua…"   About a minute ago   Up 46 seconds (unhealthy)                               mitra-m001-apps-persistm-1
21b96f69784c   ghcr.io/nsubrahm/persistr:latest      "./application -Dqua…"   About a minute ago   Up 47 seconds (unhealthy)                               mitra-m001-apps-persistr-3
c19cf619189e   ghcr.io/nsubrahm/alarms:latest        "./application -Dqua…"   About a minute ago   Up About a minute (healthy)       8080/tcp              mitra-m001-apps-alarms
83638ac45ce6   ghcr.io/nsubrahm/alerts:latest        "./application -Dqua…"   About a minute ago   Up About a minute (healthy)       8080/tcp              mitra-m001-apps-alerts
c6a28db32350   ghcr.io/nsubrahm/limits:latest        "./application"          10 minutes ago       Up 10 minutes                     8083/tcp              mitra-base-limits
ef82e2ccd659   ghcr.io/nsubrahm/http-inputs:latest   "./application -Dqua…"   10 minutes ago       Up 10 minutes                     8080/tcp              mitra-base-httpin
e1961119d1c7   ghcr.io/nsubrahm/mqtt-inputs:latest   "./application -Dqua…"   10 minutes ago       Up 10 minutes                     8080/tcp              mitra-base-mqttin
1cc45bf9558a   confluentinc/ksqldb-server:latest     "/usr/bin/docker/run"    58 minutes ago       Up 57 minutes (healthy)                                 mitra-platform-ksqldb
8337470867e2   confluentinc/cp-kafka:latest          "/etc/confluent/dock…"   58 minutes ago       Up 58 minutes (healthy)           9092/tcp              mitra-platform-broker
2e32877af715   ghcr.io/nsubrahm/mysql:latest         "docker-entrypoint.s…"   58 minutes ago       Up 58 minutes                     3306/tcp, 33060/tcp   mitra-platform-mysql
b43a183bed5f   ghcr.io/nsubrahm/mosquitto:latest     "/docker-entrypoint.…"   58 minutes ago       Up 58 minutes                     1883/tcp              mitra-platform-mqtt
```

### Clean-up

10. _(Optional)_ Shut down the complete deployment.

```bash
cd ${PROJECT_HOME}
docker compose --env-file launch/conf/gateway.env  -f launch/stacks/gateway.yaml down
docker compose --env-file launch/conf/apps.env     -f launch/stacks/apps.yaml down
docker compose --env-file launch/conf/db.env       -f launch/stacks/db.yaml down
docker compose --env-file launch/conf/base.env     -f launch/stacks/base.yaml down
docker compose --env-file launch/conf/platform.env -f launch/stacks/platform.yaml down
```

## Configuration file

The following configuration file can be set-up to generate environment variables and to control overall installation. This configuration file will generate environment variables in `outputDir` for machine ID `m001` using templates from `templateDir`. The machine has `3` parameters as set in `NUM_PARAMETERS`.

```json
{
  "PROJECT_NAME": "M001",
  "MACHINE_ID_CAPS": "M001",
  "MACHINE_ID": "m001",
  "NUM_PARAMETERS": 3,
  "templateDir" : "launch/templates",
  "outputDir": "launch/conf"
}
```

| Key               | Description                                                                |
| ----------------- | -------------------------------------------------------------------------- |
| `PROJECT_NAME`    | Machine ID in upper case to distinguish deployments for multiple machines. |
| `MACHINE_ID_CAPS` | Machine ID in upper case typically used for application IDs, etc.          |
| `MACHINE_ID`      | Machine ID in lower case typically used for topic names, etc.              |
| `NUM_PARAMETERS`  | Number of parameters of the machine.                                       |
| `templateDir`     | A folder to copy templated files.                                          |
| `outputDir`       | A folder to save generated environment variable files.                     |
