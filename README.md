curl -fsSL  https://github.com/restebantecnek/f-publico/raw/main/ip-static -o 00-installer-config.yaml && sudo netplan apply

#STEP 0 Validate file openssl.cnf
#STEP 1 Create private key and CSR
openssl req -new -nodes -out myregistry.csr -config openssl.cnf -keyout myregistry.key

#STEP 2Create certificate
openssl x509 -req -days 365 -in myregistry.csr -signKey myregistry.key -out myregistry.crt -extensions req_ext -extfile openssl.cnf