#!/bin/bash

if [ $# -eq 0 ]
	then
		echo "no arguments"
		exit 1
fi

FILENAME="$@"
FILEBASE="${FILENAME%.*}"
PREFIX=".\/..\/fig\/gph\/"
SUFFIX=".pdf"
OLD="{"${FILEBASE}${SUFFIX}"}"
NEW="{"${PREFIX}${FILEBASE}${SUFFIX}"}"

echo "replacing ${OLD} with ${NEW} in ${FILENAME}"
sed -i -e 's/'${OLD}'/'${NEW}'/g' ${FILENAME}
