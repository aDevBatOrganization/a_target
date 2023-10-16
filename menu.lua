local PlayerData = {}

ESX              = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    Citizen.Wait(5000)
    PlayerData = ESX.GetPlayerData()
end)



Config = {}

Config.isDebug = true


function Log(text)
    if (Config.isDebug) then
        print(text)
    end
end

function LogError(text)
    Log("^1" .. text)
end

-- create a new menu pool
local menuPool = MenuPool()

-- most basic loop for the menu
Citizen.CreateThread(function()
    while (true) do
        Citizen.Wait(0)

        -- call the Process function of the menu pool (needs to be called every frame)
        menuPool:Process(function(screenPosition, hitSomething, worldPosition, hitEntityHandle, normalDirection)
            -- create your menu here!
            CreateMenu(screenPosition, worldPosition, hitEntityHandle)
        end)
    end
end)


function CreateMenu(screenPosition, worldPosition, hitEntityHandle)
    -- call this when you need to recreate a menu
    menuPool:Reset()

    -- create the main menu
    local contextMenu = menuPool:AddMenu()

    -- change the menus default opacity for all items
    contextMenu.opacity = 80

    -- change the menus default text color (list of named colors can be found in Drawables/Color.lua)
    contextMenu.colors.text = Colors.White

    -- alternatively you can create a new color like this (RGB or RGBA ranging from 0-255)
    -- contextMenu.colors.text = Colors.White
    -- contextMenu.colors.text = Color(127, 0, 0, 255)

    -- change the border color of the menu
    contextMenu.colors.border = Color(127, 0, 0, 0)

    ---------------------------------


    -- check, if an entity was clicked
    if (hitEntityHandle ~= nil and DoesEntityExist(hitEntityHandle)) then
        if (PlayerPedId() == hitEntityHandle) then
            -- player
            local id = contextMenu:AddItem("~b~ID : ~w~" .. GetPlayerServerId(PlayerId()) .. "")


            -- police menu

            if ESX.PlayerData.job.name == "police" then
                local police = menuPool:AddSubmenu(contextMenu, ESX.PlayerData.job.name)

                -- local menu = police:AddItem("Menu LSPD")
                -- menu.OnClick = function()
                --     TriggerEvent("a_lspd:lspdMenu")
                --     menuPool:Reset()
                -- end

                local service = menuPool:AddSubmenu(police, "Appel a central")

                local prise = service:AddItem("~g~Prise~w~ de service")
                local fin = service:AddItem("~r~Fin~w~ de service")
                local pausse = service:AddItem("~o~Pause~w~ de service")
                local standby = service:AddItem("~o~Standby")
                local refus = service:AddItem("~o~Refus")
                local control = service:AddItem("~o~Control")
                local crime = service:AddItem("~o~Crime")

                prise.OnClick = function()
                    TriggerEvent("a_lspd:priseService")
                    menuPool:Reset()
                end
                fin.OnClick = function()
                    TriggerEvent("a_lspd:finService")
                    menuPool:Reset()
                end
                pausse.OnClick = function()
                    TriggerEvent("a_lspd:pauseService")
                    menuPool:Reset()
                end
                standby.OnClick = function()
                    TriggerEvent("a_lspd:standbyService")
                    menuPool:Reset()
                end
                refus.OnClick = function()
                    TriggerEvent("a_lspd:refusService")
                    menuPool:Reset()
                end
                control.OnClick = function()
                    TriggerEvent("a_lspd:controlService")
                    menuPool:Reset()
                end
                crime.OnClick = function()
                    TriggerEvent("a_lspd:crimeService")
                    menuPool:Reset()
                end

                local vehicule = police:AddItem("Chercher vehicule en BDD")

                police.OnClick = function()
                    TriggerEvent("a_lspd:searchVehicle")
                    menuPool:reset()
                end

                local renfort = menuPool:AddSubmenu(police, "Demande de renfort")
                local objet = menuPool:AddSubmenu(police, "Placer objet")
            elseif ESX.PlayerData.job.name == "ambulance" then
                local ems = menuPool:AddSubmenu(contextMenu, ESX.PlayerData.job.name)

                -- local menu = ems:AddItem("Menu EMS")
                -- menu.OnClick = function()
                --     TriggerEvent("a_ems:emsMenu", source)

                --     menuPool:Reset()
                -- end

                local petit = ems:AddItem("Soigner petites blessures")
                local grand = ems:AddItem("Soigner blessures graves")
                local vehicle = ems:AddItem("Mettre dans le véhicule")


                petit.OnClick = function()
                    TriggerEvent("a_ems:small", source)

                    menuPool:Reset()
                end
                grand.OnClick = function()
                    TriggerEvent("a_ems:big", source)

                    menuPool:Reset()
                end
                vehicle.OnClick = function()
                    TriggerEvent("a_ems:vehicle", source)

                    menuPool:Reset()
                end
            end





            local persoMenu, persoMenuItem = menuPool:AddSubmenu(contextMenu, "Vos Information")

            ---------Menu Vos info

            local persoItem3 = persoMenu:AddItem("Job : " .. ESX.PlayerData.job.label)

            -- jobs

            persoItem3.OnClick = function()
                if ESX.PlayerData.job.name == "police" then
                    print("police")
                    menuPool:Reset()
                elseif ESX.PlayerData.job.name == "ambulance" then
                    print("EMS")
                    menuPool:Reset()
                else
                    ESX.ShowNotification("Tu es chomeur")
                end
            end

            local utils = menuPool:AddSubmenu(contextMenu, "Outils")


            local persoItem2 = persoMenu:AddItem("Organisation : " .. ESX.PlayerData.job2.label)
            local persoItem = persoMenu:AddItem("Votre argent (sur vous) :~g~ " ..
                ESX.Math.GroupDigits(ESX.PlayerData.money) .. " $")
            local carteItem = menuPool:AddSubmenu(persoMenu, "Vos Cartes")


            -- utiles

            local persoItembilling = utils:AddItem("Factures")
            local rollJoint = utils:AddItem("Rouler un joint")
            local animGun = utils:AddItem("Animation d'armes")

            persoItembilling.OnClick = function()
                ExecuteCommand("facture")
            end

            rollJoint.OnClick = function()
                TriggerServerEvent("a_drugs:rollJoint", GetPlayerServerId(PlayerId()))
                menuPool:Reset()
            end

            animGun.OnClick = function()
                ExecuteCommand("wam")
                menuPool:Reset()
            end

            -- orga / gang
            persoItem2.OnClick = function()
                if PlayerData.job2 ~= nil and PlayerData.job2.name == 'dev' then
                    ExecuteCommand("testMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'vagos' then
                    ExecuteCommand("vagosMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'ballas' then
                    ExecuteCommand("ballasMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'lost' then
                    ExecuteCommand("lostMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'triade' then
                    ExecuteCommand("triadeMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'kkangpae' then
                    ExecuteCommand("kkangpaeMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'oneil' then
                    ExecuteCommand("oneilMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'soa' then
                    ExecuteCommand("soaMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'mayans' then
                    ExecuteCommand("mayansMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'ms13' then
                    ExecuteCommand("ms13Menu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'madrazo' then
                    ExecuteCommand("madrazoMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'aztecas' then
                    ExecuteCommand("aztecasMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'bloods' then
                    ExecuteCommand("bloodsMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'marabunta' then
                    ExecuteCommand("marabuntaMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'staff' then
                    ExecuteCommand("staffMenu")
                    menuPool:Reset()
                elseif PlayerData.job2 ~= nil and PlayerData.job2.name == 'families' then
                    ExecuteCommand("familiesMenu")
                    menuPool:Reset()
                else
                    ESX.ShowNotification("Tu ne fait pas partie d'un Gang ou d'une Organisation")
                end
            end

            -- a_staff

            local admin = menuPool:AddSubmenu(contextMenu, "Menu admin")

            local adminItem = admin:AddItem('Menu')
            local heal = admin:AddItem('Heal')
            local noclip = admin:AddItem('Noclip')
            local vehicle = admin:AddItem('Vehicule')

            adminItem.OnClick = function()
                TriggerEvent('a_staff:openAdminMenu', source)
                menuPool:Reset()
            end

            heal.OnClick = function()
                ExecuteCommand("heal")
                menuPool:Reset()
            end

            noclip.OnClick = function()
                TriggerEvent('a_staff:admin_no_clip', source)
                menuPool:Reset()
            end

            vehicle.OnClick = function()
                TriggerEvent('a_staff:openVehicleMenu', source)
                menuPool:Reset()
            end

            -- fin a_staff

            local carteItem1 = carteItem:AddItem("Montrer sa ~b~carte d'identité")
            carteItem1.OnClick = function()
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestDistance ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                else
                    ESX.ShowNotification("Aucun joueur à proximité")
                end
            end

            local carteItem2 = carteItem:AddItem("Regarder sa ~b~carte d'identité")
            carteItem2.OnClick = function()
                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
            end

            local carteItem3 = carteItem:AddItem("Montrer son ~g~permis de conduire")
            carteItem3.OnClick = function()
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestDistance ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()),
                        'driver')
                else
                    ESX.ShowNotification("Aucun joueur à proximité")
                end
            end

            local carteItem4 = carteItem:AddItem("Regarder son ~g~permis de conduire")
            carteItem4.OnClick = function()
                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()),
                    'driver')
            end

            local carteItem5 = carteItem:AddItem("Montrer son ~r~permis port d'armes")
            carteItem5.OnClick = function()
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestDistance ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()),
                        'weapon')
                else
                    ESX.ShowNotification("Aucun joueur à proximité")
                end
            end

            local carteItem6 = carteItem:AddItem("Regarder son ~r~permis port d'armes")
            carteItem6.OnClick = function()
                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()),
                    'weapon')
            end
            local playerIdx = GetPlayerFromServerId()
            local ped = GetPlayerPed(playerIdx)
            adfs = GetPlayerServerId(PlayerId())

            print(adfs)
        elseif (IsEntityAVehicle(hitEntityHandle)) then
            -- vehicle

            local vehicle = hitEntityHandle

            if ESX.PlayerData.job.name == "police" then
                -- action menu lspd

                local police = contextMenu:AddItem("Chercher dans la BDD")

                police.OnClick = function()
                    TriggerEvent("a_lspd:searchVehicle")
                    menuPool:reset()
                end
            end

            local adminVehicleMenu = menuPool:AddSubmenu(contextMenu, "Menu vehicle admin")
            local vehicleMenu = adminVehicleMenu:AddItem('Menu')
            local repaire = adminVehicleMenu:AddItem('Réparer')
            local dv = adminVehicleMenu:AddItem('DV')

            vehicleMenu.OnClick = function()
                TriggerEvent('a_staff:openVehicleMenu', source)
                menuPool:Reset()
            end

            repaire.OnClick = function()
                SetVehicleFixed(vehicle)
                SetVehicleDirtLevel(vehicle, 0.0)
                menuPool:Reset()
            end

            dv.OnClick = function()
                ExecuteCommand("cardel")
                menuPool:Reset()
            end


            local coffre = contextMenu:AddItem("Ouvrir le coffre")
            coffre.OnClick = function()
                TriggerEvent("esx_coffre:openCoffre")
            end

            local itemPmms = contextMenu:AddItem("Radio")
            itemPmms.OnClick = function()
                ExecuteCommand('pmms')
            end

            if (GetNumberOfVehicleDoors(vehicle) > 0) then
                local doorMenu = menuPool:AddSubmenu(contextMenu, "Open door")
                for i = 1, GetNumberOfVehicleDoors(vehicle), 1 do
                    local doorItem = doorMenu:AddItem("Door " .. i)
                    doorItem.OnClick = function()
                        local door = i - 1
                        if (GetVehicleDoorAngleRatio(vehicle, door) < 0.1) then
                            SetVehicleDoorOpen(vehicle, door, false, false)
                        else
                            SetVehicleDoorShut(vehicle, door, false)
                        end
                    end
                end
            end

            if (IsThisModelABoat(GetEntityModel(vehicle))) then
                local anchorItem = contextMenu:AddItem("Anchor")
                anchorItem.OnClick = function()
                    SetBoatAnchor(vehicle, true)
                end
            end

            -- ped
        elseif (IsEntityAPed(hitEntityHandle)) then
            local ped = hitEntityHandle
            local pedId = GetPlayerServerId(PlayerId(hitEntityHandle))

            if IsPedAPlayer(ped) then
                if ESX.PlayerData.job.name == "police" then
                    -- action LSDP sur civil --

                    local police = menuPool:AddSubmenu(contextMenu, "Menu Police")

                    local menu = police:AddItem("Menu LSPD")
                    menu.OnClick = function()
                        TriggerEvent("a_lspd:lspdMenu")
                        menuPool:Reset()
                    end

                    local civil = menuPool:AddSubmenu(police, "Interaction Citoyen")

                    local carte = civil:AddItem("Carte d'identité")
                    local fouille = civil:AddItem("Fouiller")
                    local license = civil:AddItem("Gérer les licenses")

                    carte.OnClick = function()
                        TriggerEvent("a_lspd:carteIdentite")
                        menuPool:Reset()
                    end
                    fouille.OnClick = function()
                        TriggerEvent("a_lspd:fouille")
                        menuPool:Reset()
                    end
                    license.OnClick = function()
                        TriggerEvent("a_lspd:license")
                        menuPool:reset()
                    end


                    local menotte = menuPool:AddSubmenu(police, "Interaction Menotte")

                    local mettre = menotte:AddItem("Mettre")
                    local enlever = menotte:AddItem("Enlever")
                    local trainer = menotte:AddItem("Porter")

                    mettre.OnClick = function()
                        TriggerEvent("a_lspd:mettreMenotte")
                        menuPool:Reset()
                    end
                    enlever.OnClick = function()
                        TriggerEvent("a_lspd:enleverMenotte")
                        menuPool:Reset()
                    end
                    trainer.OnClick = function()
                        TriggerEvent("a_lspd:trainer")
                        menuPool:reset()
                    end


                    local amende = police:AddItem("Donner amende")


                    amende.OnClick = function()
                        TriggerEvent("a_lspd:amende")
                        menuPool:reset()
                    end
                elseif ESX.PlayerData.job.name == "ambulance" then
                    local reanimer = ems:AddItem("Réanimer")

                    reanimer.OnClick = function()
                        TriggerEvent("a_ems:revive", source)

                        menuPool:Reset()
                    end
                end
                pedPlayer = ped
                local playerId = contextMenu:AddItem("Player ID : ")
                local admin = contextMenu:AddItem("Menu Admin")
                admin.OnClick = function()
                    TriggerEvent("a_staff:admin_menu_to_player", pedPlayer)
                    menuPool:Reset()
                end

                local revive = contextMenu:AddItem("Revive")
                revive.OnClick = function()
                    TriggerEvent("a_staff:revive", pedPlayer)
                end

                local heal = contextMenu:AddItem("Heal")
                heal.OnClick = function()
                    ExecuteCommand("heal", pedPlayer)
                end

                local carry = contextMenu:AddItem("Porter")
                carry.OnClick = function()
                    ExecuteCommand("carry")
                end
            else
                local sellDrugs = contextMenu:AddItem("Vendre de la drogue")
                sellDrugs.OnClick = function()
                    TriggerEvent('a_drugs:openMenu', source)
                    menuPool:Reset()
                end
            end
        elseif (GetEntityModel(hitEntityHandle)) then
            if GetEntityModel(hitEntityHandle) == GetHashKey('bkr_prop_weed_lrg_01b') then
                local weed = contextMenu:AddItem("Recolter Weed")
                weed.OnClick = function()
                    ExecuteCommand("recolteWeed")
                    Wait(2000)
                    menuPool:Reset()
                end
            elseif GetEntityModel(hitEntityHandle) == GetHashKey('prop_sapling_break_02') then
                local harvest = contextMenu:AddItem("Recolter Cocaine")
                harvest.OnClick = function()
                    ExecuteCommand("recolteCoke")
                    Wait(1000)
                    menuPool:Reset()
                end
            elseif GetEntityModel(hitEntityHandle) == GetHashKey('prop_plant_paradise') then
                local harvest = contextMenu:AddItem("Recolter Clavicipitacées")
                harvest.OnClick = function()
                    ExecuteCommand("recoltePoppy")
                    Wait(1000)
                    menuPool:Reset()
                end
            elseif GetEntityModel(hitEntityHandle) == GetHashKey('prop_plant_int_02a') then
                local harvest = contextMenu:AddItem("Recolter Diéthilamine")
                harvest.OnClick = function()
                    ExecuteCommand("recolteDiethylamine")
                    Wait(1000)
                    menuPool:Reset()
                end
            elseif GetEntityModel(hitEntityHandle) == GetHashKey('prop_plant_01a') then
                local harvest = contextMenu:AddItem("Recolter Méthylamino")
                harvest.OnClick = function()
                    ExecuteCommand("recolteMethylamino")
                    Wait(1000)
                    menuPool:Reset()
                end
            elseif GetEntityModel(hitEntityHandle) == GetHashKey('prop_plant_palm_01a') then
                local harvest = contextMenu:AddItem("Recolter Méthédrine")
                harvest.OnClick = function()
                    ExecuteCommand("recolteMethedrine")
                    Wait(1000)
                    menuPool:Reset()
                end
            elseif GetEntityModel(hitEntityHandle) == GetHashKey('prop_plant_palm_01c') then
                local harvest = contextMenu:AddItem("Recolter Pavot")
                harvest.OnClick = function()
                    ExecuteCommand("recoltePavot")
                    Wait(1000)
                    menuPool:Reset()
                end
            elseif GetEntityModel(hitEntityHandle) == GetHashKey('prop_fib_plant_01') then
                local harvest = contextMenu:AddItem("Recolter Opium")
                harvest.OnClick = function()
                    ExecuteCommand("recolteOpium")
                    Wait(1000)
                    menuPool:Reset()
                end
            else
                print("pas de props valide")
            end
        end
    end

    -- sets the position of the menu on the screen
    contextMenu:SetPosition(screenPosition)
    -- set the visibility of the menu
    contextMenu:Visible(true)
end

function RefreshMoney()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
            societymoney = ESX.Math.GroupDigits(money)
        end, ESX.PlayerData.job.name)
    end
end
