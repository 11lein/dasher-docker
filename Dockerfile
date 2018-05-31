
# Baseimage init process
#CMD cd /root/dasher && cp -n config.json /root/dasher/config/config.json  && npm run start


FROM   arm32v7/ubuntu:latest
MAINTAINER	Ronny Elflein <ronny@11lein.de>

#Install libpcap-dev
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y nodejs npm git wget libpcap-dev && \ 
    apt-get clean && rm -rf /var/lib/apt/lists/*

#update node needed for <RPi3
RUN wget http://node-arm.herokuapp.com/node_latest_armhf.deb
RUN dpkg -i node_latest_armhf.deb

#install dasher
RUN cd /root && export GIT_SSL_NO_VERIFY=1 && \
    git config --global http.sslVerify false && \
    git clone https://github.com/maddox/dasher.git

WORKDIR /root/dasher
RUN cd /root/dasher && npm install
ADD config.json /root/dasher/config.json

# Interface the environment
VOLUME /root/dasher/config

# Baseimage init process
CMD cd /root/dasher && npm run start
