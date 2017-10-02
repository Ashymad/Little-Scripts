#!/bin/bash

# Download files from server
rsync -vrzPL --append-verify $1:$2/ $3
# Check if hash matches, then delete if it does
cd $3
ssh $1 "{ cd $2; find . -type l -print0; }" | xargs -0 -I{} sh -c "ssh $1 \"{ cd $2; md5sum \\\"{}\\\"; }\" | md5sum -c - && ssh $1 \"{ cd $2; rm -v \\\"{}\\\"; }\";"
# Remove any empty directories
ssh $1 find $2/ -mindepth 1 -type d -empty -delete

