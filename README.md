# rgon-proxy
the base image of the rancher nginx letsencrypt proxy

##Usage

Add labels to containers to indicate domain name and port (if non-80):

- `rgon.domain=mydomain.com`
- `rgon.port=80`
- `rgon.ssl='true'`
- `rgon.redirect='https'`

##Lifecycle

1. entrypoint.sh: Run on start
  - Check for writable directories
  - Check for `dhparam.pem`, generate if missing
  - Check for `nginx.conf`, remove if present
  - Single-run Rancher-Gen to build `nginx.conf`
    - Reload nginx
  - Init Rancher-Gen watcher
1. Rancher-Gen: watch for metadata changes
  - acmetool: Generate certificates if needed
  - Update `nginx.conf`
    - Reload nginx
1. Repeat step 2
