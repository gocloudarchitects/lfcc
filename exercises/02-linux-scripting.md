# Linux Scripting

## Introduction to git

1. Open a github account and [create a repository](https://docs.github.com/en/get-started/quickstart/create-a-repo) where you keep study notes. This is a good personal resource and can be used to show competency, knowledge, and work ethic to potential employers. You can store:
   - Notes
   - A work log / diary
   - Configuration files
   - Code snippets
   - Links to resources
   - Personal projects (consider starting a new github repository for anything larger than a simple script)

2. To more readily manage your github repository, visit and follow the documenatation for [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

3. Visit [Red Hat Developers - Cheat Sheets](https://developers.redhat.com/cheat-sheets) and download the Git Cheat Sheet.  This document further explores git commands.

4. Fork the LFCC repository (navigate to the repository on the web and click the Fork button near the top right), so you can edit and save changes you would like to make.  If you find any errors, submit a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)


## Variables and the Environment

1. Set up a `.bashrc.d` folder and incorporate it into your environment with the file at `lfcc/linux/environment/bashrc.snippet` and add the functions and aliases from this lesson to the folder.

2. Can you think of any other simple functions or aliases? Try googling for helpful bash aliases or helpful bash functions and see if you can find anything you like. Save examples you would like to remember to an environment folder in your github project.

3. Right now, the greeting function doesn't have error handling. If you don't enter a name, it says `Hi, !`. Using the logic in the declutter function as an example and referring to the tests outlined in `man test`, can you modify it to output a different message if you don't provide a name?

## Job Control and Standard Streams

1. Review an awk tutorial such as [RIP Tutorial - Getting started with awk](https://riptutorial.com/awk/). Refer to this document as you do the following exercises. See if you can come up with an awk-based solution as well as a solution using the other listed commands.

2. Run `ip address show`, and see if you can extract only the ip address (without the subnet mask, such as "/24") for your primary network device. In virtualbox VM's built from vagrant, this should be enp0s3.  To do this, try the following commands. If you need some fuzzy matching, consider searching the Internet for regex examples that would match your desired string.
   - cut
   - tail
   - sed (particularly the 's' command)
   - grep/egrep
   - awk 

3. Can you select and output all IP addresses, no matter how many there are? Assume you want to get IPs for the loopback interface (lo), and any additional interfaces will have the format of `enp0s<number>`


## Bash Scripting

1. Visit [Red Hat Developers - Cheat Sheets](https://developers.redhat.com/cheat-sheets) and download the Bash Shell Scripting Cheat Sheet. This document provides additional snippets, such as integrated bash string manipulation functions, and data structures such as arrays (aka lists) and maps (aka dictionaries). They also cover conditional operators in more depth.

2. Review all the scripts in the LFCC github repo. Try and determine why they're done the way they are. Can you see a better or different way to accomplish the same task?

3. Write a script to include in your github repo's environment directory that will configure your environment:
   - create a `.bashrc.d` directory
   - add environment files to the `.bashrc.d` directory
   - add a section to the system's `.bashrc` to source these files, but ensure you don't add it twice
     - there are many ways you can accomplish this:
       - only run the script if it has never been run
       - test the bashrc to see if it contains a string
       - use a utility like `sed`
   - add a `~/.local/bin` directory
   - add any other scripts to the `~/.local/bin`
   - install applications you like
   - make it executable

## Python Virtual Environments and pip


1. Python has many tools beyond python and pip.  Review the documentation for [pipx](https://pypa.github.io/pipx/), specifically "How is it Different from pip?"  While pip provides a way to create and manage many isolated environments, pipx uses pip to install applications that are accessible to the regular user environment.

2. Install pipx per the documented instructions for your system.  Install the latest version of Ansible 5 using pipx. Install pip in a virtual environment, and install the latest verison of Ansible 4.9 in the venv. Switch between using the two versions of Ansible, and note how `which ansible` and `ansible --version` show different paths and versions in the output.

3. A Linux career may occasionally require that you build software, or provide a specific version of a library or application so that you can make some legacy code work. Familiarize yourself with environment and package management systems for any languages you work with or encounter regularly.
   - `Conda` is a package, dependency, and environment manager for all languages
   - `chruby` is a pip equivalent for Ruby
   - `npm` is a package manager for Node.js
   - and so on

# ANSWERS

## Variables and Environment

### Exercise 3

My solution for this exercise uses the `-z` test, which checks if the variable is zero-length:

```
greeting () {
  echo -n "What's your name? "
  read name
  test -z $name && echo "Fine, don't tell me >:("
  test ! -z $name && echo "Hi, ${name}!"
}
```

## Job Control and Standard Streams

### Exercise 1

There are many ways to accomplish this. I often just start throwing tools at the job until I solve it, which isn't the most computationally efficient, but I'm not usually building a program where I have to worry about efficiency.

Here was my first solution:

```bash
ip a | grep enp0s3$ | cut -f6 -d' ' | egrep -o "[0-9.]{7,15}"
```

1. First, I use grep to find the line that ends in `enp0s3` -- $ means end of line, just as ^ means beginning of the line.

2. Then, I use cut to select the CIDR, but `10.0.2.15/24` has the netmask, which I do not want. `cut` is a little clunky, because the leading spaces are each treated as a field delimiter. `awk` is better.

3. Finally, I use `egrep -o` to match any string that is 7-15 characters long and is made up of digits and periods.


One of the benefits of this method is it's easy to work through it piece by piece, checking your work as you go. However, I will present a more efficient solution in the next exercise.


### Exercise 2

In this exercise, we need to match any interface name and any IP.  We can construct it similarly to the previous command:

```bash
ip a | egrep 'enp0s[0-9]+$|lo$' | cut -f6 -d' ' | egrep -o "[0-9.]{7,15}"
```

The only difference is using egrep to match any interface at the end of the line.  Here is a more concise and efficient example using awk.

```bash
ip a | awk '$NF ~ /lo|enp0s[0-9]+/ {split($2,a,"/"); print array[1]}'
```

1. `$NF` means "number of fields", and returns the last field in the line.

2. `$NF ~ /lo|enp0s[0-9]+/` returns a line if the last field matches either `lo` or `enp0s` and any number of digits.

3. `split($2,a,"/")` splits the second field of the result (the full CIDR) into an array named `a`, using slash as the field delimiter

4. `print a[1]` prints the first field of the array.


## Bash Scripting

### Exercise 3

Most of this will be simple commands in a script.

1. Create directories

   You can do this with `mkdir`. It is common in scripts to use `mkdir -p`, since it will create necessary parent directories.  This won't be necessary with `.bashrc.d`, but probably will be necessary with `.local/bin`

2. Add environment files

   This can be accomplished with either `cat` or `cp`

3. Add a source section the `.bashrc`

   This is a little more complex, because the simplest way would be to echo or cat the information and append it to the file.  However, if you don't test to see if this script has been run, it will add a new entry to the file every time it's run.

   One solution is to insert an identifier line and then use that as the test:

   ```bash
   #!/bin/bash -x
   grep "#### CUSTOM SETTINGS ####" ~/.bashrc >/dev/null
   testvar=$(echo $?)
   echo $testvar
   if [ $testvar -eq 1 ]; then
     echo '#### CUSTOM SETTINGS ####' >> ~/.bashrc
     echo 'for file in ~/.bashrc.d/*.bashrc; do source "$file"; done' >> ~/.bashrc
   fi
   ```

## Python Virtual Environments and pip

### Exercise 2

1. Install pipx, and use pipx to install the latest version of Ansible 5

   Note that since pipx makes applications available to the normal user environment, you do not create the virtual environment.

   Here is what I ran.

   ```bash
   sudo apt install python3-venv python3-pip
   pip install pipx
   # log out and log back in to source new environment variables
   pipx ensurepath
   pipx install "ansible==5.*"
   pipx install "ansible==5.*" --include-deps
   ```

   You can also specify the ansible version with `ansible<6`

2. Create a virtual environment and install the latest version of Ansible 4

   ```bash
   vagrant@lab-vm:~$ mkdir venv
   vagrant@lab-vm:~$ python3 -m venv venv/ansible4
   vagrant@lab-vm:~$ source venv/ansible4/bin/activate
   (ansible4) vagrant@lab-vm:~$ pip install -U pip
   (ansible4) vagrant@lab-vm:~$ pip install "ansible==4.9.*"
   ```

   Another alternative for package version would be `ansible<4.10`. `ansible==4.9` would always install 4.9.0, regardless of whether there were later point releases.

3. Switch between the two different versions of Ansible and compare

   Note that Ansible versioning is undergoing a change, and the component packages still use the old versioning system for the time being. Ansible 4 is the same as 2.11, and Ansible 5 is the same as 2.12.

   ```bash
   (ansible4) vagrant@lab-vm:~$ which ansible
   /home/vagrant/venv/ansible4/bin/ansible
   (ansible4) vagrant@lab-vm:~$ ansible --version
   ansible [core 2.11.9] 
     config file = None
     configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
     ansible python module location = /home/vagrant/venv/ansible4/lib/python3.8/site-packages/ansible
     ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
     executable location = /home/vagrant/venv/ansible4/bin/ansible
     python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
     jinja version = 3.0.3
     libyaml = True
   (ansible4) vagrant@lab-vm:~$ deactivate
   vagrant@lab-vm:~$ which ansible
   /home/vagrant/.local/bin/ansible
   vagrant@lab-vm:~$ ansible --version
   ansible [core 2.12.3]
     config file = None
     configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
     ansible python module location = /home/vagrant/.local/pipx/venvs/ansible/lib/python3.8/site-packages/ansible
     ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
     executable location = /home/vagrant/.local/bin/ansible
     python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
     jinja version = 3.0.3
     libyaml = True
   ```

