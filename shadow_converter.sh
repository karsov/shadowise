#!/bin/bash -e

if [ $# -ne 3 ]; then
	echo 'Usage: ./shadow_converter.sh <tag> <original tag> <app-config>'
	exit
fi

tag=${1}
orig_tag=${2}
app_config=${3}
chart_name=`cat helm/*/Chart.yaml | sed -nE "s/name: *(.+)/\1/p"`

sed -i '' -E "s/^version: .+$/version: $tag/" helm/public-concordances-api/Chart.yaml
sed -E "s/({{ *.Values.service.name *}})/\1-shadow/" helm/public-concordances-api/templates/deployment.yaml > helm/public-concordances-api/templates/deployment-shadow.yaml
sed -E "s/({{ *.Values.service.name *}})/\1-shadow/" helm/public-concordances-api/templates/service.yaml > helm/public-concordances-api/templates/service-shadow.yaml
sed -i '' -E "s/({{ *.Values.service.name *}})/\1-orig/" helm/public-concordances-api/templates/service.yaml
sed -i '' -E "s/(image: +.+):{{ *.Chart.Version *}}/\1:$orig_tag/" helm/public-concordances-api/templates/deployment.yaml
sed -i '' -E "s/({{ *.Values.service.name *}})/\1-orig/" helm/public-concordances-api/templates/deployment.yaml

helm upgrade $chart_name "./helm/$chart_name" --install --values="$app_config"
