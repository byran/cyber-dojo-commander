FROM alpine:3.4
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 1. install docker-client
# Launching a docker app (that itself uses docker) is
# different on different host OS's... eg
#
# OSX 10.10 (Yosemite)
# --------------------
# The Docker-Quickstart-Terminal uses docker-machine to forward
# docker commands to a boot2docker VM called default.
# In this VM the docker binary lives at /usr/local/bin/
#
#    -v /usr/local/bin/docker:/usr/local/bin/docker
#
# Ubuntu 14.04 (Trusty)
# ---------------------
# The docker binary lives at /usr/bin and has a dependency on apparmor 1.1
#
#    -v /usr/bin/docker:/usr/bin/docker
#    -v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.1.0 ...
#
# Debian 8 (Jessie)
# -----------------
# The docker binary lives at /usr/bin and has a dependency to apparmor 1.2
#
#    -v /usr/bin/docker:/usr/bin/docker
#    -v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.2.0 ...
#
# I originally used docker-compose extension files specific to each OS.
# I now install the docker client _inside_ the image.
# This means there is no host<-container uid dependency.
# But there is a host<-container docker version dependency.
#
# docker 1.11.0+ now relies on four binaries
# See https://github.com/docker/docker/wiki/Engine-1.11.0
# See https://docs.docker.com/engine/installation/binaries/
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ARG  DOCKER_VERSION
USER root
RUN  apk update \
  && apk add --no-cache curl \
  && curl -OL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz \
  && tar -xvzf docker-${DOCKER_VERSION}.tgz \
  && mv docker/* /usr/bin/ \
  && rmdir /docker \
  && rm /docker-${DOCKER_VERSION}.tgz \
  && apk del curl

# - - - - - - - - - - - - - - - - - - - - - -
# 2. install docker-compose
# https://github.com/marcosnils/compose/blob/master/Dockerfile.run

ARG  DOCKER_COMPOSE_VERSION
ARG  DOCKER_COMPOSE_BINARY=/usr/bin/docker-compose
USER root
RUN  apk update \
  && apk add --no-cache curl openssl ca-certificates \
  && curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > ${DOCKER_COMPOSE_BINARY} \
  && chmod +x ${DOCKER_COMPOSE_BINARY} \
  && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk \
  && apk add --no-cache glibc-2.23-r3.apk && rm glibc-2.23-r3.apk \
  && ln -s /lib/libz.so.1 /usr/glibc-compat/lib/ \
  && ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib \
  && apk del curl

# - - - - - - - - - - - - - - - - - - - - - -
# 3. install ruby and json gem

USER root
RUN  apk update && apk add ruby ruby-irb ruby-io-console ruby-bigdecimal tzdata bash
RUN  gem install json_pure --no-ri --no-rdoc

# - - - - - - - - - - - - - - - - - - - - - -
# 4. install commander

RUN  mkdir /app
COPY cyber-dojo.sh          /app
COPY cyber-dojo.rb          /app
COPY docker-compose.yml     /app
COPY start_point_check.rb   /app
COPY start_point_inspect.rb /app
COPY start_point_pull.rb    /app
WORKDIR /app


