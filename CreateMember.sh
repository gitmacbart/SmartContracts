#! /bin/bash

set -e

# default values
HOME_PATH=""
ROOT="./configs"
WDIR=""
ERROR_EXIT="exit with error"

# clean --> I should backup first if $1 exists
rm -rf $1
mkdir $1
cd $1

echo "==> Generating ECC key pair for accesspoint for "$1

openssl ecparam -name prime256v1 -genkey -noout -out $1-ap-key.pem

if [ $? -eq 0 ]
then
  echo "Success"
else
  echo "Failed"
fi

echo "==> Generating x509 certificate for accesspoint for "$1

openssl req -x509 -key $1-ap-key.pem -new -sha256 -nodes -days 3650 \
         -subj "/C=CH/ST=GVA/L=GENEVA/O=SITA/OU=XS Network/CN=$1" \
         -out $1-ap-cert.pem


if [ $? -eq 0 ]
then
  echo "Success"
else
  echo "Failed"
fi

echo "==> Generating ECC key pair for signing for "$1

openssl ecparam -name prime256v1 -genkey -noout -out $1-sign-key.pem

if [ $? -eq 0 ]
then
  echo "Success"
else
  echo "Failed"
fi

echo "==> Generating x509 certificate for signing for "$1

openssl req -x509 -key $1-sign-key.pem -new -sha256 -nodes -days 3650 \
         -subj "/C=CH/ST=GVA/L=GENEVA/O=SITA/OU=XS Network/CN=$1" \
         -out $1-sign-cert.pem


if [ $? -eq 0 ]
then
  echo "Success"
else
  echo "Failed"
fi
 
#sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' $1-ap-key.pem > $1-ap-key-oneline.txt
(echo '{"kind": "privateKey"}' | jq --arg foo "$(<$1-ap-key.pem)"  '. + {key: $foo}') > key1.json

(((echo '{"kind": "certificate"}' | jq --arg foo "$(<$1-ap-cert.pem)"  '. + {certificate: $foo}') | jq '. + {privateKeySki: "SKI1"}') | jq '. + {keyType: "ECDSA"}' ) > cert1.json

echo "==> Generating cert1 and key1 for accesspoint for "$1

#sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' $1-ap-cert.pem > $1-ap-cert-oneline.txt
#sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' $1-sign-key.pem > $1-sign-key-oneline.txt

(echo '{"kind": "privateKey"}' | jq --arg foo "$(<$1-sign-key.pem)"  '. + {key: $foo}') > key2.json

(((echo '{"kind": "certificate"}' | jq --arg foo "$(<$1-sign-cert.pem)"  '. + {certificate: $foo}') | jq '. + {privateKeySki: "SKI2"}') | jq '. + {keyType: "ECDSA"}' ) > cert2.json

echo "==> Generating cert2 and key2 for signing for "$1

#sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' $1-sign-cert.pem > $1-sign-cert-oneline.txt

