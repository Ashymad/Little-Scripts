#!/bin/bash
# This scripts lists torrents from rtorrent that are currently stopped and gets path and name of the files.
# Then deletes files that are older than $AGE.
set -e

AGE=1209600 # 2 weeks
# Before using set username and password with your server access control credentials.
USERNAME=
PASSWORD=
# Path to xmlrpc binary
XMLRPC="/usr/local/bin/xmlrpc"
# Desinged to run at schedule (crontab).

HSHARR=( $( $XMLRPC -a $USERNAME:$PASSWORD https://localhost/RPC2 d.multicall2 -s "" -s stopped -s d.hash= | xmllint --xpath "string(//value)" - | awk 'NF > 0' ) )

for HSH in "${HSHARR[@]}"; do
    DIR=$( $XMLRPC -a $USERNAME:$PASSWORD https://localhost/RPC2 d.directory -s $HSH | xmllint --xpath "string(//string)" - )
    COUNT=$( $XMLRPC -a $USERNAME:$PASSWORD https://localhost/RPC2 d.size_files -s $HSH | xmllint --xpath "string(//i8)" - )
    COUNT=$(( $COUNT - 1 ))
    for IDX in $( seq 0 $COUNT ); do
	FILE=$( $XMLRPC -a $USERNAME:$PASSWORD https://localhost/RPC2 f.path -s "$HSH:f$IDX" | xmllint --xpath "string(//string)" - )
	F_PATH="$DIR/$FILE"
	if (( $IDX==0 && $(( $( date +%s ) - $( date +%s -r "$F_PATH" ) )) < $AGE )); then
	    break
	fi
	rm "$F_PATH"
	rmdir --ignore-fail-on-non-empty -p "${F_PATH%/*}"
	if (( $IDX==$COUNT )); then
	    $XMLRPC -a $USERNAME:$PASSWORD https://localhost/RPC2 d.erase -s $HSH
	fi
    done
done
