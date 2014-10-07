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

## 9) create the various certs

## openssl req -newkey rsa:2048 -new -x509 -days 1001   -out ca.pem  -keyout ca.key
#### ca phrase = "certificate"
##echo "00" > file.srl 

#### digests not allowed for FIPS 142 mode, so no digest cypher specified
## openssl genrsa -out server.key 2048
## openssl req -key server.key -new -out server.req 
## openssl x509 -req -in server.req -CA ca.pem -CAkey ca.key -CAserial file.srl -out server.crt
## cat server.key server.crt >> server.pem

#### digests not allowed for FIPS 142 mode, so no digest cypher specified
## openssl genrsa -out client.key 2048
## openssl req -key client.key -new -out client.req
## openssl x509 -req -in client.req -CA ca.pem -CAkey ca.key -CAserial file.srl -out client.crt
## cat client.key client.crt >> client.pem


## 10) restart mongo
echo "Restarting with MongoDB Auth"
service mongod restart

## 11) access database with the following
## mongo --ssl --sslPEMKeyFile /vagrant/keys/client.pem -u admin -p admin admin
