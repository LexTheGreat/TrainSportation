DebugLog('TrainSportation:Server')
RegisterNetEvent('Train:opendoor')
AddEventHandler('Train:opendoor', function(direction,train,carrige, serverid )
    
    -- direction true left side, false right side
    DebugLog(train.. 'Train:opendoor' .. carrige)
    if direction then
        --                  
        -- trigger all player clients
        TriggerClientEvent('Train:opendoor', -1, direction,train,carrige, serverid)
    else
        TriggerClientEvent('Train:opendoor', -1, direction,train,carrige, serverid)
    end
end)

RegisterNetEvent('Train:closeDoor')
AddEventHandler('Train:closeDoor', function(direction,train,carrige, serverid )
    DebugLog ('Train:closeDoor')
   
    if direction then
        --                  
        TriggerClientEvent('Train:closeDoor', -1, direction,train,carrige, serverid)
    else
        TriggerClientEvent('Train:closeDoor', -1, direction,train,carrige, serverid)
    end
end)