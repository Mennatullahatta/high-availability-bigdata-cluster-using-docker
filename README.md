#  Highly Available Hadoop Cluster with Docker


---

##  Table of Contents

- [ Project Overview](#-project-overview)
- [ Cluster Architecture](#-cluster-architecture)
- [ Services & Roles](#️-services--roles)
- [ Cluster Setup with Docker](#-cluster-setup-with-docker)
- [ Usage Instructions](#-usage-instructions)
- [ Validation & Testing](#-validation--testing)
- [ Conclusion](#-conclusion)

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

## ⚙️ Services & Roles

### Master Node Services:

-  **ZooKeeper**: Coordinates leader election for NameNode and ResourceManager.
-  **JournalNode**: Maintains a shared edit log for NameNodes.
-  **NameNode**: One active, others standby (HDFS HA).
-  **ResourceManager**: One active, others standby (YARN HA).

### Worker Node Services:

-  **DataNode**: Stores data blocks.
-  **NodeManager**: Manages execution of containers.

---

##  Cluster Setup with Docker

This project leverages Docker to automate the deployment of a fully functional HA Hadoop cluster.

- Docker Compose orchestrates all required containers.
- Each master/worker runs in an isolated Docker container.
- Named volumes and custom networks ensure reliable communication.
- Configuration files are mounted for dynamic and centralized control.

**Technologies Used:**
- Docker
- Docker Compose
- Bash scripts
- Hadoop 3.x
- Java 8
- ZooKeeper


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

4. Access Hadoop UIs on:
- HDFS UI: `http://<master-node>:9870`
- YARN UI: `http://<master-node>:8088`

---

##  Validation & Testing

- Test failover by killing active NameNode/ResourceManager and observing auto-switchover.
- Check data replication across DataNodes.
- Submit sample MapReduce job and monitor progress via YARN UI.
- Run HDFS commands (`hdfs dfs -ls /`, etc.) from any master or worker.

---

##  Conclusion

This project demonstrates a complete hands-on implementation of a **highly available Hadoop cluster** using Docker. It highlights:
- Core principles of Hadoop High Availability.
- Real-world system deployment and fault tolerance.
- Effective use of containerization for Big Data infrastructure.

---
