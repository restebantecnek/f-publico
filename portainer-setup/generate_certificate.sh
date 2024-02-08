#!/bin/bash

# Definir los detalles de tu certificado
COUNTRY="ES"
STATE="Madrid"
LOCALITY="Madrid"
ORGANIZATION="tecnek"
ORGANIZATIONAL_UNIT="tecnek"
COMMON_NAME="192.168.202.104"
ALT_NAMES="DNS:localhost,IP:127.0.0.1, IP:0.0.0.0" # Ajusta según necesidad

# Directorio donde se guardarán el certificado y la clave
CERT_DIR="./certs"
mkdir -p "${CERT_DIR}"

# Generar el certificado y la clave
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -keyout "${CERT_DIR}/portainer.key" -out "${CERT_DIR}/portainer.crt" \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${ORGANIZATIONAL_UNIT}/CN=${COMMON_NAME}" \
    -addext "subjectAltName=${ALT_NAMES}"

echo "Certificado y clave generados en ${CERT_DIR}"