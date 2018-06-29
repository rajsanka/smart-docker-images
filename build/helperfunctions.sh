#!/bin/bash
die () {
    echo >&2 "$@"
    exit 1
}

function jsonval {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $2`
        echo ${temp##*|}
}

function postjson {
    json=`curl -H 'Session-Id: '$5'' -H 'Origin: '$demodomain'' -XPOST 'http://'$server':'$port'/'$1'/'$2'/'$3 -d "$4"`
    echo $json
}

