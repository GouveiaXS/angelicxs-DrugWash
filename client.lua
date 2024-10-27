ESX = nil
QBcore = nil
PlayerGang = nil
PlayerRank = nil
PlayerJob = nil

local SalePed = nil
local washspot = nil
local washPed = nil
local isLEO = false
local GuardSpawner = {}
local savePed = false
local MissionRoute = nil
local garbage, Relationships = nil, nil
local savingpedmission = false

RegisterNetEvent('angelicxs-DrugWash:Notify', function(message, type)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-DrugWash:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
end)

CreateThread(function()
    garbage, Relationships = AddRelationshipGroup(GetHashKey('guardwash'))
    SetRelationshipBetweenGroups(0, Relationships, Relationships)

    if Config.UseESX then
        ESX = exports["es_extended"]:getSharedObject()
	    while not ESX.IsPlayerLoaded() do
            Wait(100)
        end
    
        CreateThread(function()
            while true do
                local playerData = ESX.GetPlayerData()
                if playerData.job.name ~= nil then
                    PlayerJob = playerData.job.name
                    PlayerGang = playerData.job.name
                    PlayerRank = playerData.job.rank
                    isLEO = LawEnforcement()
                end
                Wait(100)
            end
        end)

        RegisterNetEvent('esx:setJob', function(job)
            PlayerJob = job.name
            PlayerGang = job.name
            PlayerRank = job.rank
            isLEO = LawEnforcement()
        end)

        ESX.TriggerServerCallback('angelicxs-DrugWash:server:getWasher', function(cb)
            washspot = cb
        end)   

    elseif Config.UseQBCore then
        QBCore = exports['qb-core']:GetCoreObject()
        
        CreateThread(function ()
			while true do
                local playerData = QBCore.Functions.GetPlayerData()
				if playerData.citizenid ~= nil then
                    PlayerJob = playerData.job.name
					PlayerGang = playerData.gang.name
                    PlayerRank = playerData.gang.grade.level
                    if PlayerGang == 'none' then
                        PlayerRank = playerData.job.grade.level
                    end
                    isLEO = LawEnforcement()
				end
				Wait(100)
			end
		end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            local playerData = QBCore.Functions.GetPlayerData()
            PlayerJob = job.name
            PlayerGang = playerData.gang.name
            PlayerRank = playerData.gang.grade.level
            if PlayerGang == 'none' then
                PlayerRank = job.grade.level
            end
            isLEO = LawEnforcement()
        end)
        RegisterNetEvent('QBCore:Client:OnGangUpdate', function(InfoGang)
            PlayerGang = InfoGang.name
            PlayerRank = InfoGang.grade.level
	end)

        QBCore.Functions.TriggerCallback('angelicxs-DrugWash:server:getWasher', function(cb)
            washspot = cb
        end)
    end
end)

CreateThread(function()
    for gang, data in pairs (Config.DrugSales) do 
        for slot, info in pairs (data['MassSellers']) do
            CreateThread(function()
                if data['BlipSprite'] then
                    SetBlip(info.location, data)
                end
                local PedSpawned = false
                while true do
                    local Pos = GetEntityCoords(PlayerPedId())
                    local Dist = #(Pos - vector3(info.location.x, info.location.y, info.location.z))
                    if Dist <= 50 and not PedSpawned then
                        TriggerEvent('angelicxs-DrugWash:PedSpawner', info, gang, data['DrugInfo'])
                        PedSpawned = true
                    elseif DoesEntityExist(SalePed) and PedSpawned then
                        local Dist2 = #(Pos - GetEntityCoords(SalePed))
                        if Dist2 > 50 then
                            SetEntityAsNoLongerNeeded(SalePed)
                            PedSpawned = false
                            if Config.UseThirdEye then
                                if Config.ThirdEyeName == 'ox_target' then
                                    exports.ox_target:removeZone('DrugWashSalePed'..tostring(info.location))
                                else
                                    exports[Config.ThirdEyeName]:RemoveZone('DrugWashSalePed'..tostring(info.location))
                                end
                            end
                        end
                    end
                    Wait(2000)
                end
            end)
        end
    end
    if Config.UseMoneyWash then
        while not washspot do Wait(100) end
        CreateThread(function()
            local PedSpawned = false
            while true do
                local Pos = GetEntityCoords(PlayerPedId())
                local Dist = #(Pos - vector3(washspot.x, washspot.y, washspot.z))
                if Dist <= 50 and not PedSpawned then
                    TriggerEvent('angelicxs-DrugWash:WashPedSpawner')
                    PedSpawned = true
                elseif DoesEntityExist(washPed) and PedSpawned then
                    local Dist2 = #(Pos - GetEntityCoords(washPed))
                    if Dist2 > 50 then
                        SetEntityAsNoLongerNeeded(washPed)
                        PedSpawned = false
                        if Config.UseThirdEye then
                            if Config.ThirdEyeName == 'ox_target' then
                                exports.ox_target:removeZone('DrugWashwashPed')
                            else
                                exports[Config.ThirdEyeName]:RemoveZone('DrugWashwashPed')
                            end
                        end
                    end
                end
                Wait(2000)
            end
        end)
    end
end)

RegisterNetEvent('angelicxs-DrugWash:PedSpawner',function(info, gang, druginfo)
    local hash = HashGrabber(info.model)
    SalePed = CreatePed(3, hash, info.location.x, info.location.y, (info.location.z-1) , info.location.w, false, false)
    FreezeEntityPosition(SalePed, true)
    SetEntityInvincible(SalePed, true)
    SetBlockingOfNonTemporaryEvents(SalePed, true)
    TaskStartScenarioInPlace(SalePed, 'WORLD_HUMAN_STAND_IMPATIENT', 0, false)
    SetModelAsNoLongerNeeded(info.model)
    if Config.UseThirdEye then
        if Config.ThirdEyeName == 'ox_target' then
            local options = {
                {
                    name = 'DrugWashSalePed'..tostring(info.location),
                    label = Config.Lang['request_sale'],
                    onSelect = function()
                        TriggerEvent('angelicxs-DrugWash:CategoryMenu', info, druginfo)
                    end,
                    canInteract = function(entity)
                        if not Config.AllowPoliceInteract and isLEO then return false end
                        if (gang == 'none' or PlayerGang == gang) and PlayerRank >= info.minRank then return true 
                        else return false end
                    end,
                },
            }
            exports.ox_target:addLocalEntity(SalePed, options)
        else
            exports[Config.ThirdEyeName]:AddEntityZone('DrugWashSalePed'..tostring(info.location), SalePed, {
                name="DrugWashSalePed"..tostring(info.location),
                debugPoly=false,
                useZ = true
                }, {
                options = {
                    {
                    label = Config.Lang['request_sale'],
                    action = function()
                        TriggerEvent('angelicxs-DrugWash:CategoryMenu', info, druginfo)
                    end,
                    canInteract = function(entity)
                        if not Config.AllowPoliceInteract and isLEO then return false end
                        if (gang == 'none' or PlayerGang == gang) and PlayerRank >= info.minRank then return true 
                        else return false end
                    end,
                    },                    
                },
                distance = 2
            })        
        end
    end
    while DoesEntityExist(SalePed) and Config.Use3DText do
        local sleep = 2000
        local Dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(SalePed))
        if Config.AllowPoliceInteract or (not Config.AllowPoliceInteract and not isLEO) then
            if Dist <= 50 and (gang == 'none' or PlayerGang == gang) and PlayerRank >= info.minRank then 
                sleep = 1000
                if Dist <= 25 then 
                    sleep = 500
                    if Dist <= 15 then 
                        sleep = 0
                        if Dist <= 5 then 
                            DrawText3Ds(info.location.x, info.location.y, info.location.z, Config.Lang['request_sale_3d'])
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent('angelicxs-DrugWash:CategoryMenu', info, druginfo)
                            end
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('angelicxs-DrugWash:WashPedSpawner',function()
    local hash = HashGrabber(Config.MoneyWashStart.model)
    washPed = CreatePed(3, hash, washspot.x, washspot.y, (washspot.z-1) , washspot.w, false, false)
    FreezeEntityPosition(washPed, true)
    SetEntityInvincible(washPed, true)
    SetBlockingOfNonTemporaryEvents(washPed, true)
    TaskStartScenarioInPlace(washPed, 'WORLD_HUMAN_STAND_IMPATIENT', 0, false)
    SetModelAsNoLongerNeeded(Config.MoneyWashStart.model)
    if Config.UseThirdEye then
        if Config.ThirdEyeName == 'ox_target' then
            local options = {
                {
                    name = 'DrugWashwashPed',
                    label = Config.Lang['request_wash'],
                    onSelect = function()
                        TriggerEvent('angelicxs-DrugWash:StartMission')
                    end,
                    canInteract = function(entity)
                        if not Config.AllowPoliceInteract and isLEO then return false else return true end
                    end,
                },
            }
            exports.ox_target:addLocalEntity(washPed, options)
        else
            exports[Config.ThirdEyeName]:AddEntityZone('DrugWashwashPed', washPed, {
                name="DrugWashwashPed",
                debugPoly=false,
                useZ = true
                }, {
                options = {
                    {
                    label = Config.Lang['request_wash'],
                    action = function()
                        TriggerEvent('angelicxs-DrugWash:StartMission')
                    end,
                    canInteract = function(entity)
                        if not Config.AllowPoliceInteract and isLEO then return false else return true end
                    end,
                    },                    
                },
                distance = 2
            })        
        end
    end
    while DoesEntityExist(SalePed) and Config.Use3DText do
        local sleep = 2000
        local Dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(SalePed))
        if Config.AllowPoliceInteract or (not Config.AllowPoliceInteract and not isLEO) then
            if Dist <= 50 then 
                sleep = 1000
                if Dist <= 25 then 
                    sleep = 500
                    if Dist <= 15 then 
                        sleep = 0
                        if Dist <= 5 then 
                            DrawText3Ds(Data2.x, Data2.y, Data2.z, Config.Lang['request_wash_3d'])
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent('angelicxs-DrugWash:StartMission')
                            end
                        end
                    end
                end
            end
        end
    end
end)


RegisterNetEvent('angelicxs-DrugWash:CategoryMenu', function(info, options)
    TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['lookup_items'], Config.LangType['info'])
    local drugMenu = {}
    if Config.NHMenu then
        table.insert(drugMenu, {
            header = Config.Lang['drugMenu_header'],
        })
    elseif Config.QBMenu then
        table.insert(drugMenu, {
            header = Config.Lang['drugMenu_header'],
            isMenuHeader = true
        })
    end
    for drug, data in pairs(options) do
        data.pay = info.payoutMultiplier
        local hasItem = false
        if Config.UseESX then
            hasItem = ESX.SearchInventory(data.drugName, 1)
        elseif Config.UseQBCore then
            hasItem = QBCore.Functions.HasItem(data.drugName)
        end
        Wait(150)
        if hasItem then 
            if Config.NHMenu then
                table.insert(drugMenu, {
                    context = data.drugLabel,
                    event = 'angelicxs-DrugWash:SaleMenu',
                    args = {data}
                })
            elseif Config.QBMenu then
                table.insert(drugMenu, {
                    header = data.drugLabel,
                        params = {
                            event = 'angelicxs-DrugWash:SaleMenu',
                            args = data
                        }
                    })
            elseif Config.OXLib then
                table.insert(drugMenu, {
                    title = data.drugLabel,
                    onSelect = function()
                        TriggerEvent('angelicxs-DrugWash:SaleMenu', data)
                    end,
                })
            end
        end
    end
    if Config.NHMenu then
        table.insert(drugMenu, {
            context = Config.Lang['cancel'],
            event = '',
        })
        TriggerEvent("nh-context:createMenu", drugMenu)
    elseif Config.QBMenu then
        table.insert(drugMenu, {
        header = Config.Lang['cancel'],
            params = {event = ''}
        })
        TriggerEvent("qb-menu:client:openMenu", drugMenu)
    elseif Config.OXLib then
        lib.registerContext({
            id = 'DrugWashCategorymenu_ox',
            title = Config.Lang['menu_header'],
            options = drugMenu,
            position = 'top-right',
        }, function(selected, scrollIndex, args)
        end)
        lib.showContext('DrugWashCategorymenu_ox')
    end
end)

RegisterNetEvent('angelicxs-DrugWash:SaleMenu', function(data)
    local saleinfo = nil
    if Config.NHInput then
        local keyboard, a = exports["nh-keyboard"]:Keyboard({
            header = Config.Lang['drugSale_header']..' '..data.drugLabel,
            rows = {Config.Lang['drugSale_num']} 
        })
        if keyboard then
            if tonumber(a) >= 0 then
                saleinfo = tonumber(a)
            else
                TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['zero_error'], Config.LangType['error'])
            end
        end
    elseif Config.QBInput then
        local info = exports['qb-input']:ShowInput({
            header = Config.Lang['drugSale_header']..' '..data.drugLabel,
            submitText = Config.Lang['drugSale_sell'], 
            inputs = {
                {
                    type = 'number',
                    isRequired = true,
                    name = 'num',
                    text = Config.Lang['drugSale_num'],
                },
            }
        })    
        if info then
            if tonumber(info.num) >= 0 then
                saleinfo = tonumber(info.num)
            else
                TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['zero_error'], Config.LangType['error'])
            end
        end
    elseif Config.OXLib then
        local input = lib.inputDialog(Config.Lang['drugSale_header']..' '..data.drugLabel, {Config.Lang['drugSale_num']})
        if not input then return end
        saleinfo = tonumber(input[1])
    end
    if saleinfo <= 0 then return end
    TriggerServerEvent('angelicxs-DrugWash:SellDrug', saleinfo, data)
end)

RegisterNetEvent('angelicxs-DrugWash:StartMission', function()
    if savingpedmission then TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['on_mission'], Config.LangType['error']) return end
    savingpedmission = true
    local mission = Randomizer(Config.DrugWash)
    local active = true
    TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['save_ped'], Config.LangType['info'])
    MissionRoute = AddBlipForCoord(mission.pedLocation.x, mission.pedLocation.y, mission.pedLocation.z)
    SetBlipColour(MissionRoute, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Lang['rescue_me'])
    EndTextCommandSetBlipName(MissionRoute)
    SetBlipRoute(MissionRoute, true)
    SetBlipRouteColour(MissionRoute, 43)
    while true do
        local sleep = 1100
        local coord = GetEntityCoords(PlayerPedId())
        local safeCoord = vector3(mission.pedLocation.x, mission.pedLocation.y, mission.pedLocation.z)
        local dist = #(coord-safeCoord)
        if dist <= 150 then
            RemoveBlip(MissionRoute)
            break
        end
        Wait(sleep)            
    end
    TriggerEvent('angelicxs-DrugWash:CustomPoliceAlert', vector3(mission.pedLocation.x, mission.pedLocation.y, mission.pedLocation.z))
    TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['in_area'], Config.LangType['info'])
    GuardSpawner(mission)
    local hash = HashGrabber(Config.MoneyWashStart.savePed)
    savePed = CreatePed(3, hash, mission.pedLocation.x, mission.pedLocation.y, (mission.pedLocation.z-1) , mission.pedLocation.w, false, false)
    FreezeEntityPosition(savePed, true)
    SetEntityInvincible(savePed, true)
    SetBlockingOfNonTemporaryEvents(savePed, true)
    TaskStartScenarioInPlace(savePed, 'WORLD_HUMAN_STUPOR', 0, false)
    SetModelAsNoLongerNeeded(Config.MoneyWashStart.model)
    if Config.UseThirdEye then
        if Config.ThirdEyeName == 'ox_target' then
            local options = {
                {
                    name = 'DrugWashsavePed',
                    label = Config.Lang['request_wash'],
                    onSelect = function()
                        if active then
                            TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['save_thanks'], Config.LangType['success'])
                            TriggerServerEvent('angelicxs-DrugWash:WashMoney', mission.payoutPercentage)
                            active = false
                            savingpedmission = false
                        else
                            TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['already_washed'], Config.LangType['error'])
                        end
                    end,
                },
            }
            exports.ox_target:addLocalEntity(savePed, options)
        else
            exports[Config.ThirdEyeName]:AddEntityZone('DrugWashsavePed', savePed, {
                name="DrugWashsavePed",
                debugPoly=false,
                useZ = true
                }, {
                options = {
                    {
                    label = Config.Lang['request_wash'],
                    action = function()
                        if active then
                            TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['save_thanks'], Config.LangType['success'])
                            TriggerServerEvent('angelicxs-DrugWash:WashMoney', mission.payoutPercentage)
                            active = false
                            savingpedmission = false
                        else
                            TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['already_washed'], Config.LangType['error'])
                        end
                    end,
                    },                    
                },
                distance = 2
            })        
        end
    end
    while DoesEntityExist(SalePed) and Config.Use3DText do
        local sleep = 2000
        local Dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(SalePed))
        if Dist <= 50 then 
            sleep = 1000
            if Dist <= 25 then 
                sleep = 500
                if Dist <= 15 then 
                    sleep = 0
                    if Dist <= 5 then 
                        DrawText3Ds(Data2.x, Data2.y, Data2.z, Config.Lang['request_wash_3d'])
                        if IsControlJustReleased(0, 38) then
                            if active then
                                TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['save_thanks'], Config.LangType['success'])
                                TriggerServerEvent('angelicxs-DrugWash:WashMoney', mission.payoutPercentage)
                                active = false
                            else
                                TriggerEvent('angelicxs-DrugWash:Notify', Config.Lang['already_washed'], Config.LangType['error'])
                            end
                        end
                    end
                end
            end
        end
    end
end)


function GuardSpawner(data)
    GuardSpawner = {}
    for i = 1, #data.guardLocations do
        local spot = data.guardLocations[i]
        local model = data.guardModel
        local armour = math.random(50, 100)
        local weapon = Randomizer(data.guardWeapon)
        local hash = HashGrabber(model)
        GuardSpawner[i] = CreatePed(4, hash, spot.x, spot.y, spot.z-1, spot.w, true, true)
        while not DoesEntityExist(GuardSpawner[i]) do Wait(50) end
        SetEntityAsMissionEntity(GuardSpawner[i], true, true)
        SetPedRelationshipGroupHash(GuardSpawner[i], Relationships)
        NetworkRegisterEntityAsNetworked(GuardSpawner[i])
        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(GuardSpawner[i]), true)
        SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(GuardSpawner[i]), true)
        SetPedArmour(GuardSpawner[i], armour)
        GiveWeaponToPed(GuardSpawner[i], weapon, 500)
        SetPedFleeAttributes(GuardSpawner[i], 0, false)
        SetPedCombatAttributes(GuardSpawner[i], 0, true)
        SetPedCombatAttributes(GuardSpawner[i], 1, true)
        SetPedCombatAttributes(GuardSpawner[i], 2, true)
        SetPedCombatAttributes(GuardSpawner[i], 3, true)
        SetPedCombatAttributes(GuardSpawner[i], 5, true)
        SetPedCombatAttributes(GuardSpawner[i], 46, true)
        SetPedCombatAbility(GuardSpawner[i], math.random(0,2)) -- best 2
        SetPedCombatMovement(GuardSpawner[i], math.random(0,3)) -- best 1 (defence), best 2 (offence)
        SetPedAccuracy(GuardSpawner[i], math.random(75,100)) -- best 100
        SetPedCombatRange(GuardSpawner[i], math.random(0,2)) -- best 2
        SetEntityVisible(GuardSpawner[i], true) 
        TaskCombatPed(GuardSpawner[i], PlayerPedId(), 0, 16)
        SetModelAsNoLongerNeeded(model)
        Wait(100)
    end
end

function Randomizer(Options)
    local List = Options
    local Number = 0
    math.random()
    local Selection = math.random(1, #List)
    for i = 1, #List do
        Number = Number + 1
        if Number == Selection then
            return List[i]
        end
    end
end

function LawEnforcement()
    local List = Config.PoliceJobName
    for i = 1, #List do
        if PlayerJob == List[i] then
            return true
        end
    end
    return false
end

function SetBlip(loc, data)
    local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
    SetBlipSprite(blip, data['BlipSprite'])
    SetBlipColour(blip, data['BlipColour'])
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data['BlipName'])
    EndTextCommandSetBlipName(blip)
end

function HashGrabber(model)
    local hash = GetHashKey(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
      Wait(10)
    end
    return hash
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        if DoesEntityExist(SalePed) then
            DeleteEntity(SalePed)
        end
        if DoesEntityExist(savePed) then
            DeleteEntity(savePed)
        end
        if DoesEntityExist(washPed) then
            DeleteEntity(washPed)
        end
        for i = 1, #GuardSpawner do
            if DoesEntityExist(GuardSpawner[i]) then
                DeleteEntity(GuardSpawner[i])
            end
        end
        if DoesBlipExist(MissionRoute) then
            RemoveBlip(MissionRoute)
        end
        savingpedmission = false
    end
end)
