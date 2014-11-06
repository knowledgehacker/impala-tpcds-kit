#!/bin/bash
source tpcds-env.sh

impala-shell -d $TPCDS_DBNAME <<EOF
compute stats call_center;
compute stats catalog_sales;
compute stats customer_demographics;
compute stats household_demographics;
compute stats item;
compute stats ship_mode;
compute stats store_sales;
compute stats web_page;
compute stats web_site;
compute stats catalog_page;
compute stats customer;
compute stats date_dim;
compute stats income_band;
compute stats promotion;
compute stats store;
compute stats time_dim;
compute stats customer_address;
compute stats dbgen_version;
compute stats inventory;
compute stats reason;
compute stats warehouse;
compute stats web_sales;
compute stats catalog_returns;
compute stats store_returns;
compute stats web_returns;
EOF
