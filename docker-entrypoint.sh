#!/bin/sh

# Gestione certificati custom (logica ufficiale n8n)
if [ -d /opt/custom-certificates ]; then
  echo "Trusting custom certificates from /opt/custom-certificates."
  export NODE_OPTIONS="--use-openssl-ca $NODE_OPTIONS"
  export SSL_CERT_DIR=/opt/custom-certificates
  c_rehash /opt/custom-certificates
fi

if [ "$#" -gt 0 ]; then
  # Se sono stati passati argomenti al container (es: "n8n worker")
  exec n8n "$@"
else
  # Se non ci sono argomenti, avvia n8n standard
  exec n8n
fi