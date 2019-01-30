FROM debian:squeeze

ENV DEBIAN_FRONTEND noninteractive

# ignore deprecated debian:squeeze repos and expired keys
COPY squeeze.sources.list /etc/apt/sources.list
COPY squeeze.apt.conf /etc/apt/apt.conf

RUN apt-get update -y && apt-get install -y \
	wget \
	lsb-release

RUN \
	wget http://repo.zabbix.com/zabbix/1.8/debian/pool/main/z/zabbix-release/zabbix-release_1.8-1squeeze_all.deb \
	&& dpkg -i zabbix-release_1.8-1squeeze_all.deb \
	&& apt-get update -y \
	&& apt-get install -y \
		zabbix-server-mysql \
		zabbix-frontend-php \
		zabbix-agent \
		zabbix-get \
		zabbix-sender \
	&& rm -rf /var/lib/apt/lists/*

RUN \
	mkdir -p /var/run/zabbix \
	&& chown zabbix.zabbix /var/run/zabbix

# configure php
RUN sed -i \
	-e 's/;date\.timezone.*/date.timezone = UTC/' \
	/etc/php5/apache2/php.ini

# configure zabbix web server
COPY zabbix.conf.php /etc/zabbix/web/zabbix.conf.php

COPY entrypoint.sh /entrypoint.sh

EXPOSE 80 10050

ENTRYPOINT ["/entrypoint.sh"]
