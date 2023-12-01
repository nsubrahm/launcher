# EC2 install instructions

This page documents steps to install the application on EC2 instance.

- [EC2 install instructions](#ec2-install-instructions)
  - [Initialize](#initialize)
  - [Install Docker](#install-docker)
  - [Login to GHCR](#login-to-ghcr)
  - [Install Java](#install-java)
  - [Install Kafka as a service](#install-kafka-as-a-service)
  - [Install application](#install-application)


## Initialize

1. Set-up environment variables and initialize.

```bash
export KAFKA_BIN_RELEASE=2.13
export KAFKA_RELEASE=3.6.0
export KAFKA_HOME=/opt/kafka
export MTMT_VERSION=0.0.0
echo "export KAFKA_BIN_RELEASE=2.13" >> .profile
echo "export KAFKA_RELEASE=3.6.0" >> .profile
echo "export KAFKA_HOME=/opt/kafka" >> .profile
echo "export MTMT_VERSION=0.0.0" >> .profile
sudo apt-get update
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

Log out and log in again to the EC2 instance.

## Login to GHCR

3. Log in to `ghcr.io` container registry.

```bash
export CR_PAT=
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

## Install Java

4. Install Java.

```bash
sudo apt-get install -y openjdk-19-jre-headless
```

## Install Kafka as a service

5. Install Kafka.

```bash
wget https://dlcdn.apache.org/kafka/${KAFKA_RELEASE}/kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE}.tgz
tar -zxvf kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE}.tgz
sudo cp -R ~/kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE} /opt
sudo ln -s /opt/kafka_${KAFKA_BIN_RELEASE}-${KAFKA_RELEASE} /opt/kafka
```

6. Copy the following to `/etc/init.d/kafka` to set-up Kafka service.

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

7. Change permissions and launch Kafka service.

```bash
sudo chmod 755 /etc/init.d/kafka
sudo update-rc.d kafka defaults
sudo service kafka start
sudo service kafka status
```

## Install application

8. Download and unzip application archive.

```bash
cd $HOME
wget https://github.com/nsubrahm/launcher/releases/download/v${MTMT_VERSION}/launcher.tar.gz
tar -xzf launcher.tar.gz
export PROJECT_HOME=$HOME/launch
echo "export PROJECT_HOME=$HOME/launch" >> .profile
```

9. Create topics on Kafka broker.

```bash
cd ${PROJECT_HOME}/scripts
./init.sh
```

10. Launch applications.

```bash
docker compose -f apps.yaml  --env-file apps.env up -d
```

11. Check.

The following command should list the `alarms`, `alerts`, `merger` and `events` applications launched and in healthy status. 

```bash
docker ps
```
