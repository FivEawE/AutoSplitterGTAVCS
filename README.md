# GTA: Vice City Stories PPSSPP Auto Splitter

An Auto Splitter for GTA: Vice City Stories running in PPSSPP emulator.

## Features

* Automatically starts and resets the timer
* Automatic splitting for categories:
	* All Red Balloons
	* All Unique Stunt Jumps
* Supports 64 bit version of PPSSPP

## Installation

* Download or clone from this repository.
* Open PPSSPP first.
* Open LiveSplit, right-click the timer and choose **Edit Layout...**.
* A new window will pop up, click on the **+** on the top left side. Navigate to **Control** and select **Scriptable Auto Splitter**.
* A new item will show up in the list, called **Scriptable Auto Splitter**. Double-click it.
* A new window will appear. Use **Browse...** near the **Script Path** field to select the downloaded (cloned) **AutoSplitter_PPSSPP_GTAVCS.asl**.
* If everything went correctly, you should see that the options **Split** and **Reset** are not grayed out anymore and the version of your PPSSPP next to it.
* Select from the settings below what category you want to run (you can even combine categories).

## Supported PPSSPP versions

* 1.8.0 64 bit
* 1.7.4 64 bit

## Supported game versions

* EU (ULES-00502)
* US (ULUS-10160)
* GER (ULES-00503)

## Changelog

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
* [LiveSplit ASL Documentation](https://github.com/LiveSplit/LiveSplit/blob/master/Documentation/Auto-Splitters.md)
* [zoton2's Auto Splitters](https://github.com/zoton2/LiveSplit.Scripts)
* [NABN00B's GTA: Liberty City Stories Auto Splitter](https://github.com/DavidTamas/LiveSplit.Autosplitters)

## Special thanks

* NABN00B
* Fryterp23