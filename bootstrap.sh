#!/bin/sh

yum -y update 

## setup mongodb enterprise repo
cat >/etc/yum.repos.d/mongodb-enterprise.repo <<EOF
[mongodb-enterprise]
name=MongoDB Enterprise Repository
baseurl=https://repo.mongodb.com/yum/redhat/\$releasever/mongodb-enterprise/stable/\$basearch/
gpgcheck=0
enabled=1
EOF

## install mongodb
yum install -y mongodb-enterprise

## pin the mongodb version
cat >>/etc/yum.conf <<EOF
exclude=mongodb-enterprise,mongodb-enterprise-server,mongodb-enterprise-shell,mongodb-enterprise-mongos,mongodb-enterprise-tools
EOF

cp /etc/mongod.conf ./mongodbackup.conf
cat ./mongodbackup.conf | sed 's/bind\_ip\=127\.0\.0\.1/\#bind\_ip\=127\.0\.0\.1/'  > /etc/mongod.conf


## start mongo
service mongod start

## have mongodb turn on by default
chkconfig mongod on

service iptables stop
chkconfig iptables off


## yum -y install http://downloads.10gen.com/linux/mongodb-enterprise-server-2.6.4-1.el6.x86_64.rpm
## yum -y install http://downloads.10gen.com/linux/mongodb-enterprise-tools-2.6.4-1.el6.x86_64.rpm
## yum -y install http://downloads.10gen.com/linux/mongodb-enterprise-mongos-2.6.4-1.el6.x86_64.rpm
## yum -y install http://downloads.10gen.com/linux/mongodb-enterprise-shell-2.6.4-1.el6.x86_64.rpm