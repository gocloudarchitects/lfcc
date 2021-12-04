#!/usr/bin/env bash

if [ $# -eq 0 ]; then
	echo "You passed no parameters to this command!"
        exit 1
else
	echo "You passed $# parameters:"
	for i in $@; do
		echo "  - $i"
	done
fi

echo
echo "Thanks for playing"
exit 0

