function doTrains()
	if Config.ModelsLoaded then
		if (Config.EnterExitDelay == 0) then
			Config.EnterExitDelay = GetGameTimer()
		end
		
		if (Config.inTrain) then
			SetTrainSpeed(Config.TrainVeh, Config.Speed)
		end
		
		-- Speed Up/Forwards (W)
		if (IsControlPressed(0,71) and Config.inTrain and Config.Speed < getTrainSpeeds().MaxSpeed)then
			Config.Speed = Config.Speed + getTrainSpeeds().Accel
			SetTrainSpeed(Config.TrainVeh, Config.Speed)
		end
		
		-- Slow down/Reverse (S)
		if (IsControlPressed(0,72) and Config.inTrain and Config.Speed  > -getTrainSpeeds().MaxSpeed)then
			Config.Speed = Config.Speed - getTrainSpeeds().Accel
			SetTrainSpeed(Config.TrainVeh, Config.Speed)
		end
		
		-- Debug Break, instant stop. (X)
		if (IsControlPressed(0,73) and Config.inTrain and Config.Speed ~= 0 and Config.debug)then
			Citizen.Trace("break:" .. GetEntityCoords(Config.TrainVeh))
			Config.Speed = 0
			SetTrainSpeed(Config.TrainVeh, Config.Speed)
		end
		
		-- Enter/Exit (F)
		if(IsControlPressed(0,75) and(GetGameTimer() - Config.EnterExitDelay) > Config.EnterExitDelayMax) then
			Config.EnterExitDelay = 0
			
			if(Config.inTrain or Config.inTrainAsPas) then
				Citizen.Trace("exit")
				if (Config.TrainVeh ~= 0) then
					local off = GetOffsetFromEntityInWorldCoords(Config.TrainVeh, -2.0, -5.0, 0.6)
					SetEntityCoords(GetPlayerPed(-1), off.x, off.y, off.z,false,false,false,false)
				end
				Config.inTrain = false
				Config.inTrainAsPas = false
				Config.TrainVeh = 0
			else
				Config.TrainVeh = findNearestTrain()
				if (Config.TrainVeh ~= 0) then
					if (GetPedInVehicleSeat(Config.TrainVeh, 1) == 0) then -- If train has driver, then enter the back
						SetPedIntoVehicle(GetPlayerPed(-1),Config.TrainVeh,-1)
						Config.inTrain = true
					else
						local off = GetOffsetFromEntityInWorldCoords(Config.TrainVeh, 0.0, -5.0, 0.6)
						SetEntityCoords(GetPlayerPed(-1), off.x, off.y, off.z)
						Config.inTrainAsPas = true
					end
					Citizen.Trace("Set into Train!")
				end
			end
		end
		
		-- 63 = Open Left side, 64 = Open Right
		
		-- KP8 to delete train infront
		if(IsControlPressed(0,111) and(GetGameTimer() - Config.EnterExitDelay) > Config.EnterExitDelayMax) then
			Config.EnterExitDelay = 0
			local nT = findNearestTrain()
			if nT ~= 0 then
				DeleteMissionTrain(nT)
				Config.inTrain = false -- F while train doesn't have driver
				Config.inTrainAsPas = false -- F while train has driver
				Config.TrainVeh = 0
				Config.Speed = 0
			end
		end
	end
end

function setupMarkers()
	Citizen.CreateThread(function()
		Citizen.Trace("Loading Train Markers.")
		while true do		
			Wait(0)
			if Config.ModelsLoaded then	
				for i=1, #Config.TrainLocations, 1 do
					local coords = GetEntityCoords(GetPlayerPed(-1))
					local trainLocation = Config.TrainLocations[i]
					if(GetDistanceBetweenCoords(coords, trainLocation.x, trainLocation.y, trainLocation.z, true) < Config.DrawDistance) then
						DrawMarker(Config.MarkerType, trainLocation.x, trainLocation.y, trainLocation.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z-2.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
					end
					if(GetDistanceBetweenCoords(coords, trainLocation.x, trainLocation.y, trainLocation.z, true) < Config.MarkerSize.x / 2) then
						if(IsControlPressed(0,58) and(GetGameTimer() - Config.EnterExitDelay) > Config.EnterExitDelayMax) then -- G
							Config.EnterExitDelay = 0
							Wait(60)
							createNewTrain(trainLocation.trainID, trainLocation.trainX, trainLocation.trainY, trainLocation.trainZ)
						end
					end
				end
			end
		end
	end)
end

-- Load Models
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
		Config.ModelsLoaded = false
		Citizen.Trace("Loading Train Models.")
		RequestModelSync("freight")
		RequestModelSync("freightcar")
		RequestModelSync("freightgrain")
		RequestModelSync("freightcont1")
		RequestModelSync("freightcont2")
		RequestModelSync("freighttrailer")
		RequestModelSync("tankercar")
		RequestModelSync("metrotrain")
		RequestModelSync("s_m_m_lsmetro_01")
		Citizen.Trace("Done.")
		Config.ModelsLoaded = true
	end
	LoadTrainModels()
	
	Citizen.Trace("Loading Train Blips.")
	for i=1, #Config.TrainLocations, 1 do
		local blip = AddBlipForCoord(Config.TrainLocations[i].x, Config.TrainLocations[i].y, Config.TrainLocations[i].z)      
		SetBlipSprite (blip, Config.BlipSprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.9)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Trains")
		EndTextCommandSetBlipName(blip)
	end
	setupMarkers()
	
	while true do
		Wait(0)
		doTrains()
	end
end)