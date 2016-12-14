#!/bin/bash
set -e

QUAY_VERSION=v2.0.2
QUAY_INSTALL_CLAIR=1 # or 0 for no
QUAY_ENABLE_SSL=1 # or 1 to enable
QUAY_SETUP_CLAIR=0 # or 0 to disabe


# MySQL settings
MYSQL_USER="coreosuser"
MYSQL_DATABASE="quay"
MYSQL_CONTAINER_NAME="mysql"
MYSQL_ROOT_PASSWORD="password"
MYSQL_PASSWORD="coreosuserpassword"

# Quay Settings
QUAY_USERNAME="admin"
QUAY_PASSWORD="password"
DB_PORT_3306_TCP_ADDR="172.17.8.101"
DB_PORT_3306_TCP_PORT="3306"
REDIS_PORT_6379_TCP_ADDR="172.17.8.101"
REDIS_PORT_6379_TCP_PORT="6379"


# Data to Persist
MYSQL_VOLUME=/opt/docker/mysql
QUAY_STORAGE=/opt/docker/quay/storage
QUAY_CONFIG=/opt/docker/quay/config
sudo mkdir -p  $QUAY_STORAGE $QUAY_CONFIG
sudo mkdir -p $MYSQL_VOLUME

echo "Pulling MySQL"
sudo docker pull mysql:5.7 2> /dev/stdout 1> /dev/null

echo "Running MySQL"
sudo docker \
  run \
  --detach \
  --env MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  --env MYSQL_USER=${MYSQL_USER} \
  --env MYSQL_PASSWORD=${MYSQL_PASSWORD} \
  --env MYSQL_DATABASE=${MYSQL_DATABASE} \
  --name ${MYSQL_CONTAINER_NAME} \
  --publish 3306:3306 \
  --volume $MYSQL_VOLUME:/var/lib/mysql \
  mysql:5.7;

echo "Pulling Redis"
sudo docker pull quay.io/quay/redis 2> /dev/stdout 1> /dev/null

echo "Running Redis"
sudo docker run -d -p 6379:6379 quay.io/quay/redis

# Not sure why this is required, but seems to fail without it in Vagrant
sudo mkdir -p /root/.docker
sudo cp /home/core/.docker/config.json /root/.docker

echo "Pulling Quay"
docker pull quay.io/coreos/quay:$QUAY_VERSION 2> /dev/stdout 1> /dev/null

if [ "$QUAY_ENABLE_SSL" == "1" ]; then
	echo "Generating SSL Certificates"
	mkdir -p /home/core/quay/ssl 2> /dev/stdout 1> /dev/null
	pushd /home/core/quay/ssl 2> /dev/stdout 1> /dev/null
	openssl genrsa -out rootCA.key 2048 2> /dev/stdout 1> /dev/null 
	openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem -subj "/C=US/ST=New York/L=New York/O=Quay/OU=Quay/CN=coreos.com" 2> /dev/stdout 1> /dev/null
	openssl genrsa -out ssl.key 2048 2> /dev/stdout 1> /dev/null
	openssl req -new -key ssl.key -out ssl.csr -subj "/C=US/ST=New York/L=New York/O=Quay/OU=Quay/CN=coreos.com" 2> /dev/stdout 1> /dev/null
	openssl x509 -req -in ssl.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out ssl.cert -days 500 -sha256 2> /dev/stdout 1> /dev/null
	popd 2> /dev/stdout 1> /dev/null
fi

function init_templates {
    local TEMPLATE=/home/core/quay/genconfig.py
    local uuid_file="/var/run/kubelet-pod.uuid"
    if [ ! -f $TEMPLATE ]; then
        echo "TEMPLATE: $TEMPLATE"
        mkdir -p $(dirname $TEMPLATE)
        cat << EOF > $TEMPLATE
import logging
import sys
import os
import time

from urlparse import urlparse
from datetime import datetime, timedelta
from alembic.config import Config
from alembic import command

from app import config_provider, app
from data import model
from data.database import validate_database_url, configure
from util.config.configutil import add_enterprise_config_defaults


logger = logging.getLogger(__name__)


SUPER_USER_USERNAME = "$QUAY_USERNAME"
SUPER_USER_PASSWORD = "$QUAY_PASSWORD"
WAIT_FOR_DB_TIMEOUT = 30
WAIT_FOR_DB_CYCLE_TIME = 1


def docker_hostname(docker_ip):
  # Examples: tcp://192.168.99.101:2376
  # Examples: unix:///var/run/docker.sock
  # Examples: localhost
  if docker_ip.startswith('tcp://'):
    return urlparse(docker_ip).hostname
  return 'localhost'


def generate_or_update_config(hostname):
  db_host = "$DB_PORT_3306_TCP_ADDR"
  db_port = "$DB_PORT_3306_TCP_PORT"
  db_uri = 'mysql+pymysql://root:password@{0}:{1}/quay'.format(db_host, db_port)
  db_args = {}

  end = datetime.now() + timedelta(seconds=WAIT_FOR_DB_TIMEOUT)
  success = False
  while datetime.now() < end and not success:
    try:
      validate_database_url(db_uri, db_args)
      success = True
    except Exception as exc:
      logger.info('Unable to contact database, retrying after %ss', WAIT_FOR_DB_CYCLE_TIME)
      time.sleep(WAIT_FOR_DB_CYCLE_TIME)

  if not success:
    logger.error('Unable to contact database after waiting %ss', WAIT_FOR_DB_TIMEOUT)
    sys.exit(1)

  if not config_provider.config_exists():
    config_object = {}
    add_enterprise_config_defaults(config_object, app.config['SECRET_KEY'], hostname)
    config_object['SUPER_USERS'] = [SUPER_USER_USERNAME]
    config_object['DB_CONNECTION_ARGS'] = db_args
  else:
    config_object = config_provider.get_config()

  config_object['SERVER_HOSTNAME'] = hostname

  config_object['DB_URI'] = db_uri

  db_host = "$DB_PORT_3306_TCP_ADDR"
  db_port = "$DB_PORT_3306_TCP_PORT"
  config_object['DB_URI'] = 'mysql+pymysql://root:password@{0}:{1}/quay'.format(db_host, db_port)


  redis_host = "$REDIS_PORT_6379_TCP_ADDR"
  redis_port = "$REDIS_PORT_6379_TCP_PORT"
  config_object['BUILDLOGS_REDIS'] = {'host': redis_host, 'port': redis_port}
  config_object['USER_EVENTS_REDIS'] = config_object['BUILDLOGS_REDIS']
  config_object['FEATURE_BUILD_SUPPORT'] = True
  config_object['SETUP_COMPLETE'] = True

  if not config_provider.config_exists():
    # Re-initialize the database with the real URI
    app.config.update(config_object)
    configure(app.config)

    alembic_cfg = Config("/alembic.ini")
    command.upgrade(alembic_cfg, "head")

    model.user.create_user(SUPER_USER_USERNAME, SUPER_USER_PASSWORD, 'root@example.com',
                           auto_verify=True)

  config_provider.save_config(config_object)


if __name__ == '__main__':
  logging.basicConfig(level=logging.INFO)
  generate_or_update_config(docker_hostname(os.environ.get('DOCKER_HOST', 'localhost')))
  logger.info('Super user username: %s password: %s', SUPER_USER_USERNAME, SUPER_USER_PASSWORD)
EOF
    fi

}

init_templates
touch /home/core/quay/__init__.py

echo "Running Quay Init"	
docker run --privileged=true \
	-v /home/core/quay:/quickstart \
	-v $QUAY_CONFIG:/conf/stack \
	-v $QUAY_STORAGE:/datastorage \
	quay.io/coreos/quay:$QUAY_VERSION venv/bin/python -m quickstart.genconfig

echo "Running Quay"
docker run --name quay --restart=always -p 443:443 -p 80:80 --privileged=true -v $QUAY_CONFIG:/conf/stack -v $QUAY_STORAGE:/datastorage -d quay.io/coreos/quay:$QUAY_VERSION

if [ "$QUAY_SETUP_CLAIR" == "1" ]; then
  echo "Setting Up Clair"
  PSQL_VOLUME=/opt/docker/psql
  CLAIR_CONFIG=/opt/docker/clair/config
  sudo mkdir -p $PSQL_VOLUME
  echo "Pulling Clair-Postgres"
  docker pull postgres
  docker run --name postgres -p 5432:5432 -v PSQL_VOLUME:/var/lib/postgresql/data -d postgres 
  sleep 5
  docker run --rm --link postgres:postgres postgres sh -c 'echo "create database clairtest" | psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'

fi