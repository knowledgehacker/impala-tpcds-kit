# A Fair benchmark for Cloudera impala

Based on TPC-DS benchmark for Cloudera we found here [https://github.com/cloudera/impala-tpcds-kit](https://github.com/cloudera/impala-tpcds-kit)

**NOTICE: This repo contains modifications to the official TPC-DS specification so any results from this are not comparable to officially audited results.**


## Environment Setup Steps

These steps setup your environment to perform a distributed data generation for the given
scale factor.

### Prerequisites

The scripts assume that you have passwordless SSH from the master node (where you will clone the repos to) to every DataNode that is in your cluster.

These scripts also assume that your $HOME directory is the same path on all DataNodes.

### Download and build the modified TPC-DS tools

* `sudo yum -y install gcc make flex bison byacc git`
* `cd $HOME` (use your `$HOME` directory as it's hard coded in some scripts for now)
* `git clone https://github.com/grahn/tpcds-kit.git`
* `cd tpcds-kit/tools`
* `make -f Makefile.suite`

### Clone the Impala TPC-DS tools repo & Configure the HDFS directories

* `cd $HOME` (use your `$HOME` directory as it's hard coded in some scripts for now)
* clone this repo `git clone https://github.com/cloudera/impala-tpcds-kit`
* `cd impala-tpcds-kit`
* Edit `tpcds_env.sh` and modify as needed.  The defaults assume you have a `/user/$USER` directory in HDFS.  If you don't, run these commands:
  * `sudo -u hdfs hdfs dfs -mkdir /user/$USER`
  * `sudo -u hdfs hdfs dfs -chown $USER /user/$USER`
  * `sudo -u hdfs hdfs dfs -chmod 777 /user/$USER`
* Edit `dn.txt` and put one DataNode hostname per line - no blank lines.
* Run `push-bits.sh` which will scp `tpcds-kit` and `impala-tpcds-kit` to each DataNode listed in `dn.txt`.
* Run `set-nodenum.sh`.  This will create `impala-tpcds-kit/nodenum.sh` on every DataNode and set the value accordingly.  This is used to determine what portion of the distributed data generation is done on each node.

## Preparation and Data Generation
 
`./push-bits.sh && ./set-nodenum.sh && ./run-gen-facts.sh > /tmp/tpcds.log && tail -f /tmp/tpcds.log`

## Data loading

`./returns-move.sh && ./hdfs-load.sh && ./impala-drop-db.sh && ./impala-create-external-tables.sh && ./impala-load-all.sh && ./impala-compute-stats.sh`

## Queries

`impala-tpcds-kit/benchmark.py` is the python script that executes all queries. The method `run_benchmark()` allows to specify different parameters for benchmarking.

The queries themselves can be found in `impala-tpcds-kit/queries`. For each Scale Factor, 10 different query streams are generated. You can generate more using the TPC-DS toolkit. 
