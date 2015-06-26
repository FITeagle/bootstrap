
##
# build with: 
#    sudo docker tag fiteagle2test fiteagle2test:old; sudo docker rmi fiteagle2test; sudo docker build --rm --force-rm --tag=fiteagle2test . && sudo docker rmi fiteagle2test:old
# run with: 
#    sudo docker run --rm -it -p 8443:8443 --name ft2test fiteagle2test
##

FROM java:8-jre

WORKDIR /opt/fiteagle
ENV WILDFLY_ARGS -bmanagement=0.0.0.0
EXPOSE 8080 8443 9990 8787

RUN apt-get -y update && apt-get -y install git curl && apt-get -y clean
RUN addgroup --gid 9999 app && adduser --uid 9999 --gid 9999 --disabled-password --gecos "Application" app && usermod -L app

COPY . /opt/fiteagle/bootstrap
RUN chown app:app -R /opt/fiteagle
USER app


RUN (cd /opt/fiteagle/bootstrap; git branch; rm -rf .git/*) || echo "DUMMY"
RUN (cd /opt/fiteagle/; git clone --depth=1 https://github.com/FITeagle/integration-test.git)
RUN (cd /opt/fiteagle/; ./bootstrap/fiteagle.sh deployFT2binary) && echo "DUMMY"

#RUN /opt/fiteagle/bootstrap/fiteagle.sh deployBinaryOnly deployExtraBinary || echo "DUMMY"
RUN curl -fsSSkL -o /opt/fiteagle/server/wildfly/standalone/deployments/omnlib.war "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=info.open-multinet&a=omnlib&v=0.0.1-SNAPSHOT&e=war"

ENTRYPOINT ["/opt/fiteagle/bootstrap/fiteagle.sh"]
CMD ["startJ2EEDebug"]
