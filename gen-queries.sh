source tpcds-env.sh

rm -r queries/${TPCDS_SCALE_FACTOR}
mkdir -p queries/${TPCDS_SCALE_FACTOR}

${TPCDS_ROOT}/tools/dsqgen \
-INPUT ${TPCDS_ROOT}/query_templates/templates.lst \
-DIRECTORY ${TPCDS_ROOT}/query_templates/ \
-DIALECT impala \
-SCALE ${TPCDS_SCALE_FACTOR} \
-OUTPUT_DIR queries/${TPCDS_SCALE_FACTOR} \
-streams 10 \
-DISTRIBUTIONS ${TPCDS_ROOT}/tools/tpcds.idx 
