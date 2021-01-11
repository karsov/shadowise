#!/bin/bash -e

if [ $# -ne 1 ]; then
	echo 'Usage: ./shadow_converter.sh <tag to compare with>'
	exit
fi

tag=${1}

cd helm/*

sed -E "s/({{ *.Values.service.name *}})/\1-shadow/" templates/deployment.yaml > templates/deployment-shadow.yaml
sed -E "s/({{ *.Values.service.name *}})/\1-shadow/" templates/service.yaml > templates/service-shadow.yaml
sed -i '' -E "s/({{ *.Values.service.name *}})/\1-orig/" templates/service.yaml
sed -i '' -E "s/(image: +.+):{{ *.Chart.Version *}}/\1:$tag/" templates/deployment.yaml
sed -i '' -E "s/({{ *.Values.service.name *}})/\1-orig/" templates/deployment.yaml
