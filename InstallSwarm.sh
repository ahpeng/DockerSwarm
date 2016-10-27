#!/bin/bash

###########################################################
# Configure Docker swarm One Box
#
# This installs the following components
# - Consual
# - Docker swarm master
# - Docker swarm agent
###########################################################

set -x

echo "starting Docker swarm cluster configuration"
date
ps ax

SWARM_VERSION="swarm:1.0.0"
#############
# Parameters
#############

MASTERCOUNT=${1}
MASTERPREFIX=${2}
MASTERFIRSTADDR=${3}
AZUREUSER=${4}
BASESUBNET=${5}
VMNAME=`hostname`
VMNUMBER=`echo $VMNAME | sed 's/.*[^0-9]\([0-9]\+\)*$/\1/'`
VMPREFIX=`echo $VMNAME | sed 's/\(.*[^0-9]\)*[0-9]\+$/\1/'`

echo "Master Count: $MASTERCOUNT"
echo "Master Prefix: $MASTERPREFIX"
echo "Master First Addr: $MASTERFIRSTADDR"
echo "vmname: $VMNAME"
echo "VMNUMBER: $VMNUMBER, VMPREFIX: $VMPREFIX"
echo "BASESUBNET: $BASESUBNET"
echo "AZUREUSER: $AZUREUSER"
###################
# Common Functions
###################

ensureAzureNetwork()
{
  # ensure the host name is resolvable
  hostResolveHealthy=1
  for i in {1..120}; do
    host $VMNAME
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      hostResolveHealthy=0
      echo "the host name resolves"
      break
    fi
    sleep 1
  done
  if [ $hostResolveHealthy -ne 0 ]
  then
    echo "host name does not resolve, aborting install"
    exit 1
  fi

  # ensure the network works
  networkHealthy=1
  for i in {1..12}; do
    wget -O/dev/null http://bing.com
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      networkHealthy=0
      echo "the network is healthy"
      break
    fi
    sleep 10
  done
  if [ $networkHealthy -ne 0 ]
  then
    echo "the network is not healthy, aborting install"
    ifconfig
    ip a
    exit 2
  fi
  # ensure the host ip can resolve
  networkHealthy=1
  for i in {1..120}; do
    hostname -i
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      networkHealthy=0
      echo "the network is healthy"
      break
    fi
    sleep 1
  done
  if [ $networkHealthy -ne 0 ]
  then
    echo "the network is not healthy, cannot resolve ip address, aborting install"
    ifconfig
    ip a
    exit 2
  fi
}
ensureAzureNetwork
HOSTADDR=`hostname -i`

ismaster ()
{
  if [ "$MASTERPREFIX" == "$VMPREFIX" ]
  then
    return 0
  else
    return 1
  fi
}
if ismaster ; then
  echo "this node is a master"
fi

isagent()
{
  if ismaster ; then
    return 1
  else
    return 0
  fi
}
if isagent ; then
  echo "this node is an agent"
fi

################
# Modify ubuntu's Source list
################
sudo mv /etc/apt/sources.list /etc/apt/sources.list_bak
echo "\
deb http://mirrors.aliyun.com/ubuntu/ trusty main multiverse restricted universe
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main multiverse restricted universe
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main multiverse restricted universe
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main multiverse restricted universe
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main multiverse restricted universe
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main multiverse restricted universe
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main multiverse restricted universe
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main multiverse restricted universe
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main multiverse restricted universe
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main multiverse restricted universe " >/tmp/sources.list
sudo cp /tmp/sources.list /etc/apt/sources.list
sudo apt-get update

################
# Install Docker
################

echo "Installing and configuring docker"

installDocker()
{
  for i in {1..10}; do
    curl -sSL https://get.daocloud.io/docker | sh
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      echo "Docker installed successfully"
      break
    fi
    sleep 10
  done
}
time installDocker
sudo usermod -aG docker $AZUREUSER
# Set mirror daocloud
sudo curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://4d0183dd.m.daocloud.io
sudo service docker restart
if isagent ; then
  # Start Docker and listen on :2375 (no auth, but in vnet)
  echo 'DOCKER_OPTS="-H unix:///var/run/docker.sock -H 0.0.0.0:2375"' | sudo tee -a /etc/default/docker
fi

echo "Installing docker compose"
curl -L https://get.daocloud.io/docker/compose/releases/download/1.8.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

sudo service docker restart

ensureDocker()
{
  # ensure that docker is healthy
  dockerHealthy=1
  for i in {1..3}; do
    sudo docker info
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      dockerHealthy=0
      echo "Docker is healthy"
      sudo docker ps -a
      break
    fi
    sleep 10
  done
  if [ $dockerHealthy -ne 0 ]
  then
    echo "Docker is not healthy"
  fi
}
ensureDocker

##############################################
# configure init rules restart all processes
##############################################

consulstr()
{
  consulargs=""
  for i in `seq 0 $((MASTERCOUNT-1))` ;
  do
    MASTEROCTET=`expr $MASTERFIRSTADDR + $i`
    IPADDR="${BASESUBNET}${MASTEROCTET}"

    if [ "$VMNUMBER" -eq "0" ]
    then
      consulargs="${consulargs}-bootstrap-expect $MASTERCOUNT "
    fi
    if [ "$VMNUMBER" -eq "$i" ]
    then
      consulargs="${consulargs}-advertise $IPADDR "
    else
      consulargs="${consulargs}-retry-join $IPADDR "
    fi
  done
  echo $consulargs
}

consulargs=$(consulstr)
MASTEROCTET=`expr $MASTERFIRSTADDR + $VMNUMBER`
VMIPADDR="${BASESUBNET}${MASTEROCTET}"
MASTER0IPADDR="${BASESUBNET}${MASTERFIRSTADDR}"

if ismaster ; then
  mkdir -p /data/consul
  echo "consul:
  image: \"progrium/consul\"
  command: -server -node $VMNAME $consulargs
  ports:
    - \"8300:8300\"
    - \"8301:8301\"
    - \"8301:8301/udp\"
    - \"8302:8302\"
    - \"8302:8302/udp\"
    - \"8400:8400\"
    - \"8500:8500\"
  volumes:
    - \"/data/consul:/data\"
  restart: \"always\"
swarm:
  image: \"$SWARM_VERSION\"
  command: manage --replication --advertise $HOSTADDR:2375 consul://$MASTER0IPADDR:8500/nodes
  ports:
    - \"2375:2375\"
  links:
    - \"consul\"
  volumes:
    - \"/etc/docker:/etc/docker\"
  restart: \"always\"
  " > docker-compose.yml
  #" > /opt/azure/containers/docker-compose.yml

  #pushd /opt/azure/containers/
  docker-compose up -d
  #popd
  echo "completed starting docker swarm on the master"
fi

if isagent ; then
  echo "swarm:
  image: \"$SWARM_VERSION\"
  restart: \"always\"
  command: join --advertise=$HOSTADDR:2375 consul://$MASTER0IPADDR:8500/nodes
" > docker-compose.yml
#" > /opt/azure/containers/docker-compose.yml
  #pushd /opt/azure/containers/
  docker-compose up -d
  #popd
  echo "completed starting docker swarm on the agent"
fi

echo "processes at end of script"
ps ax
date
echo "completed docker swarm cluster configuration"