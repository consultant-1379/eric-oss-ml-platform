# OSS Machine Learning Platform

[TOC]


## Introduction
This repo contains the OSS Machine Learning Execution Environment Helm chart and its associated tests and CI.
It also contains the OSS Machine Learning Execution Environment Helmfile.
Please follow this documentation for further details.

### Repo Structure
This is the directory structure of the repo.
Below is a description of the contents of each of the upper level directories.
```
eric-oss-ml-platform/
├── bob
├── charts
│   └── eric-oss-ml-execution-env
│       ├── charts
│       └── templates
├── ci
│   ├── jenkinsfiles
│   ├── rulesets
│   └── scripts
├── dev
├── docs
├── helmfile
│   ├── build-environment
│   ├── default-values
│   ├── helm-values-templates
│   └── templates
└── testsuite
    ├── helm-chart-validator
    │   └── src
    └── schematests
        └── tests
            ├── negative
            └── positive
```
#### Bob
This is a submodule and contains the latest ADP BOB tool used to power the CI automation.
See the [ADP BOB Documentation](https://gerrit.ericsson.se/plugins/gitiles/adp-cicd/bob).

#### Charts
This directory contains the OSS ML Execution Environment Integration Chart.
See the [OSS ML Execution Environment Docs](docs/deployment.md) for more details.

#### CI
This directory contains the jenkinsfiles and bob rulesets used to run the CI automation for this repository.
See the [OSS ML Execution Environment CI Docs](docs/ci/ml-execution-env_ci.md) for more details.

#### Dev
This directory contains useful utility scripts for developers when contributing to this repo.
Also contains scripts used for installation and removal.
See the [OSS ML Execution Environment Dev Docs](docs/dev/developer_guide.md) for more details.

#### Docs
This directory contains all the documentation describing this repository.

#### Helmfile
This directory contains the OSS ML Execution Environment Helmfile.

#### Testsuite
This directory contains the tests created for the OSS ML Execution Environment chart.
See the [OSS ML Execution Environment Testsuite Docs](docs/testsuite/test_overview.md)
for more details.

## Release Notes

## Community
### Key people of the project
  - PO: <team_po>
  - Guardians: (Code reviews, approvals, house rules etc.)
    - [Team Smoke](https://confluence-oss.seli.wh.rnd.internal.ericsson.com/display/IDUN/Team+Smoke)
### Contact
  - PDLSMOKETE@pdl.internal.ericsson.com
