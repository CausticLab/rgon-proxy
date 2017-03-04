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
  if [[ ! -f /etc/nginx/dhparam/dhparam.pem ]]; then
    echo "Creating Diffie-Hellman group (can take several minutes...)"
    openssl dhparam -out /etc/nginx/dhparam/.dhparam.pem.tmp 2048
    mv /etc/nginx/dhparam/.dhparam.pem.tmp /etc/nginx/dhparam/dhparam.pem || exit 1
  fi
}

function check_nginx_conf {
  if [[ -f /etc/nginx/conf.d/nginx.conf ]]; then
    rm -f /etc/nginx/conf.d/nginx.conf
  fi
}

function rancher_gen_firstrun {
  if [[ -f /etc/rancher-gen/default/rancher-gen-firstrun.cfg ]]; then
    echo [ENTRYPOINT]: Running Rancher-Gen first-run 
    /usr/local/bin/rancher-gen --config /etc/rancher-gen/default/rancher-gen-firstrun.cfg
    echo [ENTRYPOINT]: Rancher-Gen first-run complete
  fi
}

check_writable_directory '/etc/nginx/certs'
check_writable_directory '/etc/nginx/vhost.d'
check_writable_directory '/etc/nginx/html'
check_dh_group
check_nginx_conf
rancher_gen_firstrun

exec "$@"
