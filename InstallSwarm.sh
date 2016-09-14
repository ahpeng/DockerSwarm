# Installing Docker Machine
sudo curl -L https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
chmod +x /usr/local/bin/docker-machine

# Define the number of managers/workers
MANAGER=1
WORKER=3

# Init the swarm
sudo docker-machine ssh swarm-master-0 docker swarm init --auto-accept manager --auto-accept worker --listen-addr $(docker-machine ip swarm-master-0):2377

# Add workers
for i in $(seq 0 $WORKER); do sudo docker-machine ssh swarm-node-$i docker swarm join --listen-addr $(docker-machine ip swarm-node-$i):2377 $(docker-machine ip swarm-master-0):2377; done
