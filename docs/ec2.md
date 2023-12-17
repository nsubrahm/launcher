# EC2 install instructions

This page documents steps to install the application on EC2 instance.

- [EC2 install instructions](#ec2-install-instructions)
  - [Pre-requisites](#pre-requisites)
  - [Initialize](#initialize)
  - [Install Docker](#install-docker)
  - [Login to GHCR](#login-to-ghcr)
  - [Install](#install)

## Pre-requisites

The pre-requisites for installation are as follows:

1. `t3a.medium` instance in public subnet or private subnet with NAT gateway enabled.
2. Following ports should be opened. It is _strongly recommended_ that the source is limited to certain IP addresses than opening to "world".
  1. `22` for `ssh`
  2. `8080` for UI
  3. `8081` for Payload
  4. `8082` for Limits

## Initialize

1. Set-up environment variables and initialize.

```bash
export MTMT_VERSION=0.0.0
echo "export MTMT_VERSION=0.0.0" >> .profile
```

## Install Docker

2. Install Docker engine and Docker Compose.

```bash
# Add Docker's official GPG key:
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Add non-root user to docker group
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

## Login to GHCR

3. Log in to `ghcr.io` container registry.

> Contact us for the value of `CR_PAT`.

```bash
export CR_PAT=
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

## Install

4. Download and unzip application archive.

```bash
cd $HOME
wget https://github.com/nsubrahm/launcher/releases/download/r${MTMT_VERSION}/launch.tar.gz
tar -xzf launch.tar.gz
export PROJECT_HOME=$HOME/launch
echo "export PROJECT_HOME=$HOME/launch" >> .profile
```

5.  Launch platform.

```bash
cd ${PROJECT_HOME}
docker compose -f platform.yaml --env-file platform.env up -d
```

6. Launch applications.

```bash
cd ${PROJECT_HOME}
docker compose -f apps.yaml --env-file apps.env up -d
```

7. Check running containers with `docker ps`.

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

If any of the applications appear as `Unhealthy`, shut down the applications and start again using the following commands.

```bash
docker compose -f apps.yaml --env-file apps.env down
docker compose -f apps.yaml --env-file apps.env up -d
```

8. _(Optional)_ Shut down.

```bash
cd ${PROJECT_HOME}
docker compose -f apps.yaml --env-file apps.env down
docker compose -f platform.yaml --env-file platform.env down
```
