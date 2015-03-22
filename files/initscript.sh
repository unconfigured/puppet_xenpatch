#!/bin/bash

waitfortoolstack() {
  time=`date +%s`
  xe host-list >/dev/null 2>&1
  while [ $? != 0 ]; do
    [ $((`date +%s`-$time)) -gt 60 ] && { 
      logger -s local0.err \
        "timeout waiting for toolstack - cannot apply patches"; 
      exit; }
    sleep 1
    xe host-list >/dev/null 2>&1
  done
}

patchinfo() {
  [ ! -z "$2" ] && label="name-label=$2"
  echo "`xe patch-list $label | sed 's/(.*)//' | \
          grep "$1" | awk '{print $3}' | sort -n`"
}


[ "$1" != "start" ] && exit

waitfortoolstack

patches=`patchinfo name-label`

for patch in $patches; do

  guidance=`patchinfo after-apply-guidance $patch`
  uuid=`patchinfo uuid $patch`
  hosts=`patchinfo hosts $patch`

  echo -ne "\tchecking patch $patch:"

  # Already applied?
  [ ! -z "$hosts" ] && { echo -e "\t\tapplied"; continue; }
  echo -e "\t\tneed installation"

  # Disable start and creation of VMsA
  if [ ! -f /etc/patch_in_progress ]; then
    xe host-disable
    touch /etc/patch_in_progress
  fi

  logger local0.info \
    "applying patch $patch with after apply guidance \"$guidance\""; 
  xe patch-pool-apply uuid=$uuid
  xe patch-clean uuid=$uuid
  waitfortoolstack

  case $guidance in
    "restartXAPI")
      echo -e "\t\t\t\trestarting Toolstack"
      /opt/xensource/bin/xe-toolstack-restart
      ;;
    "restartHost")
      echo -e "\t\t\t\trebooting Host"
      reboot
      ;;
  esac
done

# All run well
if [ -f /etc/patch_in_progress ]; then
  xe host-enable
  rm -f /etc/patch_in_progress
fi
echo -e "\tAll patches applied"

