#!/bin/bash

# Download files from server
rsync -vrzPL --append-verify $1:$2/ $3
# Check if hash matches, then delete if it does
ssh $1 find $2/ -type l -print0 | xargs -0 -I {} sh -c "ssh $1 \"md5sum \\\"{}\\\"\" | md5sum --status -c - && ssh $1 \"rm \\\"{}\\\"\";"
# Remove any empty directories
ssh $1 find $2/ -mindepth 1 -type d -empty -delete

