#!/bin/bash
set -o nounset
set -o errexit
SUPPORTED_VERSIONS_FILE_PATH=$1
FULL_TEMPLATE_PATH=$2

echo "Running kubeval against the oldest and newest supported kubernetes version"
OLDEST_SUPPORTED_VERSION=$(head -1 "$SUPPORTED_VERSIONS_FILE_PATH")
NEWEST_SUPPORTED_VERSION=$(tail -1 "$SUPPORTED_VERSIONS_FILE_PATH")

VERSIONS_TO_CHECK="
${OLDEST_SUPPORTED_VERSION}
${NEWEST_SUPPORTED_VERSION}
"

echo "$VERSIONS_TO_CHECK" | grep "\." | while read -r supported_version
do
    echo "Running Kubeval against kubernetes version $supported_version"
    if ! kubeval -v "$supported_version" --strict --force-color "$FULL_TEMPLATE_PATH" --additional-schema-locations https://arm.seli.gic.ericsson.se/artifactory/proj-ecm-k8s-schema-generic-local
    then
        echo "kubeval failed against kubernetes version $supported_version"
        exit 1
    fi
done
