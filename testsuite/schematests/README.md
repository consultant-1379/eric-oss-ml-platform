# Schema Test Suite Overview
This test suite can verify that the helm chart schema within the helm chart (the `values.schema.json`), provides the appropriate positive and negative responses, with varying inputs.

# How To Run The Tests
To run the tests, execute the test.sh script, with the full path to the chart to test. e.g.

`./testsuite/schematests/test.sh $PWD/eric*.tgz`

# How To Add Tests
Place all test values files into the 'tests' subdirectory, named as `test_<test_name>.yaml`, e.g. `test_should_fail_if_no_iam_hostname.yaml` or `test_should_pass_with_valid_iam_hostname.yaml`

The yaml files contain the values that will be passed to helm as part of the `helm template <chart> -f <test_site_values>` command.

If a given values file is expected to fail, it must be accompanied by a matching file with the expected output lines, named as `test_<test_name>_expected_errors.txt`, e.g. `test_should_fail_if_no_iam_hostname_expected_errors.txt`

This file must contain all of the error output lines that are expected. Each line in this txt file must be found in the resulting helm output, in order for the test to pass. The order of the lines does not matter, as helm itself outputs the schema errors in a random order in most cases.
