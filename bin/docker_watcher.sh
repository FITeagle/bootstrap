#!/bin/sh

# cron job for rebuilding the fiteagle Docker
# date +%F_%T --date=@$(cat /tmp/fiteagle_state_file.txt)

_CONFIG_TRIGGER_FILE="/tmp/fiteagle_state_file.txt"

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
	VOLUME="-v /root/.fiteagle:/root/.fiteagle"
	runcmd "docker run -d --name=ft2 $VOLUME -p 8443:8443 -p 8080:8080 fiteagle2bin" || die "docker failed!"
}

start_docker_ft2() {
	runcmd "docker start ft2" || die "docker start failed!"
}

if [ -f ${_CONFIG_TRIGGER_FILE} ] || [ "x$1" = "x-f" ] ; then
	echo "Rebuild of fiteagle docker requested....."
	runcmd "docker tag fiteagle2bin:latest fiteagle2bin:current"
	runcmd "docker rmi fiteagle2bin:latest"
	echo "downloading Dockerfile..."
	_docker_path=$(mktemp -d)
	wget -q https://github.com/FITeagle/bootstrap/raw/master/docker/Dockerfile -O "${_docker_path}/Dockerfile" || (echo "download failed!"; cleanup "${_docker_path}"; exit 1)
	echo "rebuild docker 'fiteagle2bin'..."
	runcmd "docker build --rm --no-cache --tag=fiteagle2bin ${_docker_path}" || ( cleanup "${_docker_path}"; die "docker build failed!" )
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
	#echo "nothing to do"
	if [ "$(docker inspect ft2 | jq '.[].State.Running==true')" = "false" ] ; then
		echo "ft2 docker is not running! restarting..."
		start_docker_ft2	
	fi
fi
