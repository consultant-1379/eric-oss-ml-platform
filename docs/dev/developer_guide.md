# Scripts
Information on scripts included in the chart source code repository.

## General information about how to run the test scripts
This directory contains development scripts, used to help run the various test suites locally on your development environment.

#### run_helm_chart_validator.sh
Executes the helm chart static checks including openshift static test as well.
This script is called by a bob rule in the pre-code review flow.

## Installation scripts
The below scripts are used to help the chart installation and uninstallation.

#### generate-random-secrets.sh
This script can be used to generate the necessary service credentials to be included in the site values for the installation.
The output should go under `ml.servicecreds` in the yaml structure.

#### cleanup.sh
Script for completely removing the ML Execution Environment from the cluster.

MXE version 2.2 does not support upgrading even to the same version, only clean install is possible.
This script removes the Helm releases, remaining Kubernetes resources, Istio resources.
Without wiping off the cluster, a clean installation is not possible.

#### cleanup_crd.sh
Script for removing the CRD dependency from the cluster.

# Schema validation

Helm Chart's values.yaml file is validated against the
[`values.schema.json`](../../charts/eric-oss-ml-execution-env/values.schema.json) file which contains the
[JSON schema definition](https://json-schema.org/understanding-json-schema/).

## Generate a schema file from the Helm values file

First install the [schema-gen plugin](https://github.com/karuppiah7890/helm-schema-gen):
```bash
$ helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git
```

Generate a skeleton:
```bash
$ helm schema-gen values.yaml > values.schema.json
```

Apply additional properties, like value type, predefined format, length, regex pattern, mandatory fields.
