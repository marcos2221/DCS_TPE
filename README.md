# DCS_TPE
Tupper's Persistency engine: Save the progress on the mission, works in Single and Multiplayer


<b>Installation: </b>


Before Start DCS:

Like a Mod, place the files in the Script Folder under Saved games/DcsOpenbeta

[Imgur](https://i.imgur.com/LO2r1qd.png)

[Imgur](https://i.imgur.com/G6vMn35.png)

[Imgur](https://i.imgur.com/RkcY13T.png)

[Imgur](https://i.imgur.com/xybDZTh.png)



Files to be added in Hooks and Net folder.

Scripts\Hooks\TPE.lua
Script\net\TPE\mainPersistentEnginenet.lua
Place JSON.lua in installation folder \\programfiles\eagleDynamics\dcsOpenbeta\ (one time, Will not be affected by Upgrades)


Game must be run as administrator. At least after upgrades.

Fist time after Running A new folder will be created in savedgames\DcsOpenbeta\ named "tpe"



This folder will contain all the files for each mission the engine is used. and a Config file that is for Internal use.

On Mission Editor:

MISSION MUST HAVE THE NAME OF THE FILE AS XXXXXX_TPE.miz

Add the file: persistentMissionFileLoad.lua in a new trigger with a doScriptFile action 

This Trigger MUST be executed After the load of MIST, CTLD and CSAR scripts.

Example: MIST - At mission Start

             CTLD Times More 1 second

             CSAR Times More 2 Seconds

            PersistentMission...  Times more 3 seconds

-------------------------------------------------------------------------------------------------------

Groups Names:

Groups that will be persisted will have to be named as TP_XXXXXX 

On road waypoint: If the Unit Contains a waypoint that has to be followed on the road, names has to be set as TP_XXXXonroad  (It works but still a WIP)

-------------------------------------------------------------------------------------------------------

Dynamic of the TPE:

Mission will start as usual,
Initialization process
All units will be read from the File and spawned.
First run since no file it's there nothing will happen.
Every 1 minute the Save process will happen
Fist run will also create the file in the folder savedgames\dcsopenbeta\MISSIONNAME.txt
