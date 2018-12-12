#!/bin/bash
# Input env variables (can be received via a pipeline environment properties.file.
echo "IMAGE_NAME=${IMAGE_NAME}"
echo "IMAGE_TAG=${IMAGE_TAG}"
echo "REGISTRY_URL=${REGISTRY_URL}"
echo "REGISTRY_NAMESPACE=${REGISTRY_NAMESPACE}"
echo "PIPELINE_KUBERNETES_CLUSTER_NAME=${PIPELINE_KUBERNETES_CLUSTER_NAME}"
echo "CLUSTER_NAMESPACE=${CLUSTER_NAMESPACE}"

# View build properties
if [ -f build.properties ]; then 
  echo "build.properties:"
  cat build.properties
else 
  echo "build.properties : not found"
fi 
if ${UPDATE}!=true then exit 0

echo "=========================================================="
echo " Modify label from green (app: test-catalog) to match blue (app: catalog) "

kubectl label --overwrite app=${LBL_NAME} --namespace ${CLUSTER_NAMESPACE} test-${DEP_NAME}

echo "=========================================================="
echo " Delete green service "

kubectl delete service test-${SVC_NAME} --namespace ${CLUSTER_NAMESPACE}

echo "=========================================================="
echo " Delete blue deployment "

kubectl delete deployment ${DEP_NAME} --namespace ${CLUSTER_NAMESPACE}

echo "=========================================================="
echo " Rename green (test-catalog-deployment) to blue (catalog-deployment) "

kubectl patch deployment test-${DEP_NAME} --namespace ${CLUSTER_NAMESPACE} -p '{ "metadata": { "name" : "${DEP_NAME}" } }'

