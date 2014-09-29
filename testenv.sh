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

function isinstalled {
  if yum list installed "$@" >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

#converttodec () { echo "ibase=16; $1" | bc; }
#alias todec=todec
alias tohex="printf '%x\n'"

echo "Installing RVM.."
cd /root
\curl -sSL https://get.rvm.io | bash
sleep 15
source /etc/profile.d/rvm.sh

echo "Installing Ruby 1.9.3.."
rvm install ruby-1.9.3

# Install bzr if it's not installed..
echo "Checking if Bazaar is installed.."
if yum list installed "bzr" > /dev/null 2>&1; then echo "Bazaar already installed."; else echo "Not installed, installing now.."; yum -y install bzr; fi

echo "Checking if git is installed.."
if yum list installed "git" > /dev/null 2>&1; then echo "Git already installed."; else echo "Not installed, installing now.."; yum -y install git; fi

echo "Installing Math::Int64 if needed.."
perldoc -l Math::Int64 2> /dev/null | grep "Int64.pm" || cpan Math::Int64

source /etc/profile.d/rvm.sh

echo "Installing innodb_ruby.."
cd /root
git clone https://github.com/jeremycole/innodb_ruby.git
cd /root/innodb_ruby
gem build innodb_ruby.gemspec
gem install innodb_ruby-0.9.10.gem

echo "Installing idb-utils.."
cd /root
git clone https://github.com/ringo380/idb-utils.git

echo "Setting up test database.."
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
echo "Backing up current my.cnf to /etc/my.cnf.orig.."
cp /etc/my.cnf{,.orig}
echo "Copying current data directory to /root/mysql.bak.."
cp -Rp /var/lib/mysql/* /root/mysql.bak/
echo "Dumping current databases to /root/mysql.bak.."
mysqldump --all-databases -E > /root/mysql.bak/mysqldump.sql
mysqldump --single-transaction --all-databases -E > /root/mysql.bak/mysqldump_st.sql
mysqldump --single-transaction -E testdb > /tmp/testdb.sql
