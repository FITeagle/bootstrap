#!/usr/bin/env bash
#TODO: change screen command to screen -dmS session_name sh -c '/path/to/script.sh; exec bash' (to see errors)

_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_base="$(pwd)"
_resources_url="https://raw.githubusercontent.com/FITeagle/bootstrap/master/resources"
_osco_url="https://svnsrv.fokus.fraunhofer.de/svn/cc/ngni/OpenSDNCore/orchestrator/branches/wildfly-branch"
[[ "$OSTYPE" == "darwin"* ]] && _isOSX=1

_bootstrap_res_folder="${_base}/bootstrap/resources/sesame"
_sesame_workbench_url="http://search.maven.org/remotecontent?filepath=org/openrdf/sesame/sesame-http-workbench/2.8.0/sesame-http-workbench-2.8.0.war"
_sesame_server_url="http://search.maven.org/remotecontent?filepath=org/openrdf/sesame/sesame-http-server/2.8.0/sesame-http-server-2.8.0.war"

_ft2_install_war="org.fiteagle.north:sfa:0.1-SNAPSHOT \
	org.fiteagle.core:reservation:0.1-SNAPSHOT \
	org.fiteagle.core:bus:1.0-SNAPSHOT \
	org.fiteagle.core:orchestrator:0.1-SNAPSHOT \
	org.fiteagle.adapters:motor:0.1-SNAPSHOT \
	org.fiteagle.core:federationManager:0.1-SNAPSHOT \
	org.fiteagle:native:0.1-SNAPSHOT \
	org.fiteagle.core:resourceAdapterManager:0.1-SNAPSHOT \
	"
_ft2_install_jar="org.fiteagle.interactors:usermanagement:0.1-SNAPSHOT "
_ft2_install_extra_war="org.fiteagle.adapters:monitoring:0.1-SNAPSHOT \
	org.fiteagle.adapters:openstack:0.1-SNAPSHOT \
	"

_labwiki_folder="${_base}/server"
_labwiki_root="${_labwiki_folder}/labwiki"
_labwiki_git_url="https://github.com/mytestbed/labwiki.git"


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
_container_version="8.2.0.Final"
#_container_version="9.0.0.Beta2" # to be tested
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
_container_standalone_deployments="${_base}/server/wildfly/standalone/deployments/"
_container_standalone_config="${_base}/server/wildfly/bin/"

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
     echo "OK."
     return 0
   else
     echo >&2 "FAILED."
     return 1
   fi
}

function checkDirectory {
  echo -n " * Checking for '${1}' folder..."
  if [ -d ${2} ] >/dev/null 2>&1; then
     echo "OK."
     return 0
   else
     echo >&2 "FAILED (directory does not exist!)."
     return 1
   fi
}

function checkPackage {
  echo -n " * Checking for '$1'..."
  PKG_OK=$(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed")
  if [ $PKG_OK -eq 1 ]; then
     echo "OK"
     return 0
   else
     echo >&2 "FAILED."
     return 1
   fi
}

function checkRubyVersion {
  echo -n " * Checking ruby version..."
  VERSION_OK=$(command -v ruby 2>/dev/null | grep -c "1.9.3")
  if [ $VERSION_OK -eq 1 ]; then
     echo "OK"
     return 0
   else
     echo >&2 "FAILED. Run \"./bootstrap/fiteagle.sh installRuby\" to install the correct version"
     return 1
   fi
}

function buildDocker() {
	echo "(Re)building Docker image..."
	(checkBinary docker && checkBinary sudo) || (echo "please install missing binaries."; exit 1)
	_docker_path="${_base}/bootstrap/docker/"
	[[ -d "docker" && -e "docker/Dockerfile" ]] && _docker_path="./docker/"

	sudo docker build $1 --rm --no-cache --tag=fiteagle2bin ${_docker_path}
	echo "Done"
	echo 'Now start container (e.g. sudo docker run -d --name=ft2 -p 8443:8443 -p 9990:9990 --env WILDFLY_ARGS="-bmanagement 0.0.0.0" fiteagle2bin)'
}

function deploySesame() {
	echo "Downloading openrdf seasame & workbench..."
	curl -fsSSkL -o "${_base}/server/wildfly/standalone/deployments/openrdf-sesame.war" "${_sesame_server_url}"
	curl -fsSSkL -o "${_base}/server/wildfly/standalone/deployments/openrdf-workbench.war" "${_sesame_workbench_url}"

    if [ "${_isOSX}" ]; then
    	mkdir -p "${_base}/server/sesame/OpenRDF Sesame"
        sesame_db="${_base}/server/sesame/OpenRDF Sesame"
    else
       	mkdir -p "${_base}/server/sesame/openrdf-sesame"
        sesame_db="${_base}/server/sesame/openrdf-sesame"
  	fi
  	echo "Installing database..."
   	cp -r "${_bootstrap_res_folder}/openrdf-sesame/"* "${sesame_db}/"
}

function deployBinaryOnly() {
	[ ! -d ".git" ] || { echo "Do not bootstrap within a repository"; exit 4; }

	(checkBinary git && checkBinary java && checkBinary curl) || (echo "please install missing binaries."; exit 1)

    installFITeagleModule bootstrap

    installContainer
    configContainer
    echo "Dowanloading binary components from repository..."
    for component in ${_ft2_install_war}; do
    	${_base}/bootstrap/bin/nxfetch.sh -n -i ${component} -r fiteagle -p war -o ${_base}/server/wildfly/standalone/deployments
    done

    deploySesame
    echo "binary-only deployment DONE."
}

function deployExtraBinary() {
	[ ! -d ".git" ] || { echo "Do not bootstrap within a repository"; exit 4; }

	(checkBinary git && checkBinary java && checkBinary curl) || (echo "please install missing binaries."; exit 1)

    echo "Dowanloading binary components from repository..."
    for component in ${_ft2_install_extra_war}; do
    	${_base}/bootstrap/bin/nxfetch.sh -n -i ${component} -r fiteagle -p war -o ${_base}/server/wildfly/standalone/deployments
    done
    echo "extra binary-only deployment DONE."
}


function installXMPP() {
    echo "Downloading XMPP server..."
    mkdir -p "${_installer_folder}"
    [ -f "${_installer_folder}/${_xmpp_file}" ] || curl -fsSSkL -o "${_installer_folder}/${_xmpp_file}" "${_xmpp_url}"
    echo "Installing XMPP server..."
    mkdir -p "${_xmpp_folder}"
    tar xzf "${_installer_folder}/${_xmpp_file}" -C "${_xmpp_folder}"
}

function installLabwiki() {
    checkEnvironmentForLabwiki
    echo "Cloning Labwiki code..."
    mkdir -p "${_labwiki_folder}"
    cd "${_labwiki_folder}"
    git clone -q ${_labwiki_git_url}
    echo "Installing Labwiki..."
    cd ${_labwiki_root}
    bundle install --path vendor
    bundle exec rake post-install
    ${_labwiki_root}/install_plugin https://github.com/mytestbed/labwiki_experiment_plugin.git
    echo "Installation finished."
    echo "Save to ~/.bashrc: export LABWIKI_TOP=${_labwiki_root}"
}

function installRuby() {
    removeOldRuby
    echo "Installing ruby 1.9.3-p286 via rvm..."
    apt-get install -qq -y build-essential libxml2-dev libxslt-dev libssl-dev
    \curl -L https://get.rvm.io | bash -s stable
    source /etc/profile.d/rvm.sh
    rvm --quiet-curl install ruby-1.9.3-p286 --autolibs=4
    rvm use ruby-1.9.3-p286 --default
    gem install bundler
    gem install rake
    rvm current; ruby -v
    echo "Installation finished."
    echo "Save to ~/.bashrc: source /etc/profile.d/rvm.sh"
    echo "To use ruby, you need to add your user to the 'rvm' group: sudo adduser <username> rvm"
    echo "Finally, logout and login again."
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
  checkBinary screen; _error=$(($_error + $?))
  checkBinary svn; _error=$(($_error + $?))
	checkDirectory JAVA_HOME ${JAVA_HOME}; _error=$(($_error + $?))
  if [ "0" != "$_error" ]; then
    echo >&2 "FAILED. Please install the above mentioned binaries."
    exit 1
  fi
}

function checkEnvironmentForLabwiki {
  _error=0
  echo "Checking environment for Labwiki..."
  checkPackage libpq-dev; _error=$(($_error + $?))
  checkPackage libicu-dev; _error=$(($_error + $?))
  checkBinary ruby; _error=$(($_error + $?))
  checkRubyVersion; _error=$(($_error + $?))
  if [ "0" != "$_error" ]; then
    echo >&2 "FAILED. Please install the above mentioned binaries."
    exit 1
  fi
}

function removeOldRuby {
  echo "Removing old ruby versions..."
  apt-get -qq -y --purge remove ruby ruby1.8 ruby1.8-dev ruby1.9.3 ruby1.9.1 ruby1.9.1-dev
  rm -rf /usr/share/ruby-rvm /etc/rvmrc /etc/profile.d/rvm.sh
  apt-get -qq -y autoremove
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
    export OPENFIRE_CMD="${OPENFIRE_HOME}/bin/openfire"
    export OPENFIRE_LOG="${OPENFIRE_HOME}/logs/stdoutt.log"
    [ -f "${OPENFIRE_CMD}" ] || { echo "Please set OPENFIRE_HOME first "; exit 3; }
    ${OPENFIRE_CMD} start
    echo "Check logs at $OPENFIRE_LOG"
}

function stopXMPP() {
    echo "Stopping XMPP Server..."
    [ ! -z "${OPENFIRE_HOME}" ] || OPENFIRE_HOME="${_xmpp_root}"
    export OPENFIRE_CMD="${OPENFIRE_HOME}/bin/openfire"
    [ -f "${OPENFIRE_CMD}" ] || { echo "Please set OPENFIRE_HOME first "; exit 3; }
    ${OPENFIRE_CMD} stop
}

function startContainer() {
    echo "Starting J2EE Container..."
    [ ! -z "${WILDFLY_HOME}" ] || WILDFLY_HOME="${_container_root}"
    CMD="${WILDFLY_HOME}/bin/standalone.sh"
    RDF=" -Dinfo.aduna.platform.appdata.basedir=../sesame"
    [ -x "${CMD}" ] || { echo "Please set WILDFLY_HOME first "; exit 2; }
    cd "${WILDFLY_HOME}"
    screen -S wildfly -dm ${CMD}${RDF} -b 0.0.0.0 -c "${_container_config}" -Djava.security.egd=file:/dev/./urandom ${WILDFLY_ARGS}
    echo "Now running in background, to show it run:"
    echo "screen -R wildfly"
}

function startContainerDebug() {
    echo "Starting J2EE Container in debug mode (port: 8787)..."
    [ ! -z "${WILDFLY_HOME}" ] || WILDFLY_HOME="${_container_root}"
    CMD="${WILDFLY_HOME}/bin/standalone.sh"
    RDF=" -Dinfo.aduna.platform.appdata.basedir=../sesame"
    [ -x "${CMD}" ] || { echo "Please set WILDFLY_HOME first "; exit 2; }
    cd "${WILDFLY_HOME}"
    ${CMD}${RDF} --debug 8787 -b 0.0.0.0 -Djava.security.egd=file:/dev/./urandom -c "${_container_config}" ${WILDFLY_ARGS}
}

function stopContainer() {
    echo "Stopping J2EE Container..."
    [ ! -z "${WILDFLY_HOME}" ] || WILDFLY_HOME="${_container_root}"
    CMD="${WILDFLY_HOME}/bin/jboss-cli.sh"
    [ -x "${CMD}" ] || { echo "Please set WILDFLY_HOME first "; exit 2; }
    ${CMD} --connect command=:shutdown
}

function restartContainer() {
    stopContainer
    startContainer
}

function restartContainerDebug() {
    stopContainer
    startContainerDebug
}

function startLabwiki() {
    echo "Starting Labwiki Server..."
    [ ! -z "${LABWIKI_TOP}" ] || LABWIKI_TOP="${_labwiki_root}"
    CMD="${LABWIKI_TOP}/bin/labwiki"
    [ -x "${CMD}" ] || { echo "Please set LABWIKI_TOP first "; exit 2; }
    cd "${LABWIKI_TOP}"
    ${CMD} --lw-config etc/labwiki/first_test.yaml --lw-no-login start
}

function checkContainer {
    echo "Checking container..."
    isRunning="$(curl -s -m 2 http://localhost:8080 > /dev/null; echo $?)"
    if [ "${isRunning}" != "0" ]; then
      startContainer
    fi
}

function deployOSCO {
    echo "WARNING: this only works within the Fraunhofer FOKUS network. Press ENTER."
    read
    checkContainer
    echo "Getting OSCO..."
    svn checkout "${_osco_url}" "${_base}/osco"

    echo "Building OSCO..."
    cd "${_base}/osco"
    find . -iname "application-*.properties" -exec cp {} "${_container_root}/standalone/configuration" \;
    mvn clean install

    echo "Configuring container..."
    CMD="${_container_root}/bin/jboss-cli.sh"
    ${CMD} --connect command="data-source remove --name=opensdncore"
    ${CMD} --connect command="data-source add --name=opensdncore --connection-url=jdbc:h2:mem:opensdncore;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;MVCC=TRUE; --jndi-name=java:jboss/datasources/opensdncore --driver-name=h2 --user-name=neto --password=oten"
    ${CMD} --connect command="jms-topic remove --topic-address=adapterRequestTopic"
    ${CMD} --connect command="jms-topic add --topic-address=adapterRequestTopic --entries=topic/adapterRequestTopic,java:jboss/exported/jms/topic/adapterRequestTopic"
    ${CMD} --connect command="jms-topic remove --topic-address=adapterRequestQueue"
    ${CMD} --connect command="jms-queue add --queue-address=adapterRequestQueue --entries=queue/adapterRequestQueue,java:jboss/exported/jms/queue/adapterRequestQueue"

    echo "Starting OSCO..."
    cd "${_base}/osco"
    mvn wildfly:deploy

    echo "Now open http://localhost:8080/gui"
}

function deployFT1 {
    checkContainer
    installFITeagleModule ft1
    cd "${_base}/ft1" && mvn clean install -DskipTests && mvn wildfly:deploy -DskipTests
}

function deployFT2 {
    checkContainer

    installFITeagleModule api
    cd "${_base}/api" && mvn -DskipTests clean install

    installFITeagleModule core
    cd "${_base}/core" && mvn -DskipTests clean install wildfly:deploy

    installFITeagleModule native
    cd "${_base}/native" && mvn -DskipTests clean install wildfly:deploy

    installFITeagleModule adapters
    cd "${_base}/adapters/abstract" && mvn -DskipTests clean install
    cd "${_base}/adapters/sshService" && mvn -DskipTests clean install wildfly:deploy
}

function deployFT2sfa {
    installFITeagleModule sfa
    cd "${_base}/sfa" && mvn clean wildfly:deploy

    installFITeagleModule adapters
    cd "${_base}/adapters/motor" && mvn -DskipTests clean wildfly:deploy
}

function testFT2sfa {
    cd "${_base}/sfa" && ./src/test/bin/runJfed.sh
}

function bootstrap() {
    [ ! -d ".git" ] || { echo "Do not bootstrap within a repository"; exit 4; }
    checkEnvironment

    installFITeagleModule bootstrap

    #installXMPP
    #configXMPP

    installContainer
    configContainer

    deploySesame

    echo "Save to ~/.bashrc: export WILDFLY_HOME=${_container_root}"
    echo "Save to ~/.bashrc: export OPENFIRE_HOME=${_xmpp_root}"
    echo ""
    echo "Now play around with ./bootstrap/fiteagle.sh"
    ./bootstrap/fiteagle.sh
}

function usage() {
  echo "Usage: $(basename $0) <command>";
  echo "  init               - Download and configure all required binaries";
  echo "  startJ2EE          - Start the J2EE service (WildFly)";
  echo "  startJ2EEDebug     - Start the J2EE service with enabled debug port";
  echo "  restartJ2EEDebug   - Restart the J2EE service with enabled debug port";
  echo "  deployFT1          - Deploy FITeagle 1";
  echo "  deployFT2          - Deploy FITeagle 2 (core modules)";
  echo "  deployFT2sfa       - Deploy FITeagle 2 SFA module and core adapters";
  echo "  testFT2sfa         - Test FITeagle 2 SFA module and core adapters";
  echo "  deployOSCO         - Deploy OpenSDNCore Orchestrator";
  echo "  stopJ2EE           - Stop the J2EE service";
  echo "  restartJ2EE        - Restart the J2EE service";
  echo "  startXMPP          - Start the XMPP service (needed e.g. for the IEEE Intercloud";
  echo "  stopXMPP           - Stop the XMPP Service";
  echo "  installLabwiki     - Install LabWiki (OMF client and GUI)";
  echo "  startLabwiki       - Start LabWiki";
  echo "  installRuby        - Install ruby";
  echo "  deploySesame       - Install and configure OpenRDF/Sesame";
  echo "  deployBinaryOnly   - Deploy binary only version of FT2 and WildFly"
  echo "  buildDocker"
  exit 1;
}

[ "${#}" -eq 0 ] && usage

for arg in "$@"; do
    [ "${arg}" = "bootstrap" ] && bootstrap
    [ "${arg}" = "init" ] && bootstrap
    [ "${arg}" = "startXMPP" ] && startXMPP
    [ "${arg}" = "stopXMPP" ] && stopXMPP
    [ "${arg}" = "startSPARQL" ] && startSPARQL
    [ "${arg}" = "startSPARQLPersist" ] && startSPARQLPersist
    [ "${arg}" = "stopSPARQL" ] && stopSPARQL
    [ "${arg}" = "startJ2EE" ] && startContainer
    [ "${arg}" = "startJ2EEDebug" ] && startContainerDebug
    [ "${arg}" = "restartJ2EEDebug" ] && restartContainerDebug
    [ "${arg}" = "stopJ2EE" ] && stopContainer
    [ "${arg}" = "restartJ2EE" ] && restartContainer
    [ "${arg}" = "deployFT2" ] && deployFT2
    [ "${arg}" = "deployFT2sfa" ] && deployFT2sfa
    [ "${arg}" = "testFT2sfa" ] && testFT2sfa
    [ "${arg}" = "deployFT1" ] && deployFT1
    [ "${arg}" = "deployOSCO" ] && deployOSCO
    [ "${arg}" = "installLabwiki" ] && installLabwiki
    [ "${arg}" = "installRuby" ] && installRuby
    [ "${arg}" = "startLabwiki" ] && startLabwiki
    [ "${arg}" = "deploySesame" ] && deploySesame
    [ "${arg}" = "deployBinaryOnly" ] && deployBinaryOnly
    [ "${arg}" = "deployExtraBinary" ] && deployExtraBinary
    [ "${arg}" = "buildDocker" ] && buildDocker
    ([ "${arg}" = "help" ] || [ "${arg}" = "?" ]) && usage
done

exit 0
