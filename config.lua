Config = {}
-- Current Train Config
Config.ModelsLoaded = false
Config.inTrain = false -- F while train doesn't have driver
Config.inTrainAsPas = false -- F while train has driver
Config.TrainVeh = 0
Config.Speed = 0
Config.EnterExitDelay = 0
Config.EnterExitDelayMax = 600
--Marker and Locations
Config.MarkerType   = 1
Config.DrawDistance = 100.0
Config.MarkerType   = 1
Config.MarkerSize   = {x = 1.5, y = 1.5, z = 1.0}
Config.MarkerColor  = {r = 0, g = 255, b = 0}
Config.BlipSprite   = 79

-- Debug, enable train spawning. FALSE THIS TO SPAWN YOUR OWN TRAINS
Config.Debug = true
Config.DebugLog = true -- If Debug is true, allow debug logs.

Config.KeyBind = {
	SpeedUp = 71, -- W
	SpeedDown = 72, -- S
	EBreak = 73, -- X
	EnterExit = 75, -- F
	LeftDoor = 82, -- ,
	RightDoor = 81 -- .
}
Config.KeyBind.Debug = { -- Only work when Config.Debug is true
	SpawnTrain = 58, -- G
	DeleteTrain = 111 -- Numpad 8
}

-- Marker/Blip Locations/Spawn locations
Config.TrainLocations = {
	{ ['x'] = 247.965,  ['y'] = -1201.17,  ['z'] = 38.92, ['trainID'] = 27, ['trainX'] = 247.9364, ['trainY'] = -1198.597, ['trainZ'] = 37.4482 }, -- Trolley
	{ ['x'] = 670.2056,  ['y'] = -685.7708,  ['z'] = 25.15311, ['trainID'] = 17, ['trainX'] = 670.2056, ['trainY'] = -685.7708, ['trainZ'] = 25.15311 }, -- FTrain
}

-- Train speeds (https://en.wikipedia.org/wiki/Rail_speed_limits_in_the_United_States)
Config.TrainSpeeds = {
	[1030400667] = { ["MaxSpeed"] = 75, ["Accel"] = 0.01, ["Dccel"] = 0.02, ["Pass"] = false }, -- F Trains
	[868868440] = { ["MaxSpeed"] = 40, ["Accel"] = 0.05, ["Dccel"] = 0.07, ["Pass"] = false}, -- metro
}
 -- Utils
function GetVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

function FindNearestTrain()
	local localPedPos = GetEntityCoords(GetPlayerPed(-1))
	local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 120.0, 0.0)
	local veh = GetVehicleInDirection(localPedPos, entityWorld)
	
	if veh > 0 and IsEntityAVehicle(veh) and IsThisModelATrain(GetEntityModel(veh)) then
		if Config.Debug then 
			DebugLog("Checking ".. GetEntityModel(veh))
			DrawLine(localPedPos, entityWorld, 0,255,0,255)
		end
		return veh
	else
		if Config.Debug then 
			DrawLine(localPedPos, entityWorld, 255,0,0,255)
		end
		return 0
	end
end

function GetTrainSpeeds(veh)
	local model = GetEntityModel(veh)
	-- print("Model: " .. model)
	local ret = {}
	ret.MaxSpeed = 0
	ret.Accel = 0
	ret.Dccel = 0
	
	if Config.TrainSpeeds[model] then
		local tcfg = Config.TrainSpeeds[model]
		ret.MaxSpeed = tcfg.MaxSpeed -- Heavy, but fast.
		ret.Accel = tcfg.Accel
		ret.Dccel = tcfg.Dccel
	end
	return ret
end

function GetCanPassenger(veh)
	local model = GetEntityModel(veh)
	local ret = false
	
	if Config.TrainSpeeds[model] ~= nil then
		local tcfg = Config.TrainSpeeds[model]
		ret = tcfg.Pass
	end
	return ret
end

function CreateTrain(type,x,y,z)
	local train = CreateMissionTrain(type,x,y,z,true,false)
	SetTrainSpeed(train,0)
	SetTrainCruiseSpeed(train,0)
	SetEntityAsMissionEntity(train, true, false)
	-- NetworkRegisterEntityAsNetworked(train)	
	NetworkRegisterEntityAsNetworked(GetTrainCarriage( train, 1 ))
	DebugLog("CreateTrain.")
end

function DebugLog(msg)
	if Config.Debug and DebugLog then
		Citizen.Trace("[TrainSportation:Debug]: " .. msg .. "\n")
	end
end

function Log(msg)
	Citizen.Trace("[TrainSportation]: " .. msg .. "\n")
end