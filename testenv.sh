#!/bin/bash

# Setup Environment

function todec()
{
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

function bin2dec () {
for i in "$@"
	do
	echo "$((2#$i))"
	done
}

function hex2bin4() {
for i in "$@"
        do
        BIN=$(echo "obase=2; ibase=16; $i" | BC_LINE_LENGTH=9999 bc | awk '{ printf "%04d\n", $0 }')
        echo $BIN
done
}

function hex2bin8() {
for i in "$@"
        do
        BIN=$(echo "obase=2; ibase=16; $i" | BC_LINE_LENGTH=9999 bc | awk '{ printf "%08d\n", $0 }')
        echo $BIN
done
}

function hex2bin16() {
for i in "$@"
        do
        BIN=$(echo "obase=2; ibase=16; $i" | BC_LINE_LENGTH=9999 bc | awk '{ printf "%16d\n", $0 }')
        echo $BIN
done
}

function dec2bin() {
for i in "$@"
        do
        BIN=$(echo "obase=2; ibase=10; $i" | BC_LINE_LENGTH=9999 bc | awk '{ printf "%08d\n", $0 }')
        echo $BIN
done
}


#converttodec () { echo "ibase=16; $1" | bc; }
#alias todec=todec
alias tohex="printf '%x\n'"


# Install bzr if it's not installed..
rpm -qa | grep -q bzr || yum -y install bzr

perldoc -l Math::Int64 2> /dev/null | grep "Int64.pm" || cpan Math::Int64

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
