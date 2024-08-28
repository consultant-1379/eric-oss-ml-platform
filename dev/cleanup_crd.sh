#!/usr/bin/env bash

namespace_crd="${1:-eric-crd-ns}"
helm_release_name="${2:-eric-mesh-controller-crd}"
helm_chart_name="eric-mesh-controller-crd"
context="$(kubectl config current-context)";
[ "$?" -ne 0 ] && echo "ERROR: KUBECONFIG is missing!" && exit 1;
echo -e "
  WARNING! This will completely delete ${helm_chart_name}
    cluster:      ${context}
    namespace:    ${namespace}
    helm chart:   ${helm_chart_name}
    helm release: ${helm_release_name}";
read -p '    Are you sure? (yes/no) ' answer;
[ "${answer}" != "yes" ] && exit;

delete_meshcrd(){
  echo "${FUNCNAME[0]}"
  helm delete -n ${namespace} "${helm_release_name}"
  kubectl delete deployment,statefulset,jobs,pods,svc,ingress,configmap,secret,sa,role,rolebinding,clusterrole,clusterrolebinding,pdb,hpa \
   -n ${namespace} -l "app.kubernetes.io/instance=${helm_release_name}"
  kubectl delete CustomResourceDefinition -l "app.kubernetes.io/name=${helm_chart_name}"
}
