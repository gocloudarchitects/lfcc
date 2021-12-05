#!/bin/bash
group_membership="$(groups)"

if [ -f /etc/os-release ]; then
	source /etc/os-release
	distribution=$ID
else
	echo "No /etc/os-release file!"
	echo "This script won't work."
	exit 1
fi

case $distribution in
	ubuntu) sudo_group=sudo ;;
	debian) sudo_group=sudo ;;
	centos) sudo_group=wheel ;;
	rhel) sudo_group=wheel ;;
	fedora) sudo_group=wheel ;;
	*) echo "I don't recognize this distribution! Exiting..."; exit 1;;
esac

for i in $group_membership; do
	if [ "$i" == "$sudo_group" ]; then
		echo "You have sudo privileges!"
		exit 0
	fi
done

echo "No sudo privileges found!"
exit 1

