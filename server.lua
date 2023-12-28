RegisterServerEvent("syncSmoke")
AddEventHandler("syncSmoke", function(netId, boneIndex, coords, RPM)
    TriggerClientEvent("syncSmoke", -1, netId, boneIndex, coords, RPM)
end)

RegisterServerEvent("startSmoke")
AddEventHandler("startSmoke", function()
    TriggerClientEvent("startSmoke", source)
end)
