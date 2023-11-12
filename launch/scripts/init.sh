#!/bin/bash
source ../conf/init.env
${KAFKA_HOME}/bin/kafka-topics.sh \
  --bootstrap-server ${KAFKA_BROKER} \
  --create --if-not-exists \
  --topic ${MACHINE_ID}_data   \
  --replication-factor ${REPLICATION_FACTOR} \
  --partitions ${PARTITION_COUNT}

${KAFKA_HOME}/bin/kafka-topics.sh \
  --bootstrap-server ${KAFKA_BROKER} \
  --create --if-not-exists \
  --topic ${MACHINE_ID}_limits   \
  --replication-factor ${REPLICATION_FACTOR} \
  --partitions ${PARTITION_COUNT}

${KAFKA_HOME}/bin/kafka-topics.sh \
  --bootstrap-server ${KAFKA_BROKER} \
  --create --if-not-exists \
  --topic ${MACHINE_ID}_alarms   \
  --replication-factor ${REPLICATION_FACTOR} \
  --partitions ${PARTITION_COUNT}

${KAFKA_HOME}/bin/kafka-topics.sh \
  --bootstrap-server ${KAFKA_BROKER} \
  --create --if-not-exists \
  --topic ${MACHINE_ID}_alerts   \
  --replication-factor ${REPLICATION_FACTOR} \
  --partitions ${PARTITION_COUNT}

${KAFKA_HOME}/bin/kafka-topics.sh \
  --bootstrap-server ${KAFKA_BROKER} \
  --create --if-not-exists \
  --topic ${MACHINE_ID}_events   \
  --replication-factor ${REPLICATION_FACTOR} \
  --partitions ${PARTITION_COUNT}
