#!/bin/bash

# start and configure mysql
echo "==> Starting MySQL..."
/etc/init.d/mysql start

echo "==> Creating Zabbix database..."
eval $(grep ^DBPassword /etc/zabbix/zabbix_server.conf)
mysql -v <<SQL
CREATE DATABASE zabbix CHARACTER SET UTF8 COLLATE UTF8_BIN;
CREATE USER zabbix@localhost IDENTIFIED BY '${DBPassword}';
GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost;
FLUSH PRIVILEGES;
SQL
sed -i -e "s/DBPassword/${DBPassword}/g" \
	/etc/zabbix/web/zabbix.conf.php

echo "==> Initializing Zabbix database..."
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

# autoload any modules loaded into /usr/lib/zabbix/modules/
echo "==> Configuring Zabbix agent modules..."
shopt -s nullglob
for module in /usr/lib/zabbix/modules/*.so; do
	echo "LoadModule=${module##*/}" >> /etc/zabbix/zabbix_agentd.conf
done

# start zabbix service
echo "==> Starting Services..."
/etc/init.d/zabbix-server start
/etc/init.d/zabbix-agent start
/etc/init.d/apache2 start

if [ "$#" -ne 0 ]; then
	# execute user commands
	$@
else
	# tail logs
	echo "==> Tailing logs..."
	tail -f \
		/var/log/zabbix/*.log \
		/var/log/mysql.* \
		/var/log/apache2/error.log
fi
