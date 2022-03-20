#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root:  sudo ./breakboot.sh"
  exit
fi

echo "WARNING: This script will break your system as part of an exercise."
echo "         Only run this inside a VM designated for this exercise."
echo
read -p "Are you sure you want to break your system? (Y/N)" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
elif [[ $REPLY =~ ^[Yy]$ ]]
  then
  usermod root --password `date +%s | md5sum -z | awk '{print $1}'` &>/dev/null 
  usermod vagrant --password `date +%s | md5sum -z | awk '{print $1}'` &>/dev/null
  deluser vagrant &>/dev/null
  reboot
fi
