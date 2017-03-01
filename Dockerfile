FROM alpine:3.5

RUN apk add --no-cache ca-certificates

ENV RANCHER_GEN_RELEASE=v0.2.1 \
    RGON_EXEC_RELEASE=v1.0.0 \
    ACMETOOL_RELEASE=v0.0.59


ADD https://github.com/causticlab/go-rancher-gen/releases/download/${RANCHER_GEN_RELEASE}/rancher-gen-linux-amd64.tar.gz /tmp/rancher-gen.tar.gz
ADD https://github.com/causticlab/rgon-exec/releases/download/${RGON_EXEC_RELEASE}/rgon-exec-linux-amd64.tar.gz /tmp/rgon-exec.tar.gz
ADD https://github.com/hlandau/acme/releases/download/${ACMETOOL_RELEASE}/acmetool-${ACMETOOL_RELEASE}-linux_amd64.tar.gz /tmp/acmetool.tar.gz

RUN ls /tmp/*.tar.gz | xargs -i tar zxf {} -C /usr/local/bin

RUN mv /usr/local/bin/acmetool-${ACMETOOL_RELEASE}-linux_amd64 /usr/local/bin/acmetool \
 && mv /usr/local/bin/rancher-gen-linux-amd64 /usr/local/bin/rancher-gen \
 && mv /usr/local/bin/rgon-exec-linux-amd64 /usr/local/bin/rgon-exec

RUN chmod +x /usr/local/bin/rancher-gen \
    && chmod +x /usr/local/bin/rgon-exec \
    && chmod +x /usr/local/bin/acmetool \
    && chown root:root /usr/local/bin/*

ADD ./examples/rancher-gen/rancher-gen.cfg ./examples/rancher-gen/nginx.tmpl /etc/rancher-gen/default/

ENTRYPOINT ["/usr/local/bin/rancher-gen"]
CMD ["--config" "/etc/rancher-gen/default/rancher-gen.cfg"]