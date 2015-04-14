#!/bin/bash

MYSQL_ROOT_PASSWORD=`pwgen -c -n -1 12`
MYSQL_DATABASE="appdb"
DRUPAL_USER=${DRUPAL_USER:-"appuser"}
DRUPAL_PASSWORD=`pwgen -c -n -1 12`

# Initialize MySQL
function initializeMySQL() {
    echo "Initializing MySQL" >> /var/www/install.flag
	chown -R mysql:mysql /var/lib/mysql
	mysql_install_db --user mysql > /dev/null
}

# Start MySQL
function startMySQL() {
	/usr/bin/mysqld_safe & sleep 10s
}

# Secure the root user by creating a random password
function configureRootUser() {
    echo "Configuring root user" >> /var/www/install.flag
	echo "Configuring root user"
	tfile=`mktemp`
	if [[ ! -f "$tfile" ]]; then
		return 1
	fi

	cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE user='root';
EOF

	mysql -uroot < $tfile
	rm -f $tfile
}

# Create the database 
function configureMySQL() {
    echo "Creating database" >> /var/www/install.flag
	echo "Creating database"

	echo "##########################################" >> /var/www/install.flag
	echo "########### INFORMATION USED #############" >> /var/www/install.flag
	echo "##########################################" >> /var/www/install.flag
	echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD" >> /var/www/install.flag
	echo "MYSQL_DATABASE: $MYSQL_DATABASE" >> /var/www/install.flag
	echo "DRUPAL_USER: $DRUPAL_USER" >> /var/www/install.flag
	echo "DRUPAL_PASSWORD: $DRUPAL_PASSWORD" >> /var/www/install.flag
	echo "##########################################" >> /var/www/install.flag
	echo "##########################################" >> /var/www/install.flag

	mysql -uroot -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci; GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$DRUPAL_USER'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; FLUSH PRIVILEGES;"
	echo "Showing databases"
	mysql -uroot -e "SHOW DATABASES"
}

if [ -f /var/www/install.flag ]
then
    echo "Installation flag install.flag exists at /var/www/install.flag. Not running the installation procedure anymore."

else
    echo "Installation flag not found. Installing ..."
    initializeMySQL
    startMySQL
    configureMySQL
    configureRootUser
fi

echo "Killing mysqld"
killall mysqld

# execute supervisor
echo "executing supervisor"
exec /usr/bin/supervisord -n
