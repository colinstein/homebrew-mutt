# Mutt with Patches
The mutt email client with sidebar and trash folder patches.

## Description
The official Homebrew formula for Mutt does not accept patches to add support
for non-upstream patches. Many of those patches are popular but not kept up to
date with Mutt releases. In order to gain access to the functionality provided
by those non-upstream patches we're required to maintain our own tap.

This tap adds the following features to the standard Mutt formula in homebrew

  * `--with-sidebar-patch` adds a "folder list" style side-bar. This feature is
    popular in many graphical email clients as well as web-base mail interfaces.
  * `--with-trash-patch` allows you to define a trash-folder where messages are
    moved when marked as deleted. You can allow your mail server to expunge your
    messages or manually delete them as needed. This feature is similar to how
    many modern graphical email clients work.

## Installation
This patch duplicates a formula already available in Homebrew. In order to use
this as the formula to install mutt you must either: *tap-pin* when adding this
tap; or install passing the full formula name:

Install with tap-pin:

    $ brew tap-pin colinstein/mutt
    $ brew install mutt

Install with full path:

    $ brew tap colinstein/mutt
    $ brew install colinstein/mutt/mutt

## Patches
The trash-bar patch was written by Cedric Duval. You can view the details of his
work and the documentation [at his website](http://cedricduval.free.fr/mutt/patches/#trash).
it has since been updated for mutt 1.5.24 by Andreas Jaggi. [Details of his work](https://blog.x-way.org/Linux/2015/09/23/Homebrew-Tap-for-Mutt-1-5-24-with-trash_folder-patch.html)
are on this blog.

The side-bar patch was written by Justin Hibbits and is maintained for the
pristine Mutt source by Terry Chan. The documentation and details of his work
can be found at [Lunar Linux](http://www.lunar-linux.org/mutt-sidebar/) though
the Thomer Gil, who improved Justin's original work, also has equivalent
[documentation](http://thomer.com/mutt/index-old.html) on his site.
