FROM java:7-jre
WORKDIR /opt/fiteagle

RUN apt-get -y update && apt-get -y install git curl && apt-get -y clean && (curl -fsSL https://raw.githubusercontent.com/FITeagle/bootstrap/master/fiteagle.sh | bash -s deployBinaryOnly) || true

ENV WILDFLY_ARGS "-bmanagement=0.0.0.0"

EXPOSE 8080 8443 9990 8787

CMD ["/opt/fiteagle/bootstrap/fiteagle.sh","startJ2EEDebug"]