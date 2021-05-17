# GTA: Vice City Stories PPSSPP Auto Splitter

An Auto Splitter for GTA: Vice City Stories running in PPSSPP emulator.

## Features

* Automatically starts and resets the timer
* Automatic splitting for categories:
	* any%
	* All Red Balloons
	* All Unique Stunt Jumps
	* All Rampages
* Supports 64 bit version of PPSSPP

## Installation

* Download or clone this repository.
* Open PPSSPP and load the game first (if not, the Auto Splitter will default to EU version).
* Open LiveSplit, right-click the timer and choose **Edit Layout...**.
* A new window will pop up, click on the **+** on the top left side. Navigate to **Control** and select **Scriptable Auto Splitter**.
* A new item will show up in the list, called **Scriptable Auto Splitter**. Double-click it.
* A new window will appear. Use **Browse...** near the **Script Path** field to select the downloaded (cloned) **AutoSplitter_PPSSPP_GTAVCS.asl**.
* If everything went correctly, you should see that the options **Split** and **Reset** are not grayed out anymore and the version of the game next to it.
* Select from the settings below what category you want to run (you can even combine categories).

## Supported PPSSPP versions

Probably any recent version of PPSSPP. If something does not work, please, open up an issue.

## Supported game versions

* EU (ULES-00502)
* US (ULUS-10160)
* JP (ULJM-05884)
* JP (ULJM-05297)

## Changelog

### Version 1.0.1
* Add support for JP (ULJM-05297).

### Version 1.0

* New timing - start and final split has been altered according to the new rules. Now it even performs the final split when the credits start (you need a separate split for credits though)!
* Splitting on mission start added as well (splits when credits start as well).

### Version 0.7

* Changed the way the offsets are retrieved. Now the autosplitter should support new PPSSPP releases without changing a single line of code (thanks to Parik's help).
* Added support for Japanese version.

### Version 0.6.2

* Added support for PPSSPP 1.9.0 64 bit version.

### Version 0.6.1

* Resetting of the needed variables is now done at the start of the timer.

### Version 0.6

* Added any%.
* Added All Rampages.
* Fixed splitting on reloads (any% was affected as well as combinations of collectibles with any%).

### Version 0.5

* Improved automatic timer starting.
* PPSSPP Gold support.
* Dropped support for GER since no one will run it and maintaining it would be just a waste of time.
* Still needs to start the game first in order to correctly pick up the version.

### Version 0.4.1

* Hot fix for broken Mission Attempts counter on US version. GER version might be broken as well. If you have EU, skip this version. If you have US, make sure to **start LiveSplit after you load the game**.

### Version 0.4

* Automatic timer starting after you press the **X** button to skip the first cutscene.
* Reworked resetting.

### Version 0.3

* Added All Unique Stunt Jumps.
* Added settings so you can choose which category you want to run.
* Added option to split after every 10 popped balloons for All Red Balloons category.
* GER version is apparently supported as well (thanks Fryterp23).

### Version 0.2.1

* Fixed version checking for 1.7.4 I had broken while testing other PPSSPP 1.7.x versions.

### Version 0.2

* Added support for PPSSPP 1.8.0 64 bit version. 
* The US version of the game works as well.

### Version 0.1

* Only started out, only balloons work :)

## Useful Links

* [Cheat Engine Tutorials](https://wiki.cheatengine.org/index.php?title=Tutorials)
* [LiveSplit ASL Documentation](https://github.com/LiveSplit/LiveSplit.AutoSplitters/blob/master/README.md)
* [zoton2's Auto Splitters](https://github.com/zoton2/LiveSplit.Scripts)
* [NABN00B's GTA: Liberty City Stories Auto Splitter](https://github.com/DavidTamas/LiveSplit.Autosplitters)

## Special thanks

* NABN00B
* Fryterp23
* Parik