ESX.RegisterServerCallback(
    "jav_inventoryhud:getStorageInventory",
    function(source, cb, storage)
        local targetXPlayer = ESX.GetPlayerFromId(target)
        local weapons, items, blackMoney

        TriggerEvent("esx_datastore:getSharedDataStore", storage,function(store)
                weapons = store.get("weapons")

                if weapons == nil then
                    weapons = {}
                end

                TriggerEvent(
                    "esx_addoninventory:getSharedInventory",
                    storage,
                    function(inventory)
                        items = inventory.items

                        if items == nil then
                            items = {}
                        end

                        TriggerEvent(
                            "esx_addonaccount:getSharedAccount",
                            storage .. "_blackMoney",
                            function(account)
                                if account ~= nil then
                                    blackMoney = account.money
                                else
                                    blackMoney = 0
                                end

                                cb({inventory = items, blackMoney = blackMoney, weapons = weapons})
                            end
                        )
                    end
                )
            end
        )
    end
)

RegisterServerEvent("jav_inventoryhud:getStorageItem")
AddEventHandler(
    "jav_inventoryhud:getStorageItem",
    function(storage, type, item, count)
        local xPlayer = ESX.GetPlayerFromId(source)

        if type == "item_standard" then
            local sourceItem = xPlayer.getInventoryItem(item)

            TriggerEvent("esx_addoninventory:getSharedInventory",storage,function(inventory)
                    local inventoryItem = inventory.getItem(item)

                    if count > 0 and inventoryItem.count >= count then
                        if xPlayer.canCarryItem(item, count) then
                            inventory.removeItem(item, count)
                            xPlayer.addInventoryItem(item, count)
                            xPlayer.showNotification('Has sacado ' ..count.. 'x  de ~g~'..inventoryItem.label)
                        else
                            
                            xPlayer.showNotification('No tienes sufienciente espacio en tu inventario')
                        end
                    else
                        xPlayer.showNotification('Cantidad invalida')
                    end
            end)

        elseif type == "item_weapon" then
            TriggerEvent("esx_datastore:getSharedDataStore",storage,function(store)
                    local storeWeapons = store.get("weapons") or {}
                    local weaponName = nil
                    local ammo = nil
                    local components = {}

                    for i = 1, #storeWeapons, 1 do
                        if storeWeapons[i].name == item then
                            weaponName = storeWeapons[i].name
                            ammo = storeWeapons[i].ammo

                            if storeWeapons[i].components ~= nil then
                                components = storeWeapons[i].components
                            end

                            table.remove(storeWeapons, i)
                            break

                            print(storeWeapons[i].name)
                        end
                    end

                    store.set("weapons", storeWeapons)
                    xPlayer.addWeapon(weaponName, ammo)
                    xPlayer.showNotification('Sacaste el arma con ' ..ammo..' balas')

                    for i = 1, #components do
                        xPlayer.addWeaponComponent(weaponName, components[i])
                    end
            end)
        end
    end
)

RegisterServerEvent("jav_inventoryhud:putStorageItem")
AddEventHandler("jav_inventoryhud:putStorageItem",function(storage, type, item, count)
        local xPlayer = ESX.GetPlayerFromId(source)

        if type == "item_standard" then
            local playerItemCount = xPlayer.getInventoryItem(item).count

            if playerItemCount >= count and count > 0 then
                TriggerEvent(
                    "esx_addoninventory:getSharedInventory",
                    storage,
                    function(inventory)
                        xPlayer.removeInventoryItem(item, count)
                        inventory.addItem(item, count)

                        local inventoryItem = inventory.getItem(item)

                        xPlayer.showNotification('Guardaste ' ..count..'x de ~g~'..item)
                    end
                )
            else
                xPlayer.showNotification('Cantidad invalida')
            end
        elseif type == "item_weapon" then
            TriggerEvent("esx_datastore:getSharedDataStore",storage,function(store)
                    local storeWeapons = store.get("weapons") or {}

                    local pos, playerWeapon = xPlayer.getWeapon(item)
                    
                    local components = playerWeapon.components

                    if components == nil then
                        components = {}
                    end

                    table.insert(
                        storeWeapons,
                        {
                            name = item,
                            ammo = count,
                            components = components
                        }
                    )

                    store.set("weapons", storeWeapons)
                    xPlayer.removeWeapon(item)
                    xPlayer.showNotification('Guardaste el arma')
            end)
        end
end)
