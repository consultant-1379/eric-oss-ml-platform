#!/usr/bin/env groovy

def bob = "bob/bob -r \${WORKSPACE}/ci/rulesets/ruleset2.0.yaml"
def filesChangedInCommit(path) {
    return sh(returnStdout: true, script: "git diff-tree --diff-filter=ACM --no-commit-id --name-only -r $GIT_COMMIT -- $path").trim()
}

pipeline {
    agent {
        label env.SLAVE_LABEL
    }
    parameters {
        string(name: 'SLAVE_LABEL', defaultValue: 'evo_docker_engine_gic_IDUN', description: 'Specify the slave label that you want the job to run on')
        string(name: 'FUNCTIONAL_USER_SECRET',
            defaultValue: 'cloudman-user-creds',
            description: 'Jenkins secret ID for ARM Registry Credentials')
    }
    environment {
        CHANGED_PYTHON_FILES = filesChangedInCommit("utils/*.py")
        HELM_REPO_CREDENTIALS = "${env.WORKSPACE}/repositories.yaml"
        HELM_REPO_CREDENTIALS_ID = "eoadm100_helm_repository_creds"
        HELM_REPOSITORY_NAME = "proj-eric-oss-drop-helm-local"
    }
    stages {
        stage('Initialize Workspace') {
            steps {
                sh 'git submodule sync'
                sh 'git submodule update --init --recursive'
                sh "${bob} git-clean"
            }
        }
        /*
        Skipping due to bug/questions with helm v3 linting
        https://github.com/helm/helm/issues/8880
        https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/SM-70818
        stage('Helm Lint') {
            steps {
                sh "${bob} lint:helm"
            }
        }*/
        stage('Package Helm Charts') {
            steps {
                script {
                    withCredentials([file(credentialsId: env.HELM_REPO_CREDENTIALS_ID, variable: 'HELM_REPO_CREDENTIALS_FILE')]) {
                        sh "install -m 600 ${HELM_REPO_CREDENTIALS_FILE} ${env.HELM_REPO_CREDENTIALS}"
                        sh "${bob} helm-package"
                    }
                }
            }
        }
        stage('Validate Helm3 Chart Schema') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                    sh "${bob} validate-helm3-charts"
                }
            }
        }
        stage('Validate Helm Chart Schema') {
            steps {
                sh "${bob} validate-chart-schema"
            }
        }
        stage('Build Helm Testsuite Image') {
            steps {
                sh "${bob} build-testsuite-image"
            }
        }
        stage('Run Helm Chart Testsuite') {
            steps {
                sh "${bob} run-chart-testsuite"
            }
            post {
                always {
                    sh "${bob} test-suite-report-and-clean"
                    archiveArtifacts artifacts: 'chart-test-report.html', allowEmptyArchive: true
                }
            }
        }
        stage('Python Lint Utilities') {
            when {
                expression
                        { env.CHANGED_PYTHON_FILES != null }
            }
            steps {
                sh "${bob} lint:python3"
            }
        }
        stage('Kubernetes Range Compatibility Tests') {
            steps {
                sh "${bob} kube-version kubeval deprek8ion"
            }
        }
        stage('Design Rules Check') {
            steps {
                withCredentials([file(credentialsId: env.HELM_REPO_CREDENTIALS_ID, variable: 'HELM_REPO_CREDENTIALS_FILE')]) {
                    sh "install -m 600 ${HELM_REPO_CREDENTIALS_FILE} ${HELM_REPO_CREDENTIALS}"
                    sh "${bob} set-design-rule-parameters design-rule-checker"
                }
            }
            post {
                always {
                    archiveArtifacts 'design-rule-check-report.html'
                }
            }
        }
        stage('Check shell scripts') {
            when {
                anyOf {
                    changeset pattern: '*.sh'
                    changeset pattern: 'testsuite/**/*.sh'
                    changeset pattern: 'dev/**/*.sh'
                }
            }
            steps {
                sh "${bob} shellcheck"
            }
        }
    }
}
