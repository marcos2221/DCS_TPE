# DCS_TPE
Tupper's Persistency Engine (TPE): This group of scripts works together to save the progress of the mission, it works in Single and Multiplayer scenarios.


[![Video1](http://img.youtube.com/vi/eD73WGEDZgI/0.jpg)](http://www.youtube.com/watch?v=eD73WGEDZgI "Save and Load Part 1")

[![Video2](http://img.youtube.com/vi/BnJ5bf_RBz8/0.jpg)](http://www.youtube.com/watch?v=BnJ5bf_RBz8 "Save and Load Part 2")



<b>Installation: </b>


Before you start DCS:
 You will need to place 2 files in the "Scripts" Directory which can be found in your Saved games/DcsOpenbeta folder.
 To be more precise, you need to place TPE.lua in the ""Hooks" folder and mainPersistentEnginenet.lua in the "Net" folder.

So Scripts\Hooks\TPE.lua & Scripts\net\TPE\mainPersistentEnginenet.lua

![1](https://i.imgur.com/LO2r1qd.png)

![2](https://i.imgur.com/G6vMn35.png)


 Now you can put JSON.lua in the installation folder \\programfiles\eagleDynamics\dcsOpenbeta\ (one time, Will not be affected by Upgrades)

![3](https://i.imgur.com/RkcY13T.png)

After completing the above steps you need to run the game "as administrator". (right click on your game shortcut and chose "Run as administrator" )

After running your game for the first time you will notice that a new folder named "tpe" has been created in your savedgames\DcsOpenbeta\ directory

![4](https://i.imgur.com/xybDZTh.png)

This folder will now hold the persistent text files necessary for the TP engine generator to build subsequent missions . It will also now contain a Config file that is for TPE's internal use.

In the Mission Editor:

Your Mission file MUST be named  XXXXXX_TPE.miz  ie: Operationsaver_TPE.miz

Using "Time more" triggers, load MIST, CTLD and CSAR scripts. Only then can you add: persistentMissionFileLoad.lua with a doScriptFile action.


[MIST]   https://forums.eagle.ru/showthread.php?t=98616

[CTLD](https://github.com/BSD-DEV/DCS-CTLD)

[CSAR](https://github.com/BSD-DEV/DCS-CSAR)


Example: MIST - At mission Start

             CTLD Times More 1 second

             CSAR Times More 2 Seconds

            persistentMissionFileLoad.lua  Times more 3 seconds

-------------------------------------------------------------------------------------------------------

Groups Names:

Groups that you want included in the persistent environment will have to have a "Group Name" prefixed with TP_ Such as TP_xxxxxx  ie TP_Tank

On road waypoints: If the Group's route includes a waypoint that is "onroad", The group name has to have "onroad" added after the groupname  eg:  TP_XXXXonroad  (It works, but it's still a WIP)

-------------------------------------------------------------------------------------------------------

Dynamics of the TPE:

The first time you run your mission it will start as per usual.
About 1 minute into the mission the TPE Initialization process will create a new "tpe" directory in savedgames\dcsopenbeta\.
The first run will also create a new text file in the savedgames\dcsopenbeta\tpe directory called ""yourmissionname_TPE.txt"
These files are updated/saved every minute and they will be used when you select "fly again" in the "Debriefing Screen".
Every 1 minute the TPE save process will notify you that your mission status is being saved.

On subsequent mission loads, the status of all correctly named groups will be read from the text file and spawned.
