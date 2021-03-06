#!/bin/bash
source tpcds-env.sh

impala-shell -d $TPCDS_DBNAME <<EOF
drop table if exists call_center;
drop table if exists et_call_center;
drop table if exists catalog_sales;
drop table if exists et_catalog_sales;
drop table if exists customer_demographics;
drop table if exists et_customer_demographics;
drop table if exists household_demographics;
drop table if exists et_household_demographics;
drop table if exists item;
drop table if exists et_item;
drop table if exists ship_mode;
drop table if exists et_ship_mode;
drop table if exists store_sales;
drop table if exists et_store_sales;
drop table if exists web_page;
drop table if exists et_web_page;
drop table if exists web_site;
drop table if exists et_web_site;
drop table if exists catalog_page;
drop table if exists et_catalog_page;
drop table if exists customer;
drop table if exists et_customer;
drop table if exists date_dim;
drop table if exists et_date_dim;
drop table if exists income_band;
drop table if exists et_income_band;
drop table if exists promotion;
drop table if exists et_promotion;
drop table if exists store;
drop table if exists et_store;
drop table if exists time_dim;
drop table if exists et_time_dim;
drop table if exists customer_address;
drop table if exists et_customer_address;
drop table if exists dbgen_version;
drop table if exists et_dbgen_version;
drop table if exists inventory;
drop table if exists et_inventory;
drop table if exists reason;
drop table if exists et_reason;
drop table if exists warehouse;
drop table if exists et_warehouse;
drop table if exists web_sales;
drop table if exists et_web_sales;
drop table if exists catalog_returns;
drop table if exists et_catalog_returns;
drop table if exists store_returns;
drop table if exists et_store_returns;
drop table if exists web_returns;
drop table if exists et_web_returns;
EOF

impala-shell -d default <<EOF
drop database if exists $TPCDS_DBNAME;
EOF
