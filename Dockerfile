FROM ubuntu:16.04

ARG LUCI_PY_COMMIT=1f8ba359e84dc7f26b1ba286dfb4e28674efbff4
# toddlipcon's fork
ARG LUCI_GO_COMMIT=6f8431521270754084d85b593604ff46f9ac51b1
## Go 1.4.3 (FIXME: only amd64)
ARG GO_DISTRIBUTION=https://storage.googleapis.com/golang/go1.4.3.linux-amd64.tar.gz

## Install apt packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  beanstalkd \
  build-essential \
  gawk \
  git \
  libmysqlclient-dev mysql-server \
  maven \
  openjdk-8-jdk \
  python python-dev python-pip python-setuptools python-virtualenv \
  unzip \
  virtualenv \
  wget \
  ## extra things for ease of use
  less vim w3m

## Install pip packages
RUN pip install -t lib google-api-python-client

## Install Go
RUN wget -q -O - $GO_DISTRIBUTION | tar xz -C /
RUN mkdir /gopath
ENV GOROOT=/go
ENV GOPATH=/gopath
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

## Install LUCI
WORKDIR /
RUN git clone https://github.com/luci/luci-py.git && \
(cd luci-py && git checkout $LUCI_PY_COMMIT)

RUN mkdir -p $GOPATH/src/github.com/luci && \
  ( cd $GOPATH/src/github.com/luci && \
    git clone https://github.com/toddlipcon/luci-go && \
    cd luci-go && git checkout $LUCI_GO_COMMIT && \
    go get github.com/luci/luci-go/server/isolateserver )

## Initialize MySQL
RUN service mysql start && \
  mysql -e 'CREATE DATABASE dist_test_db'

## Install dist_test
ADD . /dist_test
RUN ln -s /dist_test/misc/docker/dist_test.cnf /root/.dist_test.cnf

## Start init
WORKDIR /dist_test
ENTRYPOINT ["/dist_test/misc/docker/init.py"]
