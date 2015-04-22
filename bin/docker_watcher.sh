#!/bin/sh

# cron job for rebuilding the fiteagle Docker
# date +%F_%T --date=@$(cat /tmp/fiteagle_state_file.txt)

_CONFIG_TRIGGER_FILE="/tmp/fiteagle_state_file.txt"
#ECHO="echo run "
ECHO=""

die() {
	echo $1;
	exit 1;
}

cleanup() {
	rm -rf $1
}

if [ -f ${_CONFIG_TRIGGER_FILE} ] || [ "x$1" = "x-f" ] ; then
	echo "downloading Dockerfile..."
	_docker_path=$(mktemp -d)
	wget -q https://github.com/FITeagle/bootstrap/raw/master/docker/Dockerfile -O "${_docker_path}/Dockerfile" || (echo "download failed!"; rm -rf "${_docker_path}"; exit 1)
	echo "rebuild docker 'fiteagle2bin'..."
	CMD="docker build --rm --no-cache --tag=fiteagle2bin ${_docker_path}"
	$ECHO $CMD || ( cleanup "${_docker_path}"; die "docker build failed!" )
	rm -rf "${_docker_path}"
	echo "shutdown old docker container 'ft2'..."
	CMD="docker stop ft2"
	$ECHO $CMD
	echo "remove old docker container 'ft2'..."
	CMD="docker rm ft2"
	$ECHO $CMD
	echo "starting new container 'ft2'..."
	CMD='docker run -d --name=ft2 -p 8443:8443 fiteagle2bin'
	$ECHO $CMD || die "docker failed!"
	if [ "x$1" != "x-f" ] ; then 
		echo "moving state_file..."
		CMD="mv ${_CONFIG_TRIGGER_FILE} ${_CONFIG_TRIGGER_FILE}.bak"
		$ECHO $CMD
	fi
else
	#echo "nothing to do"
	true
fi
