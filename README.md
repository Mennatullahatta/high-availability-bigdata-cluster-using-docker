#  Highly Available Hadoop Cluster with Docker


## Table of Contents

- [Project Overview](#project-overview)
- [Cluster Architecture](#cluster-architecture)
- [Services & Roles](#services--roles)
- [Usage Instructions](#usage-instructions)
- [Checking Failover](#checking-failover)
- [Running a MapReduce Job](#running-a-mapreduce-job)
- [Adding a New Worker](#adding-a-new-worker)
- [Conclusion](#conclusion)


---

##  Project Overview

This project focuses on building a **Highly Available Hadoop Cluster** using **Docker automation**. The final architecture supports fault tolerance for both **HDFS** and **YARN** layers, ensuring zero downtime and high data availability.

---

##  Cluster Architecture

The target cluster setup consists of:

- **3 Master Nodes**
- **1 Worker Node**

Each Master node hosts essential services to maintain Hadoop high availability. All nodes communicate through a shared ZooKeeper ensemble.

```text
+---------------------+        +---------------------+        +---------------------+
|     Master Node 1   |        |     Master Node 2   |        |     Master Node 3   |
|---------------------|        |---------------------|        |---------------------|
| - ZooKeeper         |        | - ZooKeeper         |        | - ZooKeeper         |
| - JournalNode       |        | - JournalNode       |        | - JournalNode       |
| - NameNode (Active) | <----> | - NameNode (Standby)| <----> | - NameNode (Standby)|
| - ResourceManager   |        | - ResourceManager   |        | - ResourceManager   |
+---------------------+        +---------------------+        +---------------------+

                         |
                         |
                         v

+----------------------+
|    Worker Node       |
|----------------------|
| - DataNode           |
| - NodeManager        |
+----------------------+
```

---

## Services & Roles

### Master Node Services:

-  **ZooKeeper**: Coordinates leader election for NameNode and ResourceManager.
-  **JournalNode**: Maintains a shared edit log for NameNodes.
-  **NameNode**: One active, others standby (HDFS HA).
-  **ResourceManager**: One active, others standby (YARN HA).

### Worker Node Services:

-  **DataNode**: Stores data blocks.
-  **NodeManager**: Manages execution of containers.

---


##  Usage Instructions

1. Navigate to the project root.
2. Build and start the cluster using Docker Compose:

```bash
docker-compose up --build
```

3. Verify services using:

```bash
docker exec -it <container_id> jps
```

- Services ports


| Service   | HDFS NameNode Web UI Port   | YARN ResourceManager Web UI Port|
|------------|------------|-----------|
| master1 | 9871|  8081
| master2| 9872|  8082
| master3| 9873| 8083

---

## Checking failover


```bash
# Check HA status to see active and standby services
hdfs haadmin -getAllServiceState
yarn rmadmin -getAllServiceState
```

- Test HDFS Failover
```bash
hdfs --daemon stop namenode   # Simulate active NN failure
```

- Test YARN Failover
```bash
yarn --daemon stop resourcemanagerhdfs  # Simulate ResourceManager failure
``` 


## Running a MapReduce Job
```bash
hduser@master1:~$ hdfs dfs -mkdir -p /input
hduser@master1:~$ echo 'Hello Hadoop' > test.txt
hduser@master1:~$ hdfs dfs -put test.txt /input/
hduser@master1:~$ hadoop jar \
/usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
wordcount /input/test.txt /output
hduser@master1:~$ hdfs dfs -cat /output/part-r-00000

```

## Adding a New Worker

```bash
docker run -d --name worker2  --hostname worker2  --network hahadoop_hadoop-network  -e "YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop"  -e "HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop"  --volume hadoop_datanode2:/hadoop/dfs/data   hahadoop-worker1:latest
```
---

##  Conclusion

This project demonstrates a complete hands-on implementation of a **highly available Hadoop cluster** using Docker. It highlights:
- Core principles of Hadoop High Availability.
- Real-world system deployment and fault tolerance.
- Effective use of containerization for Big Data infrastructure.

---

### Author
Developed by [Mennatullah Atta](https://github.com/Mennatullahatta)
