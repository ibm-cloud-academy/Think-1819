#!/bin/bash
# uncomment to debug the script
#set -x

# Input env variables (can be received via a pipeline environment properties.file.
echo "IMAGE_NAME=${IMAGE_NAME}"
echo "IMAGE_TAG=${IMAGE_TAG}"
echo "REGISTRY_URL=${REGISTRY_URL}"
echo "REGISTRY_NAMESPACE=${REGISTRY_NAMESPACE}"

# View build properties
if [ -f build.properties ]; then 
  echo "build.properties:"
  cat build.properties
else 
  echo "build.properties : not found"
fi 

APP_NAME=$(kubectl get pods --namespace ${CLUSTER_NAMESPACE} -o json | jq -r '.items[].status | select(.containerStatuses!=null) | .containerStatuses[] | select(.image=="'"${IMAGE_REPOSITORY}:${IMAGE_TAG}"'") | .name' | head -n 1)
APP_SERVICE=$(kubectl get services --namespace ${CLUSTER_NAMESPACE} -o json | jq -r ' .items[] | select (.spec.selector.app=="'"${APP_NAME}"'") | .metadata.name ')
IP_ADDR=$( ibmcloud cs workers ${PIPELINE_KUBERNETES_CLUSTER_NAME} | grep normal | head -n 1 | awk '{ print $2 }')
PORT=$( kubectl get services --namespace ${CLUSTER_NAMESPACE} | grep ${APP_SERVICE} | sed 's/.*:\([0-9]*\).*/\1/g' )

curl "http://${IP_ADDR}:${PORT}/items"

exit $?
