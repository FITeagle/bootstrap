#!/bin/sh

# cron job for rebuilding the fiteagle Docker
# date +%F_%T --date=@$(cat /tmp/fiteagle_state_file.txt)


### config section #####
########################
_CONFIG_TRIGGER_FILE="/tmp/fiteagle_state_file.txt"
_CONFIG_LOCAL_BUILD_PATH=$(dirname `readlink -f $0`)/../docker/Dockerfile
_CONFIG_LOCAL_BUILD=1
_CONFIG_DOT_FITEAGLE="/opt/fiteagle/dot_fiteagle"
#_CONFIG_FAST_REBUILD_FROM_CACHE=1

### advanced config section ####
################################
#DOCKER_BUILD_ARGS="--no-cache --force-rm" #dont use the cache for building the image
DOCKER_BUILD_ARGS="--force-rm"
#DOCKER_RUN_ARGS="-p 8443:8443 -p 8080:8080 -p 9990:9990" #expose management interface on port 9990
DOCKER_RUN_ARGS="-p 443:8443 -p 8080:8080"
DOCKER_RUN_VOLUMES="-v ${_CONFIG_DOT_FITEAGLE}:/root/.fiteagle"

runcmd() {
	echo "cmd: $1"
	$1
}

die() {
	echo $1;
	exit 1;
}

cleanup() {
	#TODO: check for path not empty
	rm -rf $1
}

run_docker_ft2() {
	runcmd "docker run -d --name=ft2 ${DOCKER_RUN_VOLUMES} ${DOCKER_RUN_ARGS} fiteagle2bin" || die "docker failed!"
}

start_docker_ft2() {
	cp ${_CONFIG_DOT_FITEAGLE}/fiteagle.properties.bak ${_CONFIG_DOT_FITEAGLE}/fiteagle.properties
	runcmd "docker start ft2" || die "docker start failed!"
}

if [ "x$1" = "x-r" ] ; then
	echo "Restarting ft2 docker"
	runcmd "docker stop ft2"
	start_docker_ft2
	exit 0
fi

if [ -f ${_CONFIG_TRIGGER_FILE} ] || [ "x$1" = "x-f" ] ; then
	echo "Rebuild of fiteagle docker requested....."
	runcmd "docker tag fiteagle2bin:latest fiteagle2bin:current"
	runcmd "docker rmi fiteagle2bin:latest"
	echo "downloading Dockerfile..."
	_docker_path=$(mktemp -d)
	if [ "${_CONFIG_LOCAL_BUILD}" = "1" ] ; then
		cp ${_CONFIG_LOCAL_BUILD_PATH} ${_docker_path}/Dockerfile_ || die "fiteagle-bootstrap/docker/Dockerfile not found!!"
	else
		wget -q https://github.com/FITeagle/bootstrap/raw/master/docker/Dockerfile -O "${_docker_path}/Dockerfile_" || (echo "download failed!"; cleanup "${_docker_path}"; exit 1)
	fi
	if [ "${_CONFIG_FAST_REBUILD_FROM_CACHE}" = 1 ] ; then
		cp ${_docker_path}/Dockerfile_ ${_docker_path}/Dockerfile
	else
		sed "s/DUMMY/$(date +%s)/g" ${_docker_path}/Dockerfile_ >${_docker_path}/Dockerfile
	fi 
	echo "rebuild docker 'fiteagle2bin'..."
	if runcmd "docker build --rm ${DOCKER_BUILD_ARGS} --tag=fiteagle2bin ${_docker_path}" ; then
		echo ok;
	else
		cleanup "${_docker_path}"
		die "docker build failed!"
	fi
	rm -rf "${_docker_path}"
	echo "shutdown old docker container 'ft2'..."
	runcmd "docker stop ft2"
	echo "remove old docker container 'ft2' and image 'fiteagle2bin'..."
	runcmd "docker rm ft2"
	runcmd "docker rmi fiteagle2bin:current"
	echo "starting new container 'ft2'..."
	run_docker_ft2
	if [ "x$1" != "x-f" ] ; then 
		echo "moving state_file..."
		runcmd "mv ${_CONFIG_TRIGGER_FILE} ${_CONFIG_TRIGGER_FILE}.bak"
	fi
else
	if [ "$(docker inspect ft2 | jq '.[].State.Running==true')" = "false" ] ; then
		echo "ft2 docker is not running! restarting..."
		start_docker_ft2	
	fi
fi
