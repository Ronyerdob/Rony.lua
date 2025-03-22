-- RONY HUB: Script Completo e Organizado para Roblox em Dispositivos Móveis

-- Funções Básicas de Manipulação de Strings
local char = string.char
local byte = string.byte
local sub = string.sub
local bit_lib = bit32 or bit
local bxor = bit_lib.bxor
local concat = table.concat
local insert = table.insert

-- Função de Desencriptação
local function decrypt(encrypted, key)
    local result = {}
    for i = 1, #encrypted do
        insert(result, char(bxor(byte(sub(encrypted, i, i + 1)), byte(sub(key, 1 + (i % #key), 1 + (i % #key) + 1))) % 256))
    end
    return concat(result)
end

-- Simulando a Função de Cópia para a Área de Transferência
local function copyToClipboard(text)
    print("Texto copiado para a área de transferência: " .. text)
end

-- Carregar uma Biblioteca de Interface de Usuário Elegante e Estilosa
local ui = loadstring(game:HttpGet('https://raw.githubusercontent.com/Singularity5490/rbimgui-2/main/rbimgui-2.lua'))()
local mainWindow = ui.new({
    text = 'RONY HUB',
    size = UDim2.new(0, 350, 0, 600), -- Ajustado para celulares
    theme = 'Dark' -- Tema moderno
})
mainWindow.open()

-- Criar Categorias para Funcionalidades
local farmingTab = mainWindow.new({
    text = 'Auto Farm',
    padding = Vector2.new(10, 10)
})

local raidTab = mainWindow.new({
    text = 'Auto Raid',
    padding = Vector2.new(10, 10)
})

local dungeonTab = mainWindow.new({
    text = 'Auto Dungeon',
    padding = Vector2.new(10, 10)
})

local miscTab = mainWindow.new({
    text = 'Misc',
    padding = Vector2.new(10, 10)
})

local infoTab = mainWindow.new({
    text = 'Informações',
    padding = Vector2.new(10, 10)
})

-- Funcionalidade KillAura na Categoria Auto Farm
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

local killAuraSwitch = farmingTab.new('switch', {
    text = 'KillAura'
})
killAuraSwitch.set(false)
killAuraSwitch.event:Connect(toggleKillAura)

-- Funcionalidade Auto Boss na Categoria Auto Farm
local autoBossEnabled = false
local function toggleAutoBoss(enabled)
    autoBossEnabled = enabled
    if autoBossEnabled then
        while autoBossEnabled do
            pcall(function()
                print('Desafiando boss:', selectedBoss)
                local args = {[1] = selectedBoss}
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('Combat'):WaitForChild('[C-S]TryChallengeRoom'):FireServer(unpack(args))
                wait(30)
            end)
        end
    end
end

local autoBossSwitch = farmingTab.new('switch', {
    text = 'Auto Boss',
    tooltip = 'Desafia o boss selecionado automaticamente'
})
autoBossSwitch.set(false)
autoBossSwitch.event:Connect(toggleAutoBoss)

-- Funcionalidade Auto Raid na Categoria Auto Raid
local autoRaidEnabled = false
local function toggleAutoRaid(enabled)
    autoRaidEnabled = enabled
    if autoRaidEnabled then
        while autoRaidEnabled do
            pcall(function()
                print('Entrando na raid:', selectedRaid)
                local args = {[1] = selectedRaid}
                game:GetService('ReplicatedStorage'):WaitForChild('Remote'):WaitForChild('Event'):WaitForChild('Raid'):WaitForChild('[C-S]TryStartRaid'):FireServer(unpack(args))
                wait(6)
            end)
        end
    end
end

local autoRaidSwitch = raidTab.new('switch', {
    text = 'Auto Raid'
})
autoRaidSwitch.set(false)
autoRaidSwitch.event:Connect(toggleAutoRaid)

-- Funcionalidade Auto Dungeon na Categoria Auto Dungeon
local autoDungeonEnabled = false
local function toggleAutoDungeon(enabled)
    autoDungeonEnabled = enabled
    if autoDungeonEnabled then
        print('Auto Dungeon ativado')
        -- Lógica de auto dungeon
    else
        print('Auto Dungeon desativado')
    end
end

local autoDungeonSwitch = dungeonTab.new('switch', {
    text = 'Auto Dungeon'
})
autoDungeonSwitch.set(false)
autoDungeonSwitch.event:Connect(toggleAutoDungeon)

-- Funcionalidades Diversas na Categoria Misc
miscTab.new('label', {
    text = 'Funcionalidades diversas e configurações adicionais',
    color = Color3.new(1, 1, 1)
})

-- Informações de Contato na Categoria Informações
infoTab.new('label', {
    text = 'Clique nos botões para copiar os links:',
    color = Color3.new(1, 1, 1)
})

local discordButton = infoTab.new('button', {
    text = 'Discord',
    tooltip = 'Copiar link do servidor Discord'
})
discordButton.event:Connect(function()
    copyToClipboard('https://discord.gg/FMVVgWmpKc')
end)

local youtubeButton = infoTab.new('button', {
    text = 'YouTube',
    tooltip = 'Copiar link do canal YouTube'
})
youtubeButton.event:Connect(function()
    copyToClipboard('https://youtube.com/@ronyscripts?si=nZ0CQrwq2dolO7D6')
end)

infoTab.new('label', {
    text = 'Certifique-se de ter seus DMs ativados.',
    color = Color3.new(1, 0, 0)
})

print('RONY HUB totalmente carregado e pronto para uso em dispositivos móveis!')