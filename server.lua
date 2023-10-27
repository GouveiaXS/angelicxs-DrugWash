ESX = nil
QBcore = nil

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

local washspot = Randomizer(Config.MoneyWashStart.location)

if Config.UseESX then
    ESX = exports["es_extended"]:getSharedObject()
    ESX.RegisterServerCallback('angelicxs-DrugWash:server:getWasher', function(source, cb)
        cb(washspot)
    end)
elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
    QBCore.Functions.CreateCallback('angelicxs-DrugWash:server:getWasher', function(source, cb)
        cb(washspot)
    end)
end

RegisterNetEvent('angelicxs-DrugWash:SellDrug', function(number, data)
    local src = source
    local Player = nil
    if Config.UseESX then
        Player = ESX.GetPlayerFromId(src)
        local info = Player.getInventoryItem(data.drugName)
        if info.count >= number then
            Player.removeInventoryItem(data.drugName, number)
            TriggerClientEvent('angelicxs-DrugWash:Notify', src, Config.Lang['sold_items'], Config.LangType['success'])
            if Config.SaleMoneyAsItem then
                Player.addInventoryItem(Config.SaleMoneyItemName, math.floor(number*data.cost*data.pay))
            else
                Player.addAccountMoney(Config.SaleAccountType,math.floor(number*data.cost*data.pay))
            end
        else
            TriggerClientEvent('angelicxs-DrugWash:Notify', src, Config.Lang['low_items'], Config.LangType['error'])
        end
    elseif Config.UseQBCore then
        Player = QBCore.Functions.GetPlayer(src)
        if Player.Functions.RemoveItem(data.drugName, number) then
            TriggerClientEvent('angelicxs-DrugWash:Notify', src, Config.Lang['sold_items'], Config.LangType['success'])
            if Config.SaleMoneyAsItem then
                Player.Functions.AddItem(Config.SaleMoneyItemName, math.floor(number*data.cost*data.pay))
            else
                Player.Functions.AddMoney(Config.SaleAccountType, math.floor(number*data.cost*data.pay))
            end
        else
            TriggerClientEvent('angelicxs-DrugWash:Notify', src, Config.Lang['low_items'], Config.LangType['error'])
        end
    end 
end)

RegisterNetEvent('angelicxs-DrugWash:WashMoney', function(cut)
    local src = source
    local Player = nil
    if Config.UseESX then
        Player = ESX.GetPlayerFromId(src)
        local info = Player.getInventoryItem(Config.SaleMoneyItemName)
        Player.removeInventoryItem(Config.SaleMoneyItemName, info.count)
        if Config.WashMoneyAsItem then
            Player.addInventoryItem(Config.WashMoneyItemName, math.floor(info.count*cut))
        else
            Player.addAccountMoney(Config.WashAccountType,math.floor(info.count*cut))
        end
        TriggerClientEvent('angelicxs-DrugWash:Notify', src, Config.Lang['washed_money']..tostring(math.floor(info.count*cut)), Config.LangType['success'])
    elseif Config.UseQBCore then
        Player = QBCore.Functions.GetPlayer(src)
        local amount = Player.Functions.GetItemByName(Config.SaleMoneyItemName).amount
        if Player.Functions.RemoveItem(Config.SaleMoneyItemName, amount) then
            if Config.WashMoneyAsItem then
                Player.Functions.AddItem(Config.WashMoneyItemName, math.floor(amount*cut))
            else
                Player.Functions.AddMoney(Config.WashAccountType, math.floor(amount*cut))
            end
            TriggerClientEvent('angelicxs-DrugWash:Notify', src, Config.Lang['washed_money']..tostring(math.floor(amount*cut)), Config.LangType['success'])
        end
    end 
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then

    end
end)