#!/bin/sh

if [[ -z "$CATTLE_URL" ]]; then
    echo "Error: can't get my CATTLE_URL !" >&2
    exit 1
fi

if [[ -z "$CATTLE_ACCESS_KEY" ]]; then
    echo "Error: can't get my CATTLE_ACCESS_KEY !" >&2
    exit 1
fi

if [[ -z "$CATTLE_SECRET_KEY" ]]; then
    echo "Error: can't get my CATTLE_SECRET_KEY !" >&2
    exit 1
fi

function acmetool_init {
    if [[ -z "$ACME_EMAIL" ]]; then
        echo "Warning: can't get my ACME_EMAIL !" >&2
    else
        sed -i "s~hostmaster@example.com~$ACME_EMAIL~g" /var/lib/acme/conf/responses
    fi

    if [[ -z "$ACME_API" ]]; then
        echo "Warning: can't get my ACME_API !" >&2
    else
        sed -i "s~https://acme-staging.api.letsencrypt.org/directory~$ACME_API~g" /var/lib/acme/conf/responses
    fi

    /usr/local/bin/acmetool quickstart
}

function copy_config_files {
    if [[ ! -d /etc/rancher-gen/default ]]; then
        mkdir -p /etc/rancher-gen/default
        cp /app/rancher-gen/default/* /etc/rancher-gen/default/
    fi

    if [[ ! -f /var/lib/acme/conf/responses ]]; then
        mkdir -p /var/lib/acme/conf
        cp /app/acme/conf/responses /var/lib/acme/conf/
    fi

    if [[ ! -f /var/lib/acme/conf/target ]]; then
        cp /app/acme/conf/target /var/lib/acme/conf/
    fi
}

function check_writable_directory {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo "Error: can't access to '$dir' directory !" >&2
        echo "Check that '$dir' directory is declared has a writable volume." >&2
        exit 1
    fi
    touch $dir/.check_writable 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "Error: can't write to the '$dir' directory !" >&2
        echo "Check that '$dir' directory is export as a writable volume." >&2
        exit 1
    fi
    rm -f $dir/.check_writable
}

function check_dh_group {
  if [[ ! -f /etc/nginx/certs/dhparam.pem ]]; then
    echo "Creating Diffie-Hellman group (can take several minutes...)"
    openssl dhparam -out /etc/nginx/certs/.dhparam.pem.tmp 2048
    mv /etc/nginx/certs/.dhparam.pem.tmp /etc/nginx/certs/dhparam.pem || exit 1
  fi
}

function check_nginx_conf {
  if [[ ! -f /etc/nginx/certs/default/default.csr ]]; then
    openssl genrsa -des3 -passout pass:x -out /etc/nginx/certs/default/default.pass.key 2048
    openssl rsa -passin pass:x -in /etc/nginx/certs/default/default.pass.key \
      -out /etc/nginx/certs/default/default.key
    rm /etc/nginx/certs/default/default.pass.key
    openssl req -new -key /etc/nginx/certs/default/default.key -out /etc/nginx/certs/default/default.csr \
      -days 1000 -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"
    openssl x509 -req -days 365 -in /etc/nginx/certs/default/default.csr \
      -signkey /etc/nginx/certs/default/default.key -out /etc/nginx/certs/default/default.crt
  fi

  if [[ -f /etc/nginx/conf.d/nginx.conf ]]; then
    rm -f /etc/nginx/conf.d/nginx.conf
  fi
}

function rancher_gen_firstrun {
  if [[ -f /etc/rancher-gen/default/rancher-gen-firstrun.cfg ]]; then
    echo "[ENTRYPOINT]: Running Rancher-Gen first-run"
    /usr/local/bin/rancher-gen --config /etc/rancher-gen/default/rancher-gen-firstrun.cfg
    echo "[ENTRYPOINT]: Rancher-Gen first-run complete"
  fi
}

copy_config_files
check_writable_directory '/etc/nginx/certs'
check_writable_directory '/etc/nginx/vhost.d'
check_dh_group
check_nginx_conf
acmetool_init
rancher_gen_firstrun

exec "$@"
