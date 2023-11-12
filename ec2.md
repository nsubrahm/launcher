# Install on Amazon EC2

This document installs the Maintenance Mitra application on Amazon EC2 (**Ubuntu**) instances.

- [Install on Amazon EC2](#install-on-amazon-ec2)
  - [Architecture diagram](#architecture-diagram)
  - [Bastion host](#bastion-host)
  - [Registry installation](#registry-installation)
  - [Java and Kafka installation](#java-and-kafka-installation)
  - [Compute installation](#compute-installation)
  - [Frontend installation](#frontend-installation)

## Architecture diagram

- 5 EC2 instances will be launched as described below.

| Application                              | Instance type | Instance name | Subnet    | Description                                                                                               |
| ---------------------------------------- | :-----------: | :------------ | --------- | --------------------------------------------------------------------------------------------------------- |
| `payload`, `limits`, `dashboard`         |  `t3a.nano`   | Frontend      | `public`  | Exposes end-point for receiving payloads and limits application. Exposes an end-point for dashboard.      |
| `kafka`                                  |  `t3a.small`  | Broker        | `private` | Broker installation                                                                                       |
| `alarms`, `alerts`, `merger`, `streamer` |  `t3a.nano`   | Compute       | `private` | Run Quarkus applications                                                                                  |
| `registry`                               |  `t3a.nano`   | Registry      | `public`  | Container registry proxy to GitHub since Compute runs in `private` subnet and NAT Gateway incurs charges. |
| `bastion`                                |  `t3a.nano`   | Bastion       | `public`  | Bastion host                                                                                              |

- The following traffic control is set-up.

| Instance name | Inbound           | Outbound          |
| ------------- | ----------------- | ----------------- |
| Bastion       | Internet          | Internet          |
| Frontend      | Internet          | Internet          |
| Broker        | Frontend, Compute | Frontend, Compute |
| Compute       | Broker            | Broker            |
| Registry      | Frontend, Compute | Frontend, Compute |

## Bastion host

Launch a `t3a.nano` instance in `public` subnet to run commands on instances launched in `private` subnet.

1. Download Java, Kafka, Docker Engine and Docker Compose.

```bash
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
wget https://dlcdn.apache.org/kafka/${KAFKA_RELEASE}/kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE}.tgz
wget https://download.java.net/java/GA/jdk21.0.1/415e3f918a1f4062a0074a2794853d0d/12/GPL/openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz
wget https://github.com/nsubrahm/launcher/archive/refs/tags/v${MTMT_VERSION}.tar.gz
wget https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz
wget https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 
```

2. `sftp` to Broker machine.

```bash
sftp -i key.pem ubuntu@private-ip-of-broker
put kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE}.tgz
put openjdk-21.0.1_linux-x64_bin.tar.gz
put v${MTMT_VERSION}.tar.gz
```

3. `sftp` to Compute machine.

```bash
sftp -i key.pem ubuntu@private-ip-of-compute
put docker-24.0.7.tgz
put docker-compose-linux-x86_64
put v${MTMT_VERSION}.tar.gz
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

2. Create registry configuration - `config.yml`

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

1. Install Java

```bash
sudo tar -xvf openjdk-21.0.1_linux-x64_bin.tar.gz -C /opt
sudo update-alternatives --install /usr/bin/java java /opt/jdk-21.0.1/bin/java 1000
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

3. Set-up Kafka service with instructions from [here](https://stackoverflow.com/a/39901893/919480). 

3a. Save the following in `/etc/init.d/kafka` file.

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

3b. Set-up service.

```bash
sudo chmod 755 /etc/init.d/kafka
sudo update-rc.d kafka defaults
```

3c. Start service.

```bash
sudo service kafka start
```

4. Create topics.

```bash
echo "export MTMT_VERSION=0.0.0" >> .profile
MTMT_VERSION=0.0.0
tar -xzf v${MTMT_VERSION}.tar.gz
cd launcher-${MTMT_VERSION}/launch/scripts
./init.sh
```

## Compute installation

The following instructions are to be carried out on a `t3a.nano` instance in a `private` subnet. The `registry` instance can be used as a bastion host.

1. Install Docker using binaries - https://docs.docker.com/engine/install/binaries/
2. Run Linux post-install steps - https://docs.docker.com/engine/install/linux-postinstall/
3. Install Docker Compose using binaries - https://docs.docker.com/compose/install/linux/#install-the-plugin-manually
4. Run Docker to point to Registry server.

```bash
sudo dockerd --registry-server=http://registry-private-ip:5000/ &
```

5. Extract launcher.

```bash
echo "export MTMT_VERSION=0.0.0" >> .profile
MTMT_VERSION=0.0.0
tar -xzf launcher.tar.gz
```

5. Launch applications.

```bash
cd launcher-${MTMT_VERSION}
docker compose -f compute.yaml --env-file compute.env up -d
```

## Frontend installation

The following instructions are to be carried out on a `t3a.nano` instance in a `private` subnet. The `registry` instance can be used as a bastion host.

1. Install Docker using binaries - https://docs.docker.com/engine/install/binaries/
2. Run Linux post-install steps - https://docs.docker.com/engine/install/linux-postinstall/
3. Install Docker Compose using binaries - https://docs.docker.com/compose/install/linux/#install-the-plugin-manually
4. Extract launcher.

```bash
echo "export MTMT_VERSION=0.0.0" >> .profile
MTMT_VERSION=0.0.0
tar -xzf launcher.tar.gz
```

5. Launch applications.

```bash
cd launcher-${MTMT_VERSION}
docker compose -f front-end.yaml --env-file front-end.env up -d
```
