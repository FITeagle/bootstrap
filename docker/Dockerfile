FROM java:7
WORKDIR /opt/fiteagle

RUN apt-get -y update && apt-get -y install git curl && apt-get -y clean && (curl -fsSL https://raw.githubusercontent.com/FITeagle/bootstrap/master/fiteagle.sh | bash -s deployBinaryOnly) || true
#ADD fiteagle.sh /tmp/fiteagle.sh
#RUN apt-get -y update && apt-get -y install git curl && apt-get -y clean && (cat /tmp/fiteagle.sh | bash -s deployBinaryOnly) || true
#RUN rm -rf /opt/fiteagle/server/wildfly/standalone/configuration/standalone_xml_history/current

ENV WILDFLY_ARGS "-bmanagement=0.0.0.0"

EXPOSE 8080 8443 9990 8787

#ADD standalone-fiteagle.xml /opt/fiteagle/server/wildfly/standalone/configuration/standalone.xml

CMD ["/opt/fiteagle/bootstrap/fiteagle.sh","startJ2EEDebug"]
