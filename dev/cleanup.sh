#!/usr/bin/env bash

namespace="${1:-eric-ml-ns}"
helm_release_name="${2:-eric-oss-ml-execution-env}"
helm_chart_name="eric-oss-ml-execution-env"
helm_release_base="${helm_release_name}-base"
helm_release_apps="${helm_release_name}-apps"

context="$(kubectl config current-context)";
[ "$?" -ne 0 ] && echo "ERROR: KUBECONFIG is missing!" && exit 1;
echo -e "
  WARNING! This will completely delete MXE
    cluster:       ${context}
    namespace:     ${namespace}
    helm chart:    ${helm_chart_name}
    helm releases: ${helm_release_base}
                   ${helm_release_apps}";
read -p '    Are you sure? (yes/no) ' answer;
[ "${answer}" != "yes" ] && exit;

delete_mxe_serving(){
  echo "${FUNCNAME[0]}"
  kubectl delete CustomResourceDefinition seldondeployments.machinelearning.seldon.io --ignore-not-found=true
  # seldon-validating-webhook-configuration-eric-ml-ns
  kubectl delete validatingwebhookconfigurations -l "app.kubernetes.io/instance=${helm_release_apps}"
}

delete_mxe_deployer(){
  echo "${FUNCNAME[0]}"
  kubectl delete CustomResourceDefinition applications.argoproj.io     --ignore-not-found=true
  kubectl delete CustomResourceDefinition appprojects.argoproj.io      --ignore-not-found=true
  kubectl delete CustomResourceDefinition argocdextensions.argoproj.io --ignore-not-found=true
  kubectl delete CustomResourceDefinition applicationsets.argoproj.io  --ignore-not-found=true
}

delete_istio(){
  echo "${FUNCNAME[0]}"
  # pre-install-hook-authz-allow-deployer
  kubectl delete authorizationpolicies.security.istio.io  -n ${namespace} -l app.kubernetes.io/part-of=mxe-deployer
  # pre-install-hook-istio-req-authn-mxe-deployer
  kubectl delete requestauthentications.security.istio.io -n ${namespace} -l app.kubernetes.io/part-of=mxe-deployer
  # istiod-eric-ml-ns
  kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io \
    -l "app.kubernetes.io/instance=${helm_release_base},app.kubernetes.io/name=eric-mesh-controller,app=istiod"
  # istio-sidecar-injector-eric-ml-ns
  kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io \
    -l "app.kubernetes.io/instance=${helm_release_base},app.kubernetes.io/name=eric-mesh-controller,app=sidecar-injector"
}

delete_mxe_commons(){
  echo "${FUNCNAME[0]}"
  delete_istio
  kubectl delete CustomResourceDefinition -l app.kubernetes.io/name=ambassador
  kubectl label namespace ${namespace} istio-injection-
  kubectl label namespace ${namespace} eric-inject-ns-
}

delete_apps(){
  echo "${FUNCNAME[0]}"
  helm uninstall -n ${namespace} "${helm_release_apps}"
  kubectl delete deployment,statefulset,job,pod,svc,ingress,configmap,secret,sa,role,rolebinding,clusterrole,clusterrolebinding,pdb,hpa \
    -n ${namespace} -l "app.kubernetes.io/instance=${helm_release_apps}"
  kubectl delete deployment,statefulset,job,pod,svc,ingress,configmap,secret,sa,role,rolebinding,clusterrole,clusterrolebinding,pdb,hpa \
    -n ${namespace} -l "release=${helm_release_apps}"
  delete_mxe_serving
  delete_mxe_deployer
}

delete_base(){
  echo "${FUNCNAME[0]}"
  helm uninstall -n ${namespace} "${helm_release_base}"
  kubectl delete deployment,statefulset,job,pod,svc,ingress,configmap,secret,sa,role,rolebinding,clusterrole,clusterrolebinding,pdb,hpa \
    -n ${namespace} -l "app.kubernetes.io/instance=${helm_release_base}"
  kubectl delete deployment,statefulset,job,pod,svc,ingress,configmap,secret,sa,role,rolebinding,clusterrole,clusterrolebinding,pdb,hpa \
    -n ${namespace} -l "release=${helm_release_base}"
  kubectl delete deployment,statefulset,job,pod,svc,ingress,configmap,secret,sa,role,rolebinding,clusterrole,clusterrolebinding,pdb,hpa \
    -n ${namespace} -l "app.kubernetes.io/part-of=mxe"
  delete_mxe_commons
}

delete_eric_ctrl_bro_helm_release(){
  helm delete eric-ctrl-bro -n ${namespace}
}

delete_wcdb_crd(){
  echo "${FUNCNAME[0]}"
  helm delete eric-data-wide-column-database-cd-crd -n eric-crd-ns
  kubectl delete CustomResourceDefinition cassandraclusters.wcdbcd.data.ericsson.com
  kubectl delete deployment,statefulset,job,pod,svc,ingress,configmap,secret,sa,role,rolebinding,clusterrole,clusterrolebinding,pdb,hpa \
    -n eric-crd-ns -l "app.kubernetes.io/instance=eric-data-wide-column-database-cd-crd"
}

delete_pvcs(){
  echo "${FUNCNAME[0]}"
  kubectl delete pvc -n ${namespace} -l app=eric-data-wide-column-database-cd
  kubectl delete pvc -n ${namespace} --all
}

delete_orphan_pods(){
  echo "${FUNCNAME[0]}"
  kubectl delete pods -n ${namespace} --all
}

delete_orphan_secrets_configmaps(){
  echo "${FUNCNAME[0]}"
  kubectl delete secret,configmap -n ${namespace} --all
}

delete_apps
delete_base
delete_wcdb_crd
#delete_eric_ctrl_bro_helm_release
delete_pvcs
delete_orphan_pods
