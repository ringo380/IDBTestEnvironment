#!/bin/bash

# Setup Environment
alias tohex="printf '%x\n'"
alias todec="printf '%d\n'"

# Download/extract sample db
cd /tmp
wget http://downloads.mysql.com/docs/sakila-db.tar.gz
tar xvzf sakila-db.tar.gz

DB=testdb

# Import sakila DB data
cd /tmp/sakila-db
cp sakila-schema.sql{,.orig}
cp sakila-data.sql{,.orig}
sed -i "s/sakila/$DB/" sakila-schema.sql
sed -i "s/sakila/$DB/" sakila-data.sql
mysql -e "SOURCE sakila-schema.sql"
mysql -e "SOURCE sakila-data.sql"

# Make copies of everything in the current state
mkdir /root/mysql.bak
cp /etc/my.cnf{,.orig}
cp -Rp /var/lib/mysql/* /root/mysql.bak/
mysqldump --all-databases > /root/mysql.bak/mysqldump.sql
mysqldump --single-transaction --all-databases --events > /root/mysql.bak/mysqldump_st_events.sql

mysqldump --single-transaction testdb > /tmp/testdb.sql
