#!/bin/bash

rm -rf /tmp/kraft-controller-logs

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


# 필수 도구 설치

source $KAFKA_HOME/.env

mkdir -p /root/.aws/

# AWS CLI 자격 증명 설정
echo "[default]" > /root/.aws/credentials
echo "aws_access_key_id = ${AWS_ACCESS_KEY}" >> /root/.aws/credentials
echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> /root/.aws/credentials
echo "region = ap-northeast-2" >> /root/.aws/credentials

apt-get update && apt-get install -y curl unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# EC2 인스턴스 ID 가져오기
#INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_ID="i-01afd596ffa1bf50e"

# EC2 태그에서 Cluster.id 확인
#EXISTING_CLUSTER_ID=$(aws ec2 describe-tags \
#    --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Cluster.id" \
#    --query "Tags[0].Value" --output text)

#if [ "$EXISTING_CLUSTER_ID" == "None" ]; then
# Cluster ID가 없으면 생성
#  echo "Cluster ID가 없습니다. 새로 생성합니다."
CLUSTER_ID=$($KAFKA_HOME/bin/kafka-storage.sh random-uuid)
  
$KAFKA_HOME/bin/kafka-storage.sh format \
    -t $CLUSTER_ID \
    -c $KAFKA_HOME/config/controller.properties

# EC2 태그에 Cluster ID 저장
aws ec2 create-tags \
    --resources $INSTANCE_ID \
    --tags Key=Cluster.id,Value=$CLUSTER_ID

aws ec2 describe-tags \
  --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Cluster.id" \
  --query "Tags[0].Value" --output text


echo "생성된 Cluster ID: $CLUSTER_ID"
#else
  # 기존 Cluster ID 출력
#echo "기존 Cluster ID: $EXISTING_CLUSTER_ID"
#fi

#####################################################################################################

# Kafka를 nohup으로 백그라운드에서 실행
nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/controller.properties > $LOG_FILE 2>&1 &

# Kafka 프로세스가 계속 실행될 수 있도록 상태 유지
echo "Kafka is running..."

while true; do sleep 1000; done

