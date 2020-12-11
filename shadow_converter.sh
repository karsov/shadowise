#!/bin/bash -e

if [ $# -ne 3 ]; then
	echo 'Usage: ./shadow_converter.sh <tag> <original tag> <app-config>'
	exit
fi

tag=${1}
orig_tag=${2}
app_config=${3}

cd helm/*

sed -i '' -E "s/^version: .+$/version: $tag/" Chart.yaml
sed -E "s/({{ *.Values.service.name *}})/\1-shadow/" templates/deployment.yaml > templates/deployment-shadow.yaml
sed -E "s/({{ *.Values.service.name *}})/\1-shadow/" templates/service.yaml > templates/service-shadow.yaml
sed -i '' -E "s/({{ *.Values.service.name *}})/\1-orig/" templates/service.yaml
sed -i '' -E "s/(image: +.+):{{ *.Chart.Version *}}/\1:$orig_tag/" templates/deployment.yaml
sed -i '' -E "s/({{ *.Values.service.name *}})/\1-orig/" templates/deployment.yaml

chart_name=`cat Chart.yaml | sed -nE "s/name: *(.+)/\1/p"`
helm upgrade $chart_name . --install --values="app-configs/$app_config"
