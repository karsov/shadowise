#!/bin/bash -e

primary="orig"
candidate="shadow"

for i in "$@"
do
case $i in
	--promote-shadow)
	primary="shadow"
	candidate="orig"
	shift # past argument with no value
	;;
	*)
		# unknown option
	;;
esac
done

if [ $# -ne 1 ]; then
	echo 'Usage: ./shadow_converter.sh [--promote-shadow] <tag to compare with>'
	exit
fi

tag=${1}

cd helm/*

sed -E "s/({{ *.Values.service.name *}})/\1-shadow/" templates/deployment.yaml > templates/deployment-shadow.yaml
sed -E "s/({{ *.Values.service.name *}})/\1-shadow/" templates/service.yaml > templates/service-shadow.yaml

sed -i '' -E "s/%primary%/$primary/" templates/deployment-diferencia.yaml
sed -i '' -E "s/%candidate%/$candidate/" templates/deployment-diferencia.yaml

sed -i '' -E "s/({{ *.Values.service.name *}})/\1-orig/" templates/service.yaml
sed -i '' -E "s/(image: +.+):{{ *.Chart.Version *}}/\1:$tag/" templates/deployment.yaml
sed -i '' -E "s/({{ *.Values.service.name *}})/\1-orig/" templates/deployment.yaml
