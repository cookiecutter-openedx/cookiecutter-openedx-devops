echo "Waiting for mysql client connection..."
mysql_connection_max_attempts=10
mysql_connection_attempt=0
until mysql -u ${MYSQL_ROOT_USERNAME} --password="${MYSQL_ROOT_PASSWORD}" --host "${MYSQL_HOST}" --port ${MYSQL_PORT} -e 'exit'
do
    mysql_connection_attempt=$(expr $mysql_connection_attempt + 1)
    echo "    [$mysql_connection_attempt/$mysql_connection_max_attempts] Waiting for MySQL service (this may take a while)..."
    if [ $mysql_connection_attempt -eq $mysql_connection_max_attempts ]
    then
      echo "MySQL initialisation error" 1>&2
      exit 1
    fi
    sleep 10
done
echo "connected to mysql client"

mysql -u ${MYSQL_ROOT_USERNAME} --password="${MYSQL_ROOT_PASSWORD}" --host "${MYSQL_HOST}" --port ${MYSQL_PORT} -e "CREATE DATABASE IF NOT EXISTS ${WORDPRESS_MYSQL_DATABASE};"
mysql -u ${MYSQL_ROOT_USERNAME} --password="${MYSQL_ROOT_PASSWORD}" --host "${MYSQL_HOST}" --port ${MYSQL_PORT} -e "CREATE USER IF NOT EXISTS '${WORDPRESS_MYSQL_USERNAME}';"
mysql -u ${MYSQL_ROOT_USERNAME} --password="${MYSQL_ROOT_PASSWORD}" --host "${MYSQL_HOST}" --port ${MYSQL_PORT} -e "ALTER USER '${WORDPRESS_MYSQL_USERNAME}'@'%' IDENTIFIED BY '${WORDPRESS_MYSQL_PASSWORD}';"
mysql -u ${MYSQL_ROOT_USERNAME} --password="${MYSQL_ROOT_PASSWORD}" --host "${MYSQL_HOST}" --port ${MYSQL_PORT} -e "GRANT ALL ON ${WORDPRESS_MYSQL_DATABASE}.* TO '${WORDPRESS_MYSQL_USERNAME}'@'%';"
mysql -u ${MYSQL_ROOT_USERNAME} --password="${MYSQL_ROOT_PASSWORD}" --host "${MYSQL_HOST}" --port ${MYSQL_PORT} -e "FLUSH PRIVILEGES;"
