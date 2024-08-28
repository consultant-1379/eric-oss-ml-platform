# Bob
> **⚠ WARNING**: CI is not yet automated, Bob rules are executed manually.

[TOC]

## Bob rules
Bob configuration is located in the file [ci/rulesets/ruleset2.0.yaml](../../ci/rulesets/ruleset2.0.yaml).

To call a rule from the project base directory:
```bash
$ bob/bob -r ci/rulesets/ruleset2.0.yaml <rule_name>
```

### Inherited microservice rules
These are common microservice chart rules, provided for linting and validating the Helm chart.

### ML Execution Environment manual build
These are the project's own set of rules used for creating and releasing the artifacts manually.
The files are placed into the `.bob/` temporary directory.
The `adp-int-helm-chart-auto` bob builder image is used for packaging and uploading the artifacts to the ARM repositories.
The `ihc-auto` script cannot be used, since ML Execution Environment does not yet have an automated release process.
Other helper scripts from the image are used instead: `ihc-package`, `arm-upload`.

#### Versioning
The bob rules use the version numbers set manually in these two metadata files for the chart and the helmfile, respectively:
* [`charts/eric-oss-ml-execution-env/Chart.yaml`](../../charts/eric-oss-ml-execution-env/Chart.yaml)
* [`helmfile/metadata.yaml`](../../helmfile/metadata.yaml)

The version numbers must be stepped in line, these should always be the same.
A new Git commit with the version change must be created before executing the Bob rules,
since the helmfile packaging operates on repository content only.

#### Rules and tasks
Before executing the rules, some environment variables must be set in the shell:
* The API token for accessing the Team Smoke ARM repositories on the Artifactory instance [arm.seli.gic.ericsson.se](https://arm.seli.gic.ericsson.se/artifactory/).
  ```bash
  $ export ARM_API_TOKEN=AKCp...
  ```
* In case the above token does not belong to the executing system user, then the user id must be set in the environment:
  ```bash
  $ export HELM_USER=euserid
  ```

##### init
The init rule saves the chart version in the Bob variable `var.version`.
This will be used by the artifact generations later.

It also checks whether the same version is set for the Helmfile and fails if there's a version mismatch.

##### chart
The chart rule creates the Helm chart archive.
###### chart:package
Packages the chart using `ihc-package`.
###### chart:upload
Uploads the archive to the Team Smoke Helm chart repository using `arm-upload`.

##### helmfile
The helmfile rule creates the helmfile archive.
###### helmfile:package
Packages the chart using `helmfile` and `tar`, mimics the behaviour of the `ihc-auto` script:
- first creates `helmfile.lock` files by issuing `helmfile deps`
- creates tar archive of the `helmfile/` directory with
  - renaming the directory to the project name within the archive,
  - explicitly specifying the POSIX archive format,
  - only packaging committed Git repo content plus the lock files, additional local working directory files are skipped!

The `ihc-package` script [does not support](https://eteamproject.internal.ericsson.com/browse/ADPPRG-93374) helmfile archives.

###### helmfile:upload
Uploads the archive to the Team Smoke Helm chart repository using `arm-upload`.

##### csar
The csar rule creates the CSAR archive.
###### csar:helm-fetch-chart
Fetches the previously generated and uploaded `eric-oss-execution-env` chart using `helm`.
###### csar:helm-fetch-wcdb-crd
Fetches the `eric-data-wide-column-database-cd-crd` chart using `helm`.
This has to be included in the CSAR archive for Deployment Manager to work.
###### csar:package
Packages the CSAR using the `eric-am-package-manager` builder.
Lightweight CSAR is created, no Docker images are included in the archive!
###### csar:upload
Uploads the archive to the Team Smoke generic repository using `arm-upload`.

##### release-all
This rule calls and performs all the above steps required for releasing the artifacts.

## ARM Repos
The `HELM_USER` executing the upload Bob rules must have write access to these repositories, i.e. team members and team functional id.
- [Helm chart repository](https://arm.seli.gic.ericsson.se/artifactory/proj-smoke-helm/eric-oss-ml-execution-env/)
- [Helmfile repository](https://arm.seli.gic.ericsson.se/artifactory/proj-smoke-helm/eric-oss-ml-execution-env-helmfile/)
- [CSAR repository](https://arm.seli.gic.ericsson.se/artifactory/proj-smoke-generic-local/csars/eric-oss-ml-execution-env/)

## References
- [Bob User Guide](https://gerrit.ericsson.se/plugins/gitiles/adp-cicd/bob/+/master/USER_GUIDE_2.0.md)
- [CSAR Packaging Tool](https://gerrit.ericsson.se/plugins/gitiles/OSS/com.ericsson.orchestration.mgmt.packaging/am-package-manager/)
- [Integration Helm Chart Automation](https://gerrit.ericsson.se/plugins/gitiles/adp-cicd/adp-int-helm-chart-auto/)
