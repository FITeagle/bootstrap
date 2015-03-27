#!/bin/bash
#
# Authors:
#   * sonatype-infra
#   * Bjoern Riemer
# Based on: https://gist.github.com/sonatype-infra/777712

# Argument = -h -v -i groupId:artifactId:version -c classifier -p packaging -r repository -d dlpath

#shopt -o -s xtrace

# Define Nexus Configuration
NEXUS_BASE=http://services.av.tu-berlin.de:8081/nexus
REST_PATH=/service/local
ART_REDIR=/artifact/maven/redirect

usage()
{
cat <<EOF

usage: $0 options

This script will fetch an artifact from a Nexus server using the Nexus REST redirect service.

OPTIONS:
   -h      Show this message
   -v      Verbose
   -i      GAV coordinate groupId:artifactId:version
   -c      Artifact Classifier
   -p      Artifact Packaging
   -r      Repository
   -o      Destination folder

EOF
}

# Read in Complete Set of Coordinates from the Command Line
GROUP_ID="org.fiteagle"
ARTIFACT_ID=
VERSION="0.1-SNAPSHOT"
CLASSIFIER=""
PACKAGING="war"
REPO="fiteagle"
VERBOSE=0
DLPATH="."

while getopts "hvi:c:p:r:o:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         i)
	     OIFS=$IFS
             IFS=":"
	     GAV_COORD=( $OPTARG )
	     GROUP_ID=${GAV_COORD[0]}
             ARTIFACT_ID=${GAV_COORD[1]}
             VERSION=${GAV_COORD[2]}	     
	     IFS=$OIFS
             ;;
         c)
             CLASSIFIER=$OPTARG
             ;;
         p)
             PACKAGING=$OPTARG
             ;;
         v)
             VERBOSE=1
             ;;
         r)
             REPO=$OPTARG
             ;;
         o)
             DLPATH=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $GROUP_ID ]] || [[ -z $ARTIFACT_ID ]] || [[ -z $VERSION ]]
then
     echo "BAD ARGUMENTS: Either groupId, artifactId, or version was not supplied" >&2
     usage
     exit 1
fi

# Define default values for optional components

# Construct the base URL
REDIRECT_URL=${NEXUS_BASE}${REST_PATH}${ART_REDIR}

# Generate the list of parameters
PARAM_KEYS=( g a v r p c )
PARAM_VALUES=( $GROUP_ID $ARTIFACT_ID $VERSION $REPO $PACKAGING $CLASSIFIER )
PARAMS=""
for index in ${!PARAM_KEYS[*]} 
do
  if [[ ${PARAM_VALUES[$index]} != "" ]]
  then
    PARAMS="${PARAMS}${PARAM_KEYS[$index]}=${PARAM_VALUES[$index]}&"
  fi
done

REDIRECT_URL="${REDIRECT_URL}?${PARAMS}"

echo "Fetching Artifact from $REDIRECT_URL..." >&2
curl -o "${DLPATH}/${ARTIFACT_ID}-${VERSION}.war" -sS -L ${REDIRECT_URL}