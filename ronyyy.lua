------------------------------
-- UTILITÁRIOS E ABSTRAÇÕES
------------------------------
local bit_lib = bit32 or bit
local bxor = bit_lib.bxor
local concat = table.concat
local insert = table.insert

-- Abstração para obter objetos remotos da ReplicatedStorage
local function getRemote(path)
    local current = game:GetService("ReplicatedStorage")
    for _, childName in ipairs(path) do
        current = current:WaitForChild(childName)
    end
    return current
end

-- Helper para iniciar loops assincrônicos com tratamento de erro
local function startLoop(func, delay)
    return task.spawn(function()
        while true do
            local success, err = pcall(func)
            if not success then
                warn("Erro no loop:", err)
            end
            task.wait(delay)
        end
    end)
end

------------------------------
-- FUNÇÃO DE DESCRIPTOGRAFIA
------------------------------
local function decrypt(encrypted, key)
    local result = {}
    local keyLen = #key
    for i = 1, #encrypted do
        local encByte = string.byte(encrypted, i)
        local keyIndex = ((i - 1) % keyLen) + 1
        local keyByte = string.byte(key, keyIndex)
        insert(result, string.char(bxor(encByte, keyByte) % 256))
    end
    return concat(result)
end

------------------------------
-- INICIALIZAÇÃO DA FLUENT UI
------------------------------
-- Utilizando o link correto da Fluent UI
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Fluent.lua"))()

-- Cria a janela principal do hub
local mainWindow = ui.new({
    Title = "RONY HUB",
    Size = UDim2.new(0, 700, 0, 350)
})
mainWindow:Open()

-- Criação das abas (os métodos podem variar conforme a API da Fluent UI)
local mainTab = mainWindow:NewTab("Principal")
local equipmentTab = mainWindow:NewTab("Equipamentos")
local autoTab = mainWindow:NewTab("Automático")
local miscTab = mainWindow:NewTab("Misto")
local infoTab = mainWindow:NewTab("Informações")

------------------------------
-- RECURSO: KILL AURA
------------------------------
local isKillAuraActive = false
local function killAuraLoop()
    local combatM1 = getRemote({"Remote", "Event", "Combat", "M1"})
    print("KillAura ativado")
    while isKillAuraActive do
        local success, err = pcall(function()
            combatM1:FireServer()
        end)
        if not success then warn("KillAura erro:", err) end
        task.wait(0.1)
    end
    print("KillAura desativado")
end

local function toggleKillAura(enabled)
    isKillAuraActive = enabled
    if isKillAuraActive then task.spawn(killAuraLoop) end
end

local killAuraSwitch = mainTab:AddSwitch("KillAura", toggleKillAura)
killAuraSwitch:Set(false)

------------------------------
-- RECURSO: AUTO BOSS
------------------------------
local bossList = {
    ["Boss 1"] = 1,  ["Boss 2"] = 2,  ["Boss 3"] = 3,  ["Boss 4"] = 4,
    ["Boss 5"] = 5,  ["Boss 6"] = 6,  ["Boss 7"] = 7,  ["Boss 8"] = 8,
    ["Boss 9"] = 9,  ["Boss 10"] = 10, ["Boss 11"] = 11, ["Boss 12"] = 12,
    ["Boss 13"] = 13, ["Boss 14"] = 14, ["Boss 15"] = 15, ["Boss 16"] = 16,
    ["Boss 17"] = 17, ["Boss 18"] = 18, ["Boss 19"] = 19
}
local selectedBoss = bossList["Boss 1"]

local bossDropdown = mainTab:AddDropdown("Selecionar Boss", function(selected)
    selectedBoss = bossList[selected]
    print("Boss selecionado:", selected)
end, {
    Options = (function()
        local names = {}
        for name in pairs(bossList) do table.insert(names, name) end
        table.sort(names, function(a, b) return bossList[a] < bossList[b] end)
        return names
    end)(),
    Tooltip = "Escolha qual boss desafiar automaticamente."
})

local function autoBossLoop()
    local autoBossRemote = getRemote({"Remote", "Event", "Combat", "[C-S]TryChallengeRoom"})
    print("Auto Boss ativado")
    while true do
        local success, err = pcall(function()
            print("Desafiando boss:", selectedBoss)
            autoBossRemote:FireServer(selectedBoss)
        end)
        if not success then warn("Auto Boss erro:", err) end
        task.wait(30)
    end
end

local function toggleAutoBoss(enabled)
    if enabled then
        task.spawn(autoBossLoop)
    else
        print("Auto Boss desativado")
    end
end

local autoBossSwitch = mainTab:AddSwitch("Auto Boss", toggleAutoBoss, {
    Tooltip = "Desafia automaticamente o boss selecionado a cada 30 segundos."
})
autoBossSwitch:Set(false)

------------------------------
-- RECURSO: AUTO RAID
------------------------------
local autoRaidEnabled = false
local tweenService = game:GetService("TweenService")

local function moveToTarget(character, targetPart)
    local targetCFrame = targetPart.CFrame * CFrame.new(0, 0, 5)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = tweenService:Create(character, tweenInfo, { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Wait()
end

local selectedRaid = 1
local raidList = {
    ["Raid 1"] = 1, ["Raid 2"] = 2, ["Raid 3"] = 3,
    ["Raid 4"] = 4, ["Raid 5"] = 5, ["Raid 6"] = 6
}
local raidDropdown = mainTab:AddDropdown("Selecionar Raid", function(selected)
    selectedRaid = raidList[selected]
    print("Raid selecionada:", selected)
end, {
    Options = (function()
        local names = {}
        for name in pairs(raidList) do table.insert(names, name) end
        table.sort(names, function(a, b) return raidList[a] < raidList[b] end)
        return names
    end)(),
    Tooltip = "Escolha qual raid desafiar automaticamente."
})

local function autoRaidLoop()
    print("Auto Raid ativado")
    while autoRaidEnabled do
        local success, err = pcall(function()
            print("Entrando na raid:", selectedRaid)
            local raidRemote = getRemote({"Remote", "Event", "Raid", "[C-S]TryStartRaid"})
            raidRemote:FireServer(selectedRaid)
            task.wait(6)
            
            local player = game.Players.LocalPlayer
            local mobsFolder = workspace.Combats.Mobs:FindFirstChild(player.Name)
            local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            
            if mobsFolder and playerRoot then
                while autoRaidEnabled and mobsFolder:FindFirstChildOfClass("Model") do
                    local bossModel = mobsFolder:FindFirstChildOfClass("Model")
                    if bossModel and bossModel:FindFirstChild("HumanoidRootPart") then
                        print("Boss detectado. Indo para o boss...")
                        moveToTarget(playerRoot, bossModel.HumanoidRootPart)
                    end
                    task.wait(1)
                end
                print("Boss derrotado. Indo para a recompensa.")
                local openChestRemote = getRemote({"Remote", "Event", "Raid", "[C-S]TryOpenChestDrop"})
                openChestRemote:FireServer()
                task.wait(2)
                local leaveRaidRemote = getRemote({"Remote", "Event", "Raid", "[C-S]TryLeaveRaid"})
                leaveRaidRemote:FireServer()
                task.wait(1)
            else
                print("Pasta de combate ou HumanoidRootPart não encontrado. Tentando novamente...")
            end
        end)
        if not success then warn("Auto Raid erro:", err) end
        task.wait(2)
    end
    print("Auto Raid desativado")
end

local function toggleAutoRaid(enabled)
    autoRaidEnabled = enabled
    if autoRaidEnabled then
        task.spawn(autoRaidLoop)
    else
        print("Auto Raid desativado")
    end
end

local autoRaidSwitch = mainTab:AddSwitch("Auto Raid", toggleAutoRaid, {
    Tooltip = "Faz a farm automaticamente na raid selecionada ao entrar, derrotar inimigos e coletar recompensas."
})
autoRaidSwitch:Set(false)

mainTab:AddLabel("Você pode ignorar requisitos de ascensão com isso!", { Color = Color3.new(1, 0, 0) })

------------------------------
-- RECURSO: AUTO DUNGEON
------------------------------
local autoDungeonEnabled = false
local doorSequence = {"0", "1", "Boss"}
local currentDoorIndex = 1

local function getPlayerName() return game.Players.LocalPlayer.Name end

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

local function toggleAutoDungeon(enabled)
    autoDungeonEnabled = enabled
    if autoDungeonEnabled then
        print("Auto Dungeon ativado")
        if not isDungeonAvailable() then
            task.spawn(enterDungeon)
        end
        task.spawn(autoDungeonLoop)
    else
        print("Auto Dungeon desativado")
    end
end

local autoDungeonSwitch = mainTab:AddSwitch("Auto Dungeon", toggleAutoDungeon, {
    Tooltip = "Completa automaticamente as masmorras e aguarda cooldown se necessário."
})
autoDungeonSwitch:Set(false)

mainTab:AddLabel("Use Killaura, tenha paciência :3", { Color = Color3.new(1, 0, 0) })

------------------------------
-- RECURSO: AUTO LUCK ROLL
------------------------------
local autoLuckRollEnabled = false
local function autoLuckRollLoop()
    while autoLuckRollEnabled do
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

local function toggleAutoLuckRoll(enabled)
    autoLuckRollEnabled = enabled
    if autoLuckRollEnabled then task.spawn(autoLuckRollLoop) end
end

local autoLuckRollSwitch = equipmentTab:AddSwitch("Auto Luck Roll", toggleAutoLuckRoll, {
    Tooltip = "Confirma automaticamente os luck rolls a cada 3 segundos."
})
autoLuckRollSwitch:Set(false)

equipmentTab:AddLabel("Reclame qualquer rolagem de recompensa para funcionar!!", { Color = Color3.new(1, 0, 0) })
equipmentTab:AddLabel("Irá igualar a sorte da última rolagem de recompensa reclamada.", { Color = Color3.new(0, 1, 0) })
equipmentTab:AddLabel("Use um ou outro para baixo risco. Acho que ainda pode usar ambos.", { Color = Color3.new(1, 1, 0) })

------------------------------
-- RECURSO: NORMAL AUTO ROLL
------------------------------
local normalAutoRollEnabled = false
local function normalAutoRollLoop()
    print("Normal Auto Roll ativado")
    while normalAutoRollEnabled do
        local success, err = pcall(function()
            local rollRemote = getRemote({"Remote", "Function", "Roll", "[C-S]Roll"})
            rollRemote:InvokeServer()
        end)
        if not success then warn("Normal Auto Roll erro:", err) end
        task.wait(3)
    end
    print("Normal Auto Roll desativado")
end

local function toggleNormalAutoRoll(enabled)
    normalAutoRollEnabled = enabled
    if normalAutoRollEnabled then
        task.spawn(normalAutoRollLoop)
    else
        print("Normal Auto Roll desativado")
    end
end

local normalAutoRollSwitch = equipmentTab:AddSwitch("Normal Auto Roll", toggleNormalAutoRoll, {
    Tooltip = "Rola automaticamente a cada 3 segundos"
})
normalAutoRollSwitch:Set(false)

------------------------------
-- RECURSO: EQUIPAR MELHOR
------------------------------
local equipBestEnabled = false
local function equipBestLoop()
    print("Equipar Melhor ativado")
    while equipBestEnabled do
        local success, err = pcall(function()
            local equipRemote = getRemote({"Remote", "Event", "Backpack", "[C-S]TryEquipBest"})
            equipRemote:FireServer()
        end)
        if not success then warn("Equipar Melhor erro:", err) end
        task.wait(1)
    end
    print("Equipar Melhor desativado")
end

local function toggleEquipBest(enabled)
    equipBestEnabled = enabled
    if equipBestEnabled then
        task.spawn(equipBestLoop)
    else
        print("Equipar Melhor desativado")
    end
end

local equipBestSwitch = equipmentTab:AddSwitch("Equipar Melhor", toggleEquipBest)
equipBestSwitch:Set(false)

------------------------------
-- RECURSO: VENDER TUDO
------------------------------
local autoSellAllEnabled = false
local function performAutoSell()
    print("Venda Automática Iniciada")
    local backpackRemote = getRemote({"Remote", "Function", "Backpack", "[C-S]GetBackpackData"})
    local backpackData = backpackRemote:InvokeServer()
    if type(backpackData) ~= "table" then
        print("Nenhum dado de mochila válido encontrado.")
        return
    end
    local itemsToSell = {}
    for itemId, itemData in pairs(backpackData) do
        if not itemData.locked then
            print("Adicionando item à lista de venda:", itemId)
            itemsToSell[itemId] = true
        else
            print("Ignorando item bloqueado:", itemId)
        end
    end
    if next(itemsToSell) then
        local sellRemote = getRemote({"Remote", "Event", "Backpack", "[C-S]TryDeleteListItem"})
        sellRemote:FireServer(itemsToSell)
        print("Venda Automática acionada para os itens.")
    else
        print("Nenhum item encontrado na mochila para vender.")
    end
end

local function toggleAutoSellAll(enabled)
    autoSellAllEnabled = enabled
    if autoSellAllEnabled then
        print("Venda Automática de Todos ativada")
        task.spawn(function()
            while autoSellAllEnabled do
                pcall(performAutoSell)
                task.wait(7)
            end
        end)
    else
        print("Venda Automática de Todos desativada")
    end
end

local autoSellAllSwitch = equipmentTab:AddSwitch("Vender Tudo", toggleAutoSellAll, {
    Tooltip = "Vende automaticamente todos os itens na sua mochila, excluindo itens bloqueados."
})
autoSellAllSwitch:Set(false)

equipmentTab:AddLabel("Isso irá vender tudo, exceto itens bloqueados!", { Color = Color3.new(1, 0, 0) })

------------------------------
-- RECURSO: AUTO USO DE POÇÕES
------------------------------
-- Poção de Sorte
local autoUseLuckPotionEnabled = false
local function autoUseLuckPotionLoop()
    print("Usar Poção de Sorte ativado")
    while autoUseLuckPotionEnabled do
        local success, err = pcall(function()
            local boostRemote = getRemote({"Remote", "Event", "BoostInv", "[C-S]TryUseBoostRE"})
            boostRemote:FireServer("Luck1.2x")
        end)
        if not success then warn("Erro ao usar Poção de Sorte:", err) end
        task.wait(0.1)
    end
    print("Usar Poção de Sorte desativado")
end

local function toggleAutoUseLuckPotion(enabled)
    autoUseLuckPotionEnabled = enabled
    if autoUseLuckPotionEnabled then
        task.spawn(autoUseLuckPotionLoop)
    else
        print("Usar Poção de Sorte desativado")
    end
end

local autoUseLuckPotionSwitch = autoTab:AddSwitch("Usar Poção de Sorte", toggleAutoUseLuckPotion)
autoUseLuckPotionSwitch:Set(false)

-- Poção de Cooldown
local autoUseCooldownPotionEnabled = false
local function autoUseCooldownPotionLoop()
    print("Usar Poção de Cooldown ativado")
    while autoUseCooldownPotionEnabled do
        local success, err = pcall(function()
            local boostRemote = getRemote({"Remote", "Event", "BoostInv", "[C-S]TryUseBoostRE"})
            boostRemote:FireServer("Roll1.1x")
        end)
        if not success then warn("Erro ao usar Poção de Cooldown:", err) end
        task.wait(0.1)
    end
    print("Usar Poção de Cooldown desativado")
end

local function toggleAutoUseCooldownPotion(enabled)
    autoUseCooldownPotionEnabled = enabled
    if autoUseCooldownPotionEnabled then
        task.spawn(autoUseCooldownPotionLoop)
    else
        print("Usar Poção de Cooldown desativado")
    end
end

local autoUseCooldownPotionSwitch = autoTab:AddSwitch("Usar Poção de Cooldown", toggleAutoUseCooldownPotion)
autoUseCooldownPotionSwitch:Set(false)

-- Poção de Moeda
local autoUseCoinPotionEnabled = false
local function autoUseCoinPotionLoop()
    print("Usar Poção de Moeda ativado")
    while autoUseCoinPotionEnabled do
        local success, err = pcall(function()
            local boostRemote = getRemote({"Remote", "Event", "BoostInv", "[C-S]TryUseBoostRE"})
            boostRemote:FireServer("Coin1.2x")
        end)
        if not success then warn("Erro ao usar Poção de Moeda:", err) end
        task.wait(0.1)
    end
    print("Usar Poção de Moeda desativado")
end

local function toggleAutoUseCoinPotion(enabled)
    autoUseCoinPotionEnabled = enabled
    if autoUseCoinPotionEnabled then
        task.spawn(autoUseCoinPotionLoop)
    else
        print("Usar Poção de Moeda desativado")
    end
end

local autoUseCoinPotionSwitch = autoTab:AddSwitch("Usar Poção de Moeda", toggleAutoUseCoinPotion)
autoUseCoinPotionSwitch:Set(false)

------------------------------
-- RECURSO: MISTO (POÇÃO AUTOMÁTICA SEGURA E AUTO ASCENDER)
------------------------------
-- Poção Automática Segura
local boostTypes = {
    ["Boost de Sorte"] = "Luck1.2x",
    ["Boost de Velocidade de Rolagem"] = "Roll1.1x",
    ["Boost de Moeda"] = "Coin1.2x"
}
local selectedBoost = boostTypes["Boost de Sorte"]

local function getRandomDelay() return math.random(15, 40) end

local function pickUpBoost()
    local success = pcall(function()
        local boostPickupRemote = getRemote({"Remote", "Event", "Boost", "[C-S]PickUpBoost"})
        boostPickupRemote:FireServer(selectedBoost)
    end)
    if success then
        task.wait(getRandomDelay())
    else
        task.wait(60)
    end
end

local safeAutoPotionEnabled = false
local function safeAutoPotionLoop()
    while safeAutoPotionEnabled do
        pickUpBoost()
    end
end

local function toggleSafeAutoPotion(enabled)
    safeAutoPotionEnabled = enabled
    if safeAutoPotionEnabled then task.spawn(safeAutoPotionLoop) end
end

local boostDropdown = miscTab:AddDropdown("Selecionar Boost", function(selected)
    selectedBoost = boostTypes[selected]
end, {
    Options = (function()
        local opts = {}
        for k in pairs(boostTypes) do table.insert(opts, k) end
        return opts
    end)(),
    Tooltip = "Escolha qual boost ativar."
})

local safeAutoPotionSwitch = miscTab:AddSwitch("Poção Automática Segura", toggleSafeAutoPotion, {
    Tooltip = "Pega automaticamente o boost selecionado com intervalos discretos."
})
safeAutoPotionSwitch:Set(false)

miscTab:AddLabel("Evita uso rápido para prevenir detecção! Desculpe, é lento.", { Color = Color3.new(1, 0, 0) })

-- Auto Ascender
local autoAscendEnabled = false
local function autoAscendLoop()
    print("Ascender Automaticamente ativado")
    while autoAscendEnabled do
        local success, err = pcall(function()
            local ascendRemote = getRemote({"Remote", "Event", "Upgrade", "[C-S]TryUpgradeLevel"})
            ascendRemote:FireServer()
        end)
        if not success then warn("Ascender erro:", err) end
        task.wait(5)
    end
    print("Ascender Automaticamente desativado")
end

local function toggleAutoAscend(enabled)
    autoAscendEnabled = enabled
    if autoAscendEnabled then task.spawn(autoAscendLoop) else print("Ascender Automaticamente desativado") end
end

local autoAscendSwitch = miscTab:AddSwitch("Ascender Automaticamente", toggleAutoAscend, {
    Tooltip = "Ascende automaticamente a cada 5 segundos"
})
autoAscendSwitch:Set(false)

miscTab:AddLabel("Não ative muitos recursos ao mesmo tempo, pois você será expulso.", { Color = Color3.new(1, 0, 0) })

------------------------------
-- RECURSO: OCULTAR UI AUTOMATICAMENTE
------------------------------
local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
local openChestGui = playerGui and playerGui:FindFirstChild("OpenChest")
local tipGui = playerGui and playerGui:FindFirstChild("Tip")
if not openChestGui then warn("GUI de OpenChest não encontrada!") end
if not tipGui then warn("GUI de Dicas não encontrada!") end

local function toggleGuiVisibility(visible)
    if openChestGui then openChestGui.Enabled = visible end
    if tipGui then tipGui.Enabled = visible end
end

local autoHideUiEnabled = false
local autoHideUiTask = nil
local function toggleAutoHideUi(enabled)
    autoHideUiEnabled = enabled
    if autoHideUiEnabled then
        autoHideUiTask = task.spawn(function()
            while autoHideUiEnabled do
                toggleGuiVisibility(false)
                task.wait(0.5)
            end
        end)
    else
        if autoHideUiTask then task.cancel(autoHideUiTask) end
        toggleGuiVisibility(true)
    end
end

local autoHideUiSwitch = miscTab:AddSwitch("Ocultar UI Automaticamente", toggleAutoHideUi, {
    Tooltip = "Ative para ocultar automaticamente a GUI de OpenChest e Dicas."
})
autoHideUiSwitch:Set(false)

miscTab:AddLabel("Ative isso para ocultar elementos da UI!", { Color = Color3.new(1, 0, 0) })

------------------------------
-- ABA DE INFORMAÇÕES
------------------------------
infoTab:AddLabel("Contato", { Color = Color3.new(1, 1, 1) })
infoTab:AddLabel("Servidor Discord: https://discord.gg/JhNvSkcmZm", { Color = Color3.new(1, 1, 1) })
infoTab:AddLabel("Por favor, ative suas DMs.", { Color = Color3.new(1, 0, 0) })

print("RONY HUB carregado com sucesso.")
