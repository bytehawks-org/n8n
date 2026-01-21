#!/bin/sh
set -e # Interrompi se un comando fallisce

# Gestione certificati custom
if [ -d /opt/custom-certificates ]; then
  echo "Trusting custom certificates from /opt/custom-certificates."
  export NODE_OPTIONS="--use-openssl-ca $NODE_OPTIONS"
  export SSL_CERT_DIR=/opt/custom-certificates
  c_rehash /opt/custom-certificates
fi

# Se il primo argomento è "n8n", lo rimuoviamo per evitare "n8n n8n"
if [ "$1" = 'n8n' ]; then
  shift
fi

# Se non ci sono argomenti o se iniziano con un trattino (opzioni)
if [ $# -eq 0 ] || [ "${1#-}" != "$1" ]; then
  exec /usr/local/bin/n8n "$@"
fi

# Altrimenti esegui quello che è stato passato (es: n8n worker)
exec "$@"