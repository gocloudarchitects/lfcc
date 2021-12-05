#!/bin/bash

counter=0
while [ $counter -lt 300 ]; do
	sleep 1
	let counter=counter+1
done
