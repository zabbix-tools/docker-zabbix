#!/bin/bash

# start and configure mysql
/etc/init.d/mysql start
eval $(grep ^DBPassword /etc/zabbix/zabbix_server.conf) 
mysql <<SQL
CREATE DATABASE zabbix CHARACTER SET UTF8 COLLATE UTF8_BIN;
GRANT ALL PRIVILEGES ON zabbix.* to zabbix@localhost identified by '${DBPassword}';
SQL

if [[ -f "/usr/share/dbconfig-common/data/zabbix-server-mysql/install/mysql" ]]; then
	mysql -D zabbix < /usr/share/dbconfig-common/data/zabbix-server-mysql/install/mysql
else
	cd /usr/share/doc/zabbix-server-mysql/
	if [[ -f 'create.sql.gz' ]]; then
		zcat create.sql.gz | mysql -D zabbix
	else
		mysql -D zabbix < schema.sql
		mysql -D zabbix < images.sql
		mysql -D zabbix < data.sql
	fi
fi

# enable zabbix server monitoring
mysql -D zabbix -e 'UPDATE hosts SET status=0 WHERE status=1;'

# start zabbix service
/etc/init.d/zabbix-server start
/etc/init.d/zabbix-agent start
/etc/init.d/apache2 start

if [ "$#" -ne 0 ]; then
	# execute user commands
	$@
else
	# tail logs
	tail -f \
		/var/log/zabbix/*.log \
		/var/log/mysql.* \
		/var/log/apache2/error.log
fi
