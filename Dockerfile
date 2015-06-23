FROM java:8-jre

WORKDIR /opt/fiteagle
ENV WILDFLY_ARGS -bmanagement=0.0.0.0
EXPOSE 8080 8443 9990 8787

RUN apt-get -y update && apt-get -y install git curl && apt-get -y clean

ADD . /opt/fiteagle/bootstrap

RUN (cd /opt/fiteagle/bootstrap; git status; git branch; rm -rf .git/*) || echo "DUMMY"

RUN /opt/fiteagle/bootstrap/fiteagle.sh deployBinaryOnly deployExtraBinary || echo "DUMMY"

#RUN cp /opt/fiteagle/bootstrap/resources/wildfly/standalone/configuration/standalone-fiteagle.xml /opt/fiteagle/server/wildfly/standalone/configuration/standalone-fiteagle.xml
RUN grep org.jboss.as.threads /opt/fiteagle/server/wildfly/standalone/configuration/standalone-fiteagle.xml || false

RUN curl -fsSSkL -o /opt/fiteagle/server/wildfly/standalone/deployments/omnlib.war "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=info.open-multinet&a=omnlib&v=0.0.1-SNAPSHOT&e=war"

ENTRYPOINT ["/opt/fiteagle/bootstrap/fiteagle.sh"]
CMD ["startJ2EEDebug"]
