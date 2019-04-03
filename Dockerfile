FROM centos:7 as base

RUN yum update -y && \
    yum install -y java-1.8.0-openjdk-headless && \
    yum clean all

ENV JAVA_HOME=/usr/java/default/ \
    ZK_HOSTS=localhost:2181 \
    KM_VERSION=1.3.3.23 \
    KM_REVISION=2ca848bfdf542bf1da8fc860db9bbcc99548f89d \
    KM_CONFIGFILE="conf/application.conf"

RUN yum install -y java-1.8.0-openjdk-devel git wget unzip which && \
    mkdir -p /tmp && \
    cd /tmp && \
    git clone https://github.com/yahoo/kafka-manager && \
    cd /tmp/kafka-manager && \
    git checkout ${KM_REVISION} && \
    echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt && \
    ./sbt clean dist && \
    unzip  -d / ./target/universal/kafka-manager-${KM_VERSION}.zip && \
    rm -fr /tmp/* /root/.sbt /root/.ivy2 && \
    yum autoremove -y java-1.8.0-openjdk-devel git wget unzip which && \
    yum clean all


FROM base as working

WORKDIR /kafka-manager-${KM_VERSION}
ADD start-kafka-manager.sh /kafka-manager-${KM_VERSION}/start-kafka-manager.sh
RUN chmod +x /kafka-manager-${KM_VERSION}/start-kafka-manager.sh

EXPOSE 9000
ENTRYPOINT ["./start-kafka-manager.sh"]
