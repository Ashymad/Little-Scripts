#!/bin/bash
# This scripts lists torrents from rtorrent that are currently stopped and gets path and name of the files.
# Then deletes files that are older than $AGE.
AGE=1814400 # 3 weeks
# Before using set username and password with your server access control credentials.
USERNAME=
PASSWORD=
# Desinged to run at schedule (crontab).

HSHARR=( $( xmlrpc -a $USERNAME:$PASSWORD https://localhost/RPC2 d.multicall -s stopped -s d.get_hash= | xmllint --xpath "string(//value)" - | awk 'NF > 0' ) )

for HSH in "${HSHARR[@]}"; do
	DIR=$( xmlrpc -a $USERNAME:$PASSWORD https://localhost/RPC2 d.get_directory -s $HSH | xmllint --xpath "string(//string)" - )
	COUNT=$( xmlrpc -a $USERNAME:$PASSWORD https://localhost/RPC2 d.get_size_files -s $HSH | xmllint --xpath "string(//i8)" - )
	COUNT=$( expr $COUNT - 1 )
	for IDX in $( seq 0 $COUNT ); do
		FILE=$( xmlrpc -a $USERNAME:$PASSWORD https://localhost/RPC2 f.get_path -s $HSH -i $IDX | xmllint --xpath "string(//string)" - )
		F_PATH="$DIR/$FILE"
		if (( $IDX==0 && $( expr $( date +%s ) - $( date +%s -r "$F_PATH" ) ) < $AGE )); then
			break
 		fi
		rm "$F_PATH"
		rmdir --ignore-fail-on-non-empty -p "${F_PATH%/*}"
		if (( $IDX==$COUNT )); then
			xmlrpc -a $USERNAME:$PASSWORD https://localhost/RPC2 d.erase -s $HSH
		fi
	done
done
