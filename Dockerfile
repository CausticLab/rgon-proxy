FROM alpine:3.5

RUN apk add --no-cache ca-certificates

ENV RANCHER_GEN_RELEASE v0.2.0 \
    RGON_EXEC_RELEASE v1.0.0 \
    ACMETOOL_RELEASE v0.0.59


ADD https://github.com/causticlab/go-rancher-gen/releases/download/${RANCHER_GEN_RELEASE}/rancher-gen-linux-amd64.tar.gz /tmp/rancher-gen.tar.gz
ADD https://github.com/causticlab/rgon-exec/releases/download/${RGON_EXEC_RELEASE}/rgon-exec-linux-amd64.tar.gz /tmp/rgon-exec.tar.gz
ADD https://github.com/hlandau/acme/releases/download/${ACMETOOL_RELEASE}/acmetool-${ACMETOOL_RELEASE}-linux_amd64.tar.gz /tmp/acmetool.tar.gz

RUN tar -zxvf /tmp/*.tar.gz -C /usr/local/bin \
	&& chmod +x /usr/local/bin/rancher-gen \
  && chmod +x /usr/local/bin/rgon-exec \
  && chmod +x /usr/local/bin/acmetool


ENTRYPOINT ["/usr/local/bin/rancher-gen"]
