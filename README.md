# Description:
TrainSportation main goal is to allow you to drive trains. The idea is other resources can spawn trains (like for a job) and this resource will handle the driving of the train.

But, it does comes with a simple train spawning script that you can disable inside config.lua (by setting Config.Debug to false)
If debug is on, you will see two (by default) green T icons on your map. To spawn a train stand in the green circle and press G (can change in config.lua)

# Controlling the Train
Thanks to HJDCZY (github)! The latest update (2/4/24) allows you to open/close the doors of the trains!
You can walk into the trolley as a passenger with this! (default is , and . for left and right)

The train acceleration is controlled by a lever, holding SpeedUp increases this lever, and SpeedDown decreases it. EBreak will set the lever to 0 causing the train to break.

# Install:
Download from the github below, make sure to 'ensure TrainSportation' in your server config!

# Keybinds, changeable in config.lua
```lua
Config.KeyBind = {
	SpeedUp = 71, -- W Lever Up
	SpeedDown = 72, -- S Lever Down
	EBreak = 73, -- X Break
	EnterExit = 75, -- F Enter/Exit
	LeftDoor = 82, -- , Open/Close Left Doors
	RightDoor = 81 -- . Open/Close Right Doors
}
Config.KeyBind.Debug = { -- Only work when Config.Debug is true
	SpawnTrain = 58, -- G, Spawn while inside green circle
	DeleteTrain = 111 -- Numpad 8, Delete train that you are looking at
}
```

Download:
https://github.com/LexTheGreat/TrainSportation/archive/master.zip
https://github.com/LexTheGreat/TrainSportation

Images:
https://i.imgur.com/VMzjkLQ.jpeg
https://puu.sh/yfvNt/81b07dc023.png
