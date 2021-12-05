Linux operands
--------------

cmd1 ; cmd2
  = wait until command is complete, then continue

cmd1 & cmd2
  = send command to background and continue immediately

Redirects
---------

cmd1 | cmd2
  = pipe standard output of the command to standard input of the next command

cmd > file
  = redirect cmd standard output to file, create or overwrite

cmd >> file
  = redirect cmd standard output to file, create or append


Logical operators
-----------------
cmd1 && cmd2
  = AND operator: if cmd1 exits with exit code 0 (success), execute cmd2

cmd1 || cmd2 
  = OR operator: if cmd1 exits with exit code 1 (failure), execute cmd2
