#!/bin/sh
#
# Executed by acmetool when a certificate is updated
# Ensures that /etc/nginx/certs/ is present, then
# overwrite-copies all live SSL certs to that directory.
# Triggers a single-run of rancher-gen to reload Nginx containers.

case "$1" in
 "live-updated" )
    echo "[HOOK] 01copyCertsToNginx: Processing live-updated hook"
    mkdir -p /etc/nginx/certs
    cp -RLf /var/lib/acme/live/* /etc/nginx/certs/
    ;;
esac

