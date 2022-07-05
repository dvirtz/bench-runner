FROM ubuntu:18.04

LABEL maintainer="Fred Tingaud <ftingaud@hotmail.com>"

USER root

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y git procmail curl gnupg2 apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

RUN add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable" && \
    apt update && \
    apt install -y nodejs yarn docker-ce docker-ce-cli containerd.io

RUN git clone https://github.com/dvirtz/quick-bench-back-end /quick-bench && \
    cd /quick-bench && \
    git checkout conan && \
    npm install && \
    ./seccomp.js && \
    sysctl -w kernel.perf_event_paranoid=1

RUN git clone https://github.com/dvirtz/quick-bench-front-end /quick-bench/quick-bench-front-end && \
    cd /quick-bench/quick-bench-front-end && \
    git checkout conan && \
    cd build-bench && \
    yarn && \
    yarn build && \
    cd ../quick-bench && \
    yarn && \
    yarn build

COPY ./build-scripts/start-* /quick-bench/

WORKDIR /quick-bench

