FROM ubuntu:20.04
LABEL MAINTAINER="Junior-Steve ESSONO ELLA <junioressono@gmail.com>"

RUN apt-get update -y
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y vim
RUN apt-get install -y scala

WORKDIR /root
COPY ./data/spark/spark-3.2.1-bin-hadoop3.2.tgz .
#RUN wget https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz
RUN tar -xzvf spark-3.2.1-bin-hadoop3.2.tgz && \
    mv spark-3.2.1-bin-hadoop3.2 /usr/local/spark && \
    rm spark-3.2.1-bin-hadoop3.2.tgz

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

CMD [ "sh", "-c", "start-master.sh; bash" ]