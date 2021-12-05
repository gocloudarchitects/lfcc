Standard Streams
----------------

stdin - the input stream for a process, file descriptor 0

stdout - the main output stream, file descriptor 1

stderr - alternate error output, file descriptor 2


Redirects
---------

cmd1 | cmd2

  = pipe standard output of cmd1 to standard input of cmd2

cmd > file

  = redirect cmd standard output to file, create or overwrite

cmd >> file

  = redirect cmd standard output to file, create or append

cmd < file

  = send a file to standard input

Manipulating stdio
------------------

1>, 1>> - explicit stdout

2>, 2>> - explicit stderr

&>, &>>, |& - send both stdout and stderr

<&0 - explicitly connect stdin

1>&2 - send stdout to stderr

2>&1 - send stderr to stdout

