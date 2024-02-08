#!/bin/bash

# Directorio para los certificados y datos persistentes
CERT_DIR="./certs"
DATA_DIR="./data"

mkdir -p "${CERT_DIR}"
mkdir -p "${DATA_DIR}"

# Función para generar certificado con SANs
generate_certificate() {
  SERVICE_NAME=$1
  COMMON_NAME="${SERVICE_NAME}"

  SAN="DNS:${COMMON_NAME},DNS:${SERVICE_NAME}"

  # Rutas de archivos de certificado y clave
  CERT_FILE="${CERT_DIR}/${SERVICE_NAME}.cert"
  KEY_FILE="${CERT_DIR}/${SERVICE_NAME}.key"

  # Verificar si el certificado y la clave ya existen
  if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo "Los certificados para ${SERVICE_NAME} ya existen, omitiendo la generación."
    return
  fi

  # Crear archivo de configuración de OpenSSL para SANs
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

  # Generar el certificado utilizando el archivo de configuración
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -config "${CONFIG_FILE}" \
    -extensions req_ext

  # Limpiar el archivo de configuración temporal
  rm "${CONFIG_FILE}"
}

# Generar certificados para los servicios especificados
SERVICES="portainer registry-1 registry-2 registry-3 docker-staging docker-prod"
for SERVICE in $SERVICES; do
  generate_certificate $SERVICE
done
