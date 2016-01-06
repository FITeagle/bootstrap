#!/bin/sh

MYDOMAIN="demo.fiteagle.org"
KEYSTORE="./jetty-ssl.keystore"
PASSWORD="changeme"

MYCERT="/etc/letsencrypt/live/${MYDOMAIN}/cert.pem"
MYKEY="/etc/letsencrypt/live/${MYDOMAIN}/privkey.pem"
CACERT="/etc/letsencrypt/live/${MYDOMAIN}/chain.pem"
CHAIN="/etc/letsencrypt/live/${MYDOMAIN}/fullchain.pem"

##to see wat we are doing..
set +x

openssl pkcs12 -export -in ${MYCERT} -inkey ${MYKEY} -out mycert.p12 -name tomcat -passout pass:${PASSWORD}
keytool -importkeystore -srcstoretype PKCS12 -srckeystore mycert.p12 -srcstorepass ${PASSWORD} -srcalias tomcat -destkeystore ${KEYSTORE} -deststorepass ${PASSWORD} -destalias tomcat
keytool -importcert -alias root -keystore ${KEYSTORE} -trustcacerts -file ${CACERT} -storepass ${PASSWORD}
