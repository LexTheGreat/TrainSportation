if (Config.Debug) then
	Citizen.CreateThread(function()
		DebugLog("Train Markers Init.")
		while true do		
			Wait(0)
			if Config.ModelsLoaded then	
				for i=1, #Config.TrainLocations, 1 do
					local coords = GetEntityCoords(PlayerPedId())
					local trainLocation = Config.TrainLocations[i]
					if(GetDistanceBetweenCoords(coords, trainLocation.x, trainLocation.y, trainLocation.z, true) < Config.DrawDistance) then
						DrawMarker(Config.MarkerType, trainLocation.x, trainLocation.y, trainLocation.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z-2.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
					end
					if(GetDistanceBetweenCoords(coords, trainLocation.x, trainLocation.y, trainLocation.z, true) < Config.MarkerSize.x / 2) then
						if(IsControlPressed(0,Config.KeyBind.Debug.SpawnTrain) and(GetGameTimer() - Config.EnterExitDelay) > Config.EnterExitDelayMax) then -- G
							Config.EnterExitDelay = 0
							Wait(60)
							CreateTrain(trainLocation.trainID, trainLocation.trainX, trainLocation.trainY, trainLocation.trainZ)
						end
					end
				end
			end
		end
	end)
end

function DoTrains()
	if Config.ModelsLoaded then
		if (Config.EnterExitDelay == 0) then
			Config.EnterExitDelay = GetGameTimer()
		end
		if (Config.inTrain) then
			if (IsControlPressed(0,Config.KeyBind.SpeedUp) and IsControlPressed(0,Config.KeyBind.SpeedDown) and Config.Debug and Config.Speed ~= 0) then -- D(E)bug Break (W+S)
				DebugLog("break:" .. GetEntityCoords(Config.TrainVeh))
				Config.Speed = 0
				SetTrainSpeed(Config.TrainVeh, 0)
			elseif (IsControlPressed(0,Config.KeyBind.EBreak)) then -- E Break (X)
				Config.Speed = 0
			elseif (IsControlPressed(0,Config.KeyBind.SpeedUp) and Config.Speed < GetTrainSpeeds(Config.TrainVeh).MaxSpeed) then  -- Forward (W)
				DebugLog("W: " .. Config.Speed)
				Config.Speed = Config.Speed + GetTrainSpeeds(Config.TrainVeh).Accel
			elseif (IsControlPressed(0,Config.KeyBind.SpeedDown) and Config.Speed  > -GetTrainSpeeds(Config.TrainVeh).MaxSpeed)then -- Backwards (S)
				DebugLog("S: " .. Config.Speed)
				Config.Speed = Config.Speed - GetTrainSpeeds(Config.TrainVeh).Dccel
			end
			
			SetTrainCruiseSpeed(Config.TrainVeh,Config.Speed)
		elseif IsPedInAnyTrain(PlayerPedId()) then -- Should fix not being able to drive trains after restart resource.
			-- DebugLog("I'm in a train? Did the resource restart...")
			if GetVehiclePedIsIn(PlayerPedId(), false) == 0 then
				-- DebugLog("Unable to get train, re-enter the train, or wait!")

				-- IsPedInAnyTrain(PlayerPedId()) can be true while GetVehiclePedIsIn(PlayerPedId(), false) is false.
				-- This is a new thing with being inside a train, while not driving it. Disabling the Logs for this as it shouldn't be a issue.
			else
				DebugLog("T:" .. GetVehiclePedIsIn(PlayerPedId(), false) .. "|M:" .. GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)))
				Config.TrainVeh = GetVehiclePedIsIn(PlayerPedId(), false)
				Config.inTrain = true
			end
		end

		-- Enter/Exit (F)
		if(IsControlPressed(0,Config.KeyBind.EnterExit) and(GetGameTimer() - Config.EnterExitDelay) > Config.EnterExitDelayMax) then
			Config.EnterExitDelay = 0
			
			if(Config.inTrain or Config.inTrainAsPas) then
				DebugLog("exit")
				if (Config.TrainVeh ~= 0) then
					local off = GetOffsetFromEntityInWorldCoords(Config.TrainVeh, -2.0, -5.0, 0.6)
					SetEntityCoords(PlayerPedId(), off.x, off.y, off.z,false,false,false,false)
				end
				Config.inTrain = false
				Config.inTrainAsPas = false
				Config.TrainVeh = 0
			else
				Config.TrainVeh = FindNearestTrain()
				if (Config.TrainVeh ~= 0) then
					if (GetPedInVehicleSeat(Config.TrainVeh, 1) == 0) then -- If train has driver, then enter the back
						SetPedIntoVehicle(PlayerPedId(),Config.TrainVeh,-1)
						Config.inTrain = true
						DebugLog("Set into Train!")
						DebugLog("T:" .. GetVehiclePedIsIn( ped, false ) .. "|M:" .. GetEntityModel(GetVehiclePedIsIn( ped, false )))
					elseif GetCanPassenger(Config.TrainVeh) then
						local off = GetOffsetFromEntityInWorldCoords(Config.TrainVeh, 0.0, -5.0, 0.6)
						SetEntityCoords(PlayerPedId(), off.x, off.y, off.z)
						Config.inTrainAsPas = true
						DebugLog("Set into Train as Passenger!")
						DebugLog("T:" .. GetVehiclePedIsIn( ped, false ) .. "|M:" .. GetEntityModel(GetVehiclePedIsIn( ped, false )))
					end
				end
			end
		end
		
		-- KP8 to delete train infront
		if((IsControlPressed(0,Config.KeyBind.Debug.DeleteTrain) and(GetGameTimer() - Config.EnterExitDelay) > Config.EnterExitDelayMax) and Config.Debug) then
			Config.EnterExitDelay = 0
			local nT = FindNearestTrain()
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
		Log("Loading Train Models.")
		RequestModelSync("freight")
		RequestModelSync("freightcar")
		RequestModelSync("freightgrain")
		RequestModelSync("freightcont1")
		RequestModelSync("freightcont2")
		RequestModelSync("freighttrailer")
		RequestModelSync("tankercar")
		RequestModelSync("metrotrain")
		RequestModelSync("s_m_m_lsmetro_01")
		Log("Done Loading Train Models.")
		Config.ModelsLoaded = true
	end
	LoadTrainModels()
	
	if (Config.Debug) then
		DebugLog("Loading Train Blips.")
		for i=1, #Config.TrainLocations, 1 do
			local blip = AddBlipForCoord(Config.TrainLocations[i].x, Config.TrainLocations[i].y, Config.TrainLocations[i].z)      
			SetBlipSprite (blip, Config.BlipSprite)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 0.9)
			SetBlipColour (blip, 2)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("train")
			EndTextCommandSetBlipName(blip)
		end
		DebugLog("Done Loading Train Blips.")
	end
	
	while true do
		Wait(0)
		DoTrains()
	end
end)

Citizen.CreateThread(function()
	SetTrainsForceDoorsOpen(0)
	while true do
		Citizen.Wait(0)
		if Config.inTrain then
			--    
			-- door open/close
			local doorcount = GetTrainDoorCount(Config.TrainVeh)
			-- -- print (doorcount)
			if IsControlJustReleased(keyboard, Config.KeyBind.LeftDoor) then
				-- -- print (Config.TrainVeh)
				local carrige = GetTrainCarriage(Config.TrainVeh, 1)

				-- smoothly open door in animation	
				local serverid = GetPlayerServerId(PlayerId())
				local doorstate = GetTrainDoorOpenRatio(Config.TrainVeh, 0)
				if doorstate <=0.05 then
					--    
					--           
					-- let other players see the door opening animation	
					TriggerServerEvent('Train:opendoor', 1, NetworkGetNetworkIdFromEntity(Config.TrainVeh), NetworkGetNetworkIdFromEntity(carrige), serverid)
					while doorstate <= 1.0 do
						SetTrainDoorOpenRatio(Config.TrainVeh, 0, doorstate)
						SetTrainDoorOpenRatio(Config.TrainVeh, 2, doorstate)
						SetTrainDoorOpenRatio(carrige, 1, doorstate)
						SetTrainDoorOpenRatio(carrige, 3, doorstate)	
						doorstate = doorstate + 0.01
						Citizen.Wait(2)
					end
				else
					--    
					--           
					TriggerServerEvent('Train:closeDoor', 1, NetworkGetNetworkIdFromEntity(Config.TrainVeh), NetworkGetNetworkIdFromEntity(carrige), serverid)
					while doorstate >= 0.0 do
						SetTrainDoorOpenRatio(Config.TrainVeh, 0, doorstate)
						SetTrainDoorOpenRatio(Config.TrainVeh, 2, doorstate)
						SetTrainDoorOpenRatio(carrige, 1, doorstate)
						SetTrainDoorOpenRatio(carrige, 3, doorstate)	
						doorstate = doorstate - 0.01
						Citizen.Wait(2)
					end
				end

			elseif IsControlJustReleased(keyboard, Config.KeyBind.RightDoor) then
				local carrige = GetTrainCarriage(Config.TrainVeh, 1)

				local doorstate = GetTrainDoorOpenRatio(Config.TrainVeh, 1)
				local serverid = GetPlayerServerId(PlayerId())
				if doorstate <=0.05 then
					-- print (Config.TrainVeh .. " " .. carrige)
					-- print (NetworkGetNetworkIdFromEntity(Config.TrainVeh) .. " " .. NetworkGetNetworkIdFromEntity(carrige))
					--    
					--           	
					TriggerServerEvent('Train:opendoor', 0, NetworkGetNetworkIdFromEntity(Config.TrainVeh), NetworkGetNetworkIdFromEntity(carrige), serverid)
					while doorstate <= 1.0 do
						
						SetTrainDoorOpenRatio(Config.TrainVeh, 1, doorstate)
						SetTrainDoorOpenRatio(Config.TrainVeh, 3, doorstate)
						SetTrainDoorOpenRatio(carrige, 0, doorstate)
						SetTrainDoorOpenRatio(carrige, 2, doorstate)	
						doorstate = doorstate + 0.01
						Citizen.Wait(1)
					end
					SetVehicleDoorOpen(Config.TrainVeh, 3, false, false)
					SetVehicleDoorOpen(Config.TrainVeh, 1, false, false)
					SetVehicleDoorOpen(carrige, 0, false, false)
					SetVehicleDoorOpen(carrige, 2, false, false)
				else
					--    
					--           
					TriggerServerEvent('Train:closeDoor', 0, NetworkGetNetworkIdFromEntity(Config.TrainVeh), NetworkGetNetworkIdFromEntity(carrige), serverid)
					while doorstate >= 0.0 do
						SetTrainDoorOpenRatio(Config.TrainVeh, 1, doorstate)
						SetTrainDoorOpenRatio(Config.TrainVeh, 3, doorstate)
						SetTrainDoorOpenRatio(carrige, 0, doorstate)
						SetTrainDoorOpenRatio(carrige, 2, doorstate)	
						doorstate = doorstate - 0.01
						Citizen.Wait(1)
					end
					SetVehicleDoorShut(Config.TrainVeh, 3, false)
					SetVehicleDoorShut(Config.TrainVeh, 1, false)
					SetVehicleDoorShut(carrige, 0, false)
					SetVehicleDoorShut(carrige, 2, false)
				end
			end

					
		end
	end
end)

RegisterNetEvent('Train:opendoor')
AddEventHandler('Train:opendoor', function(direction,trainnetworkid,carrigenetworkid, serverid )
	if not NetworkDoesEntityExistWithNetworkId(trainnetworkid) or not NetworkDoesEntityExistWithNetworkId(carrigenetworkid) then
		return
	end
	--      ，  
	-- if self, return
	if serverid == GetPlayerServerId(PlayerId()) then
		return
	end
	-- print (direction .. " " .. trainnetworkid .. " " .. carrigenetworkid)
	local train = NetworkGetEntityFromNetworkId(trainnetworkid)
	local carrige = NetworkGetEntityFromNetworkId(carrigenetworkid)
	-- print (type(direction))
	-- print (train ..DoesEntityExist(train) ..  " " .. carrige .. DoesEntityExist(carrige))
	-- direction true  ，false  
	-- direction true left, false right
	local doorstate = 0.0
	if direction == 1 then
		-- print ("open left")
		while doorstate <= 1.0 do
			SetTrainDoorOpenRatio(train, 0, doorstate)
			SetTrainDoorOpenRatio(train, 2, doorstate)
			SetTrainDoorOpenRatio(carrige, 1, doorstate)
			SetTrainDoorOpenRatio(carrige, 3, doorstate)	
			doorstate = doorstate + 0.01
			Citizen.Wait(2)
		end
	else
		-- print ("open right")
		while doorstate <= 1.0 do
			SetTrainDoorOpenRatio(train, 1, doorstate)
			SetTrainDoorOpenRatio(train, 3, doorstate)
			SetTrainDoorOpenRatio(carrige, 0, doorstate)
			SetTrainDoorOpenRatio(carrige, 2, doorstate)	
			doorstate = doorstate + 0.01
			Citizen.Wait(2)
		end
	end
end)
RegisterNetEvent('Train:closeDoor')
AddEventHandler('Train:closeDoor', function(direction,trainnetworkid,carrigenetworkid,serverid)
	if not NetworkDoesEntityExistWithNetworkId(trainnetworkid) or not NetworkDoesEntityExistWithNetworkId(carrigenetworkid) then
		return
	end
	if serverid == GetPlayerServerId(PlayerId()) then
		return
	end
	-- print (direction .. " " .. trainnetworkid .. " " .. carrigenetworkid)
	-- print (type(direction))
	local train = NetworkGetEntityFromNetworkId(trainnetworkid)
	local carrige = NetworkGetEntityFromNetworkId(carrigenetworkid)
	-- direction true  ，false  
	local doorstate = 1.0
	-- print (train .. DoesEntityExist(train) .. " " .. carrige .. DoesEntityExist(carrige))
	if direction == 1 then
		while doorstate >= 0.0 do
			SetTrainDoorOpenRatio(train, 0, doorstate)
			SetTrainDoorOpenRatio(train, 2, doorstate)
			SetTrainDoorOpenRatio(carrige, 1, doorstate)
			SetTrainDoorOpenRatio(carrige, 3, doorstate)	
			doorstate = doorstate - 0.01
			Citizen.Wait(2)
		end
	else
		while doorstate >= 0.0 do
			SetTrainDoorOpenRatio(train, 1, doorstate)
			SetTrainDoorOpenRatio(train, 3, doorstate)
			SetTrainDoorOpenRatio(carrige, 0, doorstate)
			SetTrainDoorOpenRatio(carrige, 2, doorstate)	
			doorstate = doorstate - 0.01
			Citizen.Wait(2)
		end
	end
end)
