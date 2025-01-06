#!/bin/bash

# Kafka Connect 설정 파일 경로
#CONFIG_FILE="$KAFKA_HOME/config/connect-distributed.properties"
CONFIG_FILE="$KAFKA_HOME/config/connect-standalone.properties"

echo "Starting Kafka Connect with configuration: $CONFIG_FILE"

# Kafka Connect 실행
$KAFKA_HOME/bin/connect-standalone.sh "$CONFIG_FILE"

while true; do sleep 1000; done
