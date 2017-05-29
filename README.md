# rgon-proxy
the base image of the rancher nginx letsencrypt proxy

## Usage

Add labels to containers to indicate domain name and port (if non-80):

- `rgon.domain=mydomain.com`
- `rgon.port=80`
- `rgon.ssl='true'`
- `rgon.redirect=https`

## Update Notice
RGON-Proxy is currently in an development/alpha state cause of this it might be possible that default config files will change rapidly - To provide always an latest use of those config files please rename the config folder on your server before the update an merge changes by hand. We are currently on an discussion how to solve this problem in the future

## Features

### Let’s Encrypt support
Let’s Encrypt support powered by [hlandau/acme](https://github.com/hlandau/acme)

### Automatic https redirect
If the `rgon.redirect` label is defined with `https` rgon automatically redirects the specified domains to https

### Diffie-Hellman Key generation
On each start we check if there is allready an key present and if not we generate one.

### Multiple Domain support
It is possible to define multiple domains in the `rgon.domain` label seperated by an `,`. 
If the `rgon.ssl` label is also present we generate an SNI Certificate for all this domains

### Custom/Default nginx vhost & location config
You can specify an default vhost or default location config file under %YourPath%/vhost.d/default[_location].
Or define an configuration for each domain with %domain%[_location]. Please notice that if you use multiple domains the first one is the identifier.

### HTTP Basic Auth
Add an file with the domain name of the `rgon.domain` label under %YourPath%/htpasswd and your site is protected with an Basic Auth dialog.

### [Experimental] Vertical scalability
We wher able to run an nginx instance on each host using the scheduler commands of rancher but it is currently only possible for simple http requests
cause we need an centralized secure store for certificates before we can continiue this feature.


## Upcoming Features

- Vertical scalability with SSL support
- Easier generation of an basic auth file
- Possibility to use multiple ports for use with subdomains [frontend:80/api:8080/monitoring:7071]
- Use of custom SSL-Certificates


## Lifecycle

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

## Credits

- [janeczku/go-rancher-gen](https://github.com/janeczku/go-rancher-gen) - service to poll rancher-metadata api
- [hlandau/acme](https://github.com/hlandau/acme) - service to generate and reissue letsencrypt certificates
