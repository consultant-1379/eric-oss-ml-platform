#!/usr/bin/env bash

random-string(){
LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c "${1:-32}"
}

random-hex-string(){
LC_CTYPE=C tr -dc a-f0-9 < /dev/urandom | head -c "${1:-32}"
}

cat <<-EOF
minioAdminAccessKey: &minioAdminAccessKey $(random-string 20)
minioAdminSecretKey: &minioAdminSecretKey $(random-string 40)
pgCustomPassword: &mxePgCustomPassword $(random-string 10)
catalogueServiceInstanceMinioSecretkey: &catalogInstanceSecretKey $(random-string 24)
catalogueServiceMinioSecretkey: &catalogServiceSecretKey $(random-string 24)
trainingjrInstanceMinioSecretkey: &trainingjrInstanceSecretKey $(random-string 24)
trainingjrServiceMinioSecretkey: &trainingjrServiceSecretKey $(random-string 24)
trainingpkgInstanceMinioSecretkey: &trainingpkgInstanceSecretKey $(random-string 24)
trainingpkgServiceMinioSecretkey: &trainingpkgServiceSecretKey $(random-string 24)
catalogueServicePgCustomUserPwd: &catalogServicePgCustomUserPwd $(random-string 24)
trainingServicePgCustomUserPwd: &trainingServicePgCustomUserPwd $(random-string 24)
authorServicePgCustomUserPwd: &authorServicePgCustomUserPwd $(random-string 24)
lcm-container-registry-password: &lcmContainerRegistryPassword $(random-string 10)
EOF
