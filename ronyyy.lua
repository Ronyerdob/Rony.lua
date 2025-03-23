--[[
    RONY HUB - Versão Completa com Linoria UI
    Hospede este script no seu repositório e use:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Ronyerdob/Rony.lua/refs/heads/main/ronyhub_linoria.lua"))()
    para carregá‑lo. Compatível com executores móveis.
--]]

-- CARREGAR A LIB LINORIA UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/init.lua"))()
local Window = Library:CreateWindow("RONY HUB", {
    Size = UDim2.new(0, 700, 0, 350),
    Theme = "Ocean"
})

-- CRIAÇÃO DOS TABS
local MainTab = Window:CreateTab("Principal")
local EquipmentTab = Window:CreateTab("Equipamentos")
local AutoTab = Window:CreateTab("Automático")
local MiscTab = Window:CreateTab("Misto")
local InfoTab = Window:CreateTab("Informações")

---------------------------------------
-- FUNÇÕES UTILITÁRIAS E ABSTRAÇÕES
---------------------------------------
local bit_lib = bit32 or bit
local bxor = bit_lib.bxor
local concat = table.concat
local insert = table.insert

-- Função para buscar objetos remotos na ReplicatedStorage
local function getRemote(path)
    local current = game:GetService("ReplicatedStorage")
    for _, childName in ipairs(path) do
        current = current:WaitForChild(childName)
    end
    return current
end

-- Loop assíncrono com tratamento de erros
local function startLoop(func, delay)
    task.spawn(function()
        while true do
            local success, err = pcall(func)
            if not success then
                warn("Erro no loop:", err)
            end
            task.wait(delay)
        end
    end)
end

-- Função de descriptografia (exemplo)
local function decrypt(encrypted, key)
    local result = {}
    local keyLen = #key
    for i = 1, #encrypted do
        local encByte = string.byte(encrypted, i)
        local keyIndex = ((i - 1) % keyLen) + 1
        local keyByte = string.byte(key, keyIndex)
        table.insert(result, string.char((encByte ~ keyByte) % 256))
    end
    return table.concat(result)
end

---------------------------------------
-- VARIÁVEIS DE CONTROLE DOS RECURSOS
---------------------------------------
local isKillAuraActive = false
local isAutoRaidActive = false
local autoDungeonEnabled = false
local isAutoLuckRollActive = false
local isNormalAutoRollActive = false
local isEquipBestActive = false
local isAutoSellActive = false
local isAutoUseLuckPotionActive = false
local isAutoUseCooldownPotionActive = false
local isAutoUseCoinPotionActive = false
local isSafeAutoPotionActive = false
local isAutoAscendActive = false
local isAutoHideUIActive = false

---------------------------------------
-- RECURSO: KILL AURA
---------------------------------------
local function killAuraLoop()
    local combatM1 = getRemote({"Remote", "Event", "Combat", "M1"})
    Library:Notify("KillAura ativado", 3)
    while isKillAuraActive do
        local success, err = pcall(function() combatM1:FireServer() end)
        if not success then warn("KillAura erro:", err) end
        task.wait(0.1)
    end
    Library:Notify("KillAura desativado", 3)
end

MainTab:AddToggle({
    Name = "KillAura",
    Default = false,
    Callback = function(Value)
        isKillAuraActive = Value
        if Value then task.spawn(killAuraLoop) end
    end
})

---------------------------------------
-- RECURSO: AUTO BOSS
---------------------------------------
local bossList = {
    ["Boss 1"] = 1,  ["Boss 2"] = 2,  ["Boss 3"] = 3,  ["Boss 4"] = 4,
    ["Boss 5"] = 5,  ["Boss 6"] = 6,  ["Boss 7"] = 7,  ["Boss 8"] = 8,
    ["Boss 9"] = 9,  ["Boss 10"] = 10, ["Boss 11"] = 11, ["Boss 12"] = 12,
    ["Boss 13"] = 13, ["Boss 14"] = 14, ["Boss 15"] = 15, ["Boss 16"] = 16,
    ["Boss 17"] = 17, ["Boss 18"] = 18, ["Boss 19"] = 19
}
local selectedBoss = "Boss 1"

MainTab:AddDropdown({
    Name = "Selecionar Boss",
    Default = "Boss 1",
    Options = (function()
        local names = {}
        for k, _ in pairs(bossList) do
            table.insert(names, k)
        end
        table.sort(names, function(a, b) return bossList[a] < bossList[b] end)
        return names
    end)(),
    Callback = function(Value)
        selectedBoss = Value
        Library:Notify("Boss selecionado: " .. Value, 2)
    end,
    Tooltip = "Desafia automaticamente o boss selecionado a cada 30 segundos."
})

local function autoBossLoop()
    local autoBossRemote = getRemote({"Remote", "Event", "Combat", "[C-S]TryChallengeRoom"})
    Library:Notify("Auto Boss ativado", 3)
    while true do
        local success, err = pcall(function()
            autoBossRemote:FireServer(bossList[selectedBoss])
        end)
        if not success then warn("Auto Boss erro:", err) end
        task.wait(30)
    end
end

MainTab:AddToggle({
    Name = "Auto Boss",
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(autoBossLoop)
        else
            Library:Notify("Auto Boss desativado", 3)
        end
    end,
    Tooltip = "Desafia automaticamente o boss selecionado a cada 30 segundos."
})

---------------------------------------
-- RECURSO: AUTO RAID
---------------------------------------
local selectedRaid = "Raid 1"
local raidList = {
    ["Raid 1"] = 1, ["Raid 2"] = 2, ["Raid 3"] = 3,
    ["Raid 4"] = 4, ["Raid 5"] = 5, ["Raid 6"] = 6
}

MainTab:AddDropdown({
    Name = "Selecionar Raid",
    Default = "Raid 1",
    Options = (function()
        local names = {}
        for k, _ in pairs(raidList) do
            table.insert(names, k)
        end
        table.sort(names, function(a, b) return raidList[a] < raidList[b] end)
        return names
    end)(),
    Callback = function(Value)
        selectedRaid = Value
        Library:Notify("Raid selecionada: " .. Value, 2)
    end,
    Tooltip = "Escolha a raid para farm automático."
})

local function moveToTarget(character, targetPart)
    local targetCFrame = targetPart.CFrame * CFrame.new(0, 0, 5)
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = tweenService:Create(character, tweenInfo, { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Wait()
end

local function autoRaidLoop()
    isAutoRaidActive = true
    Library:Notify("Auto Raid ativado", 3)
    while isAutoRaidActive do
        local success, err = pcall(function()
            local raidRemote = getRemote({"Remote", "Event", "Raid", "[C-S]TryStartRaid"})
            raidRemote:FireServer(raidList[selectedRaid])
            task.wait(6)
            
            local player = game.Players.LocalPlayer
            local mobsFolder = workspace.Combats.Mobs:FindFirstChild(player.Name)
            local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            
            if mobsFolder and playerRoot then
                while isAutoRaidActive and mobsFolder:FindFirstChildOfClass("Model") do
                    local bossModel = mobsFolder:FindFirstChildOfClass("Model")
                    if bossModel and bossModel:FindFirstChild("HumanoidRootPart") then
                        moveToTarget(playerRoot, bossModel.HumanoidRootPart)
                    end
                    task.wait(1)
                end
                local openChestRemote = getRemote({"Remote", "Event", "Raid", "[C-S]TryOpenChestDrop"})
                openChestRemote:FireServer()
                task.wait(2)
                local leaveRaidRemote = getRemote({"Remote", "Event", "Raid", "[C-S]TryLeaveRaid"})
                leaveRaidRemote:FireServer()
                task.wait(1)
            else
                Library:Notify("Falha ao encontrar elementos da raid", 2)
            end
        end)
        if not success then warn("Auto Raid erro:", err) end
        task.wait(2)
    end
    Library:Notify("Auto Raid desativado", 3)
end

MainTab:AddToggle({
    Name = "Auto Raid",
    Default = false,
    Callback = function(Value)
        isAutoRaidActive = Value
        if Value then
            task.spawn(autoRaidLoop)
        else
            Library:Notify("Auto Raid desativado", 3)
        end
    end,
    Tooltip = "Faz a farm na raid selecionada, derrotando inimigos e coletando recompensas."
})

MainTab:AddLabel({
    Text = "Você pode ignorar requisitos de ascensão com isso!"
})

---------------------------------------
-- RECURSO: AUTO DUNGEON
---------------------------------------
local doorSequence = {"0", "1", "Boss"}
local currentDoorIndex = 1

local function getPlayerName() 
    return game.Players.LocalPlayer.Name 
end

local function isDungeonAvailable()
    local dungeonsFolder = workspace:FindFirstChild("Dungeons")
    local playerDungeon = dungeonsFolder and dungeonsFolder:FindFirstChild(getPlayerName())
    return playerDungeon ~= nil
end

local function hasEnemiesInCombat()
    local combatsFolder = workspace:FindFirstChild("Combats")
    local playerCombat = combatsFolder and combatsFolder[getPlayerName()]
    if playerCombat then
        for _, enemy in pairs(playerCombat:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                return true
            end
        end
    end
    return false
end

local function moveToNextDoor()
    local dungeonsFolder = workspace:FindFirstChild("Dungeons")
    if not dungeonsFolder then
        warn("Pasta de masmorras não encontrada!")
        return
    end
    local playerDungeon = dungeonsFolder:FindFirstChild(getPlayerName())
    if not playerDungeon then
        warn("Masmorra do jogador não encontrada!")
        return
    end
    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local targetDoorName = doorSequence[currentDoorIndex]
    local targetDoor = playerDungeon.Door:FindFirstChild(targetDoorName) or playerDungeon:FindFirstChild("Boss")
    if targetDoor and targetDoor:FindFirstChild("Part") then
        humanoidRootPart.CFrame = targetDoor.Part.CFrame
        currentDoorIndex = (currentDoorIndex % #doorSequence) + 1
    else
        warn("Parte da porta alvo não encontrada: " .. targetDoorName)
    end
end

local function autoDungeonLoop()
    while autoDungeonEnabled do
        if isDungeonAvailable() then
            while hasEnemiesInCombat() and autoDungeonEnabled do
                task.wait(1)
            end
            task.wait(3)
            pcall(moveToNextDoor)
        end
        task.wait(1)
    end
end

local function enterDungeon()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        warn("HumanoidRootPart não encontrado!")
        return
    end
    humanoidRootPart.CFrame = CFrame.new(428.6, 148.61, 88.82)
    while autoDungeonEnabled and not isDungeonAvailable() do
        task.wait(5)
        local virtualInputManager = game:GetService("VirtualInputManager")
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        if isDungeonAvailable() then break end
    end
end

MainTab:AddToggle({
    Name = "Auto Dungeon",
    Default = false,
    Callback = function(Value)
        autoDungeonEnabled = Value
        if autoDungeonEnabled then
            if not isDungeonAvailable() then
                task.spawn(enterDungeon)
            end
            task.spawn(autoDungeonLoop)
        else
            Library:Notify("Auto Dungeon desativado", 3)
        end
    end,
    Tooltip = "Completa automaticamente as masmorras e aguarda cooldown se necessário."
})

MainTab:AddLabel({
    Text = "Use KillAura, tenha paciência :3"
})

---------------------------------------
-- RECURSO: AUTO LUCK ROLL
---------------------------------------
local function autoLuckRollLoop()
    while isAutoLuckRollActive do
        task.wait(3)
        local success, err = pcall(function()
            local luckRemote = getRemote({"Remote", "Event", "LuckRoll", "[C-S]ConfirmLuckRoll"})
            luckRemote:FireServer()
        end)
        if not success then
            warn("Erro ao confirmar Luck Roll:", err)
            task.wait(10)
        end
    end
end

EquipmentTab:AddToggle({
    Name = "Auto Luck Roll",
    Default = false,
    Callback = function(Value)
        isAutoLuckRollActive = Value
        if Value then task.spawn(autoLuckRollLoop) end
    end,
    Tooltip = "Confirma automaticamente os luck rolls a cada 3 segundos."
})

EquipmentTab:AddLabel({ Text = "Reclame qualquer rolagem de recompensa para funcionar!!" })
EquipmentTab:AddLabel({ Text = "Irá igualar a sorte da última rolagem de recompensa reclamada." })
EquipmentTab:AddLabel({ Text = "Use um ou outro para baixo risco. Acho que ainda pode usar ambos." })

---------------------------------------
-- RECURSO: NORMAL AUTO ROLL
---------------------------------------
local function normalAutoRollLoop()
    while isNormalAutoRollActive do
        local success, err = pcall(function()
            local rollRemote = getRemote({"Remote", "Function", "Roll", "[C-S]Roll"})
            rollRemote:InvokeServer()
        end)
        if not success then warn("Normal Auto Roll erro:", err) end
        task.wait(3)
    end
end

EquipmentTab:AddToggle({
    Name = "Normal Auto Roll",
    Default = false,
    Callback = function(Value)
        isNormalAutoRollActive = Value
        if Value then task.spawn(normalAutoRollLoop) end
    end,
    Tooltip = "Rola automaticamente a cada 3 segundos."
})

---------------------------------------
-- RECURSO: EQUIPAR MELHOR
---------------------------------------
local function equipBestLoop()
    while isEquipBestActive do
        local success, err = pcall(function()
            local equipRemote = getRemote({"Remote", "Event", "Backpack", "[C-S]TryEquipBest"})
            equipRemote:FireServer()
        end)
        if not success then warn("Equipar Melhor erro:", err) end
        task.wait(1)
    end
end

EquipmentTab:AddToggle({
    Name = "Equipar Melhor",
    Default = false,
    Callback = function(Value)
        isEquipBestActive = Value
        if Value then task.spawn(equipBestLoop) end
    end
})

---------------------------------------
-- RECURSO: VENDER TUDO
---------------------------------------
local function performAutoSell()
    local backpackRemote = getRemote({"Remote", "Function", "Backpack", "[C-S]GetBackpackData"})
    local backpackData = backpackRemote:InvokeServer()
    if type(backpackData) ~= "table" then return end
    local itemsToSell = {}
    for itemId, itemData in pairs(backpackData) do
        if not itemData.locked then
            itemsToSell[itemId] = true
        end
    end
    if next(itemsToSell) then
        local sellRemote = getRemote({"Remote", "Event", "Backpack", "[C-S]TryDeleteListItem"})
        sellRemote:FireServer(itemsToSell)
    end
end

EquipmentTab:AddToggle({
    Name = "Vender Tudo",
    Default = false,
    Callback = function(Value)
        isAutoSellActive = Value
        if Value then
            task.spawn(function()
                while isAutoSellActive do
                    pcall(performAutoSell)
                    task.wait(7)
                end
            end)
        end
    end,
    Tooltip = "Vende automaticamente todos os itens da mochila, exceto os bloqueados."
})

EquipmentTab:AddLabel({ Text = "Isso irá vender tudo, exceto itens bloqueados." })

---------------------------------------
-- RECURSO: AUTO USO DE POÇÕES
---------------------------------------
local function autoUseLuckPotionLoop()
    while isAutoUseLuckPotionActive do
        local success, err = pcall(function()
            local boostRemote = getRemote({"Remote", "Event", "BoostInv", "[C-S]TryUseBoostRE"})
            boostRemote:FireServer("Luck1.2x")
        end)
        if not success then warn("Erro ao usar Poção de Sorte:", err) end
        task.wait(0.1)
    end
end

AutoTab:AddToggle({
    Name = "Usar Poção de Sorte",
    Default = false,
    Callback = function(Value)
        isAutoUseLuckPotionActive = Value
        if Value then task.spawn(autoUseLuckPotionLoop) end
    end
})

local function autoUseCooldownPotionLoop()
    while isAutoUseCooldownPotionActive do
        local success, err = pcall(function()
            local boostRemote = getRemote({"Remote", "Event", "BoostInv", "[C-S]TryUseBoostRE"})
            boostRemote:FireServer("Roll1.1x")
        end)
        if not success then warn("Erro ao usar Poção de Cooldown:", err) end
        task.wait(0.1)
    end
end

AutoTab:AddToggle({
    Name = "Usar Poção de Cooldown",
    Default = false,
    Callback = function(Value)
        isAutoUseCooldownPotionActive = Value
        if Value then task.spawn(autoUseCooldownPotionLoop) end
    end
})

local function autoUseCoinPotionLoop()
    while isAutoUseCoinPotionActive do
        local success, err = pcall(function()
            local boostRemote = getRemote({"Remote", "Event", "BoostInv", "[C-S]TryUseBoostRE"})
            boostRemote:FireServer("Coin1.2x")
        end)
        if not success then warn("Erro ao usar Poção de Moeda:", err) end
        task.wait(0.1)
    end
end

AutoTab:AddToggle({
    Name = "Usar Poção de Moeda",
    Default = false,
    Callback = function(Value)
        isAutoUseCoinPotionActive = Value
        if Value then task.spawn(autoUseCoinPotionLoop) end
    end
})

---------------------------------------
-- RECURSO: MISTO (POÇÃO AUTOMÁTICA SEGURA E AUTO ASCENDER)
---------------------------------------
local boostTypes = {
    ["Boost de Sorte"] = "Luck1.2x",
    ["Boost de Velocidade de Rolagem"] = "Roll1.1x",
    ["Boost de Moeda"] = "Coin1.2x"
}
local selectedBoost = "Boost de Sorte"

MiscTab:AddDropdown({
    Name = "Selecionar Boost",
    Default = "Boost de Sorte",
    Options = (function()
        local opts = {}
        for k, _ in pairs(boostTypes) do
            table.insert(opts, k)
        end
        return opts
    end)(),
    Callback = function(Value)
        selectedBoost = Value
    end,
    Tooltip = "Escolha qual boost ativar."
})

local function getRandomDelay() 
    return math.random(15, 40)
end

local function pickUpBoost()
    local success = pcall(function()
        local boostPickupRemote = getRemote({"Remote", "Event", "Boost", "[C-S]PickUpBoost"})
        boostPickupRemote:FireServer(boostTypes[selectedBoost])
    end)
    if success then
        task.wait(getRandomDelay())
    else
        task.wait(60)
    end
end

local function safeAutoPotionLoop()
    while isSafeAutoPotionActive do
        pickUpBoost()
    end
end

MiscTab:AddToggle({
    Name = "Poção Automática Segura",
    Default = false,
    Callback = function(Value)
        isSafeAutoPotionActive = Value
        if Value then task.spawn(safeAutoPotionLoop) end
    end,
    Tooltip = "Pega automaticamente o boost selecionado com intervalos discretos."
})

MiscTab:AddLabel({ Text = "Evita uso rápido para prevenir detecção! (Intervalos lentos)" })

local function autoAscendLoop()
    while isAutoAscendActive do
        local success, err = pcall(function()
            local ascendRemote = getRemote({"Remote", "Event", "Upgrade", "[C-S]TryUpgradeLevel"})
            ascendRemote:FireServer()
        end)
        if not success then warn("Ascender erro:", err) end
        task.wait(5)
    end
end

MiscTab:AddToggle({
    Name = "Ascender Automaticamente",
    Default = false,
    Callback = function(Value)
        isAutoAscendActive = Value
        if Value then task.spawn(autoAscendLoop) end
    end,
    Tooltip = "Ascende automaticamente a cada 5 segundos."
})

MiscTab:AddLabel({ Text = "Não ative muitos recursos ao mesmo tempo, pois você será expulso." })

---------------------------------------
-- RECURSO: OCULTAR UI AUTOMATICAMENTE
---------------------------------------
local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
local openChestGui = playerGui and playerGui:FindFirstChild("OpenChest")
local tipGui = playerGui and playerGui:FindFirstChild("Tip")
local function toggleGuiVisibility(visible)
    if openChestGui then openChestGui.Enabled = visible end
    if tipGui then tipGui.Enabled = visible end
end

local function autoHideUILoop()
    while isAutoHideUIActive do
        toggleGuiVisibility(false)
        task.wait(0.5)
    end
end

MiscTab:AddToggle({
    Name = "Ocultar UI Automaticamente",
    Default = false,
    Callback = function(Value)
        isAutoHideUIActive = Value
        if Value then
            task.spawn(autoHideUILoop)
        else
            toggleGuiVisibility(true)
        end
    end,
    Tooltip = "Oculta a GUI de OpenChest e Dicas automaticamente."
})

MiscTab:AddLabel({ Text = "Ative para ocultar elementos da UI!" })

---------------------------------------
-- ABA DE INFORMAÇÕES
---------------------------------------
InfoTab:AddLabel({ Text = "Contato: Ative suas DMs" })
InfoTab:AddLabel({ Text = "Servidor Discord: https://discord.gg/JhNvSkcmZm" })
InfoTab:AddLabel({ Text = "Por favor, ative suas DMs." })

Library:Notify("RONY HUB carregado com sucesso.", 5)
Library:Init()
