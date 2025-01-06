#!/bin/bash

sleep 10

echo "Starting Kafka with the following environment variables:"
echo "KAFKA_NODE_ID=${KAFKA_NODE_ID}"
echo "KAFKA_PROCESS_ROLES=${KAFKA_PROCESS_ROLES}"
echo "KAFKA_LISTENERS=${KAFKA_LISTENERS}"
echo "KAFKA_CONTROLLER_LISTENER_NAMES=${KAFKA_CONTROLLER_LISTENER_NAMES}"
echo "KAFKA_CONTROLLER_QUORUM_VOTERS=${KAFKA_CONTROLLER_QUORUM_VOTERS}"

# 환경 변수를 사용하여 설정 파일의 변수를 치환
sed -i "s|\${KAFKA_NODE_ID}|${KAFKA_NODE_ID}|g" $KAFKA_HOME/config/controller.properties
sed -i "s|\${KAFKA_PROCESS_ROLES}|${KAFKA_PROCESS_ROLES}|g" $KAFKA_HOME/config/controller.properties
sed -i "s|\${KAFKA_LISTENERS}|${KAFKA_LISTENERS}|g" $KAFKA_HOME/config/controller.properties
sed -i "s|\${KAFKA_CONTROLLER_LISTENER_NAMES}|${KAFKA_CONTROLLER_LISTENER_NAMES}|g" $KAFKA_HOME/config/controller.properties
sed -i "s|\${KAFKA_CONTROLLER_QUORUM_VOTERS}|${KAFKA_CONTROLLER_QUORUM_VOTERS}|g" $KAFKA_HOME/config/controller.properties

# Start Kafka in KRaft mode

# 로그 파일 경로 설정 수정
KAFKA_HOME="/opt/kafka"
LOG_DIR="/opt/kafka/logs"
LOG_FILE="${LOG_DIR}/my_kafka_server_log.log"

# Kafka 환경 변수 확인
echo "Kafka Version: $KAFKA_VERSION"
echo "Kafka Home: $KAFKA_HOME"

# 로그 디렉토리가 없으면 생성
mkdir -p $LOG_DIR

###################################클러스터 아이디 생성 및 저장 또는 조회 ###################################

AWS_CLI_PATH="/usr/local/bin/aws"  # AWS CLI 설치 경로
INSTANCE_ID="i-01afd596ffa1bf50e"  # EC2 인스턴스 ID (변경 필요)
CONTROLLER_PROPERTIES="/opt/kafka/config/controller.properties"  # Kafka 브로커 설정 파일 경로

source $KAFKA_HOME/.env

mkdir -p /root/.aws/

# AWS CLI 자격 증명 설정
echo "[default]" > /root/.aws/credentials
echo "aws_access_key_id = ${AWS_ACCESS_KEY}" >> /root/.aws/credentials
echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> /root/.aws/credentials
echo "region = ap-northeast-2" >> /root/.aws/credentials

# 필수 패키지 및 AWS CLI 설치
apt-get update && apt-get install -y curl unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

mkdir -p /opt/kafka/data

# Cluster ID 저장 파일 경로
CLUSTER_ID_FILE="/opt/kafka/data/cluster_id"

# AWS에서 조회한 Cluster ID
CLUSTER_ID=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Cluster.id" --query "Tags[0].Value" --output text)

# 클러스터 ID 출력
echo "Cluster ID from AWS: $CLUSTER_ID"

# 기존에 저장된 Cluster ID 확인
if [ -f "$CLUSTER_ID_FILE" ]; then
    STORED_CLUSTER_ID=$(cat "$CLUSTER_ID_FILE")
    echo "Stored Cluster ID: $STORED_CLUSTER_ID"
else
    STORED_CLUSTER_ID=""
fi

# Cluster ID 비교
if [ "$CLUSTER_ID" != "$STORED_CLUSTER_ID" ]; then
    echo "Cluster ID mismatch or not found. Formatting Kafka storage..."

    # 기존 meta.properties 파일 삭제
    rm -f /tmp/kraft-controller-logs/meta.properties

    # meta.properties 내용 출력
    cat /tmp/kraft-controller-logs/meta.properties

    chmod -R 777 /tmp/kraft-controller-logs

    # Kafka 포맷 실행
    $KAFKA_HOME/bin/kafka-storage.sh format -t $CLUSTER_ID -c $CONTROLLER_PROPERTIES
    cat /tmp/kraft-controller-logs/meta.properties

    # 새로운 Cluster ID 저장
    echo "$CLUSTER_ID" > "$CLUSTER_ID_FILE"
else
    echo "Cluster ID matches. Skipping format step."
fi


# Kafka를 nohup으로 백그라운드에서 실행
nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/controller.properties > $LOG_FILE 2>&1 &

# Kafka가 실행될 때까지 대기
#echo "Waiting for Kafka to start..."
#sleep 10

#TOPIC_NAME="logs"
#PARTITIONS=3
#REPLICATION_FACTOR=1

# 토픽 생성
#$KAFKA_HOME/bin/kafka-topics.sh --create --topic $TOPIC_NAME --partitions $PARTITIONS --replication-factor $REPLICATION_FACTOR --bootstrap-server $KAFKA_ADVERTISED_LISTENER

# 토픽 확인
#$KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server $KAFKA_ADVERTISED_LISTENER

# Kafka 프로세스가 계속 실행될 수 있도록 상태 유지
echo "Kafka is running..."

while true; do sleep 1000; done

