TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

isInInventory = false

local trunkData = nil

local fastWeapons = {
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil
}

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, Config.OpenControl) and IsInputDisabled(0) then
            openInventory()
        end

        if isInInventory then
            DisableAllControlActions(0)

            EnableControlAction(0, "INPUTGROUP_MOVE", true)
            EnableControlAction(0, 30, true)
            EnableControlAction(0, 31, true)
            EnableControlAction(0, 245, true)
        end

        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        BlockWeaponWheelThisFrame()
        DisableControlAction(0, 37, true)
    end
end)

function openInventory()
    loadPlayerInventory()
    isInInventory = true
    
    SendNUIMessage({
        action = "display",
        type = "normal"
    })
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
end

function loadInventorySecondary(data)
    SendNUIMessage({
        action = "setInfoText",
        text = data.text or 'Armario'
    })

    items = {}

    local propertyItems = data.items
    local propertyWeapons = data.weapons

    for i = 1, #propertyItems, 1 do
        local item = propertyItems[i]

        if item.count > 0 then
            item.type = "item_standard"
            item.usable = false
            item.rare = false
            item.limit = -1
            item.canRemove = false

            table.insert(items, item)
        end
    end

    for i = 1, #propertyWeapons, 1 do
        local weapon = propertyWeapons[i]
        if propertyWeapons[i].name ~= "WEAPON_UNARMED" then
            table.insert(items, {
                label = ESX.GetWeaponLabel(weapon.name),
                count = weapon.ammo,
                limit = -1,
                type = "item_weapon",
                name = weapon.name,
                usable = false,
                rare = false,
                canRemove = false
            })
        end
    end

    SendNUIMessage({
        action = "setSecondInventoryItems",
        itemList = items
    })
end

function openInventorySecondary()
    loadPlayerInventory()
    isInInventory = true

    SendNUIMessage(
        {
            action = "display",
            type = "property"
        }
    )

    SetNuiFocus(true, true)
end

exports('openInventorySecondary', openInventorySecondary)

function openTrunkInventory()
    loadPlayerInventory()
    isInInventory = true
    
    SendNUIMessage(
        {
            action = "display",
            type = "trunk"
        }
    )
    SetNuiFocus(true, true)
end

function closeInventory()
    isInInventory = false
    SendNUIMessage(
        {
            action = "hide"
        }
    )
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    ClearPedSecondaryTask(PlayerPedId())
end

local hotbar = false
local hotbarActive = false

function HotBar(used)
    if used ~= 0 then
        SendNUIMessage({
            action = "hotbarused",
            used = used,
        })
    end

    if not hotbar then
        local fastItems = {}
        local data = ESX.GetPlayerData()

        for i=1, 5 do

            if fastWeapons[i] ~= nil then
                local count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(fastWeapons[i]))

                if fastWeapons[i]:match("WEAPON_") or fastWeapons[i]:match("weapon_") then
                    for k,v in pairs(data.loadout) do
                        if v.name == fastWeapons[i] then
                            count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(fastWeapons[i]))
                        end
                    end
                else
                    for k,v in pairs(data.inventory) do
                        if v.name == fastWeapons[i] then
                            count = v.count
                        end
                    end
                end

                fastItems[i] = {name = fastWeapons[i], count = count}

            else
                fastItems[i] = nil
            end
        end
        SendNUIMessage({
            action = "hotbar",
            items = fastItems,
        })

    else

        SendNUIMessage({
            action = "hidehotbar",
        })

    end

    hotbar = not hotbar

    if used == 0 then
        if hotbar then
            hotbarActive = true
        else
            hotbarActive = false
        end
    end

end

RegisterCommand('hotbar', HotBar)

RegisterKeyMapping('hotbar', 'Abrir Hotbar', 'KEYBOARD', 'TAB')

RegisterNUICallback('NUIFocusOff', function()
    closeInventory()
end)

RegisterNUICallback('GetNearPlayers', function(data, cb)
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayers = false
    local elements = {}
    for i = 1, #players, 1 do
        if players[i] ~= PlayerId() then
            foundPlayers = true
            table.insert(elements, {
                label = GetPlayerName(players[i]),
                player = GetPlayerServerId(players[i])
            })
        end
    end
    if (not foundPlayers) then
        ESX.ShowNotification(_U("players_nearby"))
    else
        SendNUIMessage({
            action = 'nearPlayers',
            foundAny = foundPlayers,
            players = elements,
            item = data.item
        })
    end
    cb("ok")
end)

RegisterNUICallback('PutIntoTrunk', function(data, cb)
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end
    if ((type(data.number) == 'number') and (math.floor(data.number) == data.number)) then
        local count = tonumber(data.number)
        if (data.item.type == 'item_weapon') then
            count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
        end 
        TriggerServerEvent("esx_trunk:putItem", trunkData.plate, data.item.type, data.item.name, count, trunkData.max, trunkData.myVeh, data.item.label)
    end
    Wait(500)
    loadPlayerInventory()    
    cb("ok")
end)

RegisterNUICallback('TakeFromTrunk',function(data, cb)
    if (IsPedSittingInAnyVehicle(playerPed)) then
        return
    end
    if ((type(data.number) == 'number') and (math.floor(data.number) == data.number)) then
        TriggerServerEvent("esx_trunk:getItem", trunkData.plate, data.item.type, data.item.name, tonumber(data.number), trunkData.max, trunkData.myVeh)
    end
    loadPlayerInventory()
    cb("ok")
end)

RegisterNUICallback('UseItem', function(data, cb)
    if not isInInventory then
        return
    end
    TriggerServerEvent("esx:useItem", data.item.name)
    loadPlayerInventory()
    cb("ok")
end)

RegisterNUICallback("DropItem", function(data, cb)
    if not isInInventory then
        return
    end
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end
    if ((type(data.number) == 'number') and (math.floor(data.number) == data.number)) then
        TriggerServerEvent("esx:removeInventoryItem", data.item.type, data.item.name, data.number)
    end
    loadPlayerInventory()
    cb("ok")
end)

RegisterNUICallback('GiveItem', function(data, cb)
    if not isInInventory then
        return
    end
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayer = false
    for i = 1, #players, 1 do
        if (players[i] ~= PlayerId()) then
            if GetPlayerServerId(players[i]) == data.player then
                foundPlayer = true
            end
        end
    end
    if (foundPlayer) then
        local count = tonumber(data.number)
        if (data.item.type == 'item_weapon') then
            count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
        end
        TriggerServerEvent("esx:giveInventoryItem", data.player, data.item.type, data.item.name, count)
        loadPlayerInventory()
    else
        ESX.ShowNotification(_U("player_nearby"))
    end
    cb("ok")
end)

function shouldSkipAccount(accountName)
    for index, value in ipairs(Config.ExcludeAccountsList) do
        return (value == accountName)
    end
    return false
end

function getItemWeight(item)
    local weight = 0
    local itemWeight = 0
    if (item) then
        itemWeight = ESX.GetItemWeight(item)
    end
    return itemWeight
end

function getInventoryWeight(inventory)
    local weight = 0
    local itemWeight = 0
    if (inventory) then
        for i = 1, #inventory, 1 do
            if (inventory[i]) then
                itemWeight = ESX.GetItemWeight(inventory[i].name)
                weight = weight + (itemWeight * (inventory[i].count or 1))
            end
        end
    end
    return weight
end

function loadPlayerInventory()
    ESX.TriggerServerCallback("jav_inventoryhud:getPlayerInventory", function(data)
        local fastItems = {}
        items = {}
        inventory = data.inventory
        accounts = data.accounts
        money = data.money
        weapons = data.weapons
        weight = data.weight
        maxWeight = data.maxweight
        if (Config.IncludeAccounts and accounts) then
            for key, value in pairs(accounts) do
                if not shouldSkipAccount(accounts[key].name) then
                    local canDrop = accounts[key].name ~= "bank"
                    if accounts[key].money > 0 then
                        accountData = {
                            label = accounts[key].label,
                            count = accounts[key].money,
                            type = "item_account",
                            name = accounts[key].name,
                            usable = false,
                            rare = false,
                            limit = -1,
                            canRemove = canDrop
                        }
                        table.insert(items, accountData)
                    end
                end
            end
        end

        if (inventory) then
            for key, value in pairs(inventory) do
                if (inventory[key].count <= 0) then
                    inventory[key] = nil
                else
                    inventory[key].type = "item_standard"
                    table.insert(items, inventory[key])
                end
            end
        end
        
        if (Config.IncludeWeapons and weapons) then
            local totalFound = false
            for key, value in pairs(weapons) do
                local weaponHash = GetHashKey(weapons[key].name)
                local playerPed = PlayerPedId()
                if HasPedGotWeapon(playerPed, weaponHash, false) and weapons[key].name ~= "WEAPON_UNARMED" then
                    local found = false
                    for slot, weapon in pairs(fastWeapons) do
                        if (weapon == weapons[key].name) then
                            local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
                            table.insert(fastItems, {
                                label = weapons[key].label,
                                count = ammo,
                                limit = -1,
                                type = "item_weapon",
                                name = weapons[key].name,
                                usable = false,
                                rare = false,
                                canRemove = true,
                                slot = slot
                            })
                            found = true
                            totalFound = true
                            break
                        end
                    end
                    if (not found) then
                        local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
                        table.insert(items, {
                            label = weapons[key].label,
                            count = ammo,
                            limit = -1,
                            type = "item_weapon",
                            name = weapons[key].name,
                            usable = false,
                            rare = false,
                            canRemove = true
                        })
                    end
                end
            end
            for key, value in pairs(inventory) do
                local playerPed = PlayerPedId()
                local found = false
                for slot, weapon in pairs(fastWeapons) do
                    if weapon == inventory[key].name then
                        table.insert(fastItems, {
                            label = inventory[key].label,
                            count = inventory[key].count,
                            limit = -1,
                            type = "item_standard",
                            name = inventory[key].name,
                            usable = inventory[key].usable,
                            rare = false,
                            canRemove = true,
                            slot = slot
                        })
                        for k,v in pairs(items) do
                            if v.name == weapon then
                                table.remove(items, k)
                                break
                            end
                        end
                        found = true
                        break
                    end
                end
            end
        end

        ESX.TriggerServerCallback('jav_inventoryhud:Info', function(weight, pesoMax)
            SendNUIMessage({
                action = 'show:partearriba',
                peso = weight,
                pesoMax = pesoMax
            })
        end)

        SendNUIMessage({
            action = "setItems",
            itemList = items,
            fastItems = fastItems
        })
    end, GetPlayerServerId(PlayerId()))
end

RegisterNetEvent('jav_inventoryhud:openTrunkInventory', function(data, blackMoney, inventory, weapons)
    setTrunkInventoryData(data, blackMoney, inventory, weapons)
    openTrunkInventory()
end)

RegisterNetEvent("jav_inventoryhud:refreshTrunkInventory", function(data, blackMoney, inventory, weapons)
    if not isInInventory then
        return
    end
    setTrunkInventoryData(data, blackMoney, inventory, weapons)
end)

function setTrunkInventoryData(data, blackMoney, inventory, weapons)
    trunkData = data
    SendNUIMessage({
        action = "setInfoText",
        text = data.text
    })
    items = {}
    if (blackMoney > 0) then
        accountData = {
            label = _U("black_money"),
            count = blackMoney,
            type = "item_account",
            name = "black_money",
            usable = false,
            rare = false,
            limit = -1,
            canRemove = false
        }
        table.insert(items, accountData)
    end
    
    if (inventory) then
        for key, value in pairs(inventory) do
            if (inventory[key].count <= 0) then
                inventory[key] = nil
            else
                inventory[key].type = "item_standard"
                inventory[key].usable = false
                inventory[key].rare = false
                inventory[key].limit = -1
                inventory[key].canRemove = false
                table.insert(items, inventory[key])
            end
        end
    end
    
    if (Config.IncludeWeapons and weapons) then
        for key, value in pairs(weapons) do
            local weaponHash = GetHashKey(weapons[key].name)
            local playerPed = PlayerPedId()
            if (weapons[key].name ~= "WEAPON_UNARMED") then
                table.insert(items, {
                    label = weapons[key].label,
                    count = weapons[key].ammo,
                    limit = -1,
                    type = "item_weapon",
                    name = weapons[key].name,
                    usable = false,
                    rare = false,
                    canRemove = false
                })
            end
        end
    end
    
    SendNUIMessage({
        action = "setSecondInventoryItems",
        itemList = items
    })
end

function openTrunkInventory()
    loadPlayerInventory()
    isInInventory = true
    local playerPed = PlayerPedId()
    if not IsEntityPlayingAnim(playerPed, 'mini@repair', 'fixing_a_player', 3) then
        ESX.Streaming.RequestAnimDict('mini@repair', function()
            TaskPlayAnim(playerPed, 'mini@repair', 'fixing_a_player', 8.0, -8, -1, 49, 0, 0, 0, 0)
        end)
    end
    
    SendNUIMessage({
        action = "display",
        type = "trunk"
    })
    SetNuiFocus(true, true)
end


RegisterNUICallback(
    "PutIntoFast",
    function(data, cb)
        if data.item.slot ~= nil then
            fastWeapons[data.item.slot] = nil
        end
        fastWeapons[data.slot] = data.item.name
        loadPlayerInventory()
        cb("ok")
        SetTimeout(500, function()
            if hotbar then

                hotbar = false
                HotBar()

            end
        end)
    end
)
RegisterNUICallback(
    "TakeFromFast",
    function(data, cb)
        fastWeapons[data.item.slot] = nil
        loadPlayerInventory()
        cb("ok")
    end
)

local itemsDB = nil
local isPlayerNew = false;
RegisterNetEvent('esx:playerLoaded', function(xPlayer, isNew)
    Wait(750)
    ESX.TriggerServerCallback('jav_inventoryhud:getAllItems', function(items)
        itemsDB = items
    end)
    isPlayerNew = isNew
end)

RegisterNetEvent('jav_inventoryhud:receiveData', function()
    if not isPlayerNew then return end
    ESX.TriggerServerCallback('jav_inventoryhud:getAllItems', function(items)
        itemsDB = items
    end)
end)

AddEventHandler('onResourceStart', function()
    Wait(750)
    ESX.TriggerServerCallback('jav_inventoryhud:getAllItems', function(items)
        itemsDB = items
    end)
end)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)

            if IsDisabledControlJustReleased(1, 157) then
                if fastWeapons[1] ~= nil then

                    local typeItem = nil
                    local data = ESX.GetPlayerData()
                    local weaponList = ESX.GetWeaponList()

                    for k,v in pairs(itemsDB) do

                        if fastWeapons[1]:lower() == v.name:lower() then
                            typeItem = 'item_standard'
                            break
                        end

                    end

                    if not typeItem then
                        for k,v in pairs(weaponList) do

                            if fastWeapons[1]:lower() == v.name:lower() then
                                typeItem = 'item_weapon'
                                break
                            end
    
                        end
                    end

                    if typeItem == 'item_weapon' then
                        if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey(fastWeapons[1]) then
                            SetCurrentPedWeapon(PlayerPedId(), "WEAPON_UNARMED", true)
                        else
                            if hotbar then
                                hotbar = false
                            end

                            HotBar(1)
    
                            SetTimeout(2000, function()

                                if not hotbarActive then
                                    hotbar = true
        
                                    HotBar()
                                end
                            end)
                            SetCurrentPedWeapon(PlayerPedId(), fastWeapons[1], true)
                        end
                    else
                        local count = 0

                        for k,v in pairs(data.inventory) do
                            if v.name:lower() == fastWeapons[1]:lower() then
                                count = v.count
                                break
                            end
                        end

                        if count > 0 then
                            if hotbar then
                                hotbar = false
                            end
                            
                            HotBar(1)
    
                            SetTimeout(2000, function()
                                if not hotbarActive then
                                    hotbar = true
        
                                    HotBar()
                                end
                            end)
                            TriggerServerEvent('esx:useItem', fastWeapons[1])
                        end
                    end
                end
            end
            if IsDisabledControlJustReleased(1, 158) then
                if fastWeapons[2] ~= nil then
                    local typeItem = nil
                    local data = ESX.GetPlayerData()
                    local weaponList = ESX.GetWeaponList()

                    for k,v in pairs(itemsDB) do

                        if fastWeapons[2]:lower() == v.name:lower() then
                            typeItem = 'item_standard'
                            break
                        end

                    end

                    if not typeItem then
                        for k,v in pairs(weaponList) do

                            if fastWeapons[2]:lower() == v.name:lower() then
                                typeItem = 'item_weapon'
                                break
                            end
    
                        end
                    end

                    if typeItem == 'item_weapon' then
                        if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey(fastWeapons[2]) then
                            SetCurrentPedWeapon(PlayerPedId(), "WEAPON_UNARMED", true)
                        else
                            if hotbar then
                                hotbar = false
                            end

                            HotBar(2)
    
                            SetTimeout(2000, function()
                                if not hotbarActive then
                                    hotbar = true
        
                                    HotBar()
                                end
                            end)
                            SetCurrentPedWeapon(PlayerPedId(), fastWeapons[2], true)
                        end
                    else
                        local count = 0

                        for k,v in pairs(data.inventory) do
                            if v.name:lower() == fastWeapons[2]:lower() then
                                count = v.count
                                break
                            end
                        end

                        if count > 0 then
                            if hotbar then
                                hotbar = false
                            end

                            HotBar(2)
    
                            SetTimeout(2000, function()
                                if not hotbarActive then
                                    hotbar = true
        
                                    HotBar()
                                end
                            end)
                            TriggerServerEvent('esx:useItem', fastWeapons[2])
                        end
                    end
                end
            end
            if IsDisabledControlJustReleased(1, 160) then
                if fastWeapons[3] ~= nil then
                    local typeItem = nil
                    local data = ESX.GetPlayerData()
                    local weaponList = ESX.GetWeaponList()

                    for k,v in pairs(itemsDB) do

                        if fastWeapons[3]:lower() == v.name:lower() then
                            typeItem = 'item_standard'
                            break
                        end

                    end

                    if not typeItem then
                        for k,v in pairs(weaponList) do

                            if fastWeapons[3]:lower() == v.name:lower() then
                                typeItem = 'item_weapon'
                                break
                            end
    
                        end
                    end

                    if typeItem == 'item_weapon' then
                        if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey(fastWeapons[3]) then
                            SetCurrentPedWeapon(PlayerPedId(), "WEAPON_UNARMED", true)
                        else
                            if hotbar then
                                hotbar = false
                            end

                            HotBar(3)
    
                            SetTimeout(2000, function()
                                if not hotbarActive then
                                    hotbar = true
        
                                    HotBar()
                                end
                            end)
                            SetCurrentPedWeapon(PlayerPedId(), fastWeapons[3], true)
                        end
                    else
                        local count = 0

                        for k,v in pairs(data.inventory) do
                            if v.name:lower() == fastWeapons[3]:lower() then
                                count = v.count
                                break
                            end
                        end

                        if count > 0 then
                            if hotbar then
                                hotbar = false
                            end

                            HotBar(3)
    
                            SetTimeout(2000, function()
                                if not hotbarActive then
                                    hotbar = true
        
                                    HotBar()
                                end
                            end)
                            TriggerServerEvent('esx:useItem', fastWeapons[3])
                        end
                    end
                end
            end
            if IsDisabledControlJustReleased(1, 164) then
                if fastWeapons[4] ~= nil then
                    local typeItem = nil
                    local data = ESX.GetPlayerData()
                    local weaponList = ESX.GetWeaponList()

                    for k,v in pairs(itemsDB) do

                        if fastWeapons[4]:lower() == v.name:lower() then
                            typeItem = 'item_standard'
                            break
                        end

                    end

                    if not typeItem then
                        for k,v in pairs(weaponList) do

                            if fastWeapons[4]:lower() == v.name:lower() then
                                typeItem = 'item_weapon'
                                break
                            end
    
                        end
                    end

                    if typeItem == 'item_weapon' then
                        if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey(fastWeapons[4]) then
                            SetCurrentPedWeapon(PlayerPedId(), "WEAPON_UNARMED", true)
                        else
                            if hotbar then
                                hotbar = false
                            end

                            HotBar(4)
    
                            SetTimeout(2000, function()
                                if not hotbarActive then
                                    hotbar = true
        
                                    HotBar()
                                end
                            end)
                            SetCurrentPedWeapon(PlayerPedId(), fastWeapons[4], true)
                        end
                    else
                        local count = 0

                        for k,v in pairs(data.inventory) do
                            if v.name:lower() == fastWeapons[4]:lower() then
                                count = v.count
                                break
                            end
                        end

                        if count > 0 then
                            if hotbar then
                                hotbar = false
                            end

                            HotBar(4)
    
                            SetTimeout(2000, function()
                                if not hotbarActive then
                                    hotbar = true
        
                                    HotBar()
                                end
                            end)
                            TriggerServerEvent('esx:useItem', fastWeapons[4])
                        end
                    end
                end
            end
            if IsDisabledControlJustReleased(1, 165) then
                if fastWeapons[5] ~= nil then
                    local typeItem = nil
                    local data = ESX.GetPlayerData()
                    local weaponList = ESX.GetWeaponList()

                    for k,v in pairs(itemsDB) do

                        if fastWeapons[5]:lower() == v.name:lower() then
                            typeItem = 'item_standard'
                            break
                        end

                    end

                    if not typeItem then
                        for k,v in pairs(weaponList) do

                            if fastWeapons[5]:lower() == v.name:lower() then
                                typeItem = 'item_weapon'
                                break
                            end
    
                        end
                    end

                    if typeItem == 'item_weapon' then
                        if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey(fastWeapons[5]) then
                            SetCurrentPedWeapon(PlayerPedId(), "WEAPON_UNARMED", true)
                        else
                            if hotbar then
                                hotbar = false
                            end

                            HotBar(5)
    
                            SetTimeout(2000, function()
                                if not hotbarActive then
                                    hotbar = true
        
                                    HotBar()
                                end
                            end)
                            SetCurrentPedWeapon(PlayerPedId(), fastWeapons[5], true)
                        end
                    else
                        local count = 0

                        for k,v in pairs(data.inventory) do
                            if v.name:lower() == fastWeapons[5]:lower() then
                                count = v.count
                                break
                            end
                        end

                        if count > 0 then
                            if hotbar then
                                hotbar = false
                            end

                            HotBar(5)
    
                            SetTimeout(2000, function()
                                if not hotbarActive then
                                    hotbar = true
        
                                    HotBar()
                                end
                            end)
                            TriggerServerEvent('esx:useItem', fastWeapons[5])
                                end
                            end
                        end
                    end
                end
        end
)
--Add Items--
RegisterNetEvent('jav_inventoryhud:client:addItem')
AddEventHandler('jav_inventoryhud:client:addItem', function(itemname, itemlabel)
    local data = {name = itemname, label = itemlabel}
    SendNUIMessage({type = "addInventoryItem", addItemData = data})
end)

local authorizedEvents = {'qb-radialmenu:ToggleProps', 'qb-radialmenu:ToggleClothing'}

function isAuthorized(event)
    for k,v in pairs(authorizedEvents) do
        if v == event then
            return true
        end
    end
    return false
end

-- Clothing Menu

RegisterNUICallback('inventory_options', function(data)
    local isAuthorized = isAuthorized(data.event)
    if isAuthorized then
        data.action = data.action or ''
        TriggerEvent(data.event, data.action)
    else
        print('Ha ocurrido un error')
    end
end)