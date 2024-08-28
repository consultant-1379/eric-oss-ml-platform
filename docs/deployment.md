# OSS ML Execution Environment Chart

[TOC]


## Introduction
This document describes the OSS ML Execution Environment Umbrella Chart - eric-oss-ml-execution-env.
It is a Helm 3 chart structure which means that there is no requirements.yaml file - dependencies are described within the Chart.yaml.

Installs [MXE version 2.3](https://calstore.internal.ericsson.com/elex?LI=EN/LZN7921000R14A).

## Structure
The key files can be described as follows:
### Chart.yaml
This file contains the main information to describe the Chart which includes the versioning, dependencies, name etc.
### values.yaml
This file contains the configurable values that are available for this Chart. It also contains any overwritten values
from lower level dependencies.

Due to how the MXE Helm charts are structured and yaml anchors used for its configuration, this values file contains more
keys than the ones intended for users of this chart to set up their deployment. Only change values where indicated.
### values.schema.json
This file contains the rules which the exposed values from this chart must align to.
It ensures that required fields are given to the install as well as ensuring that they follow the required format/syntax.
### templates/
This directory contains templates that are deployed from this Chart level.
Secrets for Docker registry, Helm repo, GitOps repository, database, IAM, TLS certificates, Argo CD bcrypted password
are created automatically based on the provided configuration.

## Site Values
The sample site values file is available at the root of this repo.
In order to install this chart you must fill in the site values as described below, keeping all the YAML anchors in place:

## Parameters

These parameters can be set in the site_values.yaml file.

| Parameter Name              | Description                                                                         | Example                   |
|-----------------------------|-------------------------------------------------------------------------------------|---------------------------|
| global.registry.url         | URL for the Docker Registry to be used for pulling images                           | armdocker.rnd.ericsson.se |
| global.registry.username    | Username to be used to pull images from the given docker registry (ARM_USER)        | efunctionaluserid         |
| global.registry.password    | Password to be used to pull images from the given docker registry (ARM_API_TOKEN)   | AKCp8...                  |
| global.imageRegistry        | URL for the Docker Registry to be used for pulling images                           | armdocker.rnd.ericsson.se |
| global.support.ipv6.enabled | Enable IPv6 Support within the applications                                         | true                      |
| global.timezone             | Overwrite the timezone to be used in the applications                               | UTC                       |
| ...                         |                                                                                     |                           |
| ml.*                        | ML Execution Environment specific parameters                                        |                           |
| ml.certs.path               | Path of the certificates folder which contains the domain tls and ca crt pem files (for helmfile only) | /workdir/certificates |
| ml.certs.tls                | An array containing the TLS SSL certificates and keys for each domain to be used by the tls secrets (helmfile generates it) | |
| ml.certs.ca                 | Value containing the Ericsson internal trust SSL CA certificates EGADRootCA.crt and EGADIssuingCA3.crt |        |
| ml.config.deploymentManager | Set this to true, if helmfile is installed by Deployment Manager (which creates docker and tls secrets automatically) | |
| ml.iam.*                    | Keycloak credentials                                                                | mxe-user                  |
| .username                   | User ID for the MXE user                                                            | mxe-user                  |
| .password                   | Initial password of the MXE user                                                    | password                  |
| .temporal                   | If enabled, the user password must be changed on the GUI on first login before use  | true                      |
| .kcadminid                  | User ID for the Keycloak admin user                                                 | admin                     |
| .kcpasswd                   | Password of the Keycloak admin user                                                 | SecurePassword123!        |
| ml.gitops.*                 | GitOps specific configuration                                                       |                           |
| .internal                   | If enabled, Gitea service is deployed to provide the GitOps repository              | true                      |
| .repoUrl                    | The URL of the GitOps repository used, either internal or external                  | https://gitea.mxe.hall922.rnd.gic.ericsson.se/eiap/mxe-gitops.git / https://gerrit.ericsson.se/a/ORG/mxe-gitops |
| .branch                     | Branch name used in the Git repo. It must be existing before first use              | master                    |
| .credentials.*              | GitOps repo credentials, if internal, these values will be set in Gitea             |                           |
| .credentials.username       | GitOps repo user ID                                                                 | mxe-gitops                |
| .credentials.password       | GitOps repo user password                                                           | password                  |
| .credentials.email          | GitOps repo user email address                                                      | mxe-gitops@local.domain   |
| ml.gitops.commit.*          | Deployer commits will use the following user identity                               |                           |
| .authorName                 | Git commit author name                                                              | MXE Deployer              |
| .authorEmail                | Git commit author email address                                                     | mxe-deployer@local.domain |
| .authorDomain               | The service domain if using an external Git provider, ignored if internal Git is enabled | gerrit.ericsson.se / gitlab.internal.ericsson.com |
| ml.hosts.*                  | Host names of internal MXE services must be specified one by one                    |                           |
| .apiHostname                | The domain name by which MXE's API and GUI is accessible                            | mxe.hall922.rnd.gic.ericsson.se |
| .apiPort                    | The port on which MXE will be accessible (default is 443)                           | 443                       |
| .oauthApiHostname           | The domain name to access MXE's Keycloak                                            | oauth.mxe.hall922.rnd.gic.ericsson.se |
| .argocdHostName             | Argo CD http hostname if ingress is enabled                                         | argocd.hall922.rnd.gic.ericsson.se |
| .deployerServiceHostName    | Deployer service hostname                                                           | mxe-deployer.hall922.rnd.gic.ericsson.se |
| .giteaRootUrl               | Gitea root URL                                                                      | https://gitea.mxe.hall922.rnd.gic.ericsson.se |
| .giteaIngressHost           | Gitea ingress host                                                                  | gitea.mxe.hall922.rnd.gic.ericsson.se |
| .giteaOauthAutoDiscoverUrl  | openid-configuration endpoint of Keycloak                                           | https://oauth.mxe.hall922.rnd.gic.ericsson.se/auth/realms/mxe/.well-known/openid-configuration |
| ml.servicecreds.*           | Random generated passwords for internal MXE services saved here for upgrade         |                           |
| .minioAdminAccessKey                    | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .minioAdminSecretKey                    | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .pgCustomPassword                       | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .catalogueServiceInstanceMinioSecretkey | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .catalogueServiceMinioSecretkey         | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .trainingjrInstanceMinioSecretkey       | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .trainingjrServiceMinioSecretkey        | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .trainingpkgInstanceMinioSecretkey      | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .trainingpkgServiceMinioSecretkey       | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .catalogueServicePgCustomUserPwd        | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .trainingServicePgCustomUserPwd         | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .authorServicePgCustomUserPwd           | Use the bundled dev/generate-random-secrets.sh script                   |                           |
| .argocdAdminPwd             | Argo CD admin password                                                              | password                  |
| namespace                   | Due to the design of MXE, the Helm release namespace must be provided here...       | mxe                       |
| owasp                       | Enables OWASP for MXE service endpoints                                             | true                      |
| modelServiceOwasp           | Enables OWASP for model-service endpoints too, degrades performance noticeably!     | false                     |
| containerRegistryVolumeSize | Size of the container registry volume which is used to store onboarded model and training package images | 20Gi |
| enableInternalServiceMesh   | Whether to use the internal or external service mesh (Istio)                        | true                      |

## Usage
The chart can be installed and upgraded using helm.
Note: it has to be installed in its own namespace not EIAP's.

## Prerequisites
### eric-mesh-controller-crd
MXE uses the [ADP ServiceMesh Controller](https://adp.ericsson.se/marketplace/servicemesh-controller) component,
which provides the Istio Custom Resource Definitions on the cluster. It is now a mandatory part of EIAP.
Check if the CRD is already deployed on the cluster.
```bash
$ kubectl api-versions | grep security.istio.io
security.istio.io/v1beta1
```
Make sure, that the version equals to ***v1beta1*** as MXE's resources use this exact version.

This chart can be used without EIAP, in that case the CRD dependency must be installed manually before:
```bash
$ helm repo add adp-gs-all https://arm.sero.gic.ericsson.se/artifactory/proj-adp-gs-all-helm && helm repo update
$ helm upgrade --install -n eric-crd-ns eric-mesh-controller-crd adp-gs-all/eric-mesh-controller-crd --version 6.1.0+48
```

### Storage class
Set the default storage class to block type, since some services require it:
```bash
$ kubectl patch storageclass network-file  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
$ kubectl patch storageclass network-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
$ kubectl get sc
NAME                      PROVISIONER      RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
network-block (default)   ceph.com/rbd     Delete          Immediate           false                  138d
network-file              fuseim.pri/ifs   Delete          Immediate           false                  389d
```
### TLS certificates
Prepare the certificates according to the
[MXE CPI document Installation Guide](https://calstore.internal.ericsson.com/elex?LI=EN/LZN7921000R14A).
MXE only accepts certificates signed by trusted public certificate authorities or the Ericsson internal EGAD provided by
[Ericsson Certificate Services](https://clm.internal.ericsson.com/aperture/).
Multi SAN certificate is now available i.e. generating one certificate for multiple domain names.

The Helm Chart contains template to automatically create the necessary secrets from values, that `helmfile` generates
from the pem files.
```bash
$ ls -1 certificates/
EGADIssuingCA3.crt
EGADRootCA.crt
hall922.rnd.gic.ericsson.se.conf
hall922.rnd.gic.ericsson.se.csr
hall922.rnd.gic.ericsson.se.key
hall922.rnd.gic.ericsson.se.pem
argocd.mxe.hall922.rnd.gic.ericsson.se.crt
argocd.mxe.hall922.rnd.gic.ericsson.se.key
deployer.mxe.hall922.rnd.gic.ericsson.se.crt
deployer.mxe.hall922.rnd.gic.ericsson.se.key
gitea.mxe.hall922.rnd.gic.ericsson.se.crt
gitea.mxe.hall922.rnd.gic.ericsson.se.key
mxe.hall922.rnd.gic.ericsson.se.crt
mxe.hall922.rnd.gic.ericsson.se.key
oauth.mxe.hall922.rnd.gic.ericsson.se.crt
oauth.mxe.hall922.rnd.gic.ericsson.se.key
```

If installing with Helm, the TLS secrets can be created manually using the command line client `kubectl`.
Assuming the pem files are named after the subdomains they contain the TLS certificates for:
```bash
$ export namespace=eric-ml-ns
$ kubectl create namespace "${namespace}"
$ for domain in mxe argocd deployer gitea oauth ; do kubectl create secret tls "${domain}-tls" --key "${domain}.*.key" --cert "${domain}.*.crt" -n "${namespace}" ; done
```

## Installation
The ML Execution Environment can be installed in three ways.

### Helm
Helm release names must be the default ones indicated below, or the new names must be set in the values file.
```bash
$ helm repo add smoke https://arm.seli.gic.ericsson.se/artifactory/proj-smoke-helm
$ time helm install eric-oss-ml-execution-env-base smoke/eric-oss-ml-execution-env -n "${namespace}" --timeout 30m --wait -f sample-site-values.yaml --set namespace="${namespace}" --set ml.base=true
$ time helm install eric-oss-ml-execution-env-apps smoke/eric-oss-ml-execution-env -n "${namespace}" --timeout 30m --wait -f sample-site-values.yaml --set namespace="${namespace}" --set ml.apps=true
```

### Helmfile
```bash
$ cd helmfile/
$ helmfile deps
$ time helmfile --state-values-file site_values_1.0.0-0.yaml apply --skip-deps > >(tee -a log_stdout.yaml) 2> >(tee -a log_stderr.yaml >&2)
```

### Deployment manager
Deployment manager uses the Helmfile to install the ML Execution Environment.
The Helmfile and CSAR archives need to be downloaded from ARM into the working directory.
The `certificates/` directory contains the TLS certificate files.
The `kube_config/config` file contains the KUBECONFIG required to access the target cluster.
```bash
$ ls -1F
certificates/
csar/
eric-oss-ml-execution-env-1.0.0-0.csar
eric-oss-ml-execution-env-1.0.0-0.tgz
eric-oss-ml-execution-env-helmfile-1.0.0-0.tgz
kube_config/
logs/
site_values_1.0.0-0.yaml
$ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}:/workdir armdocker.rnd.ericsson.se/proj-eo/common/deployment-manager:latest install --namespace eric-ml-ns --skip-crds
```

## Upgrade
Upgrade is not supported by MXE 2.3, only clean install is possible. Removing steps are automated in the `dev/cleanup.sh` script.
