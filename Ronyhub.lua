-- Tente carregar o módulo Ronyhub e capture erros
local sucesso, erro = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Ronyerdob/Rony.lua/main/Ronyhub.lua"))()
end)

-- Verifique se houve sucesso ou erro ao carregar o script
if sucesso then
    print("Ronyhub carregado com sucesso.")
else
    print("Erro ao carregar Ronyhub:", erro)
end

-- Carregar Fluent e gerenciadores
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Inicializar a interface Fluent
local Window = Fluent:CreateWindow({
    Title = "Universal Script",
    SubTitle = "Integrado com Ronyhub",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    -- Exemplo de funcionalidades universais
    Tabs.Main:AddButton({
        Title = "Aumentar Velocidade",
        Callback = function()
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 50
                Fluent:Notify({ Title = "Velocidade", Content = "Velocidade aumentada para 50.", Duration = 3 })
            end
        end
    })

    Tabs.Main:AddButton({
        Title = "Aumentar Pulo",
        Callback = function()
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 100
                Fluent:Notify({ Title = "Pulo", Content = "Altura do pulo aumentada para 100.", Duration = 3 })
            end
        end
    })

    Tabs.Main:AddInput("Nome do Jogador", {
        Title = "Teleporte para Jogador",
        Placeholder = "Digite o nome do jogador",
        Callback = function(Value)
            local targetPlayer = game.Players:FindFirstChild(Value)
            if targetPlayer and targetPlayer.Character then
                game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(targetPlayer.Character.PrimaryPart.CFrame)
                Fluent:Notify({ Title = "Teleporte", Content = "Teleportado para " .. Value, Duration = 3 })
            else
                Fluent:Notify({ Title = "Erro", Content = "Jogador não encontrado.", Duration = 3 })
            end
        end
    })

    Tabs.Main:AddButton({
        Title = "Ativar ESP",
        Callback = function()
            for _, targetPlayer in pairs(game.Players:GetPlayers()) do
                if targetPlayer ~= game.Players.LocalPlayer and targetPlayer.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = targetPlayer.Character
                end
            end
            Fluent:Notify({ Title = "ESP", Content = "ESP ativado.", Duration = 3 })
        end
    })

    local flying = false
    Tabs.Main:AddButton({
        Title = "Ativar/Desativar Voo",
        Callback = function()
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                flying = not flying
                if flying then
                    humanoid.PlatformStand = true
                    Fluent:Notify({ Title = "Voo", Content = "Voo ativado.", Duration = 3 })
                    while flying do
                        game.Players.LocalPlayer.Character:MoveTo(game.Players.LocalPlayer.Character.Position + Vector3.new(0, 1, 0))
                        wait(0.1)
                    end
                else
                    humanoid.PlatformStand = false
                    Fluent:Notify({ Title = "Voo", Content = "Voo desativado.", Duration = 3 })
                end
            end
        end
    })
end

-- Configurações e inicialização do Fluent
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("UniversalScriptHub")
SaveManager:SetFolder("UniversalScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
Fluent:Notify({ Title = "Universal Script", Content = "O script foi carregado.", Duration = 8 })
SaveManager:LoadAutoloadConfig()
