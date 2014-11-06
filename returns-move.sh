#!/bin/bash
source tpcds-env.sh

mkdir -p ${FLATFILE_ROOT}/catalog_returns
mkdir -p ${FLATFILE_ROOT}/store_returns
mkdir -p ${FLATFILE_ROOT}/web_returns

mv ${FLATFILE_ROOT}/catalog_sales/catalog_returns* ${FLATFILE_ROOT}/catalog_returns
mv ${FLATFILE_ROOT}/store_sales/store_returns* ${FLATFILE_ROOT}/store_returns
mv ${FLATFILE_ROOT}/web_sales/web_returns* ${FLATFILE_ROOT}/web_returns

