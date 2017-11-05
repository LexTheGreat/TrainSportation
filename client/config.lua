Config = {}
-- Current Train Config
Config.ModelsLoaded = false
Config.localPed = GetPlayerPed(PlayerId())
Config.inTrain = false -- F while train doesn't have driver
Config.inTrainAsPas = false -- F while train has driver
Config.TrainVeh = 0
Config.Speed = 0
Config.EnterExitDelay = 0
Config.EnterExitDelayMax = 600

-- Train Defaults
Config.TrainSpeeds = {}
Config.TrainSpeeds.FTrain = {}
Config.TrainSpeeds.FTrain.MaxSpeed = 100
Config.TrainSpeeds.FTrain.Accel = 0.01

Config.TrainSpeeds.Trolley = {}
Config.TrainSpeeds.Trolley.MaxSpeed = 25
Config.TrainSpeeds.Trolley.Accel = 0.1

--Marker and Locations
Config.MarkerType   = 1
Config.DrawDistance = 100.0
Config.MarkerType   = 1
Config.MarkerSize   = {x = 1.5, y = 1.5, z = 1.0}
Config.MarkerColor  = {r = 0, g = 255, b = 0}
Config.BlipSprite   = 79

Config.TrainLocations = {
	{ ['x'] = 247.965,  ['y'] = -1201.17,  ['z'] = 38.92, ['trainID'] = 24, ['trainX'] = 247.9364, ['trainY'] = -1198.597, ['trainZ'] = 37.4482 }, -- Trolly
	{ ['x'] = 670.2056,  ['y'] = -685.7708,  ['z'] = 25.15311, ['trainID'] = 2, ['trainX'] = 670.2056, ['trainY'] = -685.7708, ['trainZ'] = 25.15311 }, -- FTrain
}


-- Utils
function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, Config.localPed, 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

function findNearestTrain()
	local localPedPos = GetEntityCoords(Config.localPed)
	local entityWorld = GetOffsetFromEntityInWorldCoords(Config.localPed, 0.0, 120.0, 0.0)
	local veh = getVehicleInDirection(localPedPos, entityWorld)
	
	if veh > 0 and IsEntityAVehicle(veh) and IsThisModelATrain(GetEntityModel(veh)) then
		Citizen.Trace("Checking ".. GetEntityModel(veh))
		DrawLine(localPedPos, entityWorld, 0,255,0,255)
		return veh
	else
		DrawLine(localPedPos, entityWorld, 255,0,0,255)
		return 0
	end
end

function getTrainSpeeds()
	local mod = GetEntityModel(Config.TrainVeh)
	local ret = {}
	ret.MaxSpeed = 10
	ret.Accel = 1
	
	-- Is there a better way to do this? (GetEntityModel(Config.TrainVeh))
	if (mod == 1030400667) then
		ret.MaxSpeed = Config.TrainSpeeds.FTrain.MaxSpeed -- Heavy, but fast.
		ret.Accel = Config.TrainSpeeds.FTrain.Accel
	elseif (mod == 868868440) then
		ret.MaxSpeed = Config.TrainSpeeds.Trolley.MaxSpeed -- Light weight, carrys people around not to fast
		ret.Accel = Config.TrainSpeeds.Trolley.Accel
	end
	
	return ret
end

function createNewTrain(type,x,y,z)
	local train = CreateMissionTrain(type,x,y,z,true)
	SetTrainSpeed(train,0)
	SetTrainCruiseSpeed(train,0)
	SetEntityAsMissionEntity(train, true, false)
	Citizen.Trace("Created Train.")
end