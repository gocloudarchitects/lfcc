#!/usr/bin/env bash
input="$(cat -)"
for i in $input; do
	echo Received on stdin: $i
done
