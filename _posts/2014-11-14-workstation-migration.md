---
title: 'Workstation Migration'
tags: debian diy i3
---

Since 1999, I've managed to migrate my [Debian
GNU/Linux](http://www.debian.org) workstation across hardware generations.  The
new machine is a tricked out [Lenovo
W540](http://shop.lenovo.com/at/de/laptops/thinkpad/w-series/w540/) with a
really nice 2880x1620 IPS panel, a SSD and 16G RAM. A really nice machine.
This time the task was a bit more complex than usual, as I chose to inflict
multiple complexities upon myself:

  * BIOS -> UEFI
  * ext4 -> btrfs migration

  * desktop -> laptop
  * nvidia only -> bumblebee/optimus
  * 200dpi screen

  * systemd

Here is my tale.

# BIOS, partitioning and filesystem: the transfer

I did a test installation of Debian testing on the new machine to check out
what works and what doesn't. UEFI support worked really well and provided a
branded entry to boot debian from the UEFI menu. Also this prepared the SSD
with proper partitions.

I've wanted to try out
[btrfs](https://btrfs.wiki.kernel.org/index.php/Main_Page) for quite a while
now and the time seemd ripe. I did the test installation already to a btrfs
volume and that worked fine.

On the downside all tohse changes meant that I could not just `dd` over the
whole disk and be done, but needed a file-level solution. After some fiddling
and false-starts, I settled on booting the laptop into the
[debian-installer](http://cdimage.debian.org/cdimage/weekly-builds/) (netinst,
teesting) rescue mode and the old desktop with the current [grml
2014.10-rc1](http://grml.org/download/prerelease/). The d-i on the target was
able to start a shell in the target system that was able to run update-grub
successfully after the transfer to fixup the grub config. Grml on the desktop
is just really nice to have a quick sshd running while having no traffic on the
source partition.

Transferring the actual data was accomplished by running

    rsync -avx --delete --numeric-ids root@DESKTOP:/mnt/ /

from the d-i chroot shell. The source partition was mounted on /mnt in the
grml.

After the transfer, `/etc/fstab` needs fixing to have the right device name and
fstype specified for root. Debian's default of using UUIDs doesn't help much,
when transplanting onto different partitions.

From the test installation the target had already an UEFI partition with
installed grub loader. The source system was lacking the actual binaries to
finish booting the system. Confusingly, the grub-efi-amd64-bin package delivers
the loader mods to /usr/lib/grub/x86\_64-efi, while the booting grub expects
them in /boot/grub/x86\_64-efi. The test installation had them there, so I
assume that there is some process I missed, which installs the on demand. I did
so manually to good effect. I totally exepct this to break in a few years when
a incomatible grub updates comes along and finds that I forgot to update some
weird config file.

I ran

    update-grub
    update-initramfs -k all -u

to get all the fancy new stuff to boot.

# The System

Now that the system boots, I quickly noticed two things: I had reused the MAC
adress of the virtualisation bridge I had configured and X didn't work.

Thanks to the detailled notes for [running Debian on a
W540](https://gist.github.com/fbrozovic/9102118), getting X to run was quite
easy: I installed the bumblebee and primus utilities, killed the old nvidia
`xorg.conf` and off it went.

The problem with the re-used MAC adress is not really a problem as the old
system will be re-purposed for a different project, which will include a fresh
install anyways. But I wanted to get to the gorund of this, as I was not aware
of this MAC adress persiting thingy. Turns out that systemd-networkd, which I
used to configure this bridge, computes a "static" MAC adress from
`/etc/machine-id` and the interface's name. Resetting the machine id requires
the following steps:

    rm /var/lib/dbus/machine-id /etc/machine-id
    dbus-uuidgen --ensure
    systemd-machine-id-setup

and a reboot.

#  200dpi

The new screen is absolutely gorgeous. As [LWN
reports](http://lwn.net/Articles/619784/) high dpi support on the desktop is
spotty. I use the i3wm as desktop environment and the 2880px horizontal space
mean, that I can now have two 1024+px windows side-by-side, which is really
nice as those pesky repsonsive design webpages now do not reformat. On the
downside, the text is quite small, so while it is good, it's not as good as I
expected. Iceweasel and icedove have a weird multiple-personalities disorder:
icons and content seem to be rendered in pixels, while UI-text is rendered dpi
independently. I guess I'll find some tweak somewhere to improve that, but for
today I've fiddled with this enough, and I'll live through a bit of ugliness.
