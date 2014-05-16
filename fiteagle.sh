#!/usr/bin/env bash

_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_base="$(pwd)"
_resources_url="https://raw.githubusercontent.com/FITeagle/bootstrap/master/resources"

_sparql_type="jena-fuseki"
_sparql_version="1.0.1"
_sparql_versiontype="distribution"
_sparql_extractfolder="${_sparql_type}-${_sparql_version}"
_sparql_file="${_sparql_type}-${_sparql_version}-${_sparql_versiontype}.zip"
_sparql_folder="${_base}/server"
_sparql_url="http://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist//jena/binaries/${_sparql_file}"
_sparql_config="config.ttl"
_sparql_config_path="conf"
_sparql_config_url="${_resources_url}/${_sparql_type}/${_sparql_config_path}/${_sparql_config}"

_xmpp_type="openfire"
_xmpp_version="3_8_2"
#_xmpp_version="3_9_1"
_xmpp_file="${_xmpp_type}_${_xmpp_version}.tar"
_xmpp_folder="${_base}/server"
_xmpp_url="http://download.igniterealtime.org/${_xmpp_type}/${_xmpp_file}.gz"
_xmpp_config="openfire.xml"
_xmpp_config_path="conf"
_xmpp_config_url="${_resources_url}/${_xmpp_type}/${_xmpp_config_path}/${_xmpp_config}"
_xmpp_db_props="openfire.properties"
_xmpp_db_props_path="embedded-db"
_xmpp_db_props_url="${_resources_url}/${_xmpp_type}/${_xmpp_db_props_path}/${_xmpp_db_props}"
_xmpp_db_values="openfire.script"
_xmpp_db_values_path="embedded-db"
_xmpp_db_values_url="${_resources_url}/${_xmpp_type}/${_xmpp_db_values_path}/${_xmpp_db_values}"
_xmpp_keystore="keystore"
_xmpp_keystore_path="resources/security"
_xmpp_keystore_url="${_resources_url}/${_xmpp_type}/${_xmpp_keystore_path}/${_xmpp_keystore}"
_xmpp_root="${_xmpp_folder}/${_xmpp_type}"

_container_type="wildfly"
_container_version="8.0.0.Final"
_container_name="${_container_type}-${_container_version}"
_container_file="${_container_name}.zip"
_container_url="http://download.jboss.org/${_container_type}/${_container_version}/${_container_file}"
_container_folder="${_base}/server"
_container_config="standalone-fiteagle.xml"
_container_config_url="${_resources_url}/wildfly/standalone/configuration/standalone-fiteagle.xml"
_container_root="${_container_folder}/${_container_type}"
_container_keystore="jetty-ssl.keystore"
_container_keystore_url="${_resources_url}/wildfly/standalone/configuration/jetty-ssl.keystore"
_container_truststore="jetty-ssl.truststore"
_container_truststore_url="${_resources_url}/wildfly/standalone/configuration/jetty-ssl.truststore"
_container_index="index.html"
_container_index_url="${_resources_url}/wildfly/welcome-content/${_container_index}"
_container_css="fiteagle.css"
_container_css_url="${_resources_url}/wildfly/welcome-content/${_container_css}"
_container_bg="fiteagle_bg.jpg"
_container_bg_url="${_resources_url}/wildfly/welcome-content/${_container_bg}"
_container_logo="fiteagle_logo.png"
_container_logo_url="${_resources_url}/wildfly/welcome-content/${_container_logo}"

_installer_folder="${_base}/tmp"
_logfile="${_installer_folder}/log"

_wildfly_admin_user="admin"
_wildfly_admin_pwd="admin"
_wildfly_app_user="fiteagle"
_wildfly_app_pwd="fiteagle"
_wildfly_app_group="guest"

function checkBinary {
  echo -n " * Checking for '$1'..."
  if command -v $1 >/dev/null 2>&1; then
     echo "OK"
     return 0
   else
     echo >&2 "FAILED."
     return 1
   fi
}

function installSPARQL() {
    echo "Downloading SPARQL server..."
    mkdir -p "${_installer_folder}"
    [ -f "${_installer_folder}/${_sparql_file}" ] || curl -fsSSkL -o "${_installer_folder}/${_sparql_file}" "${_sparql_url}"
    echo "Installing SPARQL server..."
    mkdir -p "${_sparql_folder}"
    unzip -qu "${_installer_folder}/${_sparql_file}" -d "${_sparql_folder}"
    mv "${_sparql_folder}/${_sparql_extractfolder}" "${_sparql_folder}/${_sparql_type}"
}

function installXMPP() {
    echo "Downloading XMPP server..."
    mkdir -p "${_installer_folder}"
    [ -f "${_installer_folder}/${_xmpp_file}" ] || curl -fsSSkL -o "${_installer_folder}/${_xmpp_file}" "${_xmpp_url}"
    echo "Installing XMPP server..."
    mkdir -p "${_xmpp_folder}"
    tar xzf "${_installer_folder}/${_xmpp_file}" -C "${_xmpp_folder}"
}

function configXMPP() {
    echo "Configuring XMPP server..."
    curl -fsSSkL -o "${_installer_folder}/${_xmpp_config}" "${_xmpp_config_url}"
    curl -fsSSkL -o "${_installer_folder}/${_xmpp_db_props}" "${_xmpp_db_props_url}"
    curl -fsSSkL -o "${_installer_folder}/${_xmpp_db_values}" "${_xmpp_db_values_url}"
    curl -fsSSkL -o "${_installer_folder}/${_xmpp_keystore}" "${_xmpp_keystore_url}"
    mkdir -p "${_xmpp_root}/${_xmpp_config_path}"
    cp "${_installer_folder}/${_xmpp_config}" "${_xmpp_root}/${_xmpp_config_path}"
    mkdir -p "${_xmpp_root}/${_xmpp_db_props_path}"
    cp "${_installer_folder}/${_xmpp_db_props}" "${_xmpp_root}/${_xmpp_db_props_path}"
    mkdir -p "${_xmpp_root}/${_xmpp_db_values_path}"
    cp "${_installer_folder}/${_xmpp_db_values}" "${_xmpp_root}/${_xmpp_db_values_path}"
    mkdir -p "${_xmpp_root}/${_xmpp_keystore_path}"
    cp "${_installer_folder}/${_xmpp_keystore}" "${_xmpp_root}/${_xmpp_keystore_path}"
}

function installContainer() {
    echo "Downloading container..."
    mkdir -p "${_installer_folder}"
    curl -C - -fsSSkL -o "${_installer_folder}/${_container_file}" "${_container_url}"
    echo "Installing container..."
    mkdir -p "${_installer_folder}"
    unzip -qu "${_installer_folder}/${_container_file}" -d "${_container_folder}"
    rm -r "${_container_root}" 2>/dev/null
    mv "${_container_folder}/${_container_name}" "${_container_root}"
}

function configContainer() {
    echo "Configuring container..."
    curl -fsSSkL -o "${_installer_folder}/${_container_config}" "${_container_config_url}"
    cp "${_installer_folder}/${_container_config}" "${_container_root}/standalone/configuration"
    curl -fsSSkL -o "${_installer_folder}/${_container_keystore}" "${_container_keystore_url}"
    cp "${_installer_folder}/${_container_keystore}" "${_container_root}/standalone/configuration"
    curl -fsSSkL -o "${_installer_folder}/${_container_truststore}" "${_container_truststore_url}"
    cp "${_installer_folder}/${_container_truststore}" "${_container_root}/standalone/configuration"
    (
    cd "${_container_root}"
    ./bin/add-user.sh -s -u "${_wildfly_admin_user}" -p "${_wildfly_admin_pwd}"
    ./bin/add-user.sh -s -a -g "${_wildfly_app_group}" -u "${_wildfly_app_user}" -p "${_wildfly_app_pwd}"
    )
    curl -fsSSkL -o "${_installer_folder}/${_container_index}" "${_container_index_url}"
    cp "${_installer_folder}/${_container_index}" "${_container_root}/welcome-content/"
    curl -fsSSkL -o "${_installer_folder}/${_container_css}" "${_container_css_url}"
    cp "${_installer_folder}/${_container_css}" "${_container_root}/welcome-content/"
    curl -fsSSkL -o "${_installer_folder}/${_container_bg}" "${_container_bg_url}"
    cp "${_installer_folder}/${_container_bg}" "${_container_root}/welcome-content/"
    curl -fsSSkL -o "${_installer_folder}/${_container_logo}" "${_container_logo_url}"
    cp "${_installer_folder}/${_container_logo}" "${_container_root}/welcome-content/"
}

function checkEnvironment {
  _error=0
  echo "Checking environment..."
  checkBinary java; _error=$(($_error + $?))
  checkBinary javac; _error=$(($_error + $?))
  checkBinary mvn; _error=$(($_error + $?))
  checkBinary git; _error=$(($_error + $?))
  checkBinary curl; _error=$(($_error + $?))
  checkBinary unzip; _error=$(($_error + $?))
  if [ "0" != "$_error" ]; then
    echo >&2 "FAILED. Please install the above mentioned binaries."
    exit 1
  fi
}

function installFITeagleModule {
  repo="$1"
  _src_folder="${_base}/${repo}"
  git_url="https://github.com/FITeagle/${repo}.git"

  if [ -d "${_src_folder}/.git" ]; then
    echo -n "Updating FITeagle ${repo} sources..."
    (cd "${_src_folder}" && git pull -q)
  else
    echo -n "Getting FITeagle ${repo} sources..."
    git clone -q --recursive --depth 1 ${git_url} ${_src_folder}
  fi
  
  echo "OK"
}

function startXMPP() {
    echo "Starting XMPP Server..."
    [ ! -z "${OPENFIRE_HOME}" ] || OPENFIRE_HOME="${_xmpp_root}"
    export OPENFIRE_LIB="${OPENFIRE_HOME}/lib"
    export OPENFIRE_OPTS="-Xmx256m -DopenfireHome=${OPENFIRE_HOME} -Dopenfire.lib.dir=${OPENFIRE_LIB}"
    export OPENFIRE_JAR="${OPENFIRE_LIB}/startup.jar"
    export OPENFIRE_ARGS="-server ${OPENFIRE_OPTS} -classpath ${OPENFIRE_JAR} -jar ${OPENFIRE_JAR}"
    [ -f "${OPENFIRE_JAR}" ] || { echo "Please set OPENFIRE_HOME first "; exit 3; }
    java $OPENFIRE_ARGS
}

function startContainer() {
    echo "Starting J2EE Container..."
    [ ! -z "${WILDFLY_HOME}" ] || WILDFLY_HOME="${_container_root}"
    CMD="${WILDFLY_HOME}/bin/standalone.sh"
    [ -x "${CMD}" ] || { echo "Please set WILDFLY_HOME first "; exit 2; }
    cd "${WILDFLY_HOME}"
    ${CMD} -b 0.0.0.0 -c "${_container_config}"
}

function startSPARQL() {
    echo "Starting SPARQL Server..."
    cd "${_sparql_folder}/${_sparql_type}"
    sh ./fuseki-server -config "${_sparql_config}"
}

function deployCore {
    cd "${_base}/api" && mvn clean install
    cd "${_base}/core" && mvn clean wildfly:deploy
    cd "${_base}/native" && mvn clean wildfly:deploy
}

function bootstrap() {
    [ ! -d ".git" ] || { echo "Do not bootstrap within a repository"; exit 4; }
    checkEnvironment

    installFITeagleModule bootstrap
    installFITeagleModule api
    installFITeagleModule core
    installFITeagleModule native    
    
    installXMPP
    configXMPP
    
    installContainer
    configContainer
    
    installSPARQL
    # configSPARQL

    echo "Save to ~/.bashrc: export WILDFLY_HOME=${_container_root}"
    echo "Save to ~/.bashrc: export OPENFIRE_HOME=${_xmpp_root}"
    echo "Now run: ./bootstrap/fiteagle.sh"
}

[ "${0}" == "bootstrap" ] && { bootstrap; exit 0; }
[ "${#}" -eq 1 ] || { echo "Usage: $(basename $0) bootstrap | startXMPP | startJ2EE | startSPARQL | deployCore"; exit 1; }

for arg in "$@"; do
    [ "${arg}" = "bootstrap" ] && bootstrap
    [ "${arg}" = "startXMPP" ] && startXMPP
    [ "${arg}" = "startSPARQL" ] && startSPARQL
    [ "${arg}" = "startJ2EE" ] && startContainer
    [ "${arg}" = "deployCore" ] && deployCore
done
