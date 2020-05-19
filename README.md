# Ubuntu Server 20.04 VM setup scripts

Hi there!

Here you'll find two bash scripts intended for a freshly installed Ubuntu VitualBox VM. The main goal is to have a repeatable environment.

Oh, and it's aimed at my interests in coding, so LAMP, an apache virtual host, node, mongodb, docker, and a bunch of assorted apps.

To quickly summarize how they work:

+ Run the script that installs VBGuest additions first
* At some point it will ask you to load the VBGuestAdditions media, in case you were unaware you needed to
+ The script forces a reboot
+ Then, you can edit the second sript for some variables. Notably, shared folder info, an apache site name and a few passwords.
* Run the script you just edited
+ It will take some time... But no input is necessary until the very very end.

And that´s it. Not much more to it. Some thoughts on improvements and instructions are listed in comments.

Not sure if it will be of use to anyone but do let me know, please! :heart:
