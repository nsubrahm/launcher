#!/bin/bash
source ../conf/init.env
${KAFKA_HOME}/bin/kafka-topics.sh --bootstrap-server ${KAFKA_BROKER} --delete --topic ${MACHINE_ID}_data
${KAFKA_HOME}/bin/kafka-topics.sh --bootstrap-server ${KAFKA_BROKER} --delete --topic ${MACHINE_ID}_limits
${KAFKA_HOME}/bin/kafka-topics.sh --bootstrap-server ${KAFKA_BROKER} --delete --topic ${MACHINE_ID}_alarms
${KAFKA_HOME}/bin/kafka-topics.sh --bootstrap-server ${KAFKA_BROKER} --delete --topic ${MACHINE_ID}_alerts
${KAFKA_HOME}/bin/kafka-topics.sh --bootstrap-server ${KAFKA_BROKER} --delete --topic ${MACHINE_ID}_events
