#!/usr/bin/env bash
#set -x

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
EXTFILE="${DIR}/createNewUserCertLocal.conf"
PASSWD="jetty6"
KEYSTORE="ssl"

U_USERNAME="testuser"
U_PASSWORD="testing1"
U_MAIL="test@example.org"
U_DAYS="365"
U_SIZE="2048"

E="echo"

extractKeyFromKeystore() {
	keytool -importkeystore -srckeystore ${KEYSTORE}.keystore -destkeystore ${KEYSTORE}.p12 -deststoretype PKCS12 -srcalias root -deststorepass ${PASSWD} -destkeypass ${PASSWD} -srcstorepass ${PASSWD}
	#Export certificate.
	#openssl pkcs12 -in keystore.p12  -nokeys -out cert.pem
	##Export unencrypted private key.
	#openssl pkcs12 -in ${KEYSTORE}.p12  -nodes -nocerts -out ${KEYSTORE}.pem
}

generateUserCert(){
	#replace username in template
	sed "s/%%USERNAME%%/${U_USERNAME}/g" ${EXTFILE} >createNewUserCertLocal_${U_USERNAME}.conf

	if [ -f "${U_USERNAME}.key" ]; then
		echo "using exsisting key ${U_USERNAME}.key"
	else
		openssl genrsa -des -passout pass:${U_PASSWORD} -out ${U_USERNAME}.key ${U_SIZE}
	fi
	##create the CSR
	openssl req -batch -new -passin pass:${U_PASSWORD} -out ${U_USERNAME}.csr -key ${U_USERNAME}.key -config createNewUserCertLocal_${U_USERNAME}.conf && \
	##print the CSR
	openssl req -text -noout -in ${U_USERNAME}.csr && \
	##sign the CSR
	openssl x509 -req -days ${U_DAYS} -in ${U_USERNAME}.csr -keyform PKCS12 -passin pass:${PASSWD} -signkey ${KEYSTORE}.p12 -out ${U_USERNAME}.crt -extensions v3_req -extfile createNewUserCertLocal_${U_USERNAME}.conf
	## print cert
	openssl x509 -in ${U_USERNAME}.crt -noout -text
	## combine cert & key
	cat ${U_USERNAME}.key ${U_USERNAME}.crt > ${U_USERNAME}.pem
}

foo_from_server(){
	DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
	CERT="${DIR}/createNewServerCert.cfg"
	SIZE="2048"
	URL="localhost"
	DAYS="3650"
	PWD="jetty6"
	KEYSTORE="ssl"

	openssl genrsa -out ${URL}.key ${SIZE}
	openssl req -batch -new -out ${URL}.csr -key ${URL}.key -config createNewUserCertLocal_${U_USERNAME}.conf
	openssl req -text -noout -in ${URL}.csr
	openssl x509 -req -days ${DAYS} -in ${URL}.csr -signkey ${URL}.key -out ${URL}.crt -extensions v3_req -extfile createNewUserCertLocal_${U_USERNAME}.conf
	openssl pkcs12 -export -name root -in ${URL}.crt -inkey ${URL}.key -out ${URL}.p12
}

if [ ! -f "${KEYSTORE}.p12" ]; then
	echo "${KEYSTORE}.p12 missing!"
	echo "trying to extract from java keystore..."
	extractKeyFromKeystore
fi

if [ -f "${KEYSTORE}.p12" ]; then
	generateUserCert
fi

# openssl x509 -in cli.pem -noout -text
# Certificate:
#     Data:
#         Version: 3 (0x2)
#         Serial Number:
#              (Negative)67:...:24
#     Signature Algorithm: sha1WithRSAEncryption
#         Issuer: C=DE, ST=Berlin, L=Berlin, O=TUB, OU=AV, CN=testCA
#         Validity
#             Not Before: Dec 17 09:28:39 2014 GMT
#             Not After : Dec 16 23:28:39 2015 GMT
#         Subject: CN=testuser@localhost
#         Subject Public Key Info:
#             Public Key Algorithm: rsaEncryption
#                 Public-Key: (2048 bit)
#                 Modulus:
#                     00:...:e9:
#                 Exponent: 65537 (0x10001)
#         X509v3 extensions:
#             X509v3 Basic Constraints: critical
#                 CA:FALSE
#             X509v3 Subject Alternative Name: 
#                 URI:urn:publicid:IDN+localhost+user+testuser
#     Signature Algorithm: sha1WithRSAEncryption
#          aa:....:47:
# -----------------
#         Requested Extensions:
#             X509v3 Subject Alternative Name: 
#                 URI:urn:publicid:IDN+localhost+user+testuser
#             X509v3 Basic Constraints: 
#                 CA:FALSE
#             Netscape Cert Type: 
#                 SSL Client
#             Netscape Comment: 
#                 OpenSSL Generated Client Certificate
#             X509v3 Subject Key Identifier: 
#                 32:78:44:C5:11:49:C6:43:9A:3A:C4:31:9A:97:BB:68:25:80:2C:65
#             X509v3 Key Usage: critical
#                 Digital Signature, Non Repudiation, Key Encipherment
#             X509v3 Extended Key Usage: 
#                 TLS Web Client Authentication