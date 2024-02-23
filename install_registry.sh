#!/bin/bash

IP_ADDRESS=`ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p'`
CERT_NAME=$1
USERNAME=$2
PASSWORD=$3

mkdir ~/registry
mkdir -p ~/registry/certs
mkdir -p ~/registry/auth
cd ~/registry/certs
openssl genrsa 2048 > $CERT_NAME.key
chmod 400 $CERT_NAME.key

cat << EOF > san.cnf
[req]
default_bits  = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
countryName = XX
stateOrProvinceName = N/A
localityName = N/A
organizationName = Self-signed certificate
commonName = 120.0.0.1: Self-signed certificate

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = $IP_ADDRESS
EOF

openssl req -new -x509 -nodes -sha1 -days 365 -key $CERT_NAME.key -out $CERT_NAME.crt -config san.cnf
cd ../auth
docker run --rm --entrypoint htpasswd registry:2.7.0 -Bbn $USERNAME $PASSWORD > htpasswd

cd ~/registry

docker run -d \
--restart=always \
--name registry \
-v `pwd`/auth:/auth \
-v `pwd`/certs:/certs \
-v `pwd`/certs:/certs \
-e REGISTRY_AUTH=htpasswd \
-e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
-e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/$CERT_NAME.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/$CERT_NAME.key \
-e REGISTRY_STORAGE_DELETE_ENABLED=true \
-p 5000:443 \
registry:2.7.0
