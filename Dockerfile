FROM alpine:3.9

ARG ISSO_VER=0.12.2

ENV GID=1000 UID=1000

RUN apk -U upgrade \
 && apk add -t build-dependencies \
    python3-dev \
    libffi-dev \
    build-base \
 && apk add \
    python3 \
    sqlite \
    openssl \
    ca-certificates \
    su-exec \
    tini \
    bash \
    sudo \
    vim \

 && pip3 install -U --no-cache pip \
 && pip install --no-cache gevent \
 && pip install --no-cache "isso==${ISSO_VER}" \
 && apk del build-dependencies \
 && rm -rf /tmp/* /var/cache/apk/*

COPY run.sh /usr/local/bin/run.sh

RUN chmod +x /usr/local/bin/run.sh

EXPOSE 8080

VOLUME /db /config

LABEL maintainer="Lightweight <dave@davelane.nz>"

CMD ["run.sh"]
