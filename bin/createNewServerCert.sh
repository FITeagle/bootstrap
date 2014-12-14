#!/usr/bin/env bash


DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CERT="${DIR}/createNewServerCert.cfg"
SIZE="2048"
URL="localhost"
DAYS="3650"
PWD="jetty6"
KEYSTORE="ssl"

openssl genrsa -out ${URL}.key ${SIZE}
openssl req -batch -new -out ${URL}.csr -key ${URL}.key -config ${CERT}
openssl req -text -noout -in ${URL}.csr
openssl x509 -req -days ${DAYS} -in ${URL}.csr -signkey ${URL}.key -out ${URL}.crt -extensions v3_req -extfile ${CERT}
openssl pkcs12 -export -name root -in ${URL}.crt -inkey ${URL}.key -out ${URL}.p12
keytool -importkeystore -destkeystore ${KEYSTORE}.keystore -srckeystore ${URL}.p12 -srcstoretype pkcs12 -alias root \
  -srcstorepass ${PWD} -deststorepass ${PWD} -destkeypass ${PWD} -srckeypass ${PWD}
 
#keytool -import -noprompt -storepass ${PWD} -alias root -keystore ${KEYSTORE}.keystore -file ${URL}.crt
#keytool -importkeystore -srckeystore openssl_ca3.p12 -srcstoretype PKCS12 -alias