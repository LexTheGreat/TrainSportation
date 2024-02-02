print('TrainSportation:Server')
RegisterNetEvent('Train:opendoor')
AddEventHandler('Train:opendoor', function(direction,train,carrige, serverid )
    -- direction true左边，false右边
    print(train.. 'Train:opendoor' .. carrige)
    if direction then
        --触发所有玩家客户端
        TriggerClientEvent('Train:opendoor', -1, direction,train,carrige, serverid)
    else
        TriggerClientEvent('Train:opendoor', -1, direction,train,carrige, serverid)
    end
end)

RegisterNetEvent('Train:closeDoor')
AddEventHandler('Train:closeDoor', function(direction,train,carrige, serverid )
    print ('Train:closeDoor')
    -- direction true左边，false右边
    if direction then
        --触发所有玩家客户端
        TriggerClientEvent('Train:closeDoor', -1, direction,train,carrige, serverid)
    else
        TriggerClientEvent('Train:closeDoor', -1, direction,train,carrige, serverid)
    end
end)