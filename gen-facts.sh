#!/bin/bash
source tpcds-env.sh

# find out what our node number is
source nodenum.sh

count=$DSDGEN_THREADS_PER_NODE

start=(NODENUM-1)*$count+1

for t in call_center catalog_sales customer_demographics household_demographics item ship_mode store_sales web_page web_site catalog_page customer date_dim income_band promotion store time_dim customer_address dbgen_version inventory reason warehouse web_sales
do
mkdir -p ${FLATFILE_ROOT}/${t}
#rm -r ~/tpcds-output
#mkdir -p ~/tpcds-output
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
       -QUIET \
       -DIR ${FLATFILE_ROOT}/${t} &
    done
    wait
done
echo "all done"
