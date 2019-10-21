FROM centos:centos7

ENV LICHOST "172.0.0.1"
ENV LICPORT "57777"
ENV LICPASS "docker"

ENV DATADIR "data"
ENV LOGDIR  "log"

ARG S6_OVERLAY_VERSION=v1.22.1.0
ARG TM_LINUX_VERSION=12.9R3

ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz /tmp

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude="./bin" \
&&  tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin \
&&  curl -s ftp://ftp.solution-soft.com/pub/tm/linux/redhat/64bit/tm_linux_2.6.up_x86_64-${TM_LINUX_VERSION}.tgz -o /tmp/tm_linux.tgz \
&&  mkdir -p /tmp/build \
&&  tar xzf /tmp/tm_linux.tgz -C /tmp/build \
&&  (cd /tmp/build; ./ssstm_install.sh tm_linux_2.6.up_x86_64-${TM_LINUX_VERSION}.rpm) \
&&  (cd /etc/ssstm/extras; rm -f .tm*.tgz Makefile.re) \
&&  mkdir -p /tmdata \
&&  rm -rf /tmp/s6-overlay-amd64.tar.gz /tmp/tm_linux.tgz /tmp/build

# -- copy user defined files
COPY config /

# -- expose tmagent listening port
EXPOSE 7800

# -- specify tm data dir
VOLUME /tmdata

ENTRYPOINT ["/init"]