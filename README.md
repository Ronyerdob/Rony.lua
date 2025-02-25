local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
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
    -- Funções Extras
    Tabs.Main:AddButton({
        Title = "Aumentar Velocidade",
        Callback = function()
            humanoid.WalkSpeed = 50
            Fluent:Notify({ Title = "Velocidade", Content = "Velocidade aumentada para 50.", Duration = 3 })
        end
    })

    Tabs.Main:AddButton({
        Title = "Aumentar Pulo",
        Callback = function()
            humanoid.JumpPower = 100
            Fluent:Notify({ Title = "Pulo", Content = "Altura do pulo aumentada para 100.", Duration = 3 })
        end
    })

    Tabs.Main:AddInput("Nome do Jogador", {
        Title = "Teleporte para Jogador",
        Placeholder = "Digite o nome do jogador",
        Callback = function(Value)
            local targetPlayer = game.Players:FindFirstChild(Value)
            if targetPlayer and targetPlayer.Character then
                character:SetPrimaryPartCFrame(targetPlayer.Character.PrimaryPart.CFrame)
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
                if targetPlayer ~= player and targetPlayer.Character then
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
            flying = not flying
            if flying then
                humanoid.PlatformStand = true
                Fluent:Notify({ Title = "Voo", Content = "Voo ativado.", Duration = 3 })
                while flying do
                    character:MoveTo(character.Position + Vector3.new(0, 1, 0))
                    wait(0.1)
                end
            else
                humanoid.PlatformStand = false
                Fluent:Notify({ Title = "Voo", Content = "Voo desativado.", Duration = 3 })
            end
        end
    })

    -- Notificações e Controles Existentes
    Fluent:Notify({ Title = "Notification", Content = "This is a notification", SubContent = "SubContent", Duration = 5 })

    Tabs.Main:AddParagraph({ Title = "Paragraph", Content = "This is a paragraph.\nSecond line!" })

    Tabs.Main:AddButton({
        Title = "Button",
        Description = "Very important button",
        Callback = function()
            Window:Dialog({
                Title = "Title",
                Content = "This is a dialog",
                Buttons = {
                    { Title = "Confirm", Callback = function() print("Confirmed the dialog.") end },
                    { Title = "Cancel", Callback = function() print("Cancelled the dialog.") end }
                }
            })
        end
    })

    local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "Toggle", Default = false })
    Toggle:OnChanged(function() print("Toggle changed:", Options.MyToggle.Value) end)
    Options.MyToggle:SetValue(false)

    local Slider = Tabs.Main:AddSlider("Slider", {
        Title = "Slider",
        Description = "This is a slider",
        Default = 2,
        Min = 0,
        Max = 5,
        Rounding = 1,
        Callback = function(Value) print("Slider was changed:", Value) end
    })
    Slider:OnChanged(function(Value) print("Slider changed:", Value) end)
    Slider:SetValue(3)

    local Dropdown = Tabs.Main:AddDropdown("Dropdown", {
        Title = "Dropdown",
        Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = false,
        Default = 1,
    })
    Dropdown:SetValue("four")
    Dropdown:OnChanged(function(Value) print("Dropdown changed:", Value) end)

    local MultiDropdown = Tabs.Main:AddDropdown("MultiDropdown", {
        Title = "Dropdown",
        Description = "You can select multiple values.",
        Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = true,
        Default = {"seven", "twelve"},
    })
    MultiDropdown:SetValue({ three = true, five = true, seven = false })
    MultiDropdown:OnChanged(function(Value)
        local Values = {}
        for Value, State in next, Value do
            table.insert(Values, Value)
        end
        print("Mutlidropdown changed:", table.concat(Values, ", "))
    end)

    local Colorpicker = Tabs.Main:AddColorpicker("Colorpicker", { Title = "Colorpicker", Default = Color3.fromRGB(96, 205, 255) })
    Colorpicker:OnChanged(function() print("Colorpicker changed:", Colorpicker.Value) end)
    Colorpicker:SetValueRGB(Color3.fromRGB(0, 255, 140))

    local TColorpicker = Tabs.Main:AddColorpicker("TransparencyColorpicker", {
        Title = "Colorpicker",
        Description = "but you can change the transparency.",
        Transparency = 0,
        Default = Color3.fromRGB(96, 205, 255)
    })
    TColorpicker:OnChanged(function()
        print("TColorpicker changed:", TColorpicker.Value, "Transparency:", TColorpicker.Transparency)
    end)

    local Keybind = Tabs.Main:AddKeybind("Keybind", {
        Title = "KeyBind",
        Mode = "Toggle",
        Default = "LeftControl",
        Callback = function(Value) print("Keybind clicked!", Value) end,
        ChangedCallback = function(New) print("Keybind changed!", New) end
    })
    Keybind:OnClick(function() print("Keybind clicked:", Keybind:GetState()) end)
    Keybind:OnChanged(function() print("Keybind changed:", Keybind.Value) end)

    task.spawn(function()
        while true do
            wait(1)
            local state = Keybind:GetState()
            if state then print("Keybind is being held down") end
            if Fluent.Unloaded then break end
        end
    end)
    Keybind:SetValue("MB2", "Toggle")

    local Input = Tabs.Main:AddInput("Input", {
        Title = "Input",
        Default = "Default",
        Placeholder = "Placeholder",
        Numeric = false,
        Finished = false,
        Callback = function(Value) print("Input changed:", Value) end
    })
    Input:OnChanged(function() print("Input updated:", Input.Value) end)
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
Fluent:Notify({ Title = "Fluent", Content = "O script foi carregado.", Duration = 8 })
SaveManager:LoadAutoloadConfig()
