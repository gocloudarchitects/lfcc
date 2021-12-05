Job Control
-----------

cmd1 ; cmd2
  = wait until command is complete, then continue

cmd1 & cmd2
  = send command to background and continue immediately

Logical operators
-----------------
cmd1 && cmd2
  = AND operator: if cmd1 exits with exit code 0 (success), execute cmd2

cmd1 || cmd2 
  = OR operator: if cmd1 exits with exit code 1 (failure), execute cmd2
