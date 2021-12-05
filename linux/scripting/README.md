Special Variables
-----------------

- $@ - all parameters
- $# - the number of params
- $? - exit status of last command
- $$ - pid of shell
- $- - shell options
- $! - pid of last command sent to bg
- $(cmd) - return the results of the command

Bash functions
--------------

if, elif, else
--------------

```
if [ $var1 -eq $var2 ]; then
  echo "Do some work"
elif [ $var1 -gt $var2]; then
  echo "Do something else"
else
  echo "A third thing
fi
```

for
---

```
for item in list of items; do
  echo $item
done
```

case
----

```
case $@ in
  match1)
	  echo "command"
		;;
	match2 | match3)
	  echo "command2"
		echo "another"
		;;
	*)
	  echo "anything else"
		;;
esac
```
while
-----

```
while read line; do
	echo $line
done < inputfile.txt
```

or:

```
counter=1
while [ $counter -lt $limit ]; do
  counter = counter+1
	echo "do other stuff"
done
```
