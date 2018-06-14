FROM  resin/raspberry-pi-alpine-node:8
LABEL maintainer="Ronny Elflein <ronny@11lein.de>"

#Install libpcap-dev
RUN apk update && apk upgrade &&\
    apk add git libpcap-dev wget sudo

#install dasher
RUN cd /root && export GIT_SSL_NO_VERIFY=1 && \
    git config --global http.sslVerify false && \
    git clone https://github.com/maddox/dasher.git 

WORKDIR /root/docker-dasher
ADD config.json /root/dasher/config/config.json

RUN cp -rf /root/dasher/* .
RUN npm install

# Interface the environment
VOLUME /root/docker-dasher/config

# Baseimage init process
CMD cp -a /root/dasher/config/* config/ &&  npm run start
