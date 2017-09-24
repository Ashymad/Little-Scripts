#!/bin/sh

DB_PATH="/mnt/data/Documents/Workspace/KeePass/Databa5e.kdbx"

! test -d /tmp/sync && mkdir /tmp/sync
rsync -aP 5hy.men:~/Backup/Databa5e.kdbx /tmp/sync/ &&

cp "$DB_PATH" "${DB_PATH}.bckp.$(date +%Y-%m-%d)" &&

keepassxc-cli merge -s "$DB_PATH" /tmp/sync/Databa5e.kdbx &&

rsync -aP "$DB_PATH" 5hy.men:~/Backup/Databa5e.kdbx
