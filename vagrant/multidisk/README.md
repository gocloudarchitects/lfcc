# Multidisk Vagrant

This Vagrantfile depends on the experimental `disks` plugin.

In MacOS or Linux, you can enable this by running:

```bash
export VAGRANT_EXPERIMENTAL="disks"
```

In Windows, it depends on whether you are using the classic command prompt, or 
PowerShell

```bash
# Classic command prompt
set VAGRANT_EXPERIMENTAL=disks
# PowerShell
$Env:VAGRANT_EXPERIMENTAL = "disks"
```

# Enabling permanently

## WINDOWS

From Microsoft:

> To make a persistent change to an environment variable on Windows, use the System Control Panel. Select Advanced System Settings. On the Advanced tab, click Environment Variable.... You can add or edit existing environment variables in the User and System (Machine) scopes. Windows writes these values to the Registry so that they persist across sessions and system restarts.

> Alternately, you can add or change environment variables in your PowerShell profile. This method works for any version of PowerShell on any supported platform.

You can access your environment variables by pressing WinKey + X to access the Power User Task Menu, and then navigating to:

`System > Advanced System Settings > Advanced > Environment Variables`

Set the variable in the User Variables section.


## MacOS

Mac can have two different shells, bash or zsh.  Find out which you're using by
running `echo $SHELL`

```bash
# for bash
echo 'export VAGRANT_EXPERIMENTAL="disks"' >> ~/.bash_profile.d/99-vagrant.env

# for zsh
echo 'export VAGRANT_EXPERIMENTAL="disks"' >> ~/.zshenv
```

## Linux

You can add this to your `.bashrc` or if you've configured a `.bashrc.d` folder,
you can add to a file in that directory.

```bash
# add to .bashrc
echo 'export VAGRANT_EXPERIMENTAL="disks"' >> ~/.bashrc
# if you've configured .bashrc.d
echo 'export VAGRANT_EXPERIMENTAL="disks"' >> ~/.bashrc.d/vagrant.env
```



