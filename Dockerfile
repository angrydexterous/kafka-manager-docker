FROM openjdk:8u201-jdk-alpine3.9 as base

ARG scala_version=2.12

ENV JAVA_HOME=/usr/java/default/ \
    ZK_HOSTS=localhost:2181 \
    KM_VERSION=1.3.3.23 \
    KM_REVISION=2ca848bfdf542bf1da8fc860db9bbcc99548f89d \
    KM_CONFIGFILE="conf/application.conf" \
    SCALA_VERSION=$scala_version

RUN apk add --no-cache bash curl jq docker git wget unzip which && \
    mkdir -p /tmp && \
    cd /tmp && \
    git clone https://github.com/yahoo/kafka-manager && \
    cd /tmp/kafka-manager && \
    git checkout ${KM_REVISION} && \
    echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt && \
    ./sbt clean dist && \
    unzip  -d / ./target/universal/kafka-manager-${KM_VERSION}.zip && \
    rm -fr /tmp/* /root/.sbt /root/.ivy2 


FROM base as working

WORKDIR /kafka-manager-${KM_VERSION}
ADD start-kafka-manager.sh /kafka-manager-${KM_VERSION}/start-kafka-manager.sh
RUN chmod +x /kafka-manager-${KM_VERSION}/start-kafka-manager.sh

EXPOSE 9000
ENTRYPOINT ["./start-kafka-manager.sh"]
