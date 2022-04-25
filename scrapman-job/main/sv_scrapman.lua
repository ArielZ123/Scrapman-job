if Config.useESX == true then 
   ESX = nil
   TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.useQBCore then
   QBCore = nil
   QBCore = exports['qb-core']:GetCoreObject()
end

RegisterServerEvent('scrapjob:scrap:find')
AddEventHandler('scrapjob:scrap:find', function()
   local _source = source
   if Config.useESX then 
       local xPlayer = ESX.GetPlayerFromId(_source)
       xPlayer.addInventoryItem('scrap', 1)  
   elseif Config.useQBCore then 
       local Player = QBCore.Functions.GetPlayer(_source)
       Player.Functions.AddItem('scrap', 1)
   end
   
end)

RegisterServerEvent('scrapjob:scrap:sell')
AddEventHandler('scrapjob:scrap:sell', function()
   local _source = source
   if Config.useESX == true then 
       local xPlayer = ESX.GetPlayerFromId(source)
       local scrapQuantity = xPlayer.getInventoryItem('scrap').count  
   elseif Config.useQBCore then 
       Player = QBCore.Functions.GetPlayer(_source)
       local item = Player.Functions.GetItemByName('scrap')
        if type(item) == 'table' then 
            item = true 
        elseif item == nil then  
            item = false 
        end
       if item == (nil or false) then scrapQuantity = 0 elseif item == true then  scrapQuantity = 1 end
   end
   
   local addmoney = math.random(20, 50) -- change here the price of the scrap sell
   if scrapQuantity >= 1 then
        if Config.useESX == true then
          xPlayer.removeInventoryItem('scrap', 1)
          xPlayer.addMoney(addmoney)
          TriggerClientEvent("pNotify:SendNotification", source, {
             text = "you sold a scrap type for <b style=color:#1588d4>"  .. addmoney .. " <b style=color:#d1d1d1> keep working</b>",
             type = "success",
             queue = "lmao",
             timeout = 7000,
             layout = "Centerleft"
          })
        elseif Config.useQBCore then 
            str = 'you sold a scrap type for '.. addMoney
            Player.Functions.RemoveItem('scrap', 1)
            TriggerClientEvent('QBCore:Notify', _source, str, 'primary', 10000)            
        end
       
   elseif scrapQuantity then
          if Config.useESX == true then 
            TriggerClientEvent("pNotify:SendNotification", source, {
                text = "you dont have any scrap type",
                type = "success",
                queue = "lmao",
                timeout = 7000,
                layout = "Centerleft"
             })
          elseif Config.useQBCore then 
            TriggerClientEvent('QBCore:Notify', _source, "you dont have any scrap type", 'primary', 10000)            
          end
   end
end)
