#!/bin/bash

# Setup Environment

function_todec() {
if [ $# -gt 0 ] ; then
	for i in "$@"
		do 
			val=$(echo $i | tr 'a-z' 'A-Z')
			echo "ibase=16; $val" | bc
		done
else
	IFS=$'\n' read -d '' -r -a vals
	for val in "${vals[@]}"; do
		val=$(echo $val | tr 'a-z' 'A-Z')
		echo "ibase=16; $val" | bc
	done
fi
}

#converttodec () { echo "ibase=16; $1" | bc; }
#alias todec=todec
alias tohex="printf '%x\n'"

# Install bzr if it's not installed..
rpm -qa | grep -q bzr || yum -q -y install bzr


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
