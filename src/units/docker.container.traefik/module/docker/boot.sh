#!/bin/sh
set -e

mkdir -p /etc/traefik
echo $HTTPS_KEY | base64 -d | gzip -d > /etc/traefik/https.key
echo $HTTPS_CERT | base64 -d | gzip -d > /etc/traefik/https.cert
echo $TRAEFIK_DYNAMIC_CONF | base64 -d | gzip -d > /etc/traefik/traefik.dynamic.conf.yml
echo $TRAEFIK_STATIC_CONF | base64 -d | gzip -d > /etc/traefik/traefik.yml
chmod 400 /etc/traefik/*

exec /entrypoint.sh "$@"
