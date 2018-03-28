#!/bin/bash

DESC="script that manages containers and vagrant"
NAME=igor

###########
#Functions#
###########

## Creating Docker containers and Vagrant's VMs
init() {
	[ -f ./tmp/ ] && sudo rm -r ./tmp/*; sudo runuser -l root -c 'echo vm.max_map_count = 262144 > /etc/sysctl.conf' && sudo sysctl -p ; \
	sudo apt install -y findutils ; \
	sudo docker network create --subnet 192.168.33.0/24 --gateway 192.168.33.1 --opt "com.docker.network.bridge.name"="igor" --opt "com.docker.network.bridge.enable_ip_masquerade"="true" --opt "com.docker.network.bridge.enable_icc"="true" igor ; \ 
	php ./manifests/docker-compose.php && sudo docker-compose up -d 2>&1 | tee -a ./logs/docker_run.log && \
	vagrant up --provision 2>&1 | tee -a ./logs/vagrant_up.log
}


## Restart Docker containers and boot Vagrant's VMs
restart() {
	php manifests/docker-compose.php && \
	sudo docker restart $(sudo docker ps -a | grep 'igor') 2>&1 | tee -a ./logs/docker_restart.log && \
	vagrant reload 2>&1 | tee -a ./logs/vagrant_reload.log
}

## Stop all containers and shutdown all VMs
stop() {
	sudo docker stop $(sudo docker ps -a | grep 'igor') 2>&1 | tee -a ./logs/docker_stop.log && \
	vagrant status | awk '/virtualbox running/{ print $1 }' | xargs vagrant halt 2>&1 | tee -a ./logs/vagrant_halt.log
}

## Pause all containers and VMs
pause() {
	sudo docker pause $(sudo docker ps -a | grep 'igor') && vagrant suspend
}

## Resume the pause
resume() {
	sudo docker unpause $(sudo docker ps -a | grep 'igor') && vagrant resume
}

## Display containers status and VMs status
status() {
	sudo docker ps -a && vagrant status 
}

## Create containers
dockercreate() {
	[ -f ./tmp/ ] && sudo rm -r ./tmp/*; sudo runuser -l root -c 'echo 262144 > /proc/sys/vm/max_map_count' && \
	php ./manifests/docker-compose.php && sudo chmod 644 ./my.cnf && sudo docker-compose up -d 2>&1 | tee -a ./logs/docker_create.log
}

## Destroy containers
dockerdestroy() {
	sudo docker stop $(sudo docker ps -a | grep 'igor'); sleep 3 && sudo docker rm $(sudo docker ps -a | grep 'igor')
}

case "$1" in

	init)
		echo "Creating environment..."
		init
		;;

	restart)
		echo "Restarting environment..."
		start
		;;
	
	stop)
		echo "Shutting down environment..."
		stop
		;;

	status)
		status
		;;

	dockercreate)
		echo "Creating containers..."
		dockercreate
		;;
	
	dockerdestroy)
		echo "Destroying containers... please use [init] or [dockercreate] to recreate"
		dockerdestroy
		;;

	*|help)
		echo $"Usage: $0 init|restart|stop|status|dockercreate|dockerdestroy"
		echo "See README for more complete description"
		exit 1
	
esac


