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
    docker_api "/containers/$HOSTNAME/json" | jq ".Mounts[].Destination" | grep -q "^\"$dir\"$"
    if [[ $? -ne 0 ]]; then
        echo "Warning: '$dir' does not appear to be a mounted volume."
    fi
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

check_writable_directory '/etc/nginx/certs'
check_writable_directory '/etc/nginx/vhost.d'
check_writable_directory '/usr/share/nginx/html'
check_dh_group

exec "$@"