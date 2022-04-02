# Linux Troubleshooting

## CLI Tools

We briefly touched on grep before, but we'll review a little more in depth, including simple regular expressions.  Extract the log at `files/example.zip` (pass: grep_exercise), and perform the following exercises.

- Refer to [this regex quickstart](https://quickref.me/regex)
- Use `egrep` or `grep -E` to enable extended regular expressions.
- Many of these commands will produce lots of output.  You can pipe into less and retain color by running `egrep --color=always [options] [search query] [file] | less -R`
- You can search for multiple expressions by using the pipe as an OR operator, eg `egrep "this|that" file_to_search`
- You can also chain grep commands together, which works somewhat like an AND operator, eg `grep "this" file | grep "that"`

1. Match all log entries from March 18th, between 4pm and 5pm
2. Match all log entries from March 17th or 18th, between 4pm and 5pm
3. Match all log entries from March 17th at 4pm to March 18th at 5pm
4. Find all kernel messages about usb from before the 15th

**HINT:** the search query may not have the same logical structure as the description.  Any solution is fine.

## Troubleshooting System Resources

Run `ps aux` and/or `pstree -p` and pick some processes to learn about.

1. Look at files in the `/proc/<pid>` subdirectory for a process you want to learn about.

2. Run `strace -p <pid>` to see system calls for the process. If you find an active process, try filtering for certain system calls.

   **HINT:** Try opening two ssh sessions to the same system, and using strace in one shell to minotor the ssh session or bash shell of the other.  What happens when you type, run commands, open files?

3. Run `which <process name>` to find the path to the binary, and run `ldd /path/to/binary` to see which libraries it depends upon.

## Network Troubleshooting

1. Check out [Free APIs at APIpheny](https://apipheny.io/free-api/) for an list of public APIs. Find an API you would like to play with, and use `curl` to navegate and retrieve information.

2. For an additional API challenge, try writing a script that mixes two or more APIs.  [Meme Generator](https://rapidapi.com/ronreiter/api/meme-generator) takes two text fields, so try combining with a random text generator, such as [Cat Facts](https://catfact.ninja/), or get a joke from the [Jokes API](https://github.com/15Dkatz/official_joke_api) and send it through [Yoda Translator](https://funtranslations.com/api/#yoda).

3. Run tcpdump to capture your API calls and DNS requests.
   - Filter out other traffic
   - Try filtering only outgoing traffic, then only incoming

   **HINT:** You may want to Google tcpdump examples, since the documentation is extensive and hard to wade through.

## System Reports - sosreport and xsos

1. Examine sosreport options. Determine how to enable and disable plugins, and collect all logs since 7 days ago.

2. Take a sosreport from one of your test systems.  Extract it and review outputs in `sos_commands`.  Take some of the commands relating to processing, memory, and disks, and try the commands on a live system.  Run `--help` and try different options.

# ANSWERS

## CLI Tools

1. Match all log entries from March 18th, between 4pm and 5pm

   This is deceptively simple. The only element that isn't just part of the string is the carat `^`, which indicates the beginning of the line.

   ```bash
   grep "^Mar 18 16:" example-syslog.log
   ```

2. Match all log entries from March 17th or 18th, between 4pm and 5pm

   This one is a bit more complex. I use egrep so I can begin to use extended operators, and use brackets to indicate what options for that character.  I also provide an alternate solution.

   ```bash
   egrep "^Mar 1[78] 16" example-syslog.log
   #alternate
   egrep "^Mar 17 16|^Mar 18 16" example-syslog.log
   ```

3. Match all log entries from March 17th at 4pm to March 18th at 5pm

   For this example, I use number ranges to simplify the expression, and simply use several OR operators.

   ```bash
   egrep "^Mar 17 1[6-9]|^Mar 17 2[0-3]|^Mar 18 0|^Mar 18 1[0-7]" example-syslog.log
   ```

4. Find all kernel messages about usb from before the 15th

   With what we've already done, this should be fairly easy. The log only goes back to the 13th, but I include a wider range because why not.  I then pipe it into another grep for kernel and usb.  Note the -i operator, which makes the search case insensitive.

   Below you can see the number of lines of difference returned, which I count with the wordcount command, with a switch to count lines: `wc -l`


   ```bash
   egrep "^Mar 1[0-4]" example.log | grep -i kernel | grep -i usb

   # comparing case insensitivity
   egrep "^Mar 1[0-4]" example.log | grep -i kernel | grep -i usb | wc -l
   958
   egrep "^Mar 1[0-4]" example.log | grep kernel | grep usb | wc -l
   837
   ```

## Network Troubleshooting - Exercise 3

The following is a command that will capture both incoming and outgoing traffic.  Note that the TCP restriction on ports 80 and 443 are unlikely to be necessary, since you're unlikely to find UDP traffic on those ports.  Similarly, the UDP restriction on DNS is perhaps overkill, since DNS is designed to be able to fail over to TCP in environments with restrictions on UDP traffic.

```bash
tcpdump -i any '(port 80 or port 443 and tcp) or (port 53 and udp)'
```

To specify incoming or outgoing, add the local address on the correct interface as the source or destination:

```bash
# outgoing
tcpdump -i any src 10.0.2.15 and '(port 80 or port 443 and tcp)' or '(port 53 and udp)'
# incoming
tcpdump -i any dst 10.0.2.15 and \(port 80 or port 443 and tcp\) or \(port 53 and udp\)
```

Please note that all three commands use quotes differently, though all are valid. `tcpdump` inteprets the expressions the same, but it's necessary to escape or quote the parentheses, since they have special meaning to the bash shell.

## System Reports - Exercise 1

To enable and disable plugins, first run `sudo sos report -l` to list plugins and their status.  Enable plugins with `-e <plugin>` or disable with `-n <plugin>`. Consider the `filesys.lsof` plugin, `networking.traceroute`, or `libraries.ldconfigv`

To collect all logs from a particular date (such as Jan 1st, 2022), use `--all-logs --since 20220101` 