"""This module contains test cases to verify that the templates follow the guidelines for Openshift Environments."""

import pytest
from helm_template import HelmTemplate
from utils import mark_test_parameters

helm_template_object = HelmTemplate("/eric-oss-ml-execution-env.tgz", "/testsuite/site_values.yaml")

marks = [
    (['eric-pm-server'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
]
test_parameters = mark_test_parameters(helm_template_object.get_pod_specs(), marks)


@pytest.mark.parametrize(('template_name', 'kind', 'pod_spec'), test_parameters)
def test_service_account_referenced_per_pod(template_name, kind, pod_spec):
    """Test that there is a service account associated with each pod."""
    assert 'serviceAccountName' in pod_spec
    assert len(pod_spec['serviceAccountName']) > 0
    assert pod_spec['serviceAccountName'] in helm_template_object.get_names_of_objects_of_kind('ServiceAccount')


marks = [
    (['-database-pg$'], ['ServiceAccount'], pytest.mark.skip(reason='Not required, exempt')),
    (['-database-pg-hook'], ['ServiceAccount'], pytest.mark.skip(reason='Not required, exempt')),
    (['-postgres'], ['ServiceAccount'], pytest.mark.skip(reason='Not required, exempt')),
]
test_parameters = mark_test_parameters(helm_template_object.get_names_of_objects_of_kind_with_test_params('ServiceAccount'), marks)


@pytest.mark.parametrize(('template_name', 'kind', 'service_account_name'), test_parameters)
def test_openshift_cluster_role_binding_referenced_per_service_account(template_name, kind, service_account_name):
    """Test that each service account has the required openshift role binding."""
    role_bindings = helm_template_object.get_objects_of_kind('RoleBinding')
    found = False
    for role_binding in role_bindings:
        if helm_template_object.does_role_binding_have_cluster_role_reference(role_binding=role_binding, service_account_name=service_account_name, cluster_role_name='RELEASE-NAME-allowed-use-privileged-policy'):
            found = True
            break

    assert found == True


marks = [
    (['-postgres'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
]
test_parameters = mark_test_parameters(helm_template_object.get_pods_and_containers(), marks)


@pytest.mark.parametrize(('template_name', 'kind', 'pod_spec', 'container_spec'), test_parameters)
def test_to_ensure_all_containers_have_securitycontext_set(template_name, kind, pod_spec, container_spec):
    """Test that there is a securityContext associated to each pod or container."""
    assert 'securityContext' in container_spec or 'securityContext' in pod_spec


marks = [
    (['-pg'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
    (['-pg'], ['Deployment'], pytest.mark.skip(reason='Not required, exempt')),
    (['-hook-cleanup'], ['Job'], pytest.mark.skip(reason='Not required, exempt')),
    (['-postgres'], ['Deployment'], pytest.mark.skip(reason='Not required, exempt')),
    (['-postgres'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-pm-server'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
]
test_parameters = mark_test_parameters(helm_template_object.get_pods_and_containers(), marks)


@pytest.mark.parametrize(('template_name', 'kind', 'pod_spec', 'container_spec'), test_parameters)
def test_to_ensure_all_containers_with_securitycontext_has_runAsUser_set(template_name, kind, pod_spec, container_spec):
    """Test that there is a runUser set with appropriate permission associated to each security context set"""
    resulting_security_context = helm_template_object.get_resulting_container_security_context(pod_spec=pod_spec, container_spec=container_spec)
    assert type(resulting_security_context.get('runAsUser', None)) is int


marks = [
    (['-pg'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
    (['-postgres'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-pm-server'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
]
test_parameters = mark_test_parameters(helm_template_object.get_pods_and_containers(), marks)


@pytest.mark.parametrize(('template_name', 'kind', 'pod_spec', 'container_spec'), test_parameters)
def test_to_ensure_all_containers_with_securitycontext_has_runAsNonRoot_set(template_name, kind, pod_spec, container_spec):
    """Test that there is a runAsNonRoot set with appropriate permission associated with each security context set"""
    resulting_security_context = helm_template_object.get_resulting_container_security_context(pod_spec=pod_spec, container_spec=container_spec)
    assert type(resulting_security_context.get('runAsNonRoot', None)) is bool


marks = [
    (['-pg'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
    (['-postgres'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-pm-server'], ['StatefulSet'], pytest.mark.skip(reason='Not required, exempt')),
]
test_parameters = mark_test_parameters(helm_template_object.get_pods_and_containers(), marks)


@pytest.mark.parametrize(('template_name', 'kind', 'pod_spec', 'container_spec'), test_parameters)
def test_to_ensure_all_containers_with_securitycontext_has_allowPrivilegeEscalation_set(template_name, kind, pod_spec, container_spec):
    """Test that there is an allowPrivilegeEscalation set with appropriate permission associated with each security context set"""
    resulting_security_context = helm_template_object.get_resulting_container_security_context(pod_spec=pod_spec, container_spec=container_spec)
    assert type(resulting_security_context.get('allowPrivilegeEscalation', None)) is bool
