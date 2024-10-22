# silverblue-postinstall_upgrade

Post install/upgrade recommendations and suggestions for Fedora Silverblue or `ostree` based Fedora (such as Kinoite). Contents, skip to what you need:

- [Basics (system update)](#update-the-system)
- [Mount external drives](#mount-external-drives)
    - [Automatically mount in boot](#automatically-mount-in-boot)
- [Third party repos, drivers and codecs](#install-rpm-fusion-and-other-repos-you-need-codecs-and-drivers)
    - [Setup Flatpak](#setup-flatpak)
    - [RPMFusion](#rpmfusion)
    - [Disable unused repositories](#disable-unused-repositories)
    - [Codecs](#codecs)
        - [Openh264](#openh264-or-ffmpeg-libs)
        - [GStreamer](#gstreamer)
    - [NVidia](#nvidia-drivers)
    - [Reinstalling RPMFusion to avoid rebasing problems](#rpmfusion-reinstall)
- [Flatpak Modifications/Solutions](#flatpak-modifications)
    - [Theming](#theming)
    - [Permissions](#permissions)
    - [Theming extended](#theming-extended)
- [System Optimizations](#system-optimizations)
    - [Disable `NetworkManager-wait-online.service`](#disable-networkmanager-wait-onlineservice)
    - [Unnecessary flatpaks](#remove-unnecessary-gnome-flatpaks)
    - [Removing Gnome software (stop consuming RAM due to autostart and background running)](#disable-gnome-software)
    - [SSD related optimizations](#ssd-related-optimizations)
        - [Disabling workqeues](#disable-dm-crypt-workqeues-for-ssd-user-to-improve-performance)
        - [Enable discard](#enable-discard)
        - [Change to `noatime`](#change-to-noatime)
    - [Replace Firefox RPM with Firefox Flatpak]
        - [Set Firefox to use wayland]
        - [Firefox `about:config` Improvements]
    - [Toolbox delays]
    - [Removing base image packages](#removing-base-image-packages)
- [Laptop Users](#laptop-users)
    - [Battery Threshold](#set-battery-threshold)
    - [Battery threshold notification](#notification-when-battery-threshold-is-reached)
    - [Keyboard Backlight](#keyboard-backlight)
    - [Set suspend to deep sleep](#set-suspend-to-deep-sleep)
- [Customizations](#customizations)
    - [Use FISH as default shell](#use-fish-as-default-shell)
        - [Install FISH](#install-fish)
        - [Set FISH as default shell](#set-fish-as-default-shell)
        - [Customize FISH (basics)](#customize-fish-basics)
- [Tips and Tricks](#tips-and-tricks)
    - [Contrast current modifications of configs with the default](#contrast-current-modifications-of-configs-with-the-default)
- [Miscellaneous](https://github.com/iaacornus/silverblue-postinstall_upgrade#miscellaneous)
    - [VSCode](https://github.com/iaacornus/silverblue-postinstall_upgrade#vscode)
        - [Install](https://github.com/iaacornus/silverblue-postinstall_upgrade#install)
            - [Toolbox installation](https://github.com/iaacornus/silverblue-postinstall_upgrade#toolbox-installation)
            - [Layering](https://github.com/iaacornus/silverblue-postinstall_upgrade#layering)
        - [Block telemetry](https://github.com/iaacornus/silverblue-postinstall_upgrade#block-telemetry)

***

# Post install

**You can skip all of the steps, majority are not required, but can be beneficial or can be useful later.**

You can get the silverblue cheatsheet of Fedora's Team Silverblue [here](https://docs.fedoraproject.org/en-US/fedora-silverblue/_attachments/silverblue-cheatsheet.pdf).

## Note/Disclaimer

I highly suggest to avoid layering as much as possible to the system image. Substantial number of layered packages will take a massive toll on system's performance. Consider installing some packages inside of a container or as a flatpak.

Lastly, the command must be first analyzed and given a thought before execution. **NEVER RUN A COMMAND FROM INTERNET WITHOUT ANY ANALYSIS AND CONSIDERATION OF ANY FORESEEABLE CONSEQUENCES.**

***

# Update the system

After booting the system, Gnome Software will automatically download updates of your system. Hence, running `rpm-ostree upgrade` after boot would only give `stderr`. You can wait and reboot later, though usually Gnome gives notifications after the update. Although you can its status with:

```bash
rpm-ostree upgrade --check
```

You can obtain the summary of the changes or update, including added, removed and upgraded with

```bash
rpm-ostree upgrade --check
# this will also work
rpm-ostree upgrade --preview
```

Update your preinstalled flatpaks, this may also not be necessary, since this is automatically updated by Gnome software center, but if you want to be sure, do:

```bash
flatpak update
```

It is also important to update your firmware using `fwupdmgr`:

```bash
fwupdmgr refresh --force
fwupdmgr get-devices
fwupdmgr get-updates
fwupdmgr update
```

Reboot to apply the updates (there is also no problem to do this in GUI).

```bash
systemctl reboot
```

***

# Mount external drives

Some of the external drives will not be automatically mounted by the system if it was not mounted/specified during the installation.

External drives, along with its `UUID` (Universally Unique Identified), can be found using `lsblk` or `fdisk -l` and be mounted using:

```bash
sudo mount /dev/sdX <dir>
# replace <dir> where you want to mount the drive
# sdx can be nvmeNnJpI where N, J and I are integers e.g. /dev/nvme0n1p1, they can also be /dev/sdb
```

## Automatically mount in boot

External drives can be automatically mounted on boot by including it into `/etc/fstab`. The `UUID` of the drive and its mount point is needed.

Firstly, the drives is recommended to be mounted. List the drives and their `UUID` with `lsblk -f`. Then, add it to `/etc/fstab` with format of:

```bash
UUID    mount_point     type    options     dump    fsck
```

Below is an example, **DO NOT COPY AND PASTE**:

```
# Ignore the comments, this is and example to fstab entry, don't copy and paste this, your system won't boot
# UUID                                      # mount point (full), also  # filesystem format   # options # dump # fsck
#                                           # no env variables such as
#                                           # $HOME
# UUID=e423cfe8-5e8a-419c-87d0-8abb39aa498c /var/home/iaacornus/Storage	ext4	              defaults	0       0
# UUID=<your device uuid>                   <mount point>               <filesystem format> <options> <dump>  <fsck>
```

Instead of using `<device>`, it is highly recommended to use the `UUID` instead. Moreover, I strongly encourage to use `defaults` for `options`, `0` for `dump` and `fsck` to disable the checking (increasing the boot time, and avoiding potential errors, and since you only do checking if the drive is part of the OS filesystem), refer to [ArchWiki - fstab](https://wiki.archlinux.org/title/fstab).

Finally, check `/etc/fstab` with `cat /etc/fstab`. Be sure to input the correct UUID and options, otherwise your system won't boot.

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


```bash
# Nonfree
rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Free
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

# Both
rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
```

## Disable unused repositories

Some repositories are enabled by default but are not used. You can disable it by:

```bash
sudo sed -i 's/enabled=1/enabled=0/' \
/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo \
/etc/yum.repos.d/fedora-cisco-openh264.repo \
/etc/yum.repos.d/google-chrome.repo \
/etc/yum.repos.d/rpmfusion-nonfree-nvidia-driver.repo \
/etc/yum.repos.d/rpmfusion-nonfree-steam.repo
```

Although you may want to enable `fedora-cisco-openh264`.

## Codecs

### `Openh264` or `ffmpeg-libs`

Fedora disable the automatic install of `openh264` by default, for this reason:

> Upstream Firefox versions download and install the OpenH264 plugin by default automatically. Due to it's binary nature, Fedora disables this automatic download.

You can install the packages `mozilla-openh264` and `gstreamer1-plugin-openh264` to support these codecs in Firefox. Finally, inside Firefox, do `CTRL` + `Shift` + `A` to enter Add Ons Manager > Plugins, and enable the OpenH264* plugins.

```bash
rpm-ostree install mozilla-openh264 gstreamer1-plugin-openh264
```

However, `mozilla-openh264` may give a bad performance some times, depending on the setup. As an alternative, [u/DelusionalSocialist](https://www.reddit.com/user/DelusionalSocialist/), suggested to use `ffmpeg-libs` which can solve the problem. `ffmpeg-libs` comes from the nonfree repo and can be installed with `rpm-ostree`.

### GStreamer

For intel (`intel-media-driver`) (_use `libva-intel-driver` for older versions of Intels_) and then the codecs:

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

Otherwise, you don't have nvidia card. If you have NVidia card you can install the proprietary driver from the nonfree repo:

```bash
rpm-ostree install akmod-nvidia
```

Finally, check your NVidia install with `modinfo -F version nvidia`, it should give the version number of your driver such as `510.60.02`, not `stderr`.

## RPMFusion reinstall

The current RPMFusion installed by the command was version-specific as notable by `$(rpm -E %fedora)` in the command. Thus, rebasing for the next release would be a [problem](https://discussion.fedoraproject.org/t/simplifying-updates-for-rpm-fusion-packages-and-other-packages-shipping-their-own-rpm-repos/30364/23). Fortunately, it can be fixed by installing a "general" repo:

```
rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release --install rpmfusion-free-release --install rpmfusion-nonfree-release
```

***

# Flatpak modifications

Flatpak apps are sandboxed. Thus, may not work as expected. The following are some solutions to the errors that may arise from default Flatpak security permissions.

## Theming

Due to the aforementioned sandboxing, there are 2 methods to installing themes:
Either the flatpak version of GTK theme you are using as a flatpak, which you can find by using `search`:

```bash
flatpak search gtk3
```

The themes directory can also be overriden depending on how the theme was installed:

```
# choose one, you can do all of them but I don't recommend doing it

# if installed in home dir
sudo flatpak override --system --filesystem=$HOME/.themes # if installed in home dir

# if layered in image
sudo flatpak override --system --filesystem=/usr/share/themes

# or whatever
sudo flatpak override --system --filesystem=xdg-data/themes
```

## Permissions

Other reddit users suggested, such as [u/IceOleg](https://www.reddit.com/user/IceOleg/), you can remove permissions for access to `home` and `host` dir with:

```bash
flatpak override --user --nofilesystem=home
flatpak override --user --nofilesystem=host
```

The overriden directories can be returned with when required. [Flatseal](https://github.com/tchx84/flatseal) is also a good utility for managing permissions as [u/GunnarRoxen](https://www.reddit.com/user/GunnarRoxen/) suggested. It can be installed with:

```bash
flatpak install flathub com.github.tchx84.Flatseal
```

The flatpak modifications made can be reset with

```bash
sudo flatpak override --system --reset
```

The `--system` flag can also be omitted, and `--user` can be used for user-wide changes.

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

```bash
sudo flatpak override --system --env=GTK_THEME='<theme-name>'
```

***

# System optimizations

## Disable `NetworkManager-wait-online.service`

You can also disable `NetworkManager-wait-online.service`. It is simply a ["service simply waits, doing absolutely nothing, until the network is connected, and when this happens, it changes its state so that other services that depend on the network can be launched to start doing their thing."](https://askubuntu.com/questions/1018576/what-does-networkmanager-wait-online-service-do/1133545#1133545)

> In some multi-user environments part of the boot-up process can come from the network. For this case `systemd` defaults to waiting for the network to come on-line before certain steps are taken.

Disabling it can decrease the boot time of at least ~15s-20s:

```bash
sudo systemctl disable NetworkManager-wait-online.service
```

Masking it is not recommend, since as explained by [u/chrisawi](https://www.reddit.com/user/chrisawi/):

> Also, wait-online services are `WantedBy=network-online.target`, so they do nothing unless another service explicitly pulls that target in because it can't handle starting before the network is up. The nfs services are a typical example, see: `systemctl list-dependencies --reverse network-online.target`. It might be better to disable such services than to leave them potentially broken.

## Remove unnecessary gnome flatpaks

There are also some preinstalled flatpak that you can safely remove. You can completely remove the flatpak with:

```bash
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

Gnome Software launches for some reason even tho it is not used, this takes at least 100MB of RAM up to 900MB (as reported anecdotally). You can prevent Gnome Software from autostart by removing `/etc/xdg/autostart/org.gnome.Software.desktop`:

```bash
sudo rm /etc/xdg/autostart/org.gnome.Software.desktop
```

## SSD Related Optimizations

If you will proceed in this part, you need to obtain your device's unique identifier (`UID`). A `UID` is unique in each of your blocks/devices. You can find your partition/block/device's `UID` with `lsblk -p`:

```bash
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

### Disable `dm-crypt` workqeues

Refer to this before proceeding[^1].

[^1]: There are reported data loss on some and not on others, citing that the code of cloudflare (they implemented it) is buggy. I've tried it myself and so far I didn't experienced any data loss, and I didn't encountered complains about it yet from zen kernel users, since zen kernel disabled it by default. But again, it may not be always the case.

Quoting [Arch Wiki](https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance):

> Solid state drive users should be aware that, by default, discarding internal read and write workqueue commands are not enabled by the device-mapper, i.e. block-devices are mounted without the no_read_workqueue and no_write_workqueue option unless you override the default.

> The no_read_workqueue and no_write_workqueue flags were introduced by [internal Cloudflare research Speeding up Linux disk encryption](https://blog.cloudflare.com/speeding-up-linux-disk-encryption/) made while investigating overall encryption performance. One of the conclusions is that internal dm-crypt read and write queues decrease performance for SSD drives. While queuing disk operations makes sense for spinning drives, bypassing the queue and writing data synchronously doubled the throughput and cut the SSD drives' IO await operations latency in half. The patches were upstreamed and are available since linux 5.9 and up [[5](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/drivers/md/dm-crypt.c?id=39d42fa96ba1b7d2544db3f8ed5da8fb0d5cb877)].

To disable this in Fedora encrypted using `dm-crypt`, replace `discard` in `/etc/crypttab` with `no-read-workqueue,no-write-workqueue`, the output of `sudo cat /etc/crypttab` should look like this:

```bash
luks-<UUID> UUID=<UUID> none no-read-workqueue,no-write-workqueue
```

In my setup, the encrypted partition is `/dev/nvme0n1p3`. This can be verified with `sudo cryptsetup isLuks /dev/<DEV> && echo SUCCESS` where device is the device name, e.g. `nvme0n1p3`, it should echo `SUCCESS` if the given partition is encrypted. Once confirmed, obtain the device name with:

```bash
sudo dmsetup info luks-<UUID>
```

Which should output something like this:

```bash
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

Take the name, in this case `luks-e88105e1-690f-423e-a168-a9f9a2e613e9`, and execute the command:

```bash
sudo cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh <name>
```

Finally, reboot.

## Enable discard

Due to [security implications](https://asalor.blogspot.com/2011/08/trim-dm-crypt-problems.html), `discard` option is not enabled by default. However, for majority it should not be significant. Thus, the performance improvement(s) outweight(s) the security concern(s).

In Fedora Silverblue, the `crypttab` (`/etc/crypttab`) is not passed into the `intramfs` images. But you can enable discard by passing it as kernel arguments using `rpm-ostree kargs --append`:

```bash
rpm-ostree kargs --append=rd.luks.options=UID=discard
```

## Change to `noatime`

By default, the BTRFS subvolumes/volumes in Fedora Silverblue is mounted as `relatime` (along with `compress=zstd:1`[^2]). The main interest here is the option, `relatime`. Disabling `relatime` can possible reduce unnecessary writes on SSD. Thus, potentially reducing the amount of read-write cycle, insignificantly improving its lifespan. Although in my case, it has considerable benefits:

[^2]: BTRFS supports transparent compression, whereas the files are automatically compressed when written into the disk. In SSD, this reduces the amount of read-write cycle. Thus, prolonging its lifespan. Although, not really that significant.

```bash
sudo sed -i 's/compress=zstd:1/noatime,compress=zstd:1/' /etc/fstab
```

## Removing base image packages

**This needs to be reset before you can rebase to another version, e.g. 36 -> 37, refer [here](https://github.com/fedora-silverblue/issue-tracker/issues/288)**

[u/VVine6](https://www.reddit.com/user/VVine6/) recommended some packages that can be removed from the base image, such as VM host support and Gnome classic shell:

```bash
rpm-ostree override remove open-vm-tools-desktop open-vm-tools qemu-guest-agent spice-vdagent spice-webdavd virtualbox-guest-additions gnome-shell-extension-apps-menu gnome-classic-session gnome-shell-extension-window-list gnome-shell-extension-background-logo gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu
```

Later on, before rebasing this needs to be included back, which can be done with `rpm-ostree override reset`.

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
ExecStart=/usr/bin/env bash -c 'echo 89 > /sys/class/power_supply/BAT0/charge_control_end_threshold'

[Install]
WantedBy=multi-user.target
```

## Notification when battery threshold is reached

I created a systemd service and timer in `systemd/` that checks the battery level and state once every 15 minutes to check whether the laptop is still plugged when the battery threshold is reached. Move `battery-threshold.service` and `battery-threshold.timer` in `$HOME/.config/systemd/user/`. Then create a `.sys` directory inside your `$HOME` with `mkdir $HOME/.sys` and move [`battery-threshold.sh`](https://github.com/iaacornus/silverblue-postinstall_upgrade/blob/main/scripts/battery-threshold.sh) inside the created directory and activate the service and timer:

```bash
systemctl --user enable battery-threshold.service
systemctl --user enable battery-threshold.timer
```

## Keyboard backlight

In some laptops whereas keyboard backlight do not work out of the box, it can be toggled with `brightnessctl`.

The keyboard backlight can be found in `/sys/class/leds`. It is usually named `::kbd_backlight/brightness` which can be contained in one more directory, in Asus laptops it is usually in `/sys/class/leds/asus\:\:kbd_backlight/brightness`. You can find out the current brightness by:

```bash
brightnessctl --device='<device>::kbd_backlight' info
```

If it is set to 0, it is disabled, in 1 it is in lowest, and as the number increment, the brightness increases. You can set the brightness by `brightnessctl --device='<device>::kbd_backlight' set 3`, for example in Asus laptops it is:

```bash
brightnessctl --device='asus::kbd_backlight' set 3
```

## Set suspend to deep sleep

**Only if your laptop drains fast under `s2idle`**

In some laptop, the battery drains rapidly when suspended under `s2idle`, particularly those with Alder Lake CPUs. One of the workaround is setting the kernel parameters with `mem_sleep_default=deep`. This can be done via `grubby`:

```bash
rpm-ostree kargs --append="mem_sleep_default=deep
```

Do a reboot, then check it with `cat /sys/power/mem_sleep`, where the `deep` should be enclosed with brackets (`[deep]`).

***

# Customizations

## Use FISH as default shell

> Fish (friendly interactive shell) is a smart and user-friendly command line shell that works on Linux, MacOS, and other operating systems. Use it for everyday work in your terminal and for scripting. Scripts written in fish are less cryptic than their equivalent bash versions.

FISH (Friendly Interactive SHell) is an alternative for BASH (Bourne Again SHell) and ZSH (Z SHell) which comes with out-of-the-box useful features such as:
    - Syntax highlighting
    - Web based configuration
    - Inline searchable history
    - Inline autosuggestion
    - Tab completion using manpage data

DEMO (Credits to Sid Mohanty, [link to original article, suggested read for more info](https://betterprogramming.pub/fish-vs-zsh-vs-bash-reasons-why-you-need-to-switch-to-fish-4e63a66687eb?gi=fc345308724e))

![](https://miro.medium.com/max/640/1*AhoFOHQxoLzKiLMg-NVRKQ.gif)

FOR INTERESTED:
- [https://opensource.com/article/20/3/fish-shell](https://opensource.com/article/20/3/fish-shell)
- [https://fedoramagazine.org/fish-a-friendly-interactive-shell/](https://fedoramagazine.org/fish-a-friendly-interactive-shell/)

### Install FISH

Install `fish` with:

```bash
rpm-ostree install fish
```

You can also install it inside `toolbox`:

```bash
sudo dnf install install fish
# or if inside toolbox
toolbox run sudo dnf install fish
```

### Set FISH as default shell

Since Fedora does not have `chsh` in the base image of Silverblue due to its `setuid` root, you can use `usermod` to set the default shell:

```bash
# after reboot
sudo usermod --shell /usr/bin/fish $USER
```

### Customize FISH (basics)

FISH comes with web-based configuration which can be access with:

```bash
fish_config
```

This will give a GUI where you can set your prompt, color of syntax highlighting, aliases, functions (view of defined functions). Then to disable the welcome message you can run (once):

```bash
set -U fish_greeting
```

***

# Tips and Tricks

## Contrast current modifications of configs with the default

This can be helpful in debugging as suggested by [u/VVine6](https://www.reddit.com/user/VVine6/)

```bash
sudo ostree admin config-diff | sort | grep -v system.control
```

> The output will list files as Removed, Added or Modified. The defaults are available in `/usr/etc` in the very same path, so to revert a modification or a removal simple copy the file over.

You can also utilize `diff` to obtain a more elaborate report:

```bash
sudo diff -yrW200 --suppress-common-lines --color=always /usr/etc /etc 2>/dev/null
```

***

# Miscellaneous

## VSCode

There are three ways to install via flatpak, toolbox or layering.

### Install

#### Toolbox installation

**This section assumes that you will use Fedora as toolbox container**

Create a toolbox with `toolbox create`, you can specify the version or distro you want to use with `-r` and `-d`, respectively. Then go inside the toolbox and update the system:

```bash
sudo dnf update
```

Following VSCode's documentation, import the GPG keys and create a repository:

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
```

```bash
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
```

Then update the metadata with `sudo dnf check-update`, and do `sudo dnf install code`. To create a desktop icon:

```bash
touch $HOME/.local/share/applications/code.desktop
```

Finally, append the following lines of code to create a desktop entry:

```bash
[Desktop Entry]
Type=Application
Version=1.0 # you can replace the version
Name=Visual Studio Code
Exec=toolbox run code
Icon=com.visualstudio.code
Terminal=false
```

If you used a toolbox with different name, change `Exec` to `toolbox --container <name-of-toolbox> run code`.

#### Layering

Since the filesystem is immutable, you cannot import the GPG, unless you do specific changes which is not covered here. Thus, simply create a repository for code:

```bash
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
```

Then refresh the metadata with `rpm-ostree refresh-md`, and do `rpm-ostree install code`.

## Block telemetry

VSCode contains telemetry, to block some of them block some of the domain in your `/etc/hosts` by setting it to loopback (`127.0.0.1`) by appending:

```
127.0.0.1	dc.services.visualstudio.com
127.0.0.1	dc.trafficmanager.net
127.0.0.1	vortex.data.microsoft.com
127.0.0.1	weu-breeziest-in.cloudapp.net
127.0.0.1	mobile.events.data.microsoft.com
```

Then in `$HOME/.config/Code/User/settings.json`, include:

```
"telemetry.telemetryLevel": "off"
```
