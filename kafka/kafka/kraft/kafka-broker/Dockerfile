FROM openjdk:11-jre-slim

# Set environment variables
ENV KAFKA_VERSION=3.7.1
ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create Kafka installation directory
RUN mkdir -p $KAFKA_HOME

# Download and install Kafka
RUN wget https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_2.13-$KAFKA_VERSION.tgz -P /tmp \
    && tar -xzf /tmp/kafka_2.13-$KAFKA_VERSION.tgz -C $KAFKA_HOME \
    && mv $KAFKA_HOME/kafka_2.13-$KAFKA_VERSION/* $KAFKA_HOME/ \
    && rm /tmp/kafka_2.13-$KAFKA_VERSION.tgz \
    && rm -rf $KAFKA_HOME/kafka_2.13-$KAFKA_VERSION

# Expose broker port
EXPOSE 9092

# Set the working directory
WORKDIR $KAFKA_HOME

# Add custom config and start script
COPY ./broker.properties /opt/kafka/config/broker.properties
COPY ./start_kafka.sh $KAFKA_HOME/start_kafka.sh

# Make the script executable
RUN chmod +x $KAFKA_HOME/start_kafka.sh

# Set the default command
CMD ["./start_kafka.sh"]
