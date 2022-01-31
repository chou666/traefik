#!/bin/sh
set -e

if [ "${1#-}" != "$1" ]; then
    set -- traefik "$@"
fi

if traefik "$1" --help | grep -s -q "help"; then
    set -- traefik "$@"
fi

if [ ! -f /etc/traefik/ca.key ] || [ ! -f /etc/traefik/ca.pem ]; then
    openssl genrsa -out /etc/traefik/ca.key 4096
    openssl req -new -x509 -nodes -sha256 -days 3650 \
        -key /etc/traefik/ca.key \
        -out /etc/traefik/ca.pem \
        -subj "/C=FR/ST=/L=/O=Developer/OU=IT/CN=localhost"

    cp /etc/traefik/ca.pem /usr/share/ca-certificates/traefik/root.cert.crt
echo done
fi

for folder in /etc/traefik/*/; do
    openssl req -new -sha256 -nodes -newkey rsa:2048 \
        -out $folder/server.csr \
        -keyout $folder/server.key \
        -config $folder/server.csr.cnf
    openssl x509 -req \
        -in $folder/server.csr \
        -CA /etc/traefik/ca.pem \
        -CAkey /etc/traefik/ca.key \
        -CAcreateserial \
        -out $folder/server.crt \
        -days 3650 -sha256
echo done $folder
done

echo done

exec "$@"
