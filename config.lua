----------------------------------------------------------------------
-- Thanks for supporting AngelicXS Scripts!							--
-- Support can be found at: https://discord.gg/tQYmqm4xNb			--
-- More paid scripts at: https://angelicxs.tebex.io/ 				--
-- More FREE scripts at: https://github.com/GouveiaXS/ 				--
-- Images are provided for new items if you choose to add them 		--
----------------------------------------------------------------------

-- Model info: https://docs.fivem.net/docs/game-references/ped-models/
-- Blip info: https://docs.fivem.net/docs/game-references/blips/

Config = {}

Config.UseESX = false						-- Use ESX Framework
Config.UseQBCore = true						-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.
-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-DrugWash:CustomNotify')
AddEventHandler('angelicxs-DrugWash:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
    --exports['okokNotify']:Alert('', Message, 4000, type, false)
end)

Config.NHMenu = false						-- Use NH-Menu [https://github.com/whooith/nh-context]
Config.NHMenu = false						-- Use NH-Menu [https://github.com/whooith/nh-context]
Config.QBMenu = true						-- Use QB-Menu (Ignored if Config.NHMenu = true) [https://github.com/qbcore-framework/qb-menu]
Config.QBInput = true						-- Use QB-Input (Ignored if Config.NHInput = true) [https://github.com/qbcore-framework/qb-input]
Config.OXLib = false						-- Use the OX_lib (Ignored if Config.NHInput or Config.QBInput = true) [https://github.com/overextended/ox_lib]  !! must add shared_script '@ox_lib/init.lua' and lua54 'yes' to fxmanifest!!

-- Visual Preference
Config.Use3DText = false 					-- Use 3D text for NPC/Job interactions; only turn to false if Config.UseThirdEye is turned on and IS working.
Config.UseThirdEye = true 					-- Enables using a third eye (third eye requires the following arguments debugPoly, useZ, options {event, icon, label}, distance)
Config.ThirdEyeName = 'qb-target' 			-- Name of third eye aplication

-- Script Preferences
Config.SaleMoneyAsItem = true                   -- Defines what is provided to the player upon SELLING to the drug sales ped 
Config.SaleMoneyItemName = 'dirty_money'        -- If Config.MoneyAsItem = true, specifies the items received from the SELLING transaction !! provides X amount of item, NOT SET UP FOR METADATA !!
Config.SaleAccountType = 'cash'                 -- If Config.MoneyAsItem = false, specifies the account the money from the SELLING transaction

Config.AllowPoliceInteract = false              -- Lets police interact with peds
Config.PoliceJobName = {'police'}               -- List of police jobs

Config.WashMoneyAsItem = false                  -- Defines what is provided to the player upon WASHING the funds !! will only wash the ITEM specified in Config.SaleMoneyItemName !!
Config.WashMoneyItemName = 'dirty_money'        -- If Config.MoneyAsItem = true, specifies the items received from the WASHING transaction
Config.WashAccountType = 'cash'                 -- If Config.MoneyAsItem = false, specifies the account the money from the WASHING transaction

Config.UseDrugSales = true                      -- Enables direct selling of drugs (Uses table Config.DrugSales)
Config.DrugSales ={
    --[[
    ['none'] = {                                                -- Gang Name      !!!! 'none' gangs can be used by anyone as long as the rank in their current job meets or exceeds the minRank of the sellers !!!!
        ['MassSellers'] = {                                     -- Information on mass sellers for gang
            {
                location = vector4(144.49, -1521.33, 29.14, 317.63),    -- Location of ped
                minRank = 1,                                            -- Minimum rank player must have to interact with the ped
                payoutMultiplier = 1,                                   -- Pay multiplier against each of the drugs in ['DrugInfo']
                model = 'g_m_m_chiboss_01'                              -- Model of the ped
            },
        },
        ['DrugInfo'] = {                                        -- Base selling price of each drug
            {
                drugName = 'weed_brick',                                -- Name of drug
                drugLabel = 'Weed Bricks',                              -- Label of drug
                cost = 5000                                             -- Price of drug
            },
        },
        ['BlipSprite'] = 84,                                    -- Sprite for blips for each seller location, if not desired turn to FALSE to turn off blips
        ['BlipName'] = 'Seller',                                -- Name of blips
        ['BlipColour'] = 2,                                     -- Colour of blips
    },
    ]]

    ['ballas'] = {                                              -- Gang Name
        ['MassSellers'] = {                                     -- Information on mass sellers for gang
            {location = vector4(332.06, -2055.59, 20.88, 329.61), minRank = 0, payoutMultiplier = 0.5, model = 'a_m_m_og_boss_01'},
            {location = vector4(327.09, -2051.56, 20.87, 291.48), minRank = 2, payoutMultiplier = 1.2, model = 'a_m_m_og_boss_01'},

        },
        ['DrugInfo'] = {                                        -- Base selling price of each drug
            {drugName = 'weed_brick', drugLabel = 'Weed Bricks', cost = 10},
        },
        ['BlipSprite'] = 84,                                    -- Sprite for blips for each seller location, if not desired turn to FALSE to turn off blips
        ['BlipName'] = 'Ballas Seller',                         -- Name of blips
        ['BlipColour'] = 2,                                     -- Colour of blips
    },
}

Config.UseMoneyWash = true                      -- Enables washing of money (Uses table Config.DrugWash)
RegisterNetEvent('angelicxs-DrugWash:CustomPoliceAlert')
AddEventHandler('angelicxs-DrugWash:CustomPoliceAlert', function(coords)
    -- Put Custom Police Notification Here
end)

Config.MoneyWashStart  = {
    model = 'a_f_y_business_01',                -- Model of ped that starts moneywash mission
    location = {
        vector4(1521.24, -2093.08, 76.99, 202.61),                              -- Possible location of starting ped (randomly chooses one)
    },
    savePed = 's_f_y_factory_01',               -- Model of ped to finish mission
}

Config.DrugWash = {
    [1] = {                                                     -- Unique mission number
        pedLocation = vector4(487.85, -2968.92, 6.04, 174.84),  -- Location of ped to save/talk to
        guardLocations = {                                      -- Location of guards (if any) to kill
            vector4(492.2, -2968.75, 6.04, 240.51),
            vector4(483.6, -2969.34, 6.04, 155.06),
        },
        guardModel = 'g_f_y_ballas_01',                         -- Models of guards
        guardWeapon = {                                         -- Weapons carried by guards
            'weapon_pistol',
            'weapon_carbinerifle',
        },
        payoutPercentage = 0.2,                                  -- Percentage of how much money is received from dirty cash (0-1) where 0.5 is 50% and 1.0 is 100%
    },
    [2] = {                                                     -- Unique mission number
        pedLocation = vector4(2764.28, 1568.62, 42.89, 252.8),  -- Location of ped to save/talk to
        guardLocations = {                                      -- Location of guards (if any) to kill
            vector4(2762.32, 1560.42, 42.89, 160.33),
            vector4(2748.1, 1563.8, 40.33, 82.89),
            vector4(2751.11, 1578.6, 40.33, 342.36),
            vector4(2758.47, 1580.09, 42.89, 249.2),
            vector4(2748.73, 1560.92, 32.51, 249.34),
            vector4(2764.9, 1564.99, 32.51, 247.8),
            vector4(2763.38, 1548.83, 30.79, 203.07),
            vector4(2745.95, 1584.72, 32.51, 157.12)
        },
        guardModel = 'g_m_y_lost_01',                           -- Models of guards
        guardWeapon = {                                         -- Weapons carried by guards
            'weapon_pistol',
            'weapon_carbinerifle',
        },
        payoutPercentage = 0.7,                                  -- Percentage of how much money is received from dirty cash (0-1) where 0.5 is 50% and 1.0 is 100%
    },
}

-- Language Configuration
Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'primary'
}

Config.Lang = {
	['request_sale_3d'] = 'Press ~r~[E]~w~ to sell drugs.',
    ['request_sale'] = 'Sell Drugs',
    ['lookup_items'] = "Lets see what you got on hand...",
    ['cancel'] = "Leave",
    ['drugMenu_header'] = 'Drugs to Sell:',
    ['drugSale_header'] = 'Selling',
    ['drugSale_num'] = 'Number to Sell',
    ['drugSale_sell'] = 'Sell',
    ['zero_error'] = 'You must enter a number larger than 0',
    ['sold_items'] = 'Cool, I will take care of this for you, here is your cash!',
    ['low_items'] = 'You do not have that many.',
    ['request_wash'] = 'Wash Money',
	['request_wash_3d'] = 'Press ~r~[E]~w~ to wash money.',
    ['save_ped'] = 'Our washer is in trouble, go save them and they can can wash it on the spot.',
    ['already_washed'] = 'I already washed these for you!',
    ['save_thanks'] = 'Thanks for saving me! Here let me wash real quick that for you!',
    ['washed_money'] = 'Here is your cut of the funds, I was able to get you $',
    ['rescue_me'] = 'Last Known Washer Location',
    ['in_area'] = 'The washer is somewhere in the area!',
    ['on_mission'] = 'You need to save our washer!',
}
