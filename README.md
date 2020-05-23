# Lastsnap Vanilla Source Code

**Disclaimer**  
Most of these files are yagoply's creation and are under the GPLv3 license, except:

Source datapacks distributed by Xisumavoid, and created by Plagiatus (plagiatus.net) or MSpaceDev (https://www.youtube.com/c/MinecraftSpace),
with some modifications done to them by yagoply. All rights reserved to their owners.  
skztr's XOpt is in the public domain.  
create_ap belongs to oblique (github.com/oblique), and is modified for pihole-FTL compat.

**Description**  
datapacks -> Datapacks used in the Lastsnap Vanilla server.

usr/bin/-> Contains scripts used for management of the Lastsnap Vanilla server by the root user, usually through
the Toasted Watchdog Framework, and other miscellaneous utilities for management of the Gallium server (the machine everything runs on)
and the Gallium router (the subsystem that handles networking). WiFi-related solutions are included. Most of these are meant to be
used on a schedule with crontab (gallium uses cronie)

skel/home/-> Contains auxilliary files for TWF to be put in the home folder.

etc -> Contains the system configuration files

twf -> The Toasted Watchdog Framework, deprived of its easy-installation part, that was used to dumb down its deployment in the
community it was born (Fully Toasted, and their Minecraft servers). TWF allows the system to communicate with and control Minecraft servers of
any version through the Linux terminal multiplexer (tmux) and console. Very useful for automation, also functions as an auto-reboot script,
which was its original purpose. None of the TWF code belongs to company Fully Toasted (even though they have a version of it full of copyright notices).
