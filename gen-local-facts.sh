#!/bin/bash
source tpcds-env.sh

# find out what our node number is
source nodenum.sh

count=$DSDGEN_THREADS_PER_NODE

start=(NODENUM-1)*$count+1


for t in store_sales 
do
    for (( c=$start; c<($count+$start); c++ ))
    do
       echo "Generating part $c/${DSDGEN_TOTAL_THREADS} of $t"
       ${TPCDS_ROOT}/tools/dsdgen \
       -TABLE $t \
       -SCALE ${TPCDS_SCALE_FACTOR} \
       -CHILD $c \
       -PARALLEL ${DSDGEN_TOTAL_THREADS} \
       -DISTRIBUTIONS ${TPCDS_ROOT}/tools/tpcds.idx \
       -TERMINATE N \
       -FILTER Y \
       -QUIET Y > /tmp/tpcds/${t}_${c}_${DSDGEN_TOTAL_THREADS}.dat &

#       -QUIET Y | hdfs dfs -put - ${FLATFILE_HDFS_ROOT}/${t}/${t}_${c}_${DSDGEN_TOTAL_THREADS}.dat &
        echo ${TPCDS_SCALE_FACTOR}
    done
    wait
done
echo "all done"
