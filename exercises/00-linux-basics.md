# Linux Basics

## Preparing the environment

1. Go to app.vagrantup.com and search for major distributions such as Debian, CentOS Stream, and openSUSE Tumbleweed.  Create a new directory in your vagrant folder and create a Vagrantfile by using the `vagrant init` command for the desired distro. Then run (`vagrant up`) and connect to the VM (`vagrant ssh`).  If you like, take a look around and run some commands.  When you're finished, run `vagrant halt` to shut down the VM.

2. Review the [Vagrant documentation](https://www.vagrantup.com/docs/) and make some changes to your VM.  For example:
  - Create an additional network interface (review the networking section, or use the commented examples in the generated Vagrantfile)
  - Modify the CPU or RAM allocation for the VM (review the Providers > Virtualbox page, or one of the Vagrantfiles in the LFCC github project)

3. Run `vagrant help` and review the subcommands and options. If you have questions about a subcommand, review its help output, for example `vagrant help box`

4. Remember to clean up your VM by running `vagrant destroy`


## Linux Command Line Basics

We've reviewed a number of commands, but there is so much more to explore.  Linux and Open Source are about engaging in the community and using open documentation.

1. Learn more about the documentation system by reviewing `man man` and `man info`

2. Visit [Red Hat Developers - Cheat Sheets](https://developers.redhat.com/cheat-sheets) and download both the Linux Commands Cheat Sheet and Intermediate Linux Cheat Sheet (create a free Red Hat developer account if you don't have one already).  Review the examples and try them out.  Use the help output and man pages to learn more about the commands. Many of these commands are covered later in this course.

3. Pay special attention to the `find` examples from the Intermediate Linux document.  Find is a powerful utility, and you should know the basics.  Try out the examples, and review the examples at the bottom of the find man page.  Try to construct the following searches:
   - a) Find all files under `/usr` with a name that contains the word "network", case insensitive.
   - b) Find files (excluding directories) under the `/etc` folder that are larger than 5k, and run an MD5 hash on them (command: `md5sum <file>`) -- HINT: Review the man page for the example that uses the `-exec` option.

Answers:
3a: find /usr -name "*network*"
3b: find /etc -type f -size +5k -exec md5sum {} \;

Note that there are different ways of accomplishing 3b.  The documentation has a solution using xargs to pipe to the md5sum command, which would be:  `find /etc -type f -size +5k | xargs md5sum`.  Compare this output to the output if we pipe directly to md5sum: `find /etc -type f -size +5k | md5sum`. Why is this?  What is xargs doing?  What is md5sum doing?

4. After reviewing the solutions to 3b, try using the same search to create a tarball, with the following variations:
   - a) `find /etc -type f -size +5k -exec tar cvf /tmp/example-1.tar.gz {} \;`
   - b) `find /etc -type f -size +5k | xargs tar cvf /tmp/example-2.tar.gz`
   - c) `find /etc -type f -size +5k | tar cvf /tmp/example-3.tar.gz` (fails)

  Why does the third example fail? Review example-1 and example-2 files with `tar tf /tmp/<filename>`.  Can you explain why the archives turned out so differently?

## Linux Text Editing

Run `vimtutor` and do the exercises at least through the Lesson 4 Summary.

## User management and file permissions

Try setting up users and a shared group with the following parameters:
1. alice and bob are members of the `product` group
2. The `/opt/product` directory should be writable by members of the `product` group.  Any product group member can read or delete any file in the `/opt/product` directory. Non-members should have read-only access.
3. alice and charlie are members of the `finance` group
4. The `/opt/finance` should be writable by members of the `finance` group. Files created by one user should be editable by other users, but only deletable by the file owner.
5. Non-members should not be able to read or write to the finance directory.

ANSWER:

Most user and permissions management must be done as root.  Run the following commands with sudo, or enter a root shell by running `sudo -i`

1. Create groups and users.  I show the full output of the creation command for alice.

    ```bash
    root@lab-vm:~# groupadd product
    root@lab-vm:~# groupadd finance
    root@lab-vm:~# adduser alice
    Adding user `alice' ...
    Adding new group `alice' (1004) ...
    Adding new user `alice' (1002) with group `alice' ...
    Creating home directory `/home/alice' ...
    Copying files from `/etc/skel' ...
    New password: 
    Retype new password: 
    passwd: password updated successfully
    Changing the user information for alice
    Enter the new value, or press ENTER for the default
    	Full Name []: 
    	Room Number []: 
    	Work Phone []: 
    	Home Phone []: 
    	Other []: 
    Is the information correct? [Y/n] y
    root@lab-vm:~# usermod -aG finance,product alice
    root@lab-vm:~# adduser bob
    root@lab-vm:~# usermod -aG product bob
    root@lab-vm:~# adduser charlie
    root@lab-vm:~# usermod -aG finance charlie
    ```

2. Create directories and apply ownership.


    ```bash
    root@lab-vm:~# mkdir /opt/{finance,product}
    root@lab-vm:~# cd /opt/
    root@lab-vm:/opt# ls
    finance  product
    root@lab-vm:/opt# chown :finance finance
    root@lab-vm:/opt# chown :product product
    root@lab-vm:/opt# ls -l | egrep 'finance|product'
    drwxr-xr-x 2 root finance 4096 Mar 20 13:14 finance
    drwxr-xr-x 2 root product 4096 Mar 20 13:14 product
    ```

3. Apply permissions to each directory


    ```sh
    root@lab-vm:/opt# chmod 2775 product
    root@lab-vm:/opt# chmod 5770 finance
    ```

    The requirements for the product directory are:
    - Full read and write permissions for the group, which is accomplished setting full permissions (read, write, execute) for user and group:
      - numeric: -77- mask
      - symbolic: ug+rwx
    - Read only access to non-members, which is accomplished by setting read and execute permission bits for `other`:
      - numeric: ---5 mask
      - symbolic: o+rx
    - Files are editable by members of the group, which is accomplished with the setgid bit:
      - numeric: 2--- mask
      - symbolic: g+s

    We add all the masks together to get the command above, or we could also run:

    ```sh
    root@lab-vm:/opt# chmod ug+rwx,o+rx,g+s product
    ```

    The requirements for the finance directory are:
    - Full read and write permissions for the group, give read, write, execute to user and group.
      - numeric: -77- mask
      - symbolic: ug+rwx
    - No access for non-members, which is accomplished by removing all permission from `other`:
      - numeric: ---0 mask
      - symbolic: o-rwx (note the minus instead of the plus)
    - New files are readable and writable by other group members. In this case we need to set the setgid bit (2) and the sticky bit (1), which in numeric system equals 3:
      - numeric: 3--- mask
      - symbolic: g+s,o+t

    We add all the masks together to get 3775, or can also run the following:

    ```sh
    root@lab-vm:/opt# chmod ug+rwx,o-rwx,g+s,o+t finance
    ```

### Package Management

1. Explore the dpkg utility.  dpkg can be thought of as the manual tool for the apt package management suite.  Reviewing the help and man page can give you a better idea of how Ubuntu's package management works.

2. Look in the `/etc` folder and use `dpkg -S` to find packages that own files. Note that it is a string search:
   - Try `dpkg -S /etc/shadow` vs `dpkg -S shadow`
   - Try `dpkg -S /etc`
   - Try `dpkg -S /boot`

3. Use `dpkg -L` to get a list of files installed by a package.  Run `apt list --installed` and select some packages to review.

4. If you're interested in how packages are built, review the [Ubuntu Packaging Guide](https://packaging.ubuntu.com/html/)

5. Red Hat uses another package format and build system. If interested, review their RHEL8 guide on [Packaging and Distributing Software](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/packaging_and_distributing_software/index)

### Linux File Hierarchy

1. Review the contents of some packages using `dpkg -L <package>` and consider why certain files were placed where.

   Interesting packages to consider:
   - openssh-client
   - openssh-server
   - sudo
   - vim

2. Review the /proc and /sys filesystems and try to get a sense of what information you can find in each location.

   - check the man pages with `man procfs` and `man sysfs`
   - use `cat` to view the contents of nodes
   - review the README file at `/sys/kernel/tracing/README`
   - investigate processes by looking at the files until its pid directory at `/proc/<pid>`
     - you can discover the pid by running `ps aux | grep <program>` or `pidof <program>` (try `pidof sshd`)