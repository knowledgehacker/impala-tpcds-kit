#!/bin/bash
source tpcds-env.sh

impala-shell -d $TPCDS_DBNAME <<EOF
drop table call_center;
drop table et_call_center;
drop table catalog_sales;
drop table et_catalog_sales;
drop table customer_demographics;
drop table et_customer_demographics;
drop table household_demographics;
drop table et_household_demographics;
drop table item;
drop table et_item;
drop table ship_mode;
drop table et_ship_mode;
drop table store_sales;
drop table et_store_sales;
drop table web_page;
drop table et_web_page;
drop table web_site;
drop table et_web_site;
drop table catalog_page;
drop table et_catalog_page;
drop table customer;
drop table et_customer;
drop table date_dim;
drop table et_date_dim;
drop table income_band;
drop table et_income_band;
drop table promotion;
drop table et_promotion;
drop table store;
drop table et_store;
drop table time_dim;
drop table et_time_dim;
drop table customer_address;
drop table et_customer_address;
drop table dbgen_version;
drop table et_dbgen_version;
drop table inventory;
drop table et_inventory;
drop table reason;
drop table et_reason;
drop table warehouse;
drop table et_warehouse;
drop table web_sales;
drop table et_web_sales;
drop table catalog_returns;
drop table et_catalog_returns;
drop table store_returns;
drop table et_store_returns;
drop table web_returns;
drop table et_web_returns;
EOF

impala-shell -d default <<EOF
drop database $TPCDS_DBNAME;
EOF
