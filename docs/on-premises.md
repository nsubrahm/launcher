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
cd $HOME
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

The instructions in this section are are required only if defaults in [Configuration file](#configuration-file) are to be changed. This section maybe skipped. 

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
cd ${PROJECT_HOME}
docker compose --env-file launch/conf/platform.env -f launch/platform.yaml up -d
```

Run `docker ps` to see the containers `mitra-platform-kafka`, `mitra-platform-ksqldb` and `mitra-platform-mqtt` running in healthy status as shown below. It might take around 10 seconds or so for containers to appear healthy.

```bash
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS                    PORTS                    NAMES
24a2b806b4d6   confluentinc/ksqldb-server:latest   "/usr/bin/docker/run"    28 seconds ago   Up 16 seconds (healthy)   0.0.0.0:8088->8088/tcp   mitra-platform-ksqldb
d058aedd768f   confluentinc/cp-kafka:7.7.0         "/etc/confluent/dock…"   28 seconds ago   Up 27 seconds (healthy)   0.0.0.0:9092->9092/tcp   mitra-platform-broker
b163b8c9e712   eclipse-mosquitto:latest            "/docker-entrypoint.…"   40 seconds ago   Up 39 seconds             0.0.0.0:1883->1883/tcp   mitra-platform-mqtt
```

6. Launch base components.

```bash
cd ${PROJECT_HOME}
docker compose --env-file launch/conf/base.env -f launch/base.yaml up -d
```

7. Launch applications.

```bash
cd ${PROJECT_HOME}
docker compose --env-file launch/conf/apps.env -f launch/apps.yaml up -d
```

8. Check running containers with `docker ps`.

```bash
CONTAINER ID   IMAGE                                  COMMAND                  CREATED         STATUS                     PORTS                              NAMES
7fbd62ca4b4e   ghcr.io/nsubrahm/dashboard:latest      "./entrypoint.sh"        3 minutes ago   Up 2 minutes (healthy)     1880/tcp, 0.0.0.0:8080->8080/tcp   mitra-m001-output
5f251e17dd7b   ghcr.io/nsubrahm/payload:latest        "./application"          3 minutes ago   Up 3 minutes (healthy)     8080/tcp, 0.0.0.0:8084->8084/tcp   mitra-m001-inputs
bbd2e88adc5f   ghcr.io/nsubrahm/streamer:latest       "./application -Dqua…"   3 minutes ago   Up 3 minutes (healthy)     8080/tcp                           mitra-m001-events
5e8a0bf5a84a   ghcr.io/nsubrahm/mqtt-payload:latest   "./application"          3 minutes ago   Up 3 minutes (healthy)                                        mitra-m001-mqttpd
2d9bd018d2a5   ghcr.io/nsubrahm/alerts:latest         "./application -Dqua…"   3 minutes ago   Up 3 minutes (healthy)     8080/tcp                           mitra-m001-alerts
b813b74d10cf   ghcr.io/nsubrahm/alarms:latest         "./application -Dqua…"   3 minutes ago   Up 3 minutes (healthy)     8080/tcp                           mitra-m001-alarms
c10230d3eb36   ghcr.io/nsubrahm/limits:latest         "./application"          3 minutes ago   Up 3 minutes               0.0.0.0:8083->8083/tcp             mitra-m001-limits
f6d4697d362e   confluentinc/ksqldb-server:latest      "/usr/bin/docker/run"    37 hours ago    Up 9 minutes (healthy)     0.0.0.0:8088->8088/tcp             mitra-platform-ksqldb
c0e09243e7ab   confluentinc/cp-kafka:7.7.0            "/etc/confluent/dock…"   37 hours ago    Up 9 minutes (healthy)     0.0.0.0:9092->9092/tcp             mitra-platform-broker
```

If any of the containers appear as `Unhealthy` in the list above, then shut down the applications and start again using the following commands.

```bash
docker compose --env-file launch/conf/apps.env -f launch/apps.yaml down
docker compose --env-file launch/conf/apps.env -f launch/apps.yaml up -d
```

As a result of launching applications, two containers would have started and exited successfully. These are `mitra-m001-topics` and `mitra-m001-queris`. These containers can be seen with `docker ps -a`.

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
