ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
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
        local ped = PlayerPedId()
        local plyCoords = GetEntityCoords(ped)
        local NearMarker = false
        for k in pairs(Scrappos) do
           if InJob == false then
              local coord1 = vector3(plyCoords.x, plyCoords.y, plyCoords.z)
	          local coord2 = vector3(Scrappos[k].x, Scrappos[k].y, Scrappos[k].z)
              local dist = #(coord1 - coord2)

              if dist <= 1.2 and not NearMarker then
                 DrawMarker(1, Scrappos[k].x, Scrappos[k].y, Scrappos[k].z, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.2001, 0, 173, 255, 47 ,0 ,0 ,0 ,0)
                 scrapmantext(Scrappos[k].x, Scrappos[k].y, Scrappos[k].z, tostring('Press ~b~[E]~w~ to search this spot'))
                 NearMarker = true
                 if IsControlJustPressed(0,38) then
                    scrap()
                    InJob = true
                 end
              end
           end
        end

        for k in pairs(Scrapsell) do
           if InJob == true then
              local coord1 = vector3(plyCoords.x, plyCoords.y, plyCoords.z)
	          local coord2 = vector3(Scrapsell[k].x, Scrapsell[k].y, Scrapsell[k].z)
	          local dist = #(coord1 - coord2)
              if dist <= 1.2 and not NearMarker then
                 scrapmantext(Scrapsell[k].x, Scrapsell[k].y, Scrapsell[k].z, tostring('Press ~g~[E]~w~ to sell scraps'))
                 DrawMarker(1, Scrapsell[k].x, Scrapsell[k].y, Scrapsell[k].z, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.2001, 50, 205, 50, 80 ,0 ,0 ,0 ,0)
                 NearMarker = true
                 if IsControlJustPressed(0,38) then
                    TriggerServerEvent('scrapjob:scrap:sell')
                    DeleteEntity(scrap_type)
                    ClearPedTasks(ped)
                    InJob = false
                 end
              end
           end
        end

        if not NearMarker then
            Citizen.Wait(1000)
        end
        Citizen.Wait(0)
    end
end)


Citizen.CreateThread(function()
     while true do
     local ped = PlayerPedId()
       if IsEntityPlayingAnim(ped, "anim@gangops@facility@servers@bodysearch@", "player_search", 3) then
          DisableControlAction(0, 24, true)
          DisableControlAction(0, 257, true)
          DisableControlAction(0, 263, true)
          DisableControlAction(0, 32, true)
          DisableControlAction(0, 34, true)
          DisableControlAction(0, 31, true)
          DisableControlAction(0, 30, true)
          DisableControlAction(0, 45, true)
          DisableControlAction(0, 22, true)
          DisableControlAction(0, 44, true)
          DisableControlAction(0, 37, true)
          DisableControlAction(0, 264, true)
          DisableControlAction(0, 257, true)
          DisableControlAction(0, 140, true)
          DisableControlAction(0, 141, true)
          DisableControlAction(0, 142, true)
          DisableControlAction(0, 143, true)
       end
       Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(-511.76, -1753.97, 18.9)
	SetBlipSprite(blip, 365)
	SetBlipScale(blip, 0.90)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Scrap Area')
	EndTextCommandSetBlipName(blip)

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
        local plyCoords = GetEntityCoords(ped)
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
	       AttachEntityToEntity(scrap_type , ped, GetPedBoneIndex(ped, 60309),  0.025, 0.00, 0.355, -75.0, 470.0, 0.0, true, true, false, true, 1, true)
	       LoadDict('anim@heists@box_carry@')
	       TaskPlayAnim(ped, 'anim@heists@box_carry@', "idle", 3.0, -8, -1, 63, 0, 0, 0, 0 )
        elseif time == 2 then
           scrap_type = CreateObject(GetHashKey('prop_rub_monitor'),plyCoords.x, plyCoords.y,plyCoords.z, true, true, true)
	       AttachEntityToEntity(scrap_type , ped, GetPedBoneIndex(ped, 60309),  0.020, 0.00, 0.255, -70.0, 470.0, 0.0, true, true, false, true, 1, true)
	       LoadDict('anim@heists@box_carry@')
	       TaskPlayAnim(ped, 'anim@heists@box_carry@', "idle", 3.0, -8, -1, 63, 0, 0, 0, 0 )
        elseif time == 3 then
           scrap_type = CreateObject(GetHashKey('prop_car_seat'),plyCoords.x, plyCoords.y,plyCoords.z, true, true, true)
	       AttachEntityToEntity(scrap_type , ped, GetPedBoneIndex(ped, 60309),  0.020, 0.00, 0.255, -70.0, 470.0, 0.0, true, true, false, true, 1, true)
	       LoadDict('anim@heists@box_carry@')
	       TaskPlayAnim(ped, 'anim@heists@box_carry@', "idle", 3.0, -8, -1, 63, 0, 0, 0, 0 )
        else
          scrap_type = CreateObject(GetHashKey('prop_rub_tyre_03'),plyCoords.x, plyCoords.y,plyCoords.z, true, true, true)
	      AttachEntityToEntity(scrap_type , ped, GetPedBoneIndex(ped, 60309),  0.30, 0.35, 0.365, -045.0, 480.0, 0.0, true, true, false, true, 1, true)
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
