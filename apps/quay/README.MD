<<<<<<< HEAD
# Quay Enterprise 

## MySQL
Setup Variables for persistent storage, these will be mounted on the local host
```shell
MYSQL_VOLUME=/opt/docker/mysql

```

 Variables for MySQL runtime
=======
# QUAY Enterprise SE Notes

# MYSQL 

Setup Variables for persistent storage, these will be mounted on the local host
```shell
MYSQL_VOLUME=/opt/docker/mysql
```

Setup Variables for MySQL runtime
>>>>>>> 4f6dce3df95fe5c4e9f8e8bbf22b27504baed628
```shell
MYSQL_USER="coreosuser"
MYSQL_DATABASE="enterpriseregistrydb"
MYSQL_CONTAINER_NAME="mysql"
MYSQL_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | sed 1q)
MYSQL_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | sed 1q)
```

<<<<<<< HEAD
Start MySQL requirements
```shell
=======
Start MySQL
```
>>>>>>> 4f6dce3df95fe5c4e9f8e8bbf22b27504baed628
sudo mkdir -p $MYSQL_VOLUME

sudo docker pull mysql:5.7

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
```

<<<<<<< HEAD
## Redis
```
=======
# Quay Enterprise
```shell

QUAY_STORAGE=/opt/docker/quay/storage
QUAY_CONFIG=/opt/docker/quay/config

sudo mkdir -p $QUAY_STORAGE $QUAY_CONFIG
>>>>>>> 4f6dce3df95fe5c4e9f8e8bbf22b27504baed628
sudo docker pull quay.io/quay/redis
sudo docker run -d -p 6379:6379 quay.io/quay/redis
```

<<<<<<< HEAD
## Quay Enterprise

=======
>>>>>>> 4f6dce3df95fe5c4e9f8e8bbf22b27504baed628
Modify Dockercfg file with pull secret
```shell
vi .dockercfg 
```

<<<<<<< HEAD
Create Quay paths
```
QUAY_STORAGE=/opt/docker/quay/storage
QUAY_CONFIG=/opt/docker/quay/config
sudo mkdir -p  $QUAY_STORAGE $QUAY_CONFIG
```

=======
>>>>>>> 4f6dce3df95fe5c4e9f8e8bbf22b27504baed628
Run Quay
```shell
cp .dockercfg ~/
sudo cp .dockercfg /root/.dockercfg

sudo docker pull quay.io/coreos/registry:v1.16.5
sudo docker run --restart=always -p 443:443 -p 80:80 --privileged=true -v $QUAY_CONFIG:/conf/stack -v $QUAY_STORAGE:/datastorage -d quay.io/coreos/registry:v1.16.5
```

## Clair 
Clair Variables
``` shell
PSQL_VOLUME=/opt/docker/psql
CLAIR_CONFIG=/opt/docker/clair/config
```

## Create a Postgres DB

``` shell
sudo mkdir -p $PSQL_VOLUME
docker run --name postgres -p 5432:5432 -v PSQL_VOLUME:/var/lib/postgresql/data -d postgres 
sleep 5
docker run --rm --link postgres:postgres postgres sh -c 'echo "create database clairtest" | psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
``` 

<<<<<<< HEAD
=======
Clair Config
>>>>>>> 4f6dce3df95fe5c4e9f8e8bbf22b27504baed628
Edit Clair config.yaml; https://tectonic.com/quay-enterprise/docs/1.16.0/clair.html
``` shell
sudo mkdir -p $CLAIR_CONFIG
sudo vi $CLAIR_CONFIG/config.yaml
```

## Run Clair
``` shell
sudo docker run --restart=always -p 6060:6060 -p 6061:6061 -v $CLAIR_CONFIG:/config quay.io/coreos/clair-jwt:v1.2.2
```
