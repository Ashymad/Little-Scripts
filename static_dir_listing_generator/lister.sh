#!/bin/bash

DIR="$1"
OUT="$2"

if [ "$DIR" == "" ]; then
 DIR="mods"
 OUT="mods.html"
fi

cd /home/minecraft/nweb/public_html

cat > $OUT << EOF
 <html>
  <head>
   <title>Index of $(readlink -f $DIR)</title>
  </head>
  <body>
   <h1>Index of $(readlink -f $DIR)<h1>
   <table><tr><th>Name</th><th>Last modified</th><th>Size</th></tr><tr><th colspan="5"><hr></th></tr>
EOF
for f in `ls -p $DIR | grep -v / | sort -f`; do
  cat >> $OUT << EOF
   <tr><td><a href="$DIR/$f" download>$(basename "$f")</a></td><td align="right">$(date -r "$DIR/$f" +"%d-%b-%Y %H:%M") </td><td align="right">$(du -h "$DIR/$f" | cut -f1)</td><td>&nbsp;</td></tr>
EOF
done
cat >> $OUT << EOF
 <tr><th colspan="5"><hr></th></tr>
  </table>
  </body>
 </html>
EOF
