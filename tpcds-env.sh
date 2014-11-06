# path to the tpcds-kit directory
export TPCDS_ROOT=$HOME/tpcds-kit

# scale factor in GB
# SF 3000 yields ~1TB for the store_sales table
export TPCDS_SCALE_FACTOR=50

# top level directory for flat files in HDFS
export FLATFILE_HDFS_ROOT=/user/root/data/tpcds/scale$TPCDS_SCALE_FACTOR
export FLATFILE_ROOT=/mnt/nfs/data/tpcds/scale$TPCDS_SCALE_FACTOR

# this is used to determine the number of dsdgen processes to generate data
# usually set to one per physical CPU core
# example - 20 nodes @ 12 threads each
export DSDGEN_NODES=5
export DSDGEN_THREADS_PER_NODE=4
export DSDGEN_TOTAL_THREADS=$((DSDGEN_NODES * DSDGEN_THREADS_PER_NODE))

# the name for the tpcds database
export TPCDS_DBNAME=tpcds_$TPCDS_SCALE_FACTOR
