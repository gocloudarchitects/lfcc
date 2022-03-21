# Linux Deep Dive

## Linux Boot System and Process

1. Create a virtual machine, log in, and download the breakboot utility

    **WARNING:** Do not run this from a production system, or any system you are not okay breaking!
    **WARNING:** ONLY RUN THIS SCRIPT ON A VM!

    ```bash
    curl https://raw.githubusercontent.com/gocloudarchitects/lfcc/main/exercises/files/breakboot.sh -o breakboot.sh
    chmod +x breakboot.sh
    sudo ./breakboot.sh
    ```

    Open VirtualBox and open the VM console.  You will see the boot menu.  Try to log in and fix the issue using what we've learned this less.

## SystemD and the Linux Init System

1. Explore the systemctl command.
   - systemctl status
   - systemctl list-unit-files
   - systemctl list-timers
   - systemctl list-sockets
   - systemctl list-jobs
   - systemctl show-environment

2. Can you disable the snapd.service entirely? What command would you use?

3. Investigate the runlevel targets (0 through 6). These are provided for backwards compatibility with SysV Init, Linux's previously most common init system.  Can you figure out what each runlevel does?

## Linux Logging

1. Read the [rsyslog](https://wiki.archlinux.org/title/rsyslog) article from the Arch Linux wiki, taking special note of severity levels and their descriptions.

2. Explore the `dmesg` command. It manages messages in the kernel ring buffer, and the timestamp is by default time since the system's last boot.  Try `dmesg -T` to get a human readable date/time timestamp.  Try restricting the log messages to only Critical, Error, and Warnings by specifying the appropriate tags with the `-l` command line option. 

3. Change log rotation:
   - daily
   - retain for 7 days
   - compress rotated logs

## Disks, Partitions, and Filesystems

1. Create a VM using the Vagrantfile at `lfcc/vagrant/multidisk`, and use it for the following exercises.  The disk plugin is in experimental state, so if it fails, create a VM normally and add 3x 5GB disks through the VirtualBox interface.

2. Partition the first disk to have 2 partitions of roughly equal size, and format them and mount them as indicated:
   - sdc1, format ext4, mount /mnt/data
   - sdc2, format xfs, mount /opt

3. Write fstab entries for the disks in step2, with the following criteria:
   - sdc1 should not automount, but should be user mountable
   - sdc2 should automount at boot, but the system should continue booting if the mount fails

4. Create a LVM pool from the remaining two disks, create a single large partition, and format the partition with the xfs filesystem.  Hint: physical volume > volume group > logical volume.

5. Mount the new fileystem to the `/var` directory.  This will require booting into a SystemD target that is not logging. If you need to use the boot menu, you can enable boot menu wait with the `enablebootwait.sh` script.

    ```bash
    curl https://raw.githubusercontent.com/gocloudarchitects/lfcc/main/exercises/files/enablebootwait.sh -o enablebootwait.sh
    sh ./enablebootwait.sh
    ```

# ANSWERS:

## Partitions and Filesystems - Exercise 2

1. Partition the disk:

    ```bash
    vagrant@multidisk-lab:~$ sudo gdisk /dev/sdc
    GPT fdisk (gdisk) version 1.0.5

    Partition table scan:
      MBR: protective
      BSD: not present
      APM: not present
      GPT: present

    Found valid GPT with protective MBR; using GPT.

    Command (? for help): n
    Partition number (1-128, default 1): 
    First sector (34-10485726, default = 2048) or {+-}size{KMGTP}:  
    Last sector (2048-10485726, default = 10485726) or {+-}size{KMGTP}: +2500M
    Current type is 8300 (Linux filesystem)
    Hex code or GUID (L to show codes, Enter = 8300): 
    Changed type of partition to 'Linux filesystem'

    Command (? for help): p
    Disk /dev/sdc: 10485760 sectors, 5.0 GiB
    Model: HARDDISK        
    Sector size (logical/physical): 512/512 bytes
    Disk identifier (GUID): 039A910E-6408-4612-AEE5-1086672000D0
    Partition table holds up to 128 entries
    Main partition table begins at sector 2 and ends at sector 33
    First usable sector is 34, last usable sector is 10485726
    Partitions will be aligned on 2048-sector boundaries
    Total free space is 5365693 sectors (2.6 GiB)

    Number  Start (sector)    End (sector)  Size       Code  Name
       1            2048         5122047   2.4 GiB     8300  Linux filesystem

    Command (? for help): n
    Partition number (2-128, default 2): 
    First sector (34-10485726, default = 5122048) or {+-}size{KMGTP}: 
    Last sector (5122048-10485726, default = 10485726) or {+-}size{KMGTP}: 
    Current type is 8300 (Linux filesystem)
    Hex code or GUID (L to show codes, Enter = 8300): 
    Changed type of partition to 'Linux filesystem'

    Command (? for help): w

    Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
    PARTITIONS!!

    Do you want to proceed? (Y/N): y
    OK; writing new GUID partition table (GPT) to /dev/sdc.
    The operation has completed successfully.
    ```

2. Create the filesystems:

    ```bash
    vagrant@multidisk-lab:~$ sudo mkfs.ext4 /dev/sdc1 
    mke2fs 1.45.5 (07-Jan-2020)
    Creating filesystem with 640000 4k blocks and 160000 inodes
    Filesystem UUID: 7a7fd06c-5988-4c9b-97c6-64f810b5b8fa
    Superblock backups stored on blocks: 
      32768, 98304, 163840, 229376, 294912

    Allocating group tables: done                            
    Writing inode tables: done                            
    Creating journal (16384 blocks): done
    Writing superblocks and filesystem accounting information: done 

    vagrant@multidisk-lab:~$ sudo mkfs.xfs /dev/sdc2
    meta-data=/dev/sdc2              isize=512    agcount=4, agsize=167615 blks
             =                       sectsz=512   attr=2, projid32bit=1
             =                       crc=1        finobt=1, sparse=1, rmapbt=0
             =                       reflink=1
    data     =                       bsize=4096   blocks=670459, imaxpct=25
             =                       sunit=0      swidth=0 blks
    naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
    log      =internal log           bsize=4096   blocks=2560, version=2
             =                       sectsz=512   sunit=0 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0
```

3. Mount the filesystems

    Note that since `/opt` is not empty, we have to move the files, or they will be mounted over.

    ```bash
    vagrant@multidisk-lab:~$ sudo mkdir /mnt/data
    vagrant@multidisk-lab:~$ ls /opt/
    VBoxGuestAdditions-6.1.32
    vagrant@multidisk-lab:~$ sudo mv /opt/VBoxGuestAdditions-6.1.32/ .
    vagrant@multidisk-lab:~$ ls -lah /opt/
    total 8.0K
    drwxr-xr-x  2 root root 4.0K Mar 20 21:05 .
    drwxr-xr-x 20 root root 4.0K Mar 20 19:56 ..
    vagrant@multidisk-lab:~$ sudo mount -t xfs /dev/sdc2 /opt/
    vagrant@multidisk-lab:~$ sudo mv VBoxGuestAdditions-6.1.32 /opt/
    ```

## Partitions and Filesystems - Exercise 3

Use `man fstab` and `man mount` to determine the solution, or look at online documentation.

Here are the entries I wrote.

```bash
/dev/sdc1 /mnt/data ext4 noauto,user 0 0
/dev/sdc2 /opt xfs nofail 0 0
```

## Partitions and Filesystems - Exercise 4

1. Create the Physical Volumes

    ```bash
    root@multidisk-lab:~# pvcreate /dev/sdd /dev/sde 
      Physical volume "/dev/sdd" successfully created.
      Physical volume "/dev/sde" successfully created.
    ```

2. Create the volume group

    ```bash
    root@multidisk-lab:~# vgcreate labvg /dev/sdd /dev/sde 
      Volume group "labvg" successfully created
    ```

3. Create the logical volume

    ```bash
    root@multidisk-lab:~# vgdisplay | grep Free
      Free  PE / Size       2558 / 9.99 GiB
    root@multidisk-lab:~# lvcreate -l 2558 labvg --name var-lv
      Logical volume "var-lv" created.
    ```

4. Create filesystem

    ```bash
    root@multidisk-lab:~# mkfs.xfs /dev/mapper/labvg-var--lv 
    ```

## Partitions and Filesystems - Exercise 5

There are different ways you can accomplish this, but you need to put the system in a state that it's not logging so that you can move the files.

This solution doesn't require the `enablebootwait.sh` script

1. Isolate the emergency target

    ```bash 
    root@multidisk-lab:~# systemctl isolate emergency.target
    ```

    NOTE: this did not disconnect me from my SSH session, but it's conceivable that it would.

3. Configure fstab 
    
    Doing this before the other steps allows for less downtime, and allows you to check that the entry is correct before rebooting.

    ```bash
    /dev/labvg/var-lv /var xfs defaults 0 1
    ```

2. Mount new fs to a temporary location and copy over files, using archival options to preserve permissions and ownership - `cp -ax`

    ```bash
    root@multidisk-lab:~# mkdir /mnt/tmp
    root@multidisk-lab:~# mount /dev/labvg/var-lv /mnt/tmp/
    root@multidisk-lab:~# cp -ax /var/. /mnt/tmp/.
    root@multidisk-lab:~# ls /mnt/tmp/
    backups  cache  crash  lib  local  lock  log  mail  opt  run  snap  spool  tmp

    ```

3. Delete old files, unmount, and mount using fstab entry

    ```bash
    root@multidisk-lab:~# rm -rf /var/*
    root@multidisk-lab:~# ls /var/
    root@multidisk-lab:~# umount /mnt/tmp 
    root@multidisk-lab:~# mount /var
    ```
4. Reboot
