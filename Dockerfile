FROM alpine:edge

ARG default_db=mysql
ARG default_user=root
ARG default_name=phpipam
ARG default_port=3306
ARG default_key=438bc82ed9810578fe8aebd36722a54f
ENV IPAM_DATABASE_HOST=$default_db
ENV IPAM_DATABASE_USER=$default_user
ENV IPAM_DATABASE_NAME=$default_name
ENV IPAM_DATABASE_PORT=$default_port
ENV IPAM_AGENT_KEY=$default_key

WORKDIR /app

RUN echo -e "http://dl-cdn.alpinelinux.org/alpine/edge/community\nhttp://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories

RUN apk -U upgrade -a
RUN apk --no-cache update

RUN apk --no-cache add dnsmasq php7 php7-session php7-pdo php7-pdo_mysql php7-gmp php7-json php7-pcntl php7-gettext php7-ctype php7-iconv php7-mbstring php7-pear php7-posix git python3 py3-mysqlclient fping perl bash nano
RUN ln -s `which python3` /usr/bin/python # Python2 is deprecated
RUN ln -s `which pip3` /usr/bin/pip

RUN git clone --recursive https://github.com/phpipam/phpipam-agent/
#RUN git clone https://github.com/debops/phpipam-scripts.git
RUN git clone --single-branch --branch patch-1 https://github.com/grea09/phpipam-scripts.git
# Latest commit: fixing deprecated file type

ENV CRONTAB_FILE=/etc/crontabs/root
RUN echo "* * * * * php /app/phpipam-agent/index.php update > /proc/1/fd/1 2>/proc/1/fd/2" >> ${CRONTAB_FILE}
RUN echo "*/5 * * * * /app/phpipam-scripts/phpipam-hosts -o /etc/dnsmasq.conf -x" >> ${CRONTAB_FILE}
RUN echo "* * * * * dnsmasq -k" >> ${CRONTAB_FILE}

RUN mkdir /etc/dhcp
COPY config.template.php config.template.php
COPY phpipam.template.conf phpipam.template.conf
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

EXPOSE 53 53/udp

ENTRYPOINT ["/app/entrypoint.sh"]
