#!/bin/bash

# Directory for certificates and persistent data
CERT_DIR="./certs"
DATA_DIR="./data"

# Create directories if they don't exist
mkdir -p "${CERT_DIR}"
mkdir -p "${DATA_DIR}"
mkdir -p "./certs/docker-staging"
mkdir -p "./certs/docker-prod"


# Function to generate a Root CA certificate and key
generate_root_ca() {
  echo "Generating Root CA..."

  # Root CA files with .pem extension
  ROOT_CA_CERT="${CERT_DIR}/rootCA.pem"
  ROOT_CA_KEY="${CERT_DIR}/rootCA.key"

  # Check if Root CA files already exist
  if [ -f "${ROOT_CA_CERT}" ] && [ -f "${ROOT_CA_KEY}" ]; then
    echo "Root CA already exists, skipping."
    return
  fi

  # Generate Root CA
  openssl req -x509 -new -nodes -days 3650 -newkey rsa:4096 -keyout "${ROOT_CA_KEY}" -out "${ROOT_CA_CERT}" -subj "/C=ES/ST=Madrid/L=Madrid/O=tecnek/OU=CA/CN=tecnek Root CA"
}

# Function to generate a certificate with SANs and sign it with the Root CA
generate_certificate() {
  SERVICE_NAME=$1
  COMMON_NAME="${SERVICE_NAME}"

  SAN="DNS:${COMMON_NAME},DNS:${SERVICE_NAME}"

  # Certificate and key paths with .pem extension for clarity
  CERT_FILE="${CERT_DIR}/${SERVICE_NAME}.pem"
  KEY_FILE="${CERT_DIR}/${SERVICE_NAME}.key"
  CSR_FILE="${CERT_DIR}/${SERVICE_NAME}.csr"

  # Check if the certificate and key already exist
  if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo "Certificates for ${SERVICE_NAME} already exist, skipping generation."
    return
  fi

  # Create OpenSSL config file for SANs
  CONFIG_FILE="${CERT_DIR}/${SERVICE_NAME}_openssl.cnf"

  cat > "${CONFIG_FILE}" <<- EOF
[ req ]
default_bits       = 2048
default_md         = sha256
prompt             = no
encrypt_key        = no
distinguished_name = req_distinguished_name
req_extensions     = req_ext

[ req_distinguished_name ]
C  = ES
ST = Madrid
L  = Madrid
O  = tecnek
OU = tecnek
CN = ${COMMON_NAME}

[ req_ext ]
subjectAltName = ${SAN}
EOF

  # Generate CSR
  openssl req -new -nodes -newkey rsa:2048 -keyout "$KEY_FILE" -out "$CSR_FILE" -config "${CONFIG_FILE}" -extensions req_ext

  # Sign the CSR with the Root CA
  openssl x509 -req -in "$CSR_FILE" -CA "${CERT_DIR}/rootCA.pem" -CAkey "${CERT_DIR}/rootCA.key" -CAcreateserial -out "$CERT_FILE" -days 365 -extensions req_ext -extfile "${CONFIG_FILE}"

  # Cleanup
  rm "${CONFIG_FILE}"
  rm "${CSR_FILE}"
}

# Generate Root CA
generate_root_ca

# Generate certificates for specified services
SERVICES="portainer registry-1 registry-2 registry-3 docker-prod docker-staging"
for SERVICE in $SERVICES; do
  generate_certificate $SERVICE
done
