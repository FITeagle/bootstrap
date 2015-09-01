#!/bin/sh

# cron job for rebuilding the fiteagle Docker
# date +%F_%T --date=@$(cat /tmp/fiteagle_state_file.txt)


### config section #####
########################
_CONFIG_TRIGGER_FILE="/tmp/fiteagle_integration-ok.txt"

_CONFIG_LOCAL_BUILD_PATH=$(dirname `readlink -f $0`)/../docker/Dockerfile
_CONFIG_LOCAL_BUILD=0
_CONFIG_DOT_FITEAGLE="/root/.fiteagle"
_CONFIG_FAST_REBUILD_FROM_CACHE=0
_CONFIG_EXPOSE_PORT_ARGS="-p 8443:8443" #-p 8443:8443 -p 8080:8080 -p 9990:9990" #expose management interface on port 9990
_CONFIG_DOCKER_IMAGE_NAME="fiteagle2bin"

[ -f "./docker_watcher.config" ] && . ./docker_watcher.config

### dont change anything here! ###
##################################
DOCKER_BUILD_ARGS="--force-rm"
DOCKER_RUN_ARGS="${_CONFIG_EXPOSE_PORT_ARGS}"
DOCKER_RUN_VOLUMES="-v ${_CONFIG_DOT_FITEAGLE}:/home/app/.fiteagle"



######### ARGS ################
# -f  - force rebuild of image (docker build)
# -r  - recreate instance (docker run)
#############################

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
	[ -z $1 ] || rm -rf $1
}

run_docker_ft2() {
	runcmd "docker run -d --name=ft2 ${DOCKER_RUN_VOLUMES} ${DOCKER_RUN_ARGS} ${_CONFIG_DOCKER_IMAGE_NAME}" || die "docker failed!"
}

start_docker_ft2() {
	cp ${_CONFIG_DOT_FITEAGLE}/fiteagle.properties.bak ${_CONFIG_DOT_FITEAGLE}/fiteagle.properties
	runcmd "docker start ft2" || die "docker start failed!"
}

if [ "x$1" = "x-r" ] ; then
	echo "re-running ft2 docker"
	runcmd "docker stop ft2"
	runcmd "docker rm ft2"
	run_docker_ft2
	exit 0
fi

if [ -f ${_CONFIG_TRIGGER_FILE} ] || [ "x$1" = "x-f" ] ; then
	echo "Rebuild of fiteagle docker requested....."
	runcmd "docker tag ${_CONFIG_DOCKER_IMAGE_NAME}:latest ${_CONFIG_DOCKER_IMAGE_NAME}:current"
	runcmd "docker rmi ${_CONFIG_DOCKER_IMAGE_NAME}:latest"
	echo "downloading Dockerfile..."
	_docker_path=$(mktemp -d)
	if [ "${_CONFIG_LOCAL_BUILD}" = "1" ] ; then
		cp -v ${_CONFIG_LOCAL_BUILD_PATH} ${_docker_path}/Dockerfile_ || die "fiteagle-bootstrap/docker/Dockerfile not found!!"
		cp -v $(dirname ${_CONFIG_LOCAL_BUILD_PATH})/* ${_docker_path}
	else
		wget -q https://github.com/FITeagle/bootstrap/raw/master/docker/Dockerfile -O "${_docker_path}/Dockerfile_" || (echo "download failed!"; cleanup "${_docker_path}"; exit 1)
	fi
	if [ "${_CONFIG_FAST_REBUILD_FROM_CACHE}" = 1 ] ; then
		cp ${_docker_path}/Dockerfile_ ${_docker_path}/Dockerfile
	else
		sed "s/DUMMY/$(date +%s)/g" ${_docker_path}/Dockerfile_ >${_docker_path}/Dockerfile
	fi 
	echo "rebuild docker '${_CONFIG_DOCKER_IMAGE_NAME}'..."
	if runcmd "docker build --rm ${DOCKER_BUILD_ARGS} --tag=${_CONFIG_DOCKER_IMAGE_NAME} ${_docker_path}" ; then
		echo ok;
	else
		cleanup "${_docker_path}"
		die "docker build failed!"
	fi
	rm -rf "${_docker_path}"
	echo "shutdown old docker container 'ft2'..."
	runcmd "docker stop ft2"
	echo "remove old docker container 'ft2' and image '${_CONFIG_DOCKER_IMAGE_NAME}'..."
	runcmd "docker rm ft2"
	runcmd "docker rmi ${_CONFIG_DOCKER_IMAGE_NAME}:current"
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
