# Install on Amazon EC2

This document installs the Maintenance Mitra application on Amazon EC2 (**Ubuntu**) LTS instances.

- [Install on Amazon EC2](#install-on-amazon-ec2)
  - [Architecture diagram](#architecture-diagram)
  - [Bastion host](#bastion-host)
  - [Registry installation](#registry-installation)
  - [Java and Kafka installation](#java-and-kafka-installation)
  - [Compute installation](#compute-installation)
  - [Frontend installation](#frontend-installation)

## Architecture diagram

- 5 EC2 instances will be launched as described below.

| Application                            | Instance type | Instance name |  Subnet   | Description                                      |
| -------------------------------------- | :-----------: | :-----------: | :-------: | ------------------------------------------------ |
| `payload`, `limits`, `dashboard`       |  `t3a.micro`  |   Frontend    | `public`  | Exposes endpoint for devices, CLI and dashboard. |
| `kafka`                                |  `t3a.small`  |    Broker     | `private` | Broker installation.                             |
| `alarms`, `alerts`, `merger`, `events` |  `t3a.micro`  |    Compute    | `private` | Run Quarkus applications.                        |
| `registry`                             |  `t3a.nano`   |   Registry    | `public`  | Container registry proxy to `ghcr`.              |
| `bastion`                              |  `t3a.nano`   |    Bastion    | `public`  | Bastion host.                                    |

## Bastion host

Launch a `t3a.nano` instance in `public` subnet to run commands on instances launched in `private` subnet.

1. Set-up environment variables for other machines.

```bash
export BROKER_HOST=172.31.21.207
export COMPUTE_HOST=172.31.28.90
export REGISTRY_HOST=172.31.8.51
export FRONTEND_HOST=172.31.5.103
echo "export BROKER_HOST=172.31.21.207" >> .profile
echo "export COMPUTE_HOST=172.31.28.90" >> .profile
echo "export REGISTRY_HOST=172.31.8.51" >> .profile
echo "export FRONTEND_HOST=172.31.5.103" >> .profile
```

2. Download Java, Kafka, Docker Engine and Docker Compose.

```bash
# Machine update
sudo apt-get update
# Software versions
export JDK_VERSION=21.0.1
export DOCKER_VERSION=24.0.7
export DOCKER_COMPOSE_VERSION=2.23.0
export KAFKA_BIN_RELEASE=2.13
export KAFKA_RELEASE=3.6.0
export MTMT_VERSION=0.0.0
echo "export JDK_VERSION=21.01.1" >> .profile
echo "export DOCKER_VERSION=24.0.7" >> .profile
echo "export DOCKER_COMPOSE_VERSION=2.23.0" >> .profile
echo "export KAFKA_BIN_RELEASE=2.13" >> .profile
echo "export KAFKA_RELEASE=3.6.0" >> .profile
echo "export MTMT_VERSION=0.0.0" >> .profile
# Download
wget https://dlcdn.apache.org/kafka/${KAFKA_RELEASE}/kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE}.tgz
wget https://download.java.net/java/GA/jdk21.0.1/415e3f918a1f4062a0074a2794853d0d/12/GPL/openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz
wget https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launch.tar.gz
wget https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz
wget https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 
```

3. `scp` to Broker machine.

```bash
scp -i mtmt.pem kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE}.tgz ubuntu@${BROKER_HOST}:.
scp -i mtmt.pem openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz ubuntu@${BROKER_HOST}:.
scp -i mtmt.pem launch.tar.gz ubuntu@${BROKER_HOST}:.
```

4. `scp` to Compute machine.

```bash
scp -i mtmt.pem docker-${DOCKER_VERSION}.tgz ubuntu@${COMPUTE_HOST}:.
scp -i mtmt.pem docker-compose-linux-x86_64 ubuntu@${COMPUTE_HOST}:.
scp -i mtmt.pem launch.tar.gz ubuntu@${COMPUTE_HOST}:.
```

5. `scp` to Registry machine.

```bash
scp -i mtmt.pem launch/registry/registry.yml ubuntu@${REGISTRY_HOST}:.
```

6. `scp` to Frontend machine.

```bash
scp -i mtmt.pem docker-${DOCKER_VERSION}.tgz ubuntu@${FRONTEND_HOST}:.
scp -i mtmt.pem docker-compose-linux-x86_64 ubuntu@${FRONTEND_HOST}:.
scp -i mtmt.pem launch.tar.gz ubuntu@${FRONTEND_HOST}:.
```

## Registry installation

1. Install Docker.

```bash
# Add Docker's official GPG key:
sudo apt-get update
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

2. Create registry configuration - `$HOME/config.yml`.

```yaml
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
proxy:
  remoteurl: https://ghcr.io
  username: USERNAME
  password: 
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
```

3. Launch registry.

```bash
docker run -d --restart=always -p 5000:5000 --name docker-registry-proxy -v `pwd`/config.yml:/etc/docker/registry/config.yml registry:2
```

## Java and Kafka installation

The following instructions are to be carried out on a `t3a.small` instance in a `private` subnet. The instructions are from [here](https://kafka.apache.org/quickstart) and [here](https://stackoverflow.com/a/39901893/919480).

1. Install Java.

```bash
export JDK_VERSION=21.0.1
echo "export JDK_VERSION=21.01.1" >> .profile
sudo tar -xvf openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz -C /opt
sudo update-alternatives --install /usr/bin/java java /opt/jdk-${JDK_VERSION}/bin/java 1000
```

2. Install Kafka.

```bash
export KAFKA_BIN_RELEASE=2.13
export KAFKA_RELEASE=3.6.0
export KAFKA_HOME=/opt/kafka
echo "export KAFKA_BIN_RELEASE=2.13" >> .profile
echo "export KAFKA_RELEASE=3.6.0" >> .profile
echo "export KAFKA_HOME=/opt/kafka" >> .profile
tar -zxvf kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE}.tgz
sudo cp -R kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE} /opt
sudo ln -s /opt/kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE} /opt/kafka
```

3. Change advertised listeners, in `/opt/kafka/config/kraft/server.properties` to private IP address for clients from Compute machine to connect.  

```bash
advertised.listeners=PLAINTEXT://172.31.22.114:9092
```

4. Set-up Kafka service with instructions from [here](https://stackoverflow.com/a/39901893/919480). 

4a. Save the following in `/etc/init.d/kafka` file.

```bash
#!/bin/bash
KAFKA_HOME=/opt/kafka
# See how we were called.
case "$1" in
  start)
      # Start daemon.
      echo "Generate cluster UUID"
      KAFKA_CLUSTER_ID="$(${KAFKA_HOME}/bin/kafka-storage.sh random-uuid)"
      echo "Format log directories"
      ${KAFKA_HOME}/bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c ${KAFKA_HOME}/config/kraft/server.properties
      echo "Start Kafka server"
      ${KAFKA_HOME}/bin/kafka-server-start.sh -daemon ${KAFKA_HOME}/config/kraft/server.properties
      ;;
  stop)
      # Stop daemons.
      echo "Shutting down Kafka";
      pid=`ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}'`
      if [ -n "$pid" ]
        then
        kill -9 $pid
      else
        echo "Kafka was not Running"
      fi
      ;;
  restart)
      $0 stop
      sleep 2
      $0 start
      ;;
  status)
      pid=`ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}'`
      if [ -n "$pid" ]
        then
        echo "Kafka is Running as PID: $pid"
      else
        echo "Kafka is not Running"
      fi
      ;;
  *)
      echo "Usage: $0 {start|stop|restart|status}"
      exit 1
esac

exit 0
```

4b. Set-up service.

```bash
sudo chmod 755 /etc/init.d/kafka
sudo update-rc.d kafka defaults
```

4c. Start service.

```bash
sudo service kafka start
```

5. Create topics.

```bash
tar -xzf launch.tar.gz
cd launch/scripts
./init.sh
```

## Compute installation

The following instructions are to be carried out on a `t3a.nano` instance in a `private` subnet. The `registry` instance can be used as a bastion host.

1. Install Docker using binaries - https://docs.docker.com/engine/install/binaries/

```bash
export DOCKER_VERSION=24.0.7
export DOCKER_COMPOSE_VERSION=2.23.0
export REGISTRY_HOST=172.31.8.51
echo "export DOCKER_VERSION=24.0.7" >> .profile
echo "export DOCKER_COMPOSE_VERSION=2.23.0" >> .profile
echo "export REGISTRY_HOST=172.31.8.51" >> .profile
tar -zxf docker-${DOCKER_VERSION}.tgz
sudo cp docker/* /usr/bin/
```

2. Run Linux post-install steps - https://docs.docker.com/engine/install/linux-postinstall/

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

3. Install Docker Compose using binaries - https://docs.docker.com/compose/install/linux/#install-the-plugin-manually

```bash
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
mv docker-compose-linux-x86_64 $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
```

4. Run Docker to point to Registry server.

```bash
sudo dockerd --registry-mirror=http://${REGISTRY_HOST}:5000/ &
```

5. Extract launcher.

```bash
tar -xzf launch.tar.gz
```

6. Set Kafka host IP address in `launch/conf/common.env` as shown below.

```env
MACHINE_ID=m001
MACHINE_DATA_TOPIC=m001_data
MACHINE_ALARMS_TOPIC=m001_alarms
MACHINE_ALERTS_TOPIC=m001_alerts
MACHINE_EVENTS_TOPIC=m001_events
# Quarkus, Kafka
QUARKUS_KAFKA_STREAMS_BOOTSTRAP_SERVERS=172.31.21.207:9092
# General
TZ="Asia/Kolkata"
```

7. Launch applications.

```bash
cd launch
docker compose -f compute.yaml --env-file compute.env up -d
```

## Frontend installation

1. Install Docker using binaries - https://docs.docker.com/engine/install/binaries/

```bash
export DOCKER_VERSION=24.0.7
export DOCKER_COMPOSE_VERSION=2.23.0
export REGISTRY_HOST=172.31.8.51
echo "export DOCKER_VERSION=24.0.7" >> .profile
echo "export DOCKER_COMPOSE_VERSION=2.23.0" >> .profile
echo "export REGISTRY_HOST=172.31.8.51" >> .profile
tar -zxf docker-${DOCKER_VERSION}.tgz
sudo cp docker/* /usr/bin/
```

2. Run Linux post-install steps - https://docs.docker.com/engine/install/linux-postinstall/

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

3. Install Docker Compose using binaries - https://docs.docker.com/compose/install/linux/#install-the-plugin-manually

```bash
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
mv docker-compose-linux-x86_64 $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
```

4. Run Docker to point to Registry server.

```bash
sudo dockerd --registry-mirror=http://${REGISTRY_HOST}:5000/ &
```

5. Extract launcher.

```bash
tar -xzf launch.tar.gz
```

6. Set Kafka host IP address in `launch/conf/common.env` as shown below.

```env
MACHINE_ID=m001
MACHINE_DATA_TOPIC=m001_data
MACHINE_ALARMS_TOPIC=m001_alarms
MACHINE_ALERTS_TOPIC=m001_alerts
MACHINE_EVENTS_TOPIC=m001_events
# Quarkus, Kafka
QUARKUS_KAFKA_STREAMS_BOOTSTRAP_SERVERS=172.31.21.207:9092
# General
TZ="Asia/Kolkata"
```

7. Launch applications.

```bash
cd launch
docker compose -f frontend.yaml --env-file frontend.env up -d
```
