-- RONY HUB

-- Funções de manipulação de strings
local char = string.char
local byte = string.byte
local sub = string.sub
local bit_lib = bit32 or bit
local bxor = bit_lib.bxor
local concat = table.concat
local insert = table.insert

-- Função de descriptografia
local function decrypt(encrypted, key)
    local result = {}
    for i = 1, #encrypted do
        insert(result, char(bxor(byte(sub(encrypted, i, i + 1)), byte(sub(key, 1 + (i % #key), 1 + (i % #key) + 1))) % 256))
    end
    return concat(result)
end

-- Carregar biblioteca de UI
local ui = loadstring(game:HttpGet('https://raw.githubusercontent.com/Singularity5490/rbimgui-2/main/rbimgui-2.lua'))()
local mainWindow = ui.new({
    text = 'RONY HUB',
    size = UDim2.new(0, 700, 0, 350)
})
mainWindow.open()

-- Aba principal
local mainTab = mainWindow.new({
    text = 'Principal',
    padding = Vector2.new(10, 10)
})

-- Recurso KillAura
local killAuraEnabled = false
local function toggleKillAura(enabled)
    killAuraEnabled = enabled
    if killAuraEnabled then
        print('KillAura ativado')
        while killAuraEnabled do
            pcall(function()
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('Combat'):WaitForChild('M1'):FireServer()
            end)
            wait(0.1)
        end
    else
        print('KillAura desativado')
    end
end

local killAuraSwitch = mainTab.new('switch', {
    text = 'KillAura'
})
killAuraSwitch.set(false)
killAuraSwitch.event:Connect(toggleKillAura)

-- Seleção de Boss
local bossList = {
    ['Boss 1'] = 1,
    ['Boss 2'] = 2,
    ['Boss 3'] = 3,
    ['Boss 4'] = 4,
    ['Boss 5'] = 5,
    ['Boss 6'] = 6,
    ['Boss 7'] = 7,
    ['Boss 8'] = 8,
    ['Boss 9'] = 9,
    ['Boss 10'] = 10,
    ['Boss 11'] = 11,
    ['Boss 12'] = 12,
    ['Boss 13'] = 13,
    ['Boss 14'] = 14,
    ['Boss 15'] = 15,
    ['Boss 16'] = 16,
    ['Boss 17'] = 17,
    ['Boss 18'] = 18,
    ['Boss 19'] = 19
}
local selectedBoss = bossList['Boss 1']
local bossDropdown = mainTab.new('dropdown', {
    text = 'Selecionar Boss',
    tooltip = 'Escolha qual boss desafiar automaticamente.'
})

local sortedBossList = {}
for bossName in pairs(bossList) do
    table.insert(sortedBossList, bossName)
end
table.sort(sortedBossList, function(a, b)
    return bossList[a] < bossList[b]
end)

for _, bossName in ipairs(sortedBossList) do
    bossDropdown.new(bossName)
end

bossDropdown.event:Connect(function(selected)
    selectedBoss = bossList[selected]
    print('Boss selecionado:', selected)
end)

-- Recurso Auto Boss
local autoBossEnabled = false
local function toggleAutoBoss(enabled)
    autoBossEnabled = enabled
    local player = game.Players.LocalPlayer
    
    if autoBossEnabled then
        while autoBossEnabled do
            pcall(function()
                print('Desafiando boss:', selectedBoss)
                local args = {
                    [1] = selectedBoss
                }
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('Combat'):WaitForChild('[C-S]TryChallengeRoom'):FireServer(unpack(args))
                wait(30)
            end)
        end
    end
end

local autoBossSwitch = mainTab.new('switch', {
    text = 'Auto Boss',
    tooltip = 'Desafia automaticamente o boss selecionado a cada 30 segundos.'
})
autoBossSwitch.set(false)
autoBossSwitch.event:Connect(toggleAutoBoss)

mainTab.new('label', {
    text = 'Certifique-se de estar pronto antes de ativar o auto boss!',
    color = Color3.new(1, 0, 0)
})

-- Seleção de Raid
local raidList = {
    ['Raid 1'] = 1,
    ['Raid 2'] = 2,
    ['Raid 3'] = 3,
    ['Raid 4'] = 4,
    ['Raid 5'] = 5,
    ['Raid 6'] = 6
}
local selectedRaid = raidList['Raid 1']
local raidDropdown = mainTab.new('dropdown', {
    text = 'Selecionar Raid',
    tooltip = 'Escolha qual raid desafiar automaticamente.'
})

local sortedRaidList = {}
for raidName in pairs(raidList) do
    table.insert(sortedRaidList, raidName)
end
table.sort(sortedRaidList, function(a, b)
    return raidList[a] < raidList[b]
end)

for _, raidName in ipairs(sortedRaidList) do
    raidDropdown.new(raidName)
end

raidDropdown.event:Connect(function(selected)
    selectedRaid = raidList[selected]
    print('Raid selecionada:', selected)
end)

-- Recurso Auto Raid
local autoRaidEnabled = false
local tweenService = game:GetService('TweenService')

local function moveToTarget(character, target)
    local targetCFrame = target.CFrame * CFrame.new(0, 0, 5)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = tweenService:Create(character, tweenInfo, {
        CFrame = targetCFrame
    })
    tween:Play()
    tween.Completed:Wait()
end

local function toggleAutoRaid(enabled)
    autoRaidEnabled = enabled
    local player = game.Players.LocalPlayer
    
    if autoRaidEnabled then
        print('Auto Raid ativado')
        while autoRaidEnabled do
            pcall(function()
                print('Entrando na raid:', selectedRaid)
                local args = {
                    [1] = selectedRaid
                }
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('Raid'):WaitForChild('[C-S]TryStartRaid'):FireServer(unpack(args))
                wait(6)
                
                local mobsFolder = workspace.Combats.Mobs:FindFirstChild(player.Name)
                local playerRoot = player.Character and player.Character:FindFirstChild('HumanoidRootPart')
                
                if mobsFolder and playerRoot then
                    while autoRaidEnabled and mobsFolder:FindFirstChildOfClass('Model') do
                        local boss = mobsFolder:FindFirstChildOfClass('Model')
                        if boss and boss:FindFirstChild('HumanoidRootPart') then
                            print('Boss detectado. Indo para o boss...')
                            moveToTarget(playerRoot, boss.HumanoidRootPart)
                        end
                        wait(1)
                    end
                    print('Boss derrotado. Indo para a recompensa.')
                    print('Abrindo recompensa da raid.')
                    game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('Raid'):WaitForChild('[C-S]TryOpenChestDrop'):FireServer()
                    wait(2)
                    print('Saindo da raid.')
                    game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('Raid'):WaitForChild('[C-S]TryLeaveRaid'):FireServer()
                    wait(1)
                else
                    print('Pasta de combate ou HumanoidRootPart não encontrado. Tentando novamente...')
                end
            end)
            wait(2)
        end
    else
        print('Auto Raid desativado')
    end
end

local autoRaidSwitch = mainTab.new('switch', {
    text = 'Auto Raid',
    tooltip = 'Faz a farm automaticamente na raid selecionada ao entrar, derrotar inimigos e coletar recompensas.'
})
autoRaidSwitch.set(false)
autoRaidSwitch.event:Connect(toggleAutoRaid)

mainTab.new('label', {
    text = 'Você pode ignorar requisitos de ascensão com isso!',
    color = Color3.new(1, 0, 0)
})

-- Variáveis de masmorra
local autoDungeonEnabled = false
local doorSequence = {
    "0",
    "1",
    'Boss'
}
local currentDoorIndex = 1

local function getPlayerName()
    return game.Players.LocalPlayer.Name
end

local function isDungeonAvailable()
    local playerName = getPlayerName()
    local dungeonsFolder = workspace:FindFirstChild('Dungeons')
    return (dungeonsFolder and dungeonsFolder:FindFirstChild(playerName)) or false
end

local function hasEnemiesInCombat()
    local combatsFolder = workspace:FindFirstChild('Combats')
    local playerName = getPlayerName()
    
    if combatsFolder and combatsFolder:FindFirstChild(playerName) then
        for _, enemy in pairs(combatsFolder[playerName]:GetChildren()) do
            if enemy:IsA('Model') and enemy:FindFirstChild('Humanoid') and enemy.Humanoid.Health > 0 then
                return true
            end
        end
    end
    return false
end

local function moveToNextDoor()
    local playerName = getPlayerName()
    local dungeonsFolder = workspace:FindFirstChild('Dungeons')
    
    if not dungeonsFolder then
        warn('Pasta de masmorras não encontrada!')
        return
    end
    
    local playerDungeon = dungeonsFolder:FindFirstChild(playerName)
    if not playerDungeon then
        warn('Masmorra do jogador não encontrada!')
        return
    end
    
    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
    local targetDoorName = doorSequence[currentDoorIndex]
    
    local targetDoor = playerDungeon.Door:FindFirstChild(targetDoorName) or playerDungeon:FindFirstChild('Boss')
    if targetDoor and targetDoor:FindFirstChild('Part') then
        humanoidRootPart.CFrame = targetDoor.Part.CFrame
        currentDoorIndex = (currentDoorIndex % #doorSequence) + 1
    else
        warn('Parte da porta alvo não encontrada: ' .. targetDoorName)
    end
end

local function autoDungeonLoop()
    while autoDungeonEnabled do
        if isDungeonAvailable() then
            while hasEnemiesInCombat() and autoDungeonEnabled do
                wait(1)
            end
            wait(3)
            pcall(moveToNextDoor)
        end
        wait(1)
    end
end

local function enterDungeon()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
    
    if not humanoidRootPart then
        warn('HumanoidRootPart não encontrado!')
        return
    end
    
    humanoidRootPart.CFrame = CFrame.new(428.5999999999999, 148.61, 88.82)
    
    while autoDungeonEnabled and not isDungeonAvailable() do
        wait(5)
        local virtualInputManager = game:GetService('VirtualInputManager')
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        wait(0.1)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        
        if isDungeonAvailable() then
            break
        end
    end
end

local function toggleAutoDungeon(enabled)
    autoDungeonEnabled = enabled
    local player = game.Players.LocalPlayer
    
    if autoDungeonEnabled then
        print('Auto Dungeon ativado')
        if not isDungeonAvailable() then
            task.spawn(enterDungeon)
        end
        task.spawn(autoDungeonLoop)
    else
        print('Auto Dungeon desativado')
    end
end

local autoDungeonSwitch = mainTab.new('switch', {
    text = 'Auto Dungeon',
    tooltip = 'Completa automaticamente as masmorras e aguarda cooldown se necessário.'
})
autoDungeonSwitch.set(false)
autoDungeonSwitch.event:Connect(toggleAutoDungeon)

mainTab.new('label', {
    text = 'Use Killaura, tenha paciência :3',
    color = Color3.new(1, 0, 0)
})

-- Aba de Equipamentos
local equipmentTab = mainWindow.new({
    text = 'Equipamentos',
    padding = Vector2.new(10, 10)
})

-- Recurso Auto Luck Roll
local autoLuckRollEnabled = false

local function autoLuckRollLoop()
    while autoLuckRollEnabled do
        wait(3)
        local success, error = pcall(function()
            game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('LuckRoll'):WaitForChild('[C-S]ConfirmLuckRoll'):FireServer()
        end)
        
        if not success then
            warn('Erro ao confirmar Luck Roll:', error)
            wait(10)
        end
    end
end

local function toggleAutoLuckRoll(enabled)
    autoLuckRollEnabled = enabled
    if autoLuckRollEnabled then
        autoLuckRollLoop()
    end
end

local autoLuckRollSwitch = equipmentTab.new('switch', {
    text = 'Auto Luck Roll',
    tooltip = 'Confirma automaticamente os luck rolls a cada 3 segundos.'
})
autoLuckRollSwitch.set(false)
autoLuckRollSwitch.event:Connect(toggleAutoLuckRoll)

equipmentTab.new('label', {
    text = 'Reclame qualquer rolagem de recompensa para funcionar!!',
    color = Color3.new(1, 0, 0)
})

equipmentTab.new('label', {
    text = 'Irá igualar a sorte da última rolagem de recompensa reclamada.',
    color = Color3.new(0, 1, 0)
})

equipmentTab.new('label', {
    text = 'Use um ou outro para baixo risco. Acho que ainda pode usar ambos.',
    color = Color3.new(1, 1, 0)
})

-- Recurso Normal Auto Roll
local normalAutoRollEnabled = false

local function toggleNormalAutoRoll(enabled)
    normalAutoRollEnabled = enabled
    if normalAutoRollEnabled then
        print('Normal Auto Roll ativado')
        while normalAutoRollEnabled do
            pcall(function()
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Function'):WaitForChild('Roll'):WaitForChild('[C-S]Roll'):InvokeServer()
            end)
            wait(3)
        end
    else
        print('Normal Auto Roll desativado')
    end
end

local normalAutoRollSwitch = equipmentTab.new('switch', {
    text = 'Normal Auto Roll',
    tooltip = 'Rola automaticamente a cada 3 segundos'
})
normalAutoRollSwitch.set(false)
normalAutoRollSwitch.event:Connect(toggleNormalAutoRoll)

-- Recurso Equipar Melhor
local equipBestEnabled = false

local function toggleEquipBest(enabled)
    equipBestEnabled = enabled
    if equipBestEnabled then
        print('Equipar Melhor ativado')
        while equipBestEnabled do
            pcall(function()
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('Backpack'):WaitForChild('[C-S]TryEquipBest'):FireServer()
            end)
            wait(1)
        end
    else
        print('Equipar Melhor desativado')
    end
end

local equipBestSwitch = equipmentTab.new('switch', {
    text = 'Equipar Melhor'
})
equipBestSwitch.set(false)
equipBestSwitch.event:Connect(toggleEquipBest)

-- Recurso Vender Tudo
local autoSellAllEnabled = false

local function performAutoSell()
    print('Venda Automática Iniciada')
    local backpackData = game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Function'):WaitForChild('Backpack'):WaitForChild('[C-S]GetBackpackData'):InvokeServer()
    
    if not backpackData or type(backpackData) ~= 'table' then
        print('Nenhum dado de mochila válido encontrado.')
        return
    end
    
    local itemsToSell = {}
    for itemId, itemData in pairs(backpackData) do
        if itemData.locked then
            print('Ignorando item bloqueado:', itemId, itemData)
        else
            print('Adicionando item à lista de venda:', itemId, itemData)
            itemsToSell[itemId] = true
        end
    end
    
    if next(itemsToSell) then
        local args = {
            [1] = itemsToSell
        }
        game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('Backpack'):WaitForChild('[C-S]TryDeleteListItem'):FireServer(unpack(args))
        print('Venda Automática acionada para os itens:', itemsToSell)
    else
        print('Nenhum item encontrado na mochila para vender.')
    end
end

local function toggleAutoSellAll(enabled)
    autoSellAllEnabled = enabled
    if autoSellAllEnabled then
        print('Venda Automática de Todos ativada')
        while autoSellAllEnabled do
            pcall(performAutoSell)
            wait(7)
        end
    else
        print('Venda Automática de Todos desativada')
    end
end

local autoSellAllSwitch = equipmentTab.new('switch', {
    text = 'Vender Tudo',
    tooltip = 'Vende automaticamente todos os itens na sua mochila, excluindo itens bloqueados.'
})
autoSellAllSwitch.set(false)
autoSellAllSwitch.event:Connect(toggleAutoSellAll)

equipmentTab.new('label', {
    text = 'Isso irá vender tudo, exceto itens bloqueados!',
    color = Color3.new(1, 0, 0)
})

-- Aba Automática
local autoTab = mainWindow.new({
    text = 'Automático',
    padding = Vector2.new(10, 10)
})

-- Recurso Usar Poção de Sorte
local autoUseLuckPotionEnabled = false

local function toggleAutoUseLuckPotion(enabled)
    autoUseLuckPotionEnabled = enabled
    if autoUseLuckPotionEnabled then
        print('Usar Poção de Sorte ativado')
        while autoUseLuckPotionEnabled do
            pcall(function()
                local args = {
                    [1] = 'Luck1.2x'
                }
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('BoostInv'):WaitForChild('[C-S]TryUseBoostRE'):FireServer(unpack(args))
            end)
            wait(0.1)
        end
    else
        print('Usar Poção de Sorte desativado')
    end
end

local autoUseLuckPotionSwitch = autoTab.new('switch', {
    text = 'Usar Poção de Sorte'
})
autoUseLuckPotionSwitch.set(false)
autoUseLuckPotionSwitch.event:Connect(toggleAutoUseLuckPotion)

-- Recurso Usar Poção de Cooldown
local autoUseCooldownPotionEnabled = false

local function toggleAutoUseCooldownPotion(enabled)
    autoUseCooldownPotionEnabled = enabled
    if autoUseCooldownPotionEnabled then
        print('Usar Poção de Cooldown ativado')
        while autoUseCooldownPotionEnabled do
            pcall(function()
                local args = {
                    [1] = 'Roll1.1x'
                }
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('BoostInv'):WaitForChild('[C-S]TryUseBoostRE'):FireServer(unpack(args))
            end)
            wait(0.1)
        end
    else
        print('Usar Poção de Cooldown desativado')
    end
end

local autoUseCooldownPotionSwitch = autoTab.new('switch', {
    text = 'Usar Poção de Cooldown'
})
autoUseCooldownPotionSwitch.set(false)
autoUseCooldownPotionSwitch.event:Connect(toggleAutoUseCooldownPotion)

-- Recurso Usar Poção de Moeda
local autoUseCoinPotionEnabled = false

local function toggleAutoUseCoinPotion(enabled)
    autoUseCoinPotionEnabled = enabled
    if autoUseCoinPotionEnabled then
        print('Usar Poção de Moeda ativado')
        while autoUseCoinPotionEnabled do
            pcall(function()
                local args = {
                    [1] = 'Coin1.2x'
                }
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('BoostInv'):WaitForChild('[C-S]TryUseBoostRE'):FireServer(unpack(args))
            end)
            wait(0.1)
        end
    else
        print('Usar Poção de Moeda desativado')
    end
end

local autoUseCoinPotionSwitch = autoTab.new('switch', {
    text = 'Usar Poção de Moeda'
})
autoUseCoinPotionSwitch.set(false)
autoUseCoinPotionSwitch.event:Connect(toggleAutoUseCoinPotion)

-- Aba Mista
local miscTab = mainWindow.new({
    text = 'Misto',
    padding = Vector2.new(10, 10)
})

-- Recurso Poção Automática Segura
local boostTypes = {
    ['Boost de Sorte'] = 'Luck1.2x',
    ['Boost de Velocidade de Rolagem'] = 'Roll1.1x',
    ['Boost de Moeda'] = 'Coin1.2x'
}
local selectedBoost = boostTypes['Boost de Sorte']

local function getRandomDelay()
    return math.random(15, 40)
end

local function pickUpBoost()
    local success = pcall(function()
        game.ReplicatedStorage.Remote.Event.Boost['[C-S]PickUpBoost']:FireServer(selectedBoost)
    end)
    
    if success then
        wait(getRandomDelay())
    else
        wait(60)
    end
end

local safeAutoPotionEnabled = false

local function toggleSafeAutoPotion(enabled)
    safeAutoPotionEnabled = enabled
    while safeAutoPotionEnabled do
        pickUpBoost()
    end
end

local boostDropdown = miscTab.new('dropdown', {
    text = 'Selecionar Boost',
    tooltip = 'Escolha qual boost ativar.'
})

for boostName, _ in pairs(boostTypes) do
    boostDropdown.new(boostName)
end

boostDropdown.event:Connect(function(selected)
    selectedBoost = boostTypes[selected]
end)

local safeAutoPotionSwitch = miscTab.new('switch', {
    text = 'Poção Automática Segura',
    tooltip = 'Pega automaticamente o boost selecionado com intervalos discretos.'
})
safeAutoPotionSwitch.set(false)
safeAutoPotionSwitch.event:Connect(toggleSafeAutoPotion)

miscTab.new('label', {
    text = 'Evita uso rápido para prevenir detecção! Desculpe, é lento.',
    color = Color3.new(1, 0, 0)
})

-- Recurso Ascender Automaticamente
local autoAscendEnabled = false

local function toggleAutoAscend(enabled)
    autoAscendEnabled = enabled
    if autoAscendEnabled then
        print('Ascender Automaticamente ativado')
        while autoAscendEnabled do
            pcall(function()
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('Upgrade'):WaitForChild('[C-S]TryUpgradeLevel'):FireServer()
            end)
            wait(5)
        end
    else
        print('Ascender Automaticamente desativado')
    end
end

local autoAscendSwitch = miscTab.new('switch', {
    text = 'Ascender Automaticamente',
    tooltip = 'Ascende automaticamente a cada 5 segundos'
})
autoAscendSwitch.set(false)
autoAscendSwitch.event:Connect(toggleAutoAscend)

miscTab.new('label', {
    text = "Não ative muitos recursos ao mesmo tempo, pois você será expulso.",
    color = Color3.new(1, 0, 0)
})

-- Recurso Ocultar UI Automaticamente
local playerGui = game:GetService('Players').LocalPlayer:FindFirstChild('PlayerGui')
local openChestGui = playerGui:FindFirstChild('OpenChest')
local tipGui = playerGui:FindFirstChild('Tip')

if not openChestGui then
    warn('GUI de OpenChest não encontrada!')
end
if not tipGui then
    warn('GUI de Dicas não encontrada!')
end

local function toggleGuiVisibility(visible)
    if openChestGui then
        openChestGui.Enabled = visible
    end
    if tipGui then
        tipGui.Enabled = visible
    end
end

local autoHideUiEnabled = false
local autoHideUiTask

local function toggleAutoHideUi(enabled)
    autoHideUiEnabled = enabled
    if autoHideUiEnabled then
        autoHideUiTask = task.spawn(function()
            while autoHideUiEnabled do
                toggleGuiVisibility(false)
                wait(0.5)
            end
        end)
    else
        if autoHideUiTask then
            task.cancel(autoHideUiTask)
            autoHideUiTask = nil
        end
        toggleGuiVisibility(true)
    end
end

local autoHideUiSwitch = miscTab.new('switch', {
    text = 'Ocultar UI Automaticamente',
    tooltip = 'Ative para ocultar automaticamente a GUI de OpenChest e Dicas.'
})
autoHideUiSwitch.set(false)
autoHideUiSwitch.event:Connect(toggleAutoHideUi)

miscTab.new('label', {
    text = 'Ative isso para ocultar elementos da UI!',
    color = Color3.new(1, 0, 0)
})

print('RONY HUB carregado com sucesso.')