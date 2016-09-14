#!/bin/bash

# Select between recent stable (e.g. 1.4) or recent unstable (e.g. 1.5dev)
if [[ $# == 3 ]]; then
  if [[ $3 != "" ]] || [[ $3 != "bwc_license" ]]
  then
    BWC_LICENSE_KEY="$3"
  else
    echo -e "Please pass the license, e.g. set env ENV['BWC_LICENSE']"
    exit 2
  fi
fi

DEBTEST=`lsb_release -a 2> /dev/null | grep Distributor | awk '{print $3}'`
RHTEST=`cat /etc/redhat-release 2> /dev/null | sed -e "s~\(.*\)release.*~\1~g"`

if [[ -n "$RHTEST" ]]; then
  echo "*** Detected Distro is ${RHTEST} ***"
  hash curl 2>/dev/null || { sudo yum install -y curl; sudo yum install -y nss; }
  sudo yum update -y curl nss
elif [[ -n "$DEBTEST" ]]; then
  echo "*** Detected Distro is ${DEBTEST} ***"
  sudo apt-get update
  sudo apt-get install -y curl
else
  echo "Unknown Operating System."
  echo "See list of supported OSes: https://github.com/StackStorm/st2vagrant/blob/master/README.md."
  exit 2
fi

curl -sSL https://brocade.com/bwc/install/install.sh | bash -s -- --user=$1 --password=$2 --license=$3