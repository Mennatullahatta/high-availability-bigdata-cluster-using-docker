FROM ubuntu:22.04


RUN apt update -y && \
    apt upgrade -y && \
    apt install -y openjdk-8-jdk openssh-server ssh wget vim sudo netcat && \
    apt clean


ENV HADOOP_HOME=/usr/local/hadoop 
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV PATH=$JAVA_HOME/bin:$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin 
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native 
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
ENV ZOOKEEPER_HOME=/usr/local/zookeeper/bin/zkServer.sh


RUN addgroup hadoop && \
    adduser --disabled-password --gecos "" --ingroup hadoop hduser && \
    echo "hduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers



RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    tar -xvzf hadoop-3.3.6.tar.gz -C /usr/local && \
    mv /usr/local/hadoop-3.3.6 /usr/local/hadoop && \
    chown -R hduser:hadoop /usr/local/hadoop && \
    chmod -R 777 /usr/local/hadoop



RUN wget https://dlcdn.apache.org/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz && \
    tar -xvzf apache-zookeeper-3.8.4-bin.tar.gz -C /usr/local && \
    mv /usr/local/apache-zookeeper-3.8.4-bin /usr/local/zookeeper && \
    mkdir -p /usr/local/zookeeper/data && \
    chown -R hduser:hadoop /usr/local/zookeeper && \
    chmod -R 777 /usr/local/zookeeper



USER hduser
WORKDIR /home/hduser


RUN ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys


COPY config/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY config/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY config/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY config/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
COPY config/workers $HADOOP_HOME/etc/hadoop/workers
COPY zoo.cfg /usr/local/zookeeper/conf/zoo.cfg
COPY entrypoint.sh /home/hduser/entrypoint.sh
RUN sudo chmod +x ~/entrypoint.sh


RUN sudo mkdir -p /hadoop/dfs/name /hadoop/dfs/data && \
    sudo chown -R hduser:hadoop /hadoop/dfs && \
    sudo chmod -R 777 /hadoop/dfs


ENTRYPOINT ["/home/hduser/entrypoint.sh"]
