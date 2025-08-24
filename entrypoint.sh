#!/bin/bash
set -e

sudo service ssh start

HOSTNAME=$(hostname)
NODE_NUMBER=$(echo "$HOSTNAME" | tail -c 2)

is_master() {
    echo "$HOSTNAME" | grep -qi 'master'
}

wait_for_port() {
    local host=$1
    local port=$2
    echo "Waiting for $host:$port"
    while ! nc -z $host $port; do
        sleep 1
    done
}

if is_master; then
    # Master configuration
    echo "Zookeeper myid: $NODE_NUMBER"
    echo "$NODE_NUMBER" > /usr/local/zookeeper/data/myid

    # Start JournalNode and Zookeeper 
    hdfs --daemon start journalnode
    /usr/local/zookeeper/bin/zkServer.sh start

    if [ "$NODE_NUMBER" -eq "1" ]; then
        # Primary NameNode
        echo "Initializing primary NameNode"
        
        # Wait for JournalNodes to form quorum
        wait_for_port master2 8485
        wait_for_port master3 8485
        
        hdfs namenode -format -force
        hdfs zkfc -formatZK -force
        hdfs --daemon start namenode
    else
        # Standby NameNode
        echo "Initializing standby NameNode"
        
        # Ensure primary NameNode is fully up
        wait_for_port master1 8020
        wait_for_port master1 9870  
        
        hdfs namenode -bootstrapStandby -force
        hdfs --daemon start namenode
    fi

    # Start remaining services
    yarn --daemon start resourcemanager
    hdfs --daemon start zkfc
    
    # Verify HA status
    echo "Checking HA status"
    hdfs haadmin -getAllServiceState || true
else
    # Worker node configuration
    echo "Starting DataNode and NodeManager"
    wait_for_port master1 8020   # Ensure NameNode is ready
    wait_for_port master1 8088   # Ensure ResourceManager is ready
    
    hdfs --daemon start datanode
    yarn --daemon start nodemanager
fi

sleep infinity
