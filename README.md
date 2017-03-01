# rgon-proxy
the base image of the rancher nginx letsencrypt proxy

#Usage

Add labels to containers to indicate domain name and port (if non-80):

- `rgon.domain=mydomain.com`
- `rgon.port=80`