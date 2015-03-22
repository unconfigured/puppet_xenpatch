rm -f updates.xml
wget http://updates.xensource.com/XenServer/updates.xml
for x in `cat updates.xml | sed -n '/build-number="70446c"/,/version/p' | grep uuid | cut -d'"' -f2`; do url=`grep $x updates.xml | sed -n 's/<patch\(.*\)>[ ]*$/\1/p' | sed -n 's/.*patch-url=.\(.[^"]*\).*/\1/p'`; wget -nc "$url"; done
