#!/bin/sh

# /etc/letsencrypt/live/demo.fiteagle.org
# /etc/letsencrypt/live/demo.fiteagle.org/fullchain.pem
# /etc/letsencrypt/live/demo.fiteagle.org/chain.pem
# /etc/letsencrypt/live/demo.fiteagle.org/privkey.pem
# /etc/letsencrypt/live/demo.fiteagle.org/cert.pem

MYCERT="/etc/letsencrypt/live/demo.fiteagle.org/cert.pem"
MYKEY="/etc/letsencrypt/live/demo.fiteagle.org/privkey.pem"
CACERT="/etc/letsencrypt/live/demo.fiteagle.org/chain.pem"
CHAIN="/etc/letsencrypt/live/demo.fiteagle.org/fullchain.pem"
KEYSTORE="./jetty-ssl.keystore"
PASSWORD="changeme"

set +x

openssl pkcs12 -export -in ${MYCERT} -inkey ${MYKEY} -out mycert.p12 -name tomcat -passout pass:${PASSWORD}
keytool -importkeystore -srcstoretype PKCS12 -srckeystore mycert.p12 -srcstorepass ${PASSWORD} -srcalias tomcat -destkeystore ${KEYSTORE} -deststorepass ${PASSWORD} -destalias tomcat
keytool -importcert -alias root -keystore ${KEYSTORE} -trustcacerts -file ${CACERT} -storepass ${PASSWORD}
