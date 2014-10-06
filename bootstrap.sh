#!/bin/sh

## 1) update machine
yum -y update 

## 2) setup mongodb enterprise repo
cat >/etc/yum.repos.d/mongodb-enterprise.repo <<EOF
[mongodb-enterprise]
name=MongoDB Enterprise Repository
baseurl=https://repo.mongodb.com/yum/redhat/\$releasever/mongodb-enterprise/stable/\$basearch/
gpgcheck=0
enabled=1
EOF

## 3) install mongodb
yum install -y mongodb-enterprise

## 4) pin the mongodb version
cat >>/etc/yum.conf <<EOF
exclude=mongodb-enterprise,mongodb-enterprise-server,mongodb-enterprise-shell,mongodb-enterprise-mongos,mongodb-enterprise-tools
EOF


## 5) have mongodb turn on by default
chkconfig mongod on

## 6) turn off iptables
service iptables stop
chkconfig iptables off


## 7) start mongo and create an admin user
service mongod start
echo "Creating an admin User"
mongo << 'EOF'
use admin
db.createUser({
	user:"admin",
	pwd:"admin",
	roles: [
		{role:"clusterAdmin", db:"admin"},
		{role:"readWriteAnyDatabase", db:"admin"},
		{role:"userAdminAnyDatabase", db: "admin"},
		{role:"dbAdminAnyDatabase",db: "admin"}
	]
});
EOF

## 8) switch to a YAML config file with real settings
echo "Installing new config file with Auth and SSL enabled"
## note the config file also disables the default bind_ip
## config file references a .pem in the /vagrant folder
cp /vagrant/mongod-yaml.conf /etc/mongod.conf

## 9) create SSL server side cert
## the step is interactive so I've just checked in finished .pem file
## openssl req -newkey rsa:2048 -new -x509 -days 365 -nodes -out mongodb-cert.crt -keyout mongodb-cert.key
## cat mongodb-cert.key mongodb-cert.crt > mongodb.pem

## 10) restart mongo
echo "Restarting with MongoDB Auth"
service mongod restart

