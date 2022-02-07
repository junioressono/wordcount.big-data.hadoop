FROM ubuntu:20.04
LABEL MAINTAINER="Junior-Steve ESSONO ELLA <junioressono@gmail.com>"

RUN apt-get update -y
RUN apt-get install -y apt-utils
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y wget
RUN apt-get install -y openssh-server
RUN apt-get install -y net-tools

# Setup passphraseless ssh
RUN  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
     cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
     chmod 0600 ~/.ssh/authorized_keys

WORKDIR /root
COPY ./data/hadoop/hadoop-3.3.1-aarch64.tar.gz .
#RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1-aarch64.tar.gz
RUN tar -xzvf hadoop-3.3.1-aarch64.tar.gz && \
    mv hadoop-3.3.1 /usr/local/hadoop && \
    rm hadoop-3.3.1-aarch64.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin


# To use the root account to start and stop Hadoop services
COPY config/hadoop/hdfs-users.txt .
COPY config/hadoop/yarn-users.txt .
RUN sed -i '1r ./hdfs-users.txt' $HADOOP_HOME/sbin/start-dfs.sh && \
    sed -i '1r ./hdfs-users.txt' $HADOOP_HOME/sbin/stop-dfs.sh && \
    sed -i '1r ./yarn-users.txt' $HADOOP_HOME/sbin/start-yarn.sh && \
    sed -i '1r ./yarn-users.txt' $HADOOP_HOME/sbin/stop-yarn.sh && \
    sed -i -E '/JAVA_HOME+/a JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    sed -i -E '/export HADOOP_OPTS+/a export HADOOP_OPTS = "\$HADOOP_OPTS"-Djava.library.path = /usr/local/hadoop/lib \n export HADOOP_COMMON_LIB_NATIVE_DIR = "/usr/local/hadoop/lib/native"' $HADOOP_HOME/etc/hadoop/hadoop-env.sh


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


#ENTRYPOINT [ "sh", "-c", "service ssh start; ~/start-hadoop.sh; bash;" ]
CMD [ "sh", "-c", "service ssh start; ~/start-hadoop.sh; bash" ]