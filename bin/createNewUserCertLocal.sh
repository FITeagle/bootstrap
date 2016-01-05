#!/usr/bin/env bash
#set -x

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
EXTFILE="${DIR}/createNewUserCertLocal.conf"
PASSWD="jetty6"

KEYSTORE="jetty-ssl.truststore"
#KEYALIAS="fiteaglesa"
KEYALIAS="root"
CANAME="testCA"


U_USERNAME="testuser"
U_PASSWORD="testing1"
U_DAYS="365"
U_SIZE="2048"

extractKeyFromKeystore() {
	##extract key from java keystore
	echo "extracting key ${KEYALIAS} from ${KEYSTORE}..."
	keytool -importkeystore -srckeystore ${KEYSTORE} -destkeystore ${CANAME}.p12 -deststoretype PKCS12 -srcalias ${KEYALIAS} -deststorepass ${PASSWD} -destkeypass ${PASSWD} -srcstorepass ${PASSWD}
	#Export certificate.
	echo "export certificate in PEM format..."
	openssl pkcs12 -in ${CANAME}.p12 -passin pass:${PASSWD} -nokeys -out ${CANAME}_cert.pem
	echo "export private key in PEM format..."
	##Export unencrypted private key.
	#openssl pkcs12 -in ${CANAME}.p12 -passin pass:${PASSWD} -nodes -nocerts -out ${CANAME}_key.pem
	##Export private key.
	openssl pkcs12 -in ${CANAME}.p12 -passin pass:${PASSWD} -passout pass:${PASSWD} -des3 -nocerts -out ${CANAME}_key.pem
}

generateUserCert(){
	#replace username in template
	sed "s/%%USERNAME%%/${U_USERNAME}/g" ${EXTFILE} >createNewUserCertLocal_${U_USERNAME}.conf
	sed -i "s/%%CANAME%%/${CANAME}/g" createNewUserCertLocal_${U_USERNAME}.conf

	if [ -f "${U_USERNAME}.key" ]; then
		echo "using exsisting key ${U_USERNAME}.key"
	else
		## create encrypted private key
		openssl genrsa -des3 -passout pass:${U_PASSWORD} -out ${U_USERNAME}.key ${U_SIZE}
	fi
	
	##create the CSR
	openssl req -sha1 -batch -new -passin pass:${U_PASSWORD} -out ${U_USERNAME}.csr -key ${U_USERNAME}.key -config createNewUserCertLocal_${U_USERNAME}.conf

	echo "Show CSR"
	echo openssl req -text -noout -in ${U_USERNAME}.csr

	##sign the CSR
	openssl x509 -sha1 -req -days ${U_DAYS} -in ${U_USERNAME}.csr -set_serial $(date +%s%N) \
		-passin pass:${PASSWD} -CA ${CANAME}_cert.pem -CAkey ${CANAME}_key.pem \
		-out ${U_USERNAME}.crt -extensions signing_req -extfile createNewUserCertLocal_${U_USERNAME}.conf

	## print cert
	echo "Show CERT"
	openssl x509 -in ${U_USERNAME}.crt -noout -text

	## combine cert & key
	cat ${U_USERNAME}.key ${U_USERNAME}.crt >${U_USERNAME}.pem
}

if [ ! -f "${CANAME}.p12" ]; then
	echo "${CANAME}.p12 missing!"
	echo "trying to extract from java keystore..."
	extractKeyFromKeystore
fi

if [ -f "${CANAME}.p12" ]; then
	generateUserCert
else
	echo "cant't open CA files!"
fi
