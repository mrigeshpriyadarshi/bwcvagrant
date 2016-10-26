#!/bin/bash
#
# Vagrant script to Install the BWC
#
# Author: Mrigesh Priyadarshi

os_check()
{
    DEBTEST=$(lsb_release -a 2> /dev/null | grep Distributor | awk '{print $3}')
    RHTEST=$(cat /etc/redhat-release 2> /dev/null | sed -e "s~\(.*\)release.*~\1~g")

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
      echo "See list of supported OSes: https://github.com/mrigeshpriyadarshi/bwcvagrant/blob/master/README.md."
      exit 2
    fi
}

check_license()
{
    if [[ ${1} != "" ]] || [[ ${1} != "bwc_license_key" ]]; then
      BWC_LICENSE_KEY="$1"
    else
      echo -e "Please pass the license, e.g. set env ENV['BWC_LICENSE']"
      exit 2
    fi
}

bwc_install()
{
  os_check
  curl -sSL https://brocade.com/bwc/install/install.sh | bash -s -- --user=${USER} --password=${PSSWD} --license=${BWC_LICENSE_KEY}
}

bwc_install_suite()
{
  bwc_install
  curl -sSL https://brocade.com/bwc/install/install-suite.sh  | bash -s -- --user=${USER} --password=${PSSWD} --license=${BWC_LICENSE_KEY} --suite=bwc-ipfabric-suite
}

setToken()
{
  export ST2_AUTH_TOKEN=$(st2 auth ${USER} -p ${PSSWD} -t)
}

campus_ztp_pack()
{
  st2 run packs.install repo_url=https://github.com/tbraly/campus_ztp packs=campus_ztp
}

vadc_pack()
{
  st2 run packs.install packs=vadc repo_url=https://github.com/tuxinvader/st2contrib packs=vadc
}

openstack_pack()
{
  st2 run packs.install repo_url=https://github.com/stackstorm/openstack packs=openstack
}

bwc_packs()
{
  setToken
  for packs in ${BWC_PACKS}; do
      if [[ ${packs} == "openstack" ]]; then
          openstack_pack
      elif [[ ${packs} == "vadc" || ${packs} == "vdx"  ]]; then
        echo "vdx"
          vadc_pack
      elif [[ ${packs} == "campus_ztp" || ${packs} == "icx"  ]]; then
        echo "icx"
          campus_ztp_pack
      else
          st2 run packs.install repo_url=https://github.com/stackstorm/st2contrib packs=${packs}
      fi
  done
}

#### Main Script ####
# Check argument passed and configure BWC accordingly
if [[ $# == 4 ]]; then
    USER=${1}
    PSSWD=${2}
    check_license "$3"
    if [[ $4 == '' ]]; then
      bwc_install
    else
      bwc_install_suite
      bwc_packs
    fi
else
      echo -e "Please pass the params, e.g. set env ENV['BWC_LICENSE'], ENV['ST2PASSWORD'] and ENV['BWC_SUITES']"
      exit 2
fi