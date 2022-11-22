Citizen.CreateThread(function() 
    while ESX == nil do 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)     
        Citizen.Wait(0) 
    end
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
    PlayerData = ESX.GetPlayerData()
    Almacenes()
end)

local lastStorage = nil

RegisterNetEvent("jav_inventoryhud:openStorageInventory")
AddEventHandler(
    "jav_inventoryhud:openStorageInventory",
    function(storage)
        lastStorage = storage

        ESX.TriggerServerCallback(
            "jav_inventoryhud:getStorageInventory",
            function(storageData)
                setStorageInventoryData(storageData)
                openStorageInventory()
            end,
            storage
        )
    end
)

function refreshStorageInventory()
    ESX.TriggerServerCallback(
        "jav_inventoryhud:getStorageInventory",
        function(storageData)
            setStorageInventoryData(storageData)
        end,
        lastStorage
    )
end

function setStorageInventoryData(data)
    items = {}

    local storageItems = data.inventory
    local storageWeapons = data.weapons

    for i = 1, #storageItems, 1 do
        local item = storageItems[i]

        if item.count > 0 then
            item.type = "item_standard"
            item.usable = false
            item.rare = false
            item.limit = -1
            item.canRemove = false

            table.insert(items, item)
        end
    end

    for i = 1, #storageWeapons, 1 do
        local weapon = storageWeapons[i]

        if storageWeapons[i].name ~= "WEAPON_UNARMED" then
            table.insert(
                items,
                {
                    label = ESX.GetWeaponLabel(weapon.name),
                    count = weapon.ammo,
                    limit = -1,
                    type = "item_weapon",
                    name = weapon.name,
                    usable = false,
                    rare = false,
                    canRemove = false
                }
            )
        end
    end

    SendNUIMessage(
        {
            action = "setSecondInventoryItems",
            itemList = items
        }
    )
end

function openStorageInventory()
    loadPlayerInventory()

    isInInventory = true

    local job_name = PlayerData.job.label

    SendNUIMessage(
        {
            action = "display",
            type = "storage",
            job = job_name
        }
    )

    SetNuiFocus(true, true)
end

RegisterNUICallback(
    "PutIntoStorage",
    function(data, cb)
        if IsPedSittingInAnyVehicle(playerPed) then
            return
        end

        if type(data.number) == "number" and math.floor(data.number) == data.number then
            local count = tonumber(data.number)

            if data.item.type == "item_weapon" then
                count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
            end

            TriggerServerEvent("jav_inventoryhud:putStorageItem", lastStorage, data.item.type, data.item.name, count)
        end

        Wait(150)
        refreshStorageInventory()
        Wait(150)
        loadPlayerInventory()

        cb("ok")
    end
)

RegisterNUICallback(
    "TakeFromStorage",
    function(data, cb)
        if IsPedSittingInAnyVehicle(playerPed) then
            return
        end

        if type(data.number) == "number" and math.floor(data.number) == data.number then
            TriggerServerEvent("jav_inventoryhud:getStorageItem", lastStorage, data.item.type, data.item.name, tonumber(data.number))
        end

        Wait(150)
        refreshStorageInventory()
        Wait(150)
        loadPlayerInventory()

        cb("ok")
    end
)

function Almacenes()
    CreateThread(function()
        while true do
            local time = 1000
            local job = PlayerData.job.name
            if PlayerData.job and job== Config.Job_Policia then
                for k in pairs(Config.Alamacenes_Pol) do
                    if GetDistanceBetweenCoords(Config.Alamacenes_Pol[k].x, Config.Alamacenes_Pol[k].y, Config.Alamacenes_Pol[k].z, GetEntityCoords(PlayerPedId(),true)) <= 2 then
                        DrawMarker(2, Config.Alamacenes_Pol[k].x, Config.Alamacenes_Pol[k].y, Config.Alamacenes_Pol[k].z, 0, 0, 0, 0, 0, 0, 0.300, 0.300, 0.300, 0,0,0,200, 0, 0, 0, 0)
                        time = 0
                        ESX.ShowHelpNotification('Presiona ~INPUT_CONTEXT~ para abrir el alamacen')
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent("jav_inventoryhud:openStorageInventory", "society_police")
                        end
                    end
                end
            end 
            Wait(time)
        end
    end)
    
    CreateThread(function()
        while true do
            local time = 1000
            local job = PlayerData.job.name
            if PlayerData.job and job== Config.Job_Ems then
                for k in pairs(Config.Alamacenes_Ems) do
                    if GetDistanceBetweenCoords(Config.Alamacenes_Ems[k].x, Config.Alamacenes_Ems[k].y, Config.Alamacenes_Ems[k].z, GetEntityCoords(PlayerPedId(),true)) <= 2 then
                        DrawMarker(2, Config.Alamacenes_Ems[k].x, Config.Alamacenes_Ems[k].y, Config.Alamacenes_Ems[k].z, 0, 0, 0, 0, 0, 0, 0.300, 0.300, 0.300, 0,0,0,200, 0, 0, 0, 0)
                        time = 0
                        ESX.ShowHelpNotification('Presiona ~INPUT_CONTEXT~ para abrir el alamacen')
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent("jav_inventoryhud:openStorageInventory", "society_ambulance")
                        end
                    end
                end
            end 
            Wait(time)
        end
    end)
    
    CreateThread(function()
        while true do
            local time = 1000
            local job = PlayerData.job.name
            if PlayerData.job and job== Config.Job_Mecanico then
                for k in pairs(Config.Alamacenes_Meca) do
                    if GetDistanceBetweenCoords(Config.Alamacenes_Meca[k].x, Config.Alamacenes_Meca[k].y, Config.Alamacenes_Meca[k].z, GetEntityCoords(PlayerPedId(),true)) <= 2 then
                        DrawMarker(2, Config.Alamacenes_Meca[k].x, Config.Alamacenes_Meca[k].y, Config.Alamacenes_Meca[k].z, 0, 0, 0, 0, 0, 0, 0.300, 0.300, 0.300, 0,0,0,200, 0, 0, 0, 0)
                        time = 0
                        ESX.ShowHelpNotification('Presiona ~INPUT_CONTEXT~ para abrir el alamacen')
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent("jav_inventoryhud:openStorageInventory", "society_mechanic")
                        end
                    end
                end
            end 
            Wait(time)
        end
    end)
end
