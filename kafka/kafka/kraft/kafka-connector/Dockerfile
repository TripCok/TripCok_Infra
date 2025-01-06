# OpenJDK 11 (Java 런타임 환경) 기반의 슬림 버전 이미지 사용
FROM openjdk:11-jre-slim

# 환경 변수 설정
ENV KAFKA_VERSION=3.7.1
ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

# 필요한 패키지 설치 (wget)
RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Kafka 설치 디렉터리 생성
RUN mkdir -p $KAFKA_HOME

# Kafka 다운로드 및 설치
RUN wget https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_2.13-$KAFKA_VERSION.tgz -P /tmp \
    && tar -xzf /tmp/kafka_2.13-$KAFKA_VERSION.tgz -C $KAFKA_HOME \
    && mv $KAFKA_HOME/kafka_2.13-$KAFKA_VERSION/* $KAFKA_HOME/ \
    && rm /tmp/kafka_2.13-$KAFKA_VERSION.tgz \
    && rm -rf $KAFKA_HOME/kafka_2.13-$KAFKA_VERSION

# Kafka Connect REST API 포트 노출
EXPOSE 8083

# 작업 디렉터리를 Kafka 홈 디렉터리로 설정
WORKDIR $KAFKA_HOME

# Kafka Connect 환경 설정 파일 복사
#COPY ./connect-distributed.properties $KAFKA_HOME/config/connect-distributed.properties
COPY ./connect-standalone.properties $KAFKA_HOME/config/connect-standalone.properties


# Kafka Connect 시작 스크립트 복사
COPY ./start_connector.sh $KAFKA_HOME/start_connector.sh


# 시작 스크립트 실행 권한 부여
RUN chmod +x $KAFKA_HOME/start_connector.sh

# 기본 실행 명령 설정
CMD ["./start_connector.sh"]

