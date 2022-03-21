#!/bin/bash
sudo echo "GRUB_TIMEOUT=30" >> /etc/default/grub.d/99-timeout.cfg
sudo grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null
