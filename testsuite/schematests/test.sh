#!/bin/bash
set -o nounset
set -o errexit

if [[ -z "${1-}" ]]
then
    echo "ERROR: The first argument must be the full path to the helm chart to test against"
    exit 1
fi

CHART_PATH=$1
if [[ ! -f $CHART_PATH ]]
then
    echo "ERROR: Cannot find the provided helm chart $CHART_PATH"
    exit 1
fi
echo "INFO: Testing chart $CHART_PATH"
CURRENT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${CURRENT_DIRECTORY}"

TEST_OUTPUT_SUBDIR=tmp
rm -rf $TEST_OUTPUT_SUBDIR
mkdir -p $TEST_OUTPUT_SUBDIR
pass_counter=0
fail_counter=0
while read -r test_values_file
do
    test_values_file_short=$(basename "$test_values_file")
    test_expected_failure_output_file=$(dirname "${test_values_file}")/$(basename "$test_values_file" .yaml)_expected_errors.txt
    test_expected_failure_output_file_short=$(basename "$test_expected_failure_output_file")

    test_output_file=${CURRENT_DIRECTORY}/tmp/$(basename "$test_values_file" .yaml)_output.txt

    expected_command_failed=false
    test_expected_failure_output_file_string="none"
    if [[ -f ${test_expected_failure_output_file} ]]
    then
        expected_command_failed=true
        test_expected_failure_output_file_string=${test_expected_failure_output_file_short}
    fi

    echo -n "INFO: Testing ${test_values_file_short} (Expected Failure Output File: ${test_expected_failure_output_file_string}): "

    command_failed=false
    if ! helm template "${CHART_PATH}" -f "$test_values_file" > "${test_output_file}" 2>&1
    then
        command_failed=true
    fi

    if [[ "${command_failed}" != "${expected_command_failed}" ]]
    then
        if [[ "${expected_command_failed}" == true ]]
        then
            echo "fail (the helm command was expected to fail but it didn't)"
        else
            echo "fail (the helm command was not expected to fail but it did). Here was the output."
            cat "${test_output_file}"
        fi
        fail_counter=$((fail_counter+1))
        continue
    fi

    if [[ ${expected_command_failed} != true ]]
    then
        echo "pass"
        pass_counter=$((pass_counter+1))
        continue
    fi

    if ! diffoutput=$(diff -wB <(sort "${test_expected_failure_output_file}") <(sort "${test_output_file}"))
    then
        echo "fail (see reason below)"
        echo "ERROR: Expected helm output from ${test_values_file_short} did not match what came from helm. Here is the differences."
        echo "${diffoutput}"
        fail_counter=$((fail_counter+1))
    else
        echo "pass"
        pass_counter=$((pass_counter+1))
    fi
done < <(find "${CURRENT_DIRECTORY}/tests" -name "test*.yaml")
echo "INFO: Result: $pass_counter tests passed, $fail_counter tests failed"
if [[ ${fail_counter} != 0 ]]
then
    exit 1
fi
