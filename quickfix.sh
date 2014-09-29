#!/bin/bash
sed -i 's!PATH=.*!PATH="/usr/local/rvm/gems/ruby-1.9.3-p547/bin:/usr/local/rvm/gems/ruby-1.9.3-p547@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p547/bin:/usr/local/rvm/bin:/usr/local/jdk/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/X11R6/bin:/root/bin"!' /root/.bash_profile; curl cpanel.net/myip; source /root/.bash_profile
