FROM ubuntu:20.04
LABEL MAINTAINER="Junior-Steve ESSONO ELLA <junioressono@gmail.com>"

RUN apt-get update -y
RUN apt-get install -y apt-utils
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y wget
RUN apt-get install -y openssh-server
RUN apt-get install -y net-tools
RUN apt-get install -y vim

# Setup passphraseless ssh
RUN  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
     cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
     chmod 0600 ~/.ssh/authorized_keys

WORKDIR /root
COPY ./data/hadoop/hadoop-3.3.6-aarch64.tar.gz .
#RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.1-aarch64.tar.gz
RUN tar -xzvf hadoop-3.3.6-aarch64.tar.gz && \
    mv hadoop-3.3.6 /usr/local/hadoop && \
    rm hadoop-3.3.6-aarch64.tar.gz

# COPY ./data/spark/spark-3.2.1-bin-hadoop3.2.tgz .
#RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1-aarch64.tar.gz
# RUN tar -xzvf spark-3.2.1-bin-hadoop3.2.tgz && \
#     mv spark-3.2.1-bin-hadoop3.2 /usr/local/spark && \
#     rm spark-3.2.1-bin-hadoop3.2.tgz

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
ENV HADOOP_HOME=/usr/local/hadoop
# ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin
# ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/spark/bin

RUN java -version

# To use the root account to start and stop Hadoop services
COPY config/hadoop/hdfs-users.txt .
COPY config/hadoop/yarn-users.txt .
RUN echo "ToFix ERRORs & WARNs" && \
    \
    #ToFix ERROR: sd
    sed -i '1r ./hdfs-users.txt' $HADOOP_HOME/sbin/start-dfs.sh && \
    sed -i '1r ./hdfs-users.txt' $HADOOP_HOME/sbin/stop-dfs.sh && \
    sed -i '1r ./yarn-users.txt' $HADOOP_HOME/sbin/start-yarn.sh && \
    sed -i '1r ./yarn-users.txt' $HADOOP_HOME/sbin/stop-yarn.sh && \
    rm -f ~/*-users.txt && \
    \
    # tofix ERROR:
    sed -i -E '/JAVA_HOME+/a JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64' $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    \
    # tofix ERROR: Cannot set priority of datanode process  \
    # https://blog.titanwolf.in/a?ID=01000-5b05054c-3e55-4d7e-81ff-d4d67ea5ed9b)
    sed -i -E '/HADOOP_SHELL_EXECNAME+/a HADOOP_SHELL_EXECNAME="root"' $HADOOP_HOME/bin/hdfs && \
    \
    #tofix WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
    sed -i -E '/export HADOOP_OPTS+/a export HADOOP_OPTS="\$HADOOP_OPTS -Djava.net.preferIPv4Stack=true -Djava.security.krb5.realm= -Djava.security.krb5.kdc="' $HADOOP_HOME/etc/hadoop/hadoop-env.sh


COPY config/hadoop/ssh_config .ssh/config
COPY config/hadoop/start-hadoop.sh start-hadoop.sh

# Allow start-hadoop file to be executable
RUN chmod +x $HADOOP_HOME/etc/hadoop/*.sh && \
    chmod +x ~/start-hadoop.sh

# Create namenode, datanode and logs folders
RUN mkdir -p ~/hdfs/namenode && \
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# Format namenode
RUN $HADOOP_HOME/bin/hdfs namenode -format


COPY apps/**/target/*.jar ./apps/target/
#RUN apt-get update && apt-get install -y vim

#ENTRYPOINT [ "sh", "-c", "service ssh start; ~/start-hadoop.sh; bash;" ]
CMD [ "sh", "-c", "service ssh start; ~/start-hadoop.sh; bash" ]