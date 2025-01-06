#!/bin/bash

echo "Starting Kafka with the following environment variables:"
echo "KAFKA_NODE_ID=${KAFKA_NODE_ID}"
echo "KAFKA_PROCESS_ROLES=${KAFKA_PROCESS_ROLES}"
echo "KAFKA_LISTENERS=${KAFKA_LISTENERS}"
echo "KAFKA_ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS}"
echo "KAFKA_INTER_BROKER_LISTENER_NAME=${KAFKA_INTER_BROKER_LISTENER_NAME}"
echo "KAFKA_CONTROLLER_LISTENER_NAMES=${KAFKA_CONTROLLER_LISTENER_NAMES}"
echo "KAFKA_CONTROLLER_QUORUM_VOTERS=${KAFKA_CONTROLLER_QUORUM_VOTERS}"

# 환경 변수를 사용하여 설정 파일의 변수를 치환
sed -i "s|\${KAFKA_NODE_ID}|${KAFKA_NODE_ID}|g" $KAFKA_HOME/config/broker.properties
sed -i "s|\${KAFKA_PROCESS_ROLES}|${KAFKA_PROCESS_ROLES}|g" $KAFKA_HOME/config/broker.properties
sed -i "s|\${KAFKA_LISTENERS}|${KAFKA_LISTENERS}|g" $KAFKA_HOME/config/broker.properties
sed -i "s|\${KAFKA_ADVERTISED_LISTENERS}|${KAFKA_ADVERTISED_LISTENERS}|g" $KAFKA_HOME/config/broker.properties
sed -i "s|\${KAFKA_INTER_BROKER_LISTENER_NAME}|${KAFKA_INTER_BROKER_LISTENER_NAME}|g" $KAFKA_HOME/config/broker.properties
sed -i "s|\${KAFKA_CONTROLLER_LISTENER_NAMES}|${KAFKA_CONTROLLER_LISTENER_NAMES}|g" $KAFKA_HOME/config/broker.properties
sed -i "s|\${KAFKA_CONTROLLER_QUORUM_VOTERS}|${KAFKA_CONTROLLER_QUORUM_VOTERS}|g" $KAFKA_HOME/config/broker.properties

#rm -rf /tmp/kraft-broker-logs/*
#rm -rf /tmp/kraft-controller-logs/*

# Start Kafka in KRaft mode

sleep 10

# 로그 파일 경로 설정 수정
KAFKA_HOME="/opt/kafka"
LOG_DIR="/opt/kafka/logs"
LOG_FILE="${LOG_DIR}/my_kafka_server_log.log"
#CONFIG_FILE="$KAFKA_HOME/config/broker.properties"

# Kafka 환경 변수 확인
echo "Kafka Version: $KAFKA_VERSION"
echo "Kafka Home: $KAFKA_HOME"

# 로그 디렉토리가 없으면 생성
mkdir -p $LOG_DIR

CLUSTER_ID=$(cat /tmp/kraft-clusterid/cluster.id)
echo "*************"
echo $CLUSTER_ID

$KAFKA_HOME/bin/kafka-storage.sh format \
  -t $CLUSTER_ID \
  -c /opt/kafka/config/broker.properties 

# Kafka를 nohup으로 백그라운드에서 실행
nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/broker.properties > $LOG_FILE 2>&1 &

# Kafka가 실행될 때까지 대기
#echo "Waiting for Kafka to start..."
#sleep 10

#TOPIC_NAME="logs"
#PARTITIONS=3
#REPLICATION_FACTOR=1
#KAFKA_ADVERTISED_LISTENER="13.125.119.159:9092"


# 토픽 생성
#$KAFKA_HOME/bin/kafka-topics.sh --create --topic $TOPIC_NAME --partitions $PARTITIONS --replication-factor $REPLICATION_FACTOR --bootstrap-server $KAFKA_ADVERTISED_LISTENER

#echo "******************"

# 토픽 확인
#$KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server $KAFKA_ADVERTISED_LISTENER

# Kafka 프로세스가 계속 실행될 수 있도록 상태 유지
echo "Kafka is running..."

while true; do sleep 1000; done

