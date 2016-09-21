# Install docker 1.11.2 for Unbuntu
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-engine=1.11*
sudo curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://4d0183dd.m.daocloud.io
sudo service docker restart
docker pull progrium/consul
docker pull swarm
