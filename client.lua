Citizen.CreateThread(function()
	function RequestModelSync(mod) -- eh
		tempmodel = GetHashKey(mod)
		RequestModel(tempmodel)
		while not HasModelLoaded(tempmodel) do
			RequestModel(tempmodel)
			Citizen.Wait(0)
		end
	end

	function LoadTrainModels()
		DeleteAllTrains()
		
		tempmodel = GetHashKey("freight")
		RequestModel(tempmodel)
		while not HasModelLoaded(tempmodel) do
			RequestModel(tempmodel)
			Citizen.Wait(0)
		end
		
		tempmodel = GetHashKey("freightcar")
		RequestModel(tempmodel)
		while not HasModelLoaded(tempmodel) do
			RequestModel(tempmodel)
			Citizen.Wait(0)
		end
		
		tempmodel = GetHashKey("freightgrain")
		RequestModel(tempmodel)
		while not HasModelLoaded(tempmodel) do
			RequestModel(tempmodel)
			Citizen.Wait(0)
		end
		
		tempmodel = GetHashKey("freightcont1")
		RequestModel(tempmodel)
		while not HasModelLoaded(tempmodel) do
			RequestModel(tempmodel)
			Citizen.Wait(0)
		end
		
		tempmodel = GetHashKey("freightcont2")
		RequestModel(tempmodel)
		while not HasModelLoaded(tempmodel) do
			RequestModel(tempmodel)
			Citizen.Wait(0)
		end
		
		tempmodel = GetHashKey("freighttrailer")
		RequestModel(tempmodel)
		while not HasModelLoaded(tempmodel) do
			RequestModel(tempmodel)
			Citizen.Wait(0)
		end

		tempmodel = GetHashKey("tankercar")
		RequestModel(tempmodel)
		while not HasModelLoaded(tempmodel) do
			RequestModel(tempmodel)
			Citizen.Wait(0)
		end
		
		tempmodel = GetHashKey("metrotrain")
		RequestModel(tempmodel)
		while not HasModelLoaded(tempmodel) do
			RequestModel(tempmodel)
			Citizen.Wait(0)
		end
		
		tempmodel = GetHashKey("s_m_m_lsmetro_01")
		RequestModel(tempmodel)
		while not HasModelLoaded(tempmodel) do
			RequestModel(tempmodel)
			Citizen.Wait(0)
		end
		Citizen.Trace("Done Loading Train Models")
	end
	LoadTrainModels()

	-- ------------------------------------------ --
	Citizen.Trace("Loading Train Keys")
	local localPed = GetPlayerPed(PlayerId())
	
	
    local TrainVars = {}
	local TrainList = {}
	TrainVars.inTrain = false
	TrainVars.TrainVeh = 0
	TrainVars.Speed = 0
	TrainVars.EnterExitDelay = 0
	TrainVars.EnterExitDelayMax = 3000
	
	TrainVars.TrainSpeeds = {}
	TrainVars.TrainSpeeds.FTrain = {}
	TrainVars.TrainSpeeds.FTrain.MaxSpeed = 100
	TrainVars.TrainSpeeds.FTrain.Accel = 0.01
	
	TrainVars.TrainSpeeds.Trally = {}
	TrainVars.TrainSpeeds.Trally.MaxSpeed = 25
	TrainVars.TrainSpeeds.Trally.Accel = 0.1
	
	function findNearestTrain()
		for _, train in ipairs(TrainList) do
			if(not IsEntityDead(train)) then
				local pedPosition = GetEntityCoords(localPed)
				local trainPosition = GetEntityCoords(train)
				local thedist = GetDistanceBetweenCoords(pedPosition.x,pedPosition.y,pedPosition.z,trainPosition.x,trainPosition.y,trainPosition.z, false)
				Citizen.Trace("Checking ".. GetEntityModel(train) .." at: " .. tostring(trainPosition))
				Citizen.Trace("Checking Player at: " .. tostring(pedPosition))

				Citizen.Trace("Dist: " .. thedist)
				if (thedist <= 20) then
					return train
				end
			end
		end
		return 0
	end
	
	function getTrainSpeeds()
		local mod = GetEntityModel(TrainVars.TrainVeh)
		local ret = {}
		ret.MaxSpeed = 10
		ret.Accel = 1
		
		-- Is there a better way to do this? (GetEntityModel(TrainVars.TrainVeh))
		if (mod == 1030400667) then
			ret.MaxSpeed = TrainVars.TrainSpeeds.FTrain.MaxSpeed -- Heavy, but fast.
			ret.Accel = TrainVars.TrainSpeeds.FTrain.Accel
		elseif (mod == 868868440) then
			ret.MaxSpeed = TrainVars.TrainSpeeds.Trally.MaxSpeed -- Light weight, carrys people around not to fast
			ret.Accel = TrainVars.TrainSpeeds.Trally.Accel
		end
		
		return ret
	end
	
	RegisterNetEvent("UpdateTrainList")
	function UpdateTrainList(Trains, Del)
		if (Del == true) then
			for _,k in ipairs(TrainList) do
				DeleteMissionTrain(k)
			end
			
			TrainVars.inTrain = false
			TrainVars.TrainVeh = 0
			TrainVars.Speed = 0
			TrainVars.EnterExitDelay = 0
			
			Citizen.Trace("Got Delete Message, have not removed array yet.")
			return
		end
	
		Citizen.Trace("Added new Trains from server.")
		TrainList = Trains
	end
	AddEventHandler("UpdateTrainList", UpdateTrainList)
	
	function createNewTrain(type,x,y,z)
		local train = CreateMissionTrain(type,x,y,z,true)
		SetTrainSpeed(train,0)
		SetTrainCruiseSpeed(train,0)
		Citizen.Trace("Created Train, sending to server.")
		TriggerServerEvent("AddToTrainList",train)
	end
	
	function DeleteTrains()
		TriggerServerEvent("DeleteTrains")
	end
	
    while true do
        Wait(1)
		
		if (TrainVars.EnterExitDelay == 0) then
			TrainVars.EnterExitDelay = GetGameTimer()
		 end
		
		if (TrainVars.inTrain) then
			SetTrainSpeed(TrainVars.TrainVeh, TrainVars.Speed)
		end
		
		-- Speed Up/Forwards (W)
		if (IsControlPressed(0,71) and TrainVars.inTrain and TrainVars.Speed < getTrainSpeeds().MaxSpeed)then
			TrainVars.Speed = TrainVars.Speed + getTrainSpeeds().Accel
			SetTrainSpeed(TrainVars.TrainVeh, TrainVars.Speed)
		end
		
		-- Slow down/Reverse (S)
		if (IsControlPressed(0,72) and TrainVars.inTrain and TrainVars.Speed  > -getTrainSpeeds().MaxSpeed)then
			TrainVars.Speed = TrainVars.Speed - getTrainSpeeds().Accel
			SetTrainSpeed(TrainVars.TrainVeh, TrainVars.Speed)
		end
		
		-- Debug Break, instant stop. (X)
		if (IsControlPressed(0,73) and TrainVars.inTrain and TrainVars.Speed ~= 0)then
			Citizen.Trace("break:" .. GetEntityCoords(TrainVars.TrainVeh))
			TrainVars.Speed = 0
			SetTrainSpeed(TrainVars.TrainVeh, TrainVars.Speed)
		end
		
		-- Enter/Exit (F)
		if(IsControlPressed(0,75) and(GetGameTimer() - TrainVars.EnterExitDelay) > TrainVars.EnterExitDelayMax) then
			TrainVars.EnterExitDelay = 0
			
			if(TrainVars.inTrain) then
				Citizen.Trace("exit")
				if (TrainVars.TrainVeh ~= 0) then
					local pedPosition = GetEntityCoords(localPed)
					SetEntityCoords(localPed, pedPosition.x , pedPosition.y-0.5, pedPosition.z,false,false,false,false)
				end
				TrainVars.inTrain = false
				TrainVars.TrainVeh = 0
			else
				Citizen.Trace("enter")
				TrainVars.TrainVeh = findNearestTrain()
				if (TrainVars.TrainVeh ~= 0) then
					Citizen.Trace("Set into Train!")
					SetPedIntoVehicle(localPed,TrainVars.TrainVeh,-1)
					TrainVars.inTrain = true
				end
			end
		end
		
		-- 63 = Open Left side, 64 = Open Right
		
		-- Debug setup trains. (G)
		if(IsControlPressed(0,58) and(GetGameTimer() - TrainVars.EnterExitDelay) > TrainVars.EnterExitDelayMax) then
			TrainVars.EnterExitDelay = 0
			DeleteTrains()
			
			Wait(60)
			createNewTrain(24, 247.9364, -1198.597, 37.4482) -- Trally
			createNewTrain(2, 670.2056, -685.7708, 25.15311) -- ?
		end
		
		-- Debug Remove Trains (Do this before restart or trains will forever haunt you) (KP8)
		if(IsControlPressed(0,111) and(GetGameTimer() - TrainVars.EnterExitDelay) > TrainVars.EnterExitDelayMax) then
			TrainVars.EnterExitDelay = 0
			DeleteTrains()
		end
    end
end)