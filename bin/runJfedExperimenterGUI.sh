#!/usr/bin/env bash

_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${_DIR}

_VERSION="233"
_FILE="jFed-experimenter-GUI.jar"
_URL="http://jfed.iminds.be/releases/develop/${_VERSION}/jar/${_FILE}"
_PATH="${_DIR}/jfed_experimenter"

if [ ! -f "${_PATH}/${_FILE}" ]; then
  echo "downloading $_URL"
  mkdir -p "${_PATH}"
  curl -L "${_URL}" -o "${_PATH}/${_FILE}"
fi

# fixme: need better test
if [ ! -f "${HOME}/.jFed/authorities.xml" ]; then
  mkdir -p "${HOME}/.jFed/"
  # fixme: ugly
  cp ${_DIR}/../../integration-test/conf/cli.authorities "${HOME}/.jFed/authorities.xml"
fi

java \
  -jar "${_PATH}/${_FILE}"

RET=$?

exit $RET
