TrainList = {} -- Not tested with more than one person... 
-- Should work? Couldn't find a diff way to track spawned trains, or any trains at all!

RegisterServerEvent("hardcap:playerActivated")
AddEventHandler('hardcap:playerActivated', function()
	TriggerClientEvent("UpdateTrainList",-1, TrainList, false)
	print("Sending list to new client")
end)

RegisterServerEvent("AddToTrainList")
AddEventHandler('AddToTrainList', function(Train)
	table.insert(TrainList,Train)
	TriggerClientEvent("UpdateTrainList",-1, TrainList)
end)

RegisterServerEvent("DeleteTrains")
AddEventHandler('DeleteTrains', function(Train)
	TrainList = {}
	print("Sending Delete")
	TriggerClientEvent("UpdateTrainList", -1, {}, true)
end)