FROM java:8-jre

WORKDIR /opt/fiteagle
ENV WILDFLY_ARGS -bmanagement=0.0.0.0
EXPOSE 8080 8443 9990 8787

RUN apt-get -y update && apt-get -y install git curl libaio1 && apt-get -y clean

RUN addgroup --gid 9999 app && adduser --uid 9999 --gid 9999 --disabled-password --gecos "Application" app && usermod -L app
RUN chown -R app:app /opt/fiteagle
USER app
#VOLUME /home/app/.fiteagle

#RUN (curl -fsSL https://raw.githubusercontent.com/FITeagle/bootstrap/master/fiteagle.sh | bash -s deployBinaryOnly) || echo "DUMMY"
#RUN /opt/fiteagle/bootstrap/fiteagle.sh deployExtraBinary; echo "DUMMY"
RUN (curl -fsSL https://raw.githubusercontent.com/FITeagle/bootstrap/master/fiteagle.sh | bash -s init deployFT2binary deployFT2sfaBinary) || echo "DUMMY"
#Fix for: WFLYCTL0056: Could not rename /opt/fiteagle/server/wildfly/standalone/configuration/standalone_xml_history/current to 
RUN rm -rf /opt/fiteagle/server/wildfly/standalone/configuration/standalone_xml_history

#RUN curl -fsSSkL -o /opt/fiteagle/server/wildfly/standalone/deployments/omnweb.war "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=info.open-multinet&a=omnweb&v=0.0.1-SNAPSHOT&e=war"
#RUN /opt/fiteagle/bootstrap/fiteagle.sh binDeploy-org.fiteagle:native:0.1-SNAPSHOT
RUN /opt/fiteagle/bootstrap/fiteagle.sh \
	binDeploy-org.fiteagle.adapters:tosca:0.1-SNAPSHOT \
	binDeploy-org.fiteagle.adapters:sshService:0.1-SNAPSHOT \
	binDeploy-org.fiteagle.adapters:openstack:0.1-SNAPSHOT \
	binDeploy-org.fiteagle.adapters:monitoring:0.1-SNAPSHOT

ENTRYPOINT ["/opt/fiteagle/bootstrap/fiteagle.sh"]
CMD ["startJ2EEDebug"]
