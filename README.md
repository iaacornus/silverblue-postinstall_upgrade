# silverblue-postinstall_upgrade

This is a post install/post upgrade recommendations and suggestions for Fedora Silverblue or ostree based Fedora (such as Kinoite)

Contents, skip to what you need:

- [Basics (system update)](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#update-the-system)
- [Mounting of external drive temporarily or permanently](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#mount-external-drives-and-perhaps-add-it-to-etcfstab)
- [Third party repos, drivers and codecs](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#install-rpm-fusion-and-other-repos-you-need-codecs-and-drivers)
    - [Setup Flatpak](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#setup-flatpak)
    - [RPMFusion](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#rpmfusion)
    - Codecs
        - [Openh264](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#openh264)
        - [GStreamer](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#codecs)
    - [NVidia](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#nvidia-drivers)
    - [Reinstalling RPMFusion to avoid rebasing problems](https://github.com/iaacornus/silverblue-postinstall_upgrade#rpmfusion-reinstall)
- [Flatpak Modifications/Solutions](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#flatpak-modifications)
    - [Theming](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#theming)
    - [Permissions](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#permissions)
    - [Theming extended](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#theming-extended)
- [System Optimizations/Cleaning](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#system-optimizations)
    - [Mask `NetworkManager-wait-online.service`](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#mask-networkmanager-wait-onlineservice)
    - [Removing Gnome software (stop consuming RAM due to autostart and background running)](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#remove-unnecessary-gnome-flatpaks)
    - [Unnecessary flatpaks](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#remove-unnecessary-gnome-flatpaks)
    - [Disabling workqeues to improve SSD performance](https://github.com/iaacornus/silverblue-postinstall_upgrade/edit/main/README.md#disable-dm-crypt-workqeues-for-ssd-user-to-improve-performance)
- [Laptop Users](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#laptop-users)
    - [Battery Threshold](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#set-battery-threshold-for-laptop-users)
    - [Battery threshold notification](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#notification-when-battery-threshold-is-reached)
    - [Keyboard Backlight](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/README.md#keyboard-backlight)
        
***
        
# Post install

**You can skip all of the steps, these are not required, but can be beneficial or may be some use later.**

You can get the silverblue cheatsheet of Fedora's Team Silverblue [here](https://docs.fedoraproject.org/en-US/fedora-silverblue/_attachments/silverblue-cheatsheet.pdf).

## Note/Disclaimer

I highly suggest to avoid layering as much as possible to the system image, thus you would notice the installation of rpmfusion repositories separated. You should read first the information above the command and try to think it through before executing the given command.

***

# Update the system

After the system is Gnome software automatically download updates of your system, so running `rpm-ostree upgrade` after boot would only give `stderr`. You can wait and reboot later, usually Gnome would give notifications after the update is done. Although you can check the packages with:

```bash
rpm-ostree upgrade --check
```

If you just want a summary of update, such as the added, removed and upgraded do: `rpm-ostree upgrade --check` or `rpm-ostree upgrade --preview`

Update your preinstalled flatpaks, this may also not be necessary, since this is automatically updated by Gnome software center, but if you want to be sure, do:

```bash
flatpak update
```

And reboot after to apply the updates (there is also no problem to do this in GUI).

```bash
systemctl reboot
```

***

# Mount external drives and perhaps add it to `/etc/fstab`

If you have an external drive, which you can find with `lsblk` or `fdisk -l` and mount it using:

```bash
sudo mount /dev/sdX <dir>
```

To automatically mount it in boot, include the drive in `/etc/fstab`, you need the `UUID` of the drive and its mount point. List the drives and their `UUID` with `lsblk -f` and add it to `/etc/fstab` with format of:

```
# Ignore the comments, this is and example to fstab entry, don't copy and paste this, your system won't boot
# UUID                                      # mount point (full), also  # filesystem format   # options # dump # fsck
#                                           # no env variables such as
#                                           # $HOME
# UUID=e423cfe8-5e8a-419c-87d0-8abb39aa498c /var/home/iaacornus/Storage	ext4	              defaults	0       0
# UUID=<your device uuid>                   <mount point>               <filesystem format> <options> <dump>  <fsck>
```

Here I suggest using `defaults` for options, 0 for `dump` and `fsck` to disable the checking (increasing the boot time, and avoiding potential errors, and since you only do checking if the drive is part of the OS filesystem), refer to [archwiki - fstab](https://wiki.archlinux.org/title/fstab). Check `/etc/fstab` with `cat /etc/fstab`. Be sure to input the correct UUID and options, other wise your system won't boot.

***

# Install rpm-fusion and other repos you need, codecs, and drivers

Note that some of the drivers may come preinstalled in your system, confirm before proceeding.

## Setup flatpak

Fedora has its own flatpak repository where it filters some of the applications, for access to flathub setup the flathub repository: 

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

## RPMfusion

The main repository of Fedora does not contain every applications, some of the codecs are in the RPMFusion, the NVidia drivers are in the nonfree, while some of the codecs are in free.

Nonfree: `rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm`

Free: `rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm`

For both: `rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm`

## Codecs

### `Openh264` or `ffmpeg-libs`

Fedora disable the automatic install of `openh264` by default, for this reason:

> Upstream Firefox versions download and install the OpenH264 plugin by default automatically. Due to it's binary nature, Fedora disables this automatic download.

You can install it `mozilla-openh264` and `gstreamer1-plugin-openh264` to support codecs in Firefox. And do `CTRL` + `Shift` + `A` in Firefox to go into the add ons manager > Plugins, and enable the OpenH264* plugins.

```
rpm-ostree install mozilla-openh264 gstreamer1-plugin-openh264
```

However, `mozill-openh264` may give a bad performance some times, depending on the setup, if this is the case, you may want to use `ffmpeg-libs` instead which can solve the problem as suggested by [u/DelusionalSocialist](https://www.reddit.com/user/DelusionalSocialist/), which comes from the nonfree repo and can be installed with `rpm-ostree`.

### GStreamer

For intel (`intel-media-driver`) (_use `libva-intel-driver`) for older versions of Intels_) and then the codecs:

```
rpm-ostree install ffmpeg gstreamer1-plugin-libav gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-vaapi intel-media-driver
```

For AMD users, refer [here](https://rpmfusion.org/Howto/OSTree)

Reboot again.

## NVidia Drivers

Check first if you have nvidia card with `/sbin/lspci | grep -e 3D`, it would show you something like this:

```
02:00.0 3D controller: NVIDIA Corporation GP108M [GeForce MX230] (rev a1)
```

Otherwise, you don't have nvidia card, and don't proceed here. If you have nvidia card, install it, assuming you already installed rpmfusion repo nonfree

```bash
rpm-ostree install akmod-nvidia
```

And after reboot, check your nvidia install with `modinfo -F version nvidia`, it should give the version number of your driver such as `510.60.02`, not `stderr`.

## RPMFusion reinstall

When RPMFusion was installed, it was tied to a specific version of Fedora, thus rebasing for the next release would be a [problem](https://discussion.fedoraproject.org/t/simplifying-updates-for-rpm-fusion-packages-and-other-packages-shipping-their-own-rpm-repos/30364/23), it can be fixed by uninstalling the currently installed and installing a "general" repo:

```
rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release --install rpmfusion-free-release --install rpmfusion-nonfree-release
```

***

# Flatpak modifications

Flatpaks are sandboxed, it may not work as expected. These are some solutions to the errors that may arise or encountered.

## Theming

Since flatpaks are sandboxed, you can either install the flatpak version of GTK theme you are using as flatpak, which you can find by using `search`:

```bash
flatpak search gtk3
```

Or override the themes directory which depends on how the theme was installed:

```
# choose one, you can do all of them but I don't recommend doing it

# if install in home dir
sudo flatpak override --system --filesystem=$HOME/.themes # if installed in home dir

# if layered in image
sudo flatpak override --system --filesystem=/usr/share/themes 

# or whatever
sudo flatpak override --system --filesystem=xdg-data/themes
```

## Permissions

Other reddit users suggested, such as [u/IceOleg](https://www.reddit.com/user/IceOleg/), to override the `home` and `host` dir as well with:

```bash
flatpak override --user --nofilesystem=home
flatpak override --user --nofilesystem=host
```

Which can be given back to some applications that need it later on. [Flatseal](https://github.com/tchx84/flatseal) is also a good utility for managing permissions as [u/GunnarRoxen](https://www.reddit.com/user/GunnarRoxen/) suggested, can be installed with `flatpak install flathub com.github.tchx84.Flatseal`

The flatpak modifcations made can be undone by `sudo flatpak override --system --reset`. The `--system` flag can also be ommited, and `--user` can be used for user-wide changes.

## Theming Extended

In some cases, where themes do not apply, especially in GTK4, it can be forced by including it in `$HOME/.profile`, as well as the settings (`settings.ini`):

**Do not copy and execute the command, replace `<theme-name>` with the name of the theme**

```
echo "export GTK_THEME=<theme-name>" >> $HOME/.profile; if [ ! -d $HOME/.config/environment.d/ ]; then mkdir -p $HOME/.config/environment.d/; fi; echo "GTK_THEME=<theme-name>" >> $HOME/.config/environment.d/gtk_theme.conf; echo "GTK_THEME=<theme-name>" >> $HOME/.config/gtk-4.0/settings.ini
```

Which does (explanation):

1. `echo "export GTK_THEME=<theme-name>" >> $HOME/.profile`: append `export GTK_THEME=<theme-name>` to `$HOME/.profile`
2. Create `$HOME/.config/environment.d/gtk_theme.conf` file:

```bash
if [ ! -d $HOME/.config/environment.d/ ]; then
    mkdir -p $HOME/.config/environment.d/
fi

echo "GTK_THEME=<theme-name>" >> $HOME/.config/environment.d/gtk_theme.conf
```

And append `GTK_THEME=<theme-name>` at the end of the `gtk_theme.conf`

3. And finally append `GTK_THEME=<theme-name>` to `settings.ini` config.

If this didn't sufficed, then, you can try:

```
sudo flatpak override --system --env=GTK_THEME='<theme-name>'
```

***

# System optimizations

## Disable `NetworkManager-wait-online.service`

You can also disable `NetworkManager-wait-online.service`. It is simply a ["service simply waits, doing absolutely nothing, until the network is connected, and when this happens, it changes its state so that other services that depend on the network can be launched to start doing their thing."](https://askubuntu.com/questions/1018576/what-does-networkmanager-wait-online-service-do/1133545#1133545)

> In some multi-user environments part of the boot-up process can come from the network. For this case `systemd` defaults to waiting for the network to come on-line before certain steps are taken.

Disabling it can decrease the boot time of at least ~15s-20s:

```
sudo systemctl disable NetworkManager-wait-online.service
```

Masking it is not recommend, since as explained by [u/chrisawi](https://www.reddit.com/user/chrisawi/):

> Also, wait-online services are `WantedBy=network-online.target`, so they do nothing unless another service explicitly pulls that target in because it can't handle starting before the network is up. The nfs services are a typical example, see: `systemctl list-dependencies --reverse network-online.target`. It might be better to disable such services than to leave them potentially broken.

## Remove unnecessary gnome flatpaks

There are also some preinstalled flatpak that you can safely remove. You can completely remove the flatpak with:

```
flatpak uninstall --system --delete-data <app>
# example
flatpak uninstall --system --delete-data org.gnome.Calculator
```
 
Here are some you can remove:

1. Calculator `org.gnome.Calculator`
2. Calendar `org.gnome.Calendar`
3. Connections `org.gnome.Connections`
4. Contacts `org.gnome.Contacts`
5. PDF reader `org.gnome.Evince` if you plan to install another pdf reader
6. Logs `org.gnome.Logs`
7. Maps `org.gnome.Maps`
8. Weather apps `org.gnome.Weather`
9. Disk usage analyzer `org.gnome.baobab`

## Disable Gnome Software

Gnome software launches for some reason even tho it is not used, this takes at least 100MB of RAM upto 900MB (as reported anecdotically). You can remove from from the autostart in `/etc/xdg/autostart/org.gnome.Software.desktop`, by:

```
sudo rm /etc/xdg/autostart/org.gnome.Software.desktop
```

# Disable `dm-crypt` workqeues for SSD user to improve performance

Quoting [Arch Wiki](https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance):

> Solid state drive users should be aware that, by default, discarding internal read and write workqueue commands are not enabled by the device-mapper, i.e. block-devices are mounted without the no_read_workqueue and no_write_workqueue option unless you override the default. 

> The no_read_workqueue and no_write_workqueue flags were introduced by [internal Cloudflare research Speeding up Linux disk encryption](https://blog.cloudflare.com/speeding-up-linux-disk-encryption/) made while investigating overall encryption performance. One of the conclusions is that internal dm-crypt read and write queues decrease performance for SSD drives. While queuing disk operations makes sense for spinning drives, bypassing the queue and writing data synchronously doubled the throughput and cut the SSD drives' IO await operations latency in half. The patches were upstreamed and are available since linux 5.9 and up [[5](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/drivers/md/dm-crypt.c?id=39d42fa96ba1b7d2544db3f8ed5da8fb0d5cb877)]. 

To disable this in Fedora encrypted using `dm-crypt`, replace `discard` in `/etc/crypttab` with `no-read-workqueue,no-write-workqueue`, the output of `sudo cat /etc/crypttab` should look like this:

```
luks-<UUID> UUID=<UUID> none no-read-workqueue,no-write-workqueue
```

Where `<UUID>` should be unique to your system. Since Fedora uses LUKS2, you should also set the parameter with `cryptsetup`. Find the device with `lsblk -p`, the one with `/dev/mapper/luks-<UUID>` is the one encrypted, for example:

```
❯ lsblk -p
NAME                MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
/dev/zram0          252:0    0   7.5G  0 disk  [SWAP]
/dev/nvme0n1        259:0    0 476.9G  0 disk  
├─/dev/nvme0n1p1    259:1    0   600M  0 part  /boot/efi
├─/dev/nvme0n1p2    259:2    0     1G  0 part  /boot
└─/dev/nvme0n1p3    259:3    0 475.4G  0 part  
  └─/dev/mapper/luks-<UUID>
                    253:0    0 475.3G  0 crypt /var/home
...
```

In my case it is the `/dev/nvme0n1p3`. Then verify it with `sudo cryptsetup isLuks /dev/<DEV> && echo SUCCESS` where device is the device name, e.g. `nvme0n1p3`, if it echoed success then the device is LUKS. Then get the name of the encrypted device with:

```
sudo dmsetup info luks-<UUID>
```

Which should output something like this:

```
❯ sudo dmsetup info luks-e88105e1-690f-423e-a168-a9f9a2e613e9
Name:              luks-e88105e1-690f-423e-a168-a9f9a2e613e9
State:             ACTIVE
Read Ahead:        256
Tables present:    LIVE
Open count:        1
Event number:      0
Major, minor:      253, 0
Number of targets: 1
UUID: CRYPT-LUKS2-e88105e1690f423ea168a9f9a2e613e9-luks-e88105e1-690f-423e-a168-a9f9a2e613e9
```

Take the name, in this case, `luks-e88105e1-690f-423e-a168-a9f9a2e613e9`, and execute the command:

```
sudo cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh <name>
```

And do a reboot.

***

# Laptop Users

## Set battery threshold for laptop users

I recommend setting battery threshold of at least 80% to decrease wear on the battery. This can be done by echoing the threshold to `/sys/class/power_supply/BAT0/charge_control_end_threshold`. However, this resets every reboot, so it is good idea to make a systemd service for it:

```
[Unit]
Description=Set the battery charge threshold
After=multi-user.target
StartLimitBurst=0

[Service]
Type=oneshot
Restart=on-failure
ExecStart=/usr/bin/env bash -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold'

[Install]
WantedBy=multi-user.target
```

## Notification when battery threshold is reached

I created a systemd service and timer in `systemd/` that checks the battery level and state once every 15 minutes to check whether the laptop is still plugged when the battery threshold is reached. Move `battery-threshold.service` and `battery-threshold.timer` in `$HOME/.config/systemd/user/`. Then create a `.sys` directory inside your `$HOME` with `mkdir $HOME/.sys` and move [`battery-threshold.sh`](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/scripts/battery-threshold.sh) inside the created directory, then activate the service and timer:

```
systemctl --user enable battery-threshold.service
systemctl --user enable battery-threshold.timer
```

## Keyboard backlight

In some laptops, keyboard backlight may not work out of the box, it can be toggled with `brightnessctl`. First find the keyboard backlight in `/sys/class/leds` by listing the directories, it is usually named `::kbd_backlight/brightness` which can be contained in one more directory, in Asus laptops it is usually in `/sys/class/leds/asus\:\:kbd_backlight/brightness`.

You can find out the current brightness by:

```
brightnessctl --device='<device>::kbd_backlight' info
```

If it is set to 0, it is disabled, in 1 it is in lowest, and as the number increment, the brightness increases. You can set the brightness by `brightnessctl --device='<device>::kbd_backlight' set 3`, for example in Asus laptops it is:

```
brightnessctl --device='asus::kbd_backlight' set 3
```

You can also instead use a script to echo to the file, but it would not persist in boot, thus you may need systemd service if you would go to this route.
