
##
# build with: sudo docker build --rm --force-rm --tag=fiteagle2test .
# run with: sudo docker run --rm -it -p 8443:8443 --name ft2test fiteagle2test
##

FROM java:8-jre

WORKDIR /opt/fiteagle
ENV WILDFLY_ARGS -bmanagement=0.0.0.0
EXPOSE 8080 8443 9990 8787

RUN apt-get -y update && apt-get -y install git curl screen && apt-get -y clean

COPY . /opt/fiteagle/bootstrap

RUN (cd /opt/fiteagle/bootstrap; git branch; rm -rf .git/*) || echo "DUMMY"

RUN (cd /opt/fiteagle/; git clone --depth=1 https://github.com/FITeagle/integration-test.git)
RUN /opt/fiteagle/bootstrap/fiteagle.sh deployBinaryOnly deployExtraBinary || echo "DUMMY"

RUN curl -fsSSkL -o /opt/fiteagle/server/wildfly/standalone/deployments/omnlib.war "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=info.open-multinet&a=omnlib&v=0.0.1-SNAPSHOT&e=war"

ENTRYPOINT ["/opt/fiteagle/bootstrap/fiteagle.sh"]
CMD ["startJ2EEDebug"]
