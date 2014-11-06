#!/bin/bash
source tpcds-env.sh

hadoop fs -rm -r ${FLATFILE_HDFS_ROOT}
hadoop fs -mkdir ${FLATFILE_HDFS_ROOT}/
hadoop fs -put ${FLATFILE_ROOT}/*  ${FLATFILE_HDFS_ROOT}



