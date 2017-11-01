#!/bin/bash

FILEEXTENSION="*.pdf_tex"
COMMAND="./substitute.sh"

for FILE in $FILEEXTENSION;
	do $COMMAND "$FILE";
done;
