#!/bin/bash
declare -a resources=("server" "volume" "router" "floating ip" "subnet" "network" "flavor" "image") 

if [ "$1" != "--run" ]; then
  echo "This is a dry run, no changes will be made"
  for i in "${resources[@]}"; do
    echo "### $i ###"
    openstack $i list
  done
  echo "To delete these resources, run this script with the '--run' flag."
elif [ "$1" == "--run" ]; then
  echo "Deleting resources in 5 seconds..."
  echo "Hit Ctrl-C to cancel!"
  sleep 5
  for i in "${resources[@]}"; do
    echo 'Running: openstack $i list -c ID -f value 2>/dev/null | xargs -n1 openstack $i delete 2>/dev/null'
    openstack $i list -c ID -f value 2>/dev/null | xargs -n1 openstack $i delete 2>/dev/null;
  done
  echo "Done!"
fi

