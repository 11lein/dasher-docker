FROM   arm32v7/node
LABEL maintainer="Ronny Elflein <ronny@11lein.de>"

#Install libpcap-dev
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y git libpcap-dev wget sudo  && \ 
    apt-get clean && rm -rf /var/lib/apt/lists/*

#update node needed for <RPi3
#RUN wget http://node-arm.herokuapp.com/node_latest_armhf.deb
#RUN dpkg -i node_latest_armhf.deb

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
CMD cp -r /root/dasher/config/* config/ &&  npm run start
