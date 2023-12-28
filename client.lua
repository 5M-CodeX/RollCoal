local time = 15
local particleDict = "core"
local particleName = "ent_amb_generator_smoke"
local bone = "exhaust"
local key = 73

local allowedVehicles = {
    "sandking", "fhauler", "sbearcat", "00f350d", "3500flatbed", "flatbedm2", "14suvbb", "riot",
    "bailbondsram", "f450towtruk", "18ram", "mcu", "poltowtruck", "aflatbed", "atow", "um20ram",
    "20ramambo", "16gmcbrush", "f750", "leg14ram", "fd1", "fd2", "fd3", "fd4", "fd5", "fd6", "fd7",
    "337flatbed", "f450plat", "loadstar76", "3500flatbed"
}

local intensity = 2

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = GetPlayerPed(-1)

        if IsPedInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(vehicle, -1) == ped and IsVehicleAllowed(vehicle) then
                RequestNamedPtfxAsset(particleDict)

                while not HasNamedPtfxAssetLoaded(particleDict) do
                    Citizen.Wait(0)
                end

                local RPM = GetVehicleCurrentRpm(vehicle) * intensity

                if ped == GetPlayerPed(-1) and not IsControlPressed(0, 71) then
                    RPM = RPM / intensity
                end

                CreateParticleEffects(vehicle, RPM)
            end
        end
    end
end)

function IsVehicleAllowed(vehicle)
    local hash = GetEntityModel(vehicle)

    for _, v in pairs(allowedVehicles) do
        if GetHashKey(v) == hash then
            return true
        end
    end

    return false
end

function CreateParticleEffects(vehicle, RPM)
    local boneIndex = GetEntityBoneIndexByName(vehicle, bone)

    if boneIndex == -1 then
        return
    end

    local coords = GetWorldPositionOfEntityBone(vehicle, bone)
    local loopAmount = RPM * 25
    local particleEffects = {}

    for i = 0, loopAmount do
        UseParticleFxAssetNextCall(particleDict)
        local particle = StartParticleFxLoopedOnEntityBone(particleName, vehicle, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, boneIndex, RPM, false, false, false)
        SetParticleFxLoopedEvolution(particle, particleName, RPM, 0)
        table.insert(particleEffects, particle)
        Citizen.Wait(0)
    end

    Citizen.Wait(10)

    for _, particle in pairs(particleEffects) do
        StopParticleFxLooped(particle, true)
    end
end


RegisterNetEvent("syncSmoke")
AddEventHandler("syncSmoke", function(netId, boneIndex, coords, RPM)
    local vehicle = NetworkGetEntityFromNetworkId(netId)

    local loopAmount = RPM * 25
    local particleEffects = {}

    for i = 0, loopAmount do
        UseParticleFxAssetNextCall(particleDict)
        local particle = StartParticleFxLoopedOnEntityBone(particleName, vehicle, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, boneIndex, RPM, false, false, false)
        SetParticleFxLoopedEvolution(particle, particleName, RPM, 0)
        table.insert(particleEffects, particle)
        Citizen.Wait(0)
    end

    Citizen.Wait(10)

    for _, particle in pairs(particleEffects) do
        StopParticleFxLooped(particle, true)
    end
end)

RegisterNetEvent("startSmoke")
AddEventHandler("startSmoke", function()
    local ped = GetPlayerPed(-1)

    if IsPedInAnyVehicle(ped) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local boneIndex = GetEntityBoneIndexByName(vehicle, bone)

        if boneIndex ~= -1 then
            local coords = GetWorldPositionOfEntityBone(vehicle, bone)
            local RPM = GetVehicleCurrentRpm(vehicle) * intensity

            if ped == GetPlayerPed(-1) and not IsControlPressed(0, 71) then
                RPM = RPM / intensity
            end

            TriggerServerEvent("syncSmoke", NetworkGetNetworkIdFromEntity(vehicle), boneIndex, coords, RPM)
        end
    end
end)