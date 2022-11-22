itemsDB = nil

TriggerEvent("esx:getSharedObject",
    function(obj)
        ESX = obj
    end
)

ESX.RegisterServerCallback("jav_inventoryhud:getPlayerInventory",function(source, cb, target)
        local targetXPlayer = ESX.GetPlayerFromId(target)
        
        if (targetXPlayer) then
            cb({inventory = targetXPlayer.inventory, money = targetXPlayer.getMoney(), accounts = targetXPlayer.accounts, weapons = targetXPlayer.loadout, weight = targetXPlayer.getWeight(), maxweight = targetXPlayer.getMaxWeight()})
        else
            cb(nil)
        end
end)
RegisterServerEvent("jav_inventoryhud:tradePlayerItem")
AddEventHandler("jav_inventoryhud:tradePlayerItem", function(from, target, type, itemName, itemCount)
    local _source = from
    
    local sourceXPlayer = ESX.GetPlayerFromId(_source)
    local targetXPlayer = ESX.GetPlayerFromId(target)
    
    if type == "item_standard" then
        local sourceItem = sourceXPlayer.getInventoryItem(itemName)
        local targetItem = targetXPlayer.getInventoryItem(itemName)
        
        if itemCount > 0 and sourceItem.count >= itemCount then
            if targetItem.limit == -1 or not targetXPlayer.canCarryItem(itemName, itemCount) then
                xPlayer.showNotification("Espacio insuficiente!")
            else
                sourceXPlayer.removeInventoryItem(itemName, itemCount)
                targetXPlayer.addInventoryItem(itemName, itemCount)
            end
        end
    elseif type == "item_money" then
        if itemCount > 0 and sourceXPlayer.getMoney() >= itemCount then
            sourceXPlayer.removeMoney(itemCount)
            targetXPlayer.addMoney(itemCount)
        end
    elseif type == "item_account" then
        if itemCount > 0 and sourceXPlayer.getAccount(itemName).money >= itemCount then
            sourceXPlayer.removeAccountMoney(itemName, itemCount)
            targetXPlayer.addAccountMoney(itemName, itemCount)
        end
    elseif type == "item_weapon" then
        if not targetXPlayer.hasWeapon(itemName) then
            sourceXPlayer.removeWeapon(itemName, itemCount)
            targetXPlayer.addWeapon(itemName, itemCount)
        end
    end
end
)
RegisterCommand("openinventory", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "inventory.openinventory") then
        local target = tonumber(args[1])
        local targetXPlayer = ESX.GetPlayerFromId(target)
        
        if targetXPlayer ~= nil then
            TriggerClientEvent("jav_inventoryhud:openPlayerInventory", source, target, targetXPlayer.name)
        else
            xPlayer.showNotification(_U("no_player"))
            TriggerClientEvent("chatMessage", source, "^1" .. _U("no_player"))
        end
    else
        xPlayer.showNotification(_U("no_permissions"))
        TriggerClientEvent("chatMessage", source, "^1" .. _U("no_permissions"))
    end
end
)
AddEventHandler('esx:playerLoaded', function(source)
    GetLicenses(source)
end)

function GetLicenses(source)
    TriggerEvent('esx_license:getLicenses', source, function(licenses)
            
            TriggerClientEvent('jav_inventoryhud:GetLicenses', source, licenses)
    end)


end

CreateThread(function()

    Wait(500)

    MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
        itemsDB = result
    end)

end)

ESX.RegisterServerCallback('jav_inventoryhud:getAllItems', function(source, cb)
    cb(itemsDB)
end)

ESX.RegisterServerCallback('jav_inventoryhud:Info', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local weight = xPlayer.getWeight()
    local pesoMax = xPlayer.getMaxWeight()
    cb(weight , pesoMax)
end)

RegisterServerEvent('javi_inventoryhud:cachear')
AddEventHandler('javi_inventoryhud:cachear', function(targetId)
    TriggerClientEvent('javi_inventoryhud:cachear', source, targetId, GetPlayerPed(targetId))
end)