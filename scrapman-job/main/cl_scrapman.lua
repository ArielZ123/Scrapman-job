Citizen.CreateThread(function()
     if Config.useESX then 
	    ESX = nil
		while ESX == nil do
		  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		  Citizen.Wait(0)
		end
	 elseif Config.useQBCore then 
	   QBCore = nil
	   QBCore = exports['qb-core']:GetCoreObject()
	   Player = QBCore.Functions.GetPlayerData()
	 end
end)

local InJob = false
local scrap_type = nil

------------------------
-- settings --
local Scrappos = { -- Add more positions for search...
   {x= -507.06, y= -1741.13, z= 17.94},
   {x= -511.76, y= -1753.97, z= 17.9},
   {x= -501.03, y= -1746.44, z= 17.48},
}

local Scrapsell = { -- Add more positions for sell markrer...
   {x= -512.01, y= -1738.1, z= 18.29},
}

local Npc = { -- Add more npcs for sell markrer...
   {x= -512.31, y= -1738.59, z= 18.3, h=324.46},
}
------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		local ped = PlayerPedId()
        local plyCoords = GetEntityCoords(PlayerPedId())
        for k in pairs(Scrappos) do
           if InJob == false then
              DrawMarker(1, Scrappos[k].x, Scrappos[k].y, Scrappos[k].z, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.2001, 0, 173, 255, 47 ,0 ,0 ,0 ,0)
              local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Scrappos[k].x, Scrappos[k].y, Scrappos[k].z)
              if dist <= 1.2 then
                 scrapmantext(Scrappos[k].x, Scrappos[k].y, Scrappos[k].z, tostring('Press ~b~[E]~w~ to search this spot'))
                 if IsControlJustPressed(0,38) then
                    scrap()
                    InJob = true
                 end
              end
           end
        end

        for k in pairs(Scrapsell) do
           DrawMarker(1, Scrapsell[k].x, Scrapsell[k].y, Scrapsell[k].z, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.2001, 50, 205, 50, 80 ,0 ,0 ,0 ,0)
           local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Scrapsell[k].x, Scrapsell[k].y, Scrapsell[k].z)
           if dist <= 1.2 then
              scrapmantext(Scrapsell[k].x, Scrapsell[k].y, Scrapsell[k].z, tostring('Press ~g~[E]~w~ to sell scraps'))
              if IsControlJustPressed(0,38) then
                 TriggerServerEvent('scrapjob:scrap:sell')
                 DeleteEntity(scrap_type)
                 ClearPedTasks(ped)
                 InJob = false
              end
           end
        end

        if InJob == true then
            if IsEntityPlayingAnim(ped, "anim@gangops@facility@servers@bodysearch@", "player_search", 3) then
               DisableAllControlActions(0, true)
            end
	    end
    end
end)

-- Create Blips
Citizen.CreateThread(function()

	local blip = AddBlipForCoord(-511.76, -1753.97, 18.9)
	SetBlipSprite(blip, 365)
	SetBlipScale(blip, 0.90)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Scrap Area')
	EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    for k in pairs(Npc) do
       RequestModel(GetHashKey("s_m_m_dockwork_01"))
       while not HasModelLoaded(GetHashKey("s_m_m_dockwork_01")) do
         Citizen.Wait(0)
       end
       local sell_npc =  CreatePed(4, GetHashKey("s_m_m_dockwork_01"), Npc[k].x, Npc[k].y, Npc[k].z, Npc[k].h, false, true)
       TaskStartScenarioInPlace(sell_npc, "WORLD_HUMAN_CLIPBOARD", 0, 1)
       FreezeEntityPosition(sell_npc, true)
       SetEntityHeading(sell_npc, Npc[k].h, true)
       SetEntityInvincible(sell_npc, true)
       SetBlockingOfNonTemporaryEvents(sell_npc, true)
    end
end)

function scrap()
    Citizen.CreateThread(function()
        local impacts = 0
        local ped = PlayerPedId()
        local plyCoords = GetEntityCoords(PlayerPedId())
        local time = math.random(1,4)
        while impacts < 3 do
            Citizen.Wait(0)
            LoadDict('anim@gangops@facility@servers@bodysearch@')  
            TaskPlayAnim(ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, -8.0, -1, 48, 0)
            Citizen.Wait(2500)
            ClearPedTasks(ped)
            impacts = impacts+1
            print('search loop->',impacts)
            if impacts == 3 then
               impacts = 0
               TriggerServerEvent('scrapjob:scrap:find')
               exports.pNotify:SendNotification({text = "you found some scrap type, go ahead to sell this scrap to the dealer nearby", type = "success", timeout = 8000, layout = "centerRight", queue = "right"})
               break
            end
        end

        if time == 1 then
           scrap_type = CreateObject(GetHashKey('prop_car_door_01'),plyCoords.x, plyCoords.y,plyCoords.z, true, true, true)
	       AttachEntityToEntity(scrap_type , GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 60309),  0.025, 0.00, 0.355, -75.0, 470.0, 0.0, true, true, false, true, 1, true)
	       LoadDict('anim@heists@box_carry@')
	       TaskPlayAnim(ped, 'anim@heists@box_carry@', "idle", 3.0, -8, -1, 63, 0, 0, 0, 0 )
        elseif time == 2 then
           scrap_type = CreateObject(GetHashKey('prop_rub_monitor'),plyCoords.x, plyCoords.y,plyCoords.z, true, true, true)
	       AttachEntityToEntity(scrap_type , GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 60309),  0.020, 0.00, 0.255, -70.0, 470.0, 0.0, true, true, false, true, 1, true)
	       LoadDict('anim@heists@box_carry@')
	       TaskPlayAnim(ped, 'anim@heists@box_carry@', "idle", 3.0, -8, -1, 63, 0, 0, 0, 0 )
        elseif time == 3 then
           scrap_type = CreateObject(GetHashKey('prop_car_seat'),plyCoords.x, plyCoords.y,plyCoords.z, true, true, true)
	       AttachEntityToEntity(scrap_type , GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 60309),  0.020, 0.00, 0.255, -70.0, 470.0, 0.0, true, true, false, true, 1, true)
	       LoadDict('anim@heists@box_carry@')
	       TaskPlayAnim(ped, 'anim@heists@box_carry@', "idle", 3.0, -8, -1, 63, 0, 0, 0, 0 )
        else
          scrap_type = CreateObject(GetHashKey('prop_rub_tyre_03'),plyCoords.x, plyCoords.y,plyCoords.z, true, true, true)
	      AttachEntityToEntity(scrap_type , GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 60309),  0.30, 0.35, 0.365, -045.0, 480.0, 0.0, true, true, false, true, 1, true)
	      LoadDict('anim@heists@box_carry@')
	      TaskPlayAnim(ped, 'anim@heists@box_carry@', "idle", 3.0, -8, -1, 63, 0, 0, 0, 0 )
        end
    end)
end

function LoadDict(dict)
    RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	  	Citizen.Wait(10)
    end
end

function scrapmantext(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z+ 0.9)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.30)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

--[[ If you want to make some changes from DisableAllControlActions(0, true) to your own decide, Go to line 65 delete and paste what you want. (Took from esx police job)

			DisableControlAction(0, 1, true) -- Disable pan
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 32, true) -- W
			DisableControlAction(0, 34, true) -- A
			DisableControlAction(0, 31, true) -- S
			DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
]]
