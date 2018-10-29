#!/bin/sh
set -xe
./gradlew mlDeploy
mlcp.sh import -mode "local" -host localhost -port 9010 -username admin -password admin -input_file_path input/json/ -input_file_type "documents" -output_collections "Product,json,input" -output_permissions "rest-reader,read,rest-writer,update" -document_type "json" -transform_module "/data-hub/4/transforms/mlcp-flow-transform.sjs" -transform_namespace "http://marklogic.com/data-hub/mlcp-flow-transform" -transform_param "entity-name=Product,flow-name=ProductIpFlowJS"
./gradlew hubCreateHarmonizeFlow -PentityName=Product -PflowName=ProductHmFlowJS -PdataFormat=json -PpluginFormat=sjs -PuseES=true
./gradlew mlLoadModules
./gradlew hubRunFlow -PentityName=Product -PflowName=ProductHmFlowJS -PbatchSize=100 -PthreadCount=4 -PsourceDB=emerald-hub-staging -PdestDB=emerald-hub-final
./gradlew mlUndeploy -Pconfirm=true
