# SnapBack
[![Build Status](https://travis-ci.com/midnightchip/SnapBack.svg?branch=Theos)](https://travis-ci.com/midnightchip/SnapBack) ![Made With](https://img.shields.io/badge/made%20with-objective--c-green.svg)

[![forthebadge](https://forthebadge.com/images/badges/built-by-developers.svg)](https://github.com/midnightchip/SnapBack) [![forthebadge](https://forthebadge.com/images/badges/check-it-out.svg)](https://github.com/midnightchip/SnapBack) [![forthebadge](https://forthebadge.com/images/badges/gluten-free.svg)](https://github.com/midnightchip/SnapBack) [![forthebadge](https://forthebadge.com/images/badges/made-with-crayons.svg)](https://github.com/midnightchip/SnapBack)[![forthebadge](https://forthebadge.com/images/badges/reading-6th-grade-level.svg)](https://github.com/midnightchip/SnapBack) [![forthebadge](https://forthebadge.com/images/badges/powered-by-watergate.svg)](https://github.com/midnightchip/SnapBack) [![forthebadge](https://forthebadge.com/images/badges/uses-badges.svg)](https://github.com/midnightchip/SnapBack)

# TimeMachine for iOS 10.3.0+ arm64 devices

Disclaimer: SnapBack has been tested thoroughly, but it is still beta software, so proceed with caution. 


Now then, what are apfs snapshots?
"Snapshots are a new feature of Apple's APFS filesystem. A snapshot is a point-in-time representation of a volume on your hard drive. Once the snapshot is taken, each file within that snapshot will be available on the snapshot in its exact state at the moment that the snapshot was taken, even if you delete the file."
Imagine taking a picture of your devices memory, and being able to jump back to that point in time whenever you want. Snapshots aren't known to take up to much space, but Var snapshots (the user partition, that holds your photos and apps) is more likely to take up a lot of space.

When you first launch SnapBack, I urge you to create a root snapshot, so that you can always jump back to the moment after you installed SnapBack, as long as you can jailbreak.

Those of you on iOS 11+, the root snapshot named "orig-fs" is the original snapshot that is either made right before you jailbroke the first time, or the snapshot that apple made when you updated your OS. Under no circumstance should you ever delete this Snapshot. It is your fallback to use Rollectra or Unc0vers reset FS option. Another word of warning, don't use Rollectra or Unc0vers reset FS option unless you really need to, as doing that will delete all of your APFS snapshots.
If you are able, revert using SnapBack so that you can retain your other snapshots.

SnapBack can be used to jump between jailbreaks. In order to do this, take a root snapshot when you have a jailbreak setup the way you want, then jump back to the orig-fs snapshot. At this point you can jailbreak using a different jailbreak with no issues. Install SnapBack again, and if all went to plan you will be able to jump to your previous jailbreak snapshot and vice versa. This is a good way to try out other jailbreaks or to just have a fallback point in time when you had everything set up perfectly.

When restoring var snapshots, if you jump to a snapshot that was signed in with a different iCloud account, you will be prompted over and over again to log into icloud. Simply open settings and sign out of the iCloud account to get rid of these messages.

Notes:
-	SnapBack requires your battery to be above 50% or to be plugged in.
-	Even if the app appears to be frozen during the snapping process, wait.
-	SnapBack is written for iOS 10.3.0+ for arm64 and arm64e devices only. 

[Images](https://imgur.com/gallery/Hb1YDXN)

Special thanks to:
CreatureSurvive, 
PINPAL, 
the_casle,
pwn20wnd,
sbingner,
Samg_is_a_Ninja
Tony, 
Chilaxan and 
Easy-Z

Warning: Do not attempt to revert while on low memory. Make sure you have a good amount of space before you revert just so it doesn’t fail. I can’t say an exact number as all snapshots when mounted are different sizes
# Installation

1. Add https://repo.midnightchips.me to your favorite package manager.
2. Install SnapBack
3. Profit

# How to build 

1. Install [Theos](https://github.com/theos/theos/wiki/Installation)
2. Clone This Repository
3. Type `make`
4. Succeed

# Legal
<body>
   <h2>SnapBack</h2>
   <h3>Copyright (C) 2019  MidnightChips</h3>
   <p>GNU Affero General Public License, Version 3</p>
   <p>This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.</p>
   <p>This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.</p>
   <p>You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <a href="http://www.gnu.org/licenses/">http://www.gnu.org/licenses/</a></p>
   <h2>rsync</h2>
   <p>Run from commandline</p>
   <p>GNU General Public License, Version 3</p>
   <p>This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.</p>
   <p>This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.</p>
   <p>You should have received a copy of the General Public License along with this program.  If not, see <a href="http://www.gnu.org/licenses/">http://www.gnu.org/licenses/</a></p>
   <h2>libSnappy</h2>
   <h3>Copyright (C) 2018  Sam Bingner (sbingner), All rights reserved</h3>
   <p><a href="https://github.com/sbingner/snappy/">https://github.com/sbingner/snappy/</a></p>
   <h2>iAmGRoot</h2>
   <h3>Copyright © 2016 - 2019 CreatureCoding (Dana Buehre), All Rights Reserved.</h3>
   <p><i>Any distribution of this software software must contain this copyright notice</i></p>
   <p><a href="https://github.com/CreatureSurvive/iAmGRoot">https://github.com/CreatureSurvive/iAmGRoot</a></p>
   <h2>Settings Idea, Reprovision</h2>
   <h3>Copyright (C) 2018-2019 Matchstic</h3>
   <p>GNU Affero General Public License, Version 3</p>
   <p>This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.</p>
   <p>This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.</p>
   <p>You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <a href="http://www.gnu.org/licenses/">http://www.gnu.org/licenses/</a></p>
</body>
