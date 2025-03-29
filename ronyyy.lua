--[[
  Anime Battle Rony Hub - Wize Style + Botão Flutuante (Final)
  Inclui:
   - Power Click, Auto Reset, Giro Automático, Girar Ovos do Evento, Black Screen
   - Girar Ovo Mundo Magma, Girar Ovos Mundo 6
   - Interface estilo "Wize Hub" (700×420) c/ top bar e sidebar
   - Botão "X" para fechar
   - Botão flutuante (arrastável) que minimiza/restaura a janela
]]

-----------------------------
-- SERVIÇOS E VARIÁVEIS
-----------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variáveis de controle das funcionalidades
local powerClickEnabled = false
local autoResetEnabled = false
local autoWheelEnabled = false
local autoEggEnabled = false
local autoMagmaEgg = false
local autoOverseerEgg = false

-- Referência ao RemoteFunction
local remoteFunction = ReplicatedStorage:WaitForChild("Common")
    :WaitForChild("Library")
    :WaitForChild("Network")
    :WaitForChild("RemoteFunction")

-----------------------------
-- FUNÇÕES REMOTAS
-----------------------------
local function doPowerClick()
    remoteFunction:InvokeServer("S_Power_Click", {Vector3.new(-5590.44, -184.83, 1611.095)})
end

local function doAutoReset()
    remoteFunction:InvokeServer("S_Rebirth_Request", {})
end

local function doWheelSpinCombined()
    remoteFunction:InvokeServer("S_Wheel_Spin_Request", {})
    remoteFunction:InvokeServer("S_Wheel_Spin_Confirm", {"5d2f00d9-bd43-41f7-86bb-054d4a51de65"})
end

local function doEggOpen()
    -- Gira 3 e depois 1 do "100K_Egg"
    remoteFunction:InvokeServer("S_Egg_Open_3", {"100K_Egg"})
    remoteFunction:InvokeServer("S_Egg_Open_1", {"100K_Egg"})
end

local function doMagmaEgg()
    remoteFunction:InvokeServer("S_Egg_Open_1", {"Magma_Egg"})
end

local function doOverseerEgg()
    remoteFunction:InvokeServer("S_Egg_Open_1", {"Overseer_Egg"})
end

-----------------------------
-- LOOPS DE EXECUÇÃO INFINITA
-----------------------------
task.spawn(function()
    while true do
        if powerClickEnabled then
            doPowerClick()
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if autoResetEnabled then
            doAutoReset()
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if autoWheelEnabled then
            doWheelSpinCombined()
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if autoEggEnabled then
            doEggOpen()
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if autoMagmaEgg then
            doMagmaEgg()
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if autoOverseerEgg then
            doOverseerEgg()
        end
        task.wait()
    end
end)

-----------------------------
-- BLACK SCREEN (Overlay)
-----------------------------
local BlackScreenGUI = Instance.new("ScreenGui")
BlackScreenGUI.Name = "BlackScreenGUI"
BlackScreenGUI.Parent = PlayerGui
BlackScreenGUI.ResetOnSpawn = false
BlackScreenGUI.DisplayOrder = 1  -- Fica atrás da interface

local BlackScreenFrame = Instance.new("Frame")
BlackScreenFrame.Name = "BlackScreenFrame"
BlackScreenFrame.Parent = BlackScreenGUI
BlackScreenFrame.Size = UDim2.new(3, 0, 3, 0)
BlackScreenFrame.Position = UDim2.new(-1, 0, -1, 0)
BlackScreenFrame.BackgroundColor3 = Color3.new(0, 0, 0)
BlackScreenFrame.Visible = false

-----------------------------
-- SCRIPT GUI (Wize Style)
-----------------------------
local ScriptGUI = Instance.new("ScreenGui")
ScriptGUI.Name = "WizeStyleHubGUI"
ScriptGUI.Parent = PlayerGui
ScriptGUI.ResetOnSpawn = false
ScriptGUI.DisplayOrder = 2  -- Acima do BlackScreenGUI

-----------------------------
-- FUNÇÃO createToggle
-----------------------------
local function createToggle(parent, toggleName, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = toggleName .. "Toggle"
    toggleFrame.Parent = parent
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 1

    local corner = Instance.new("UICorner", toggleFrame)
    corner.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Name = "ToggleLabel"
    label.Parent = toggleFrame
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = toggleName .. " Off"
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2

    local switch = Instance.new("Frame")
    switch.Name = "Switch"
    switch.Parent = toggleFrame
    switch.Size = UDim2.new(0, 40, 0, 20)
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -10, 0.5, 0)
    switch.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    switch.BorderSizePixel = 0
    switch.ZIndex = 3

    local switchCorner = Instance.new("UICorner", switch)
    switchCorner.CornerRadius = UDim.new(0, 10)

    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Parent = switch
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 1, 0, 1)
    circle.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- off
    circle.BorderSizePixel = 0
    circle.ZIndex = 4

    local circleCorner = Instance.new("UICorner", circle)
    circleCorner.CornerRadius = UDim.new(0, 9)

    local isOn = false
    local function updateToggle(state)
        isOn = state
        label.Text = toggleName .. " " .. (isOn and "On" or "Off")
        local newColor = isOn and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        local targetPos = isOn and UDim2.new(1, -19, 0, 1) or UDim2.new(0, 1, 0, 1)

        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = targetPos,
            BackgroundColor3 = newColor
        }):Play()

        if callback then
            callback(isOn)
        end
    end

    -- Botão invisível de clique
    local clickBtn = Instance.new("TextButton")
    clickBtn.Name = "ClickZone"
    clickBtn.Parent = toggleFrame
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 5

    clickBtn.MouseButton1Click:Connect(function()
        updateToggle(not isOn)
    end)
end

-----------------------------
-- CONSTRUÇÃO DA JANELA PRINCIPAL
-----------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScriptGUI
MainFrame.Size = UDim2.new(0, 700, 0, 420)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local UICornerMain = Instance.new("UICorner", MainFrame)
UICornerMain.CornerRadius = UDim.new(0, 8)

-- TOP BAR (30px) + BOTÃO X
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
TopBar.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TopBar
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Anime Battle Rony Hub"
TitleLabel.TextColor3 = Color3.fromRGB(200,200,200)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.Size = UDim2.new(0, 50, 1, 0)
CloseButton.Position = UDim2.new(1, -50, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(220,220,220)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Draggable logic via TopBar
local dragging = false
local dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-----------------------------
-- SIDEBAR (ESQUERDA) + ABA
-----------------------------
local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Parent = MainFrame
LeftPanel.Size = UDim2.new(0, 160, 1, -30)
LeftPanel.Position = UDim2.new(0, 0, 0, 30)
LeftPanel.BackgroundColor3 = Color3.fromRGB(24,24,24)
LeftPanel.BorderSizePixel = 0

local SideCorner = Instance.new("UICorner", LeftPanel)
SideCorner.CornerRadius = UDim.new(0,8)

local LeftLayout = Instance.new("UIListLayout", LeftPanel)
LeftLayout.FillDirection = Enum.FillDirection.Vertical
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.Padding = UDim.new(0,5)

local LeftPadding = Instance.new("UIPadding", LeftPanel)
LeftPadding.PaddingTop = UDim.new(0,10)
LeftPadding.PaddingLeft = UDim.new(0,10)

local function createTabButton(tabName)
    local b = Instance.new("TextButton")
    b.Name = tabName.."Button"
    b.Parent = LeftPanel
    b.Size = UDim2.new(1, -10, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(38,38,38)
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.fromRGB(220,220,220)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 16
    b.Text = tabName

    local bc = Instance.new("UICorner", b)
    bc.CornerRadius = UDim.new(0,6)
    return b
end

-----------------------------
-- ÁREA DE CONTEÚDO (DIREITA)
-----------------------------
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -160, 1, -30)
ContentArea.Position = UDim2.new(0, 160, 0, 30)
ContentArea.BackgroundColor3 = Color3.fromRGB(28,28,28)
ContentArea.BorderSizePixel = 0

local CAcorner = Instance.new("UICorner", ContentArea)
CAcorner.CornerRadius = UDim.new(0,8)

local function createTabFrame(tabName)
    local f = Instance.new("Frame")
    f.Name = tabName.."Frame"
    f.Parent = ContentArea
    f.Size = UDim2.new(1,0, 1,0)
    f.BackgroundColor3 = Color3.fromRGB(28,28,28)
    f.BorderSizePixel = 0
    f.Visible = false

    local list = Instance.new("UIListLayout", f)
    list.FillDirection = Enum.FillDirection.Vertical
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0,5)

    local pad = Instance.new("UIPadding", f)
    pad.PaddingTop = UDim.new(0,10)
    pad.PaddingLeft = UDim.new(0,10)
    pad.PaddingRight = UDim.new(0,10)
    return f
end

local InicioButton = createTabButton("Início")
local FuncButton = createTabButton("Funcionalidades")
local ConfButton = createTabButton("Configurações")

local InicioFrame = createTabFrame("Início")
local FuncFrame = createTabFrame("Funcionalidades")
local ConfFrame = createTabFrame("Configurações")

-- Aba Início
InicioFrame.Visible = true

local Intro = Instance.new("TextLabel", InicioFrame)
Intro.Size = UDim2.new(1, -16, 0,60)
Intro.BackgroundTransparency = 1
Intro.TextColor3 = Color3.fromRGB(220,220,220)
Intro.Font = Enum.Font.SourceSansBold
Intro.TextSize = 16
Intro.TextWrapped = true
Intro.Text = "Bem-vindo(a) ao Anime Battle Rony Hub!\nClique na aba Funcionalidades para usar."

-- Aba Funcionalidades
-- Botões/toggles
createToggle(FuncFrame, "Power Click", function(b) powerClickEnabled = b end)
createToggle(FuncFrame, "Auto reset", function(b) autoResetEnabled = b end)
createToggle(FuncFrame, "Giro Automático", function(b) autoWheelEnabled = b end)
createToggle(FuncFrame, "Girar Ovos do Evento", function(b) autoEggEnabled = b end)
createToggle(FuncFrame, "Girar Ovo Mundo Magma", function(b) autoMagmaEgg = b end)
createToggle(FuncFrame, "Girar Ovos Mundo 6", function(b) autoOverseerEgg = b end)
createToggle(FuncFrame, "Black Screen", function(b) BlackScreenFrame.Visible = b end)

-- Aba Configurações
local ConfigLabel = Instance.new("TextLabel", ConfFrame)
ConfigLabel.Size = UDim2.new(1, -16, 0,60)
ConfigLabel.BackgroundTransparency = 1
ConfigLabel.TextColor3 = Color3.fromRGB(220,220,220)
ConfigLabel.Font = Enum.Font.SourceSansBold
ConfigLabel.TextSize = 16
ConfigLabel.TextWrapped = true
ConfigLabel.Text = "Aba de Configurações (Exemplo)."

-- Exibir/ocultar cada aba
local function showTab(frame)
    InicioFrame.Visible = false
    FuncFrame.Visible = false
    ConfFrame.Visible = false
    frame.Visible = true
end

InicioButton.MouseButton1Click:Connect(function() showTab(InicioFrame) end)
FuncButton.MouseButton1Click:Connect(function() showTab(FuncFrame) end)
ConfButton.MouseButton1Click:Connect(function() showTab(ConfFrame) end)

-----------------------------
-- BOTÃO FLUTUANTE (ARRASTÁVEL)
-----------------------------
local FloatButton = Instance.new("TextButton", ScriptGUI)
FloatButton.Size = UDim2.new(0, 60, 0, 60)
FloatButton.Position = UDim2.new(0, 50, 0.5, -30)
FloatButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
FloatButton.BorderSizePixel = 0
FloatButton.TextColor3 = Color3.new(1,1,1)
FloatButton.Font = Enum.Font.SourceSansBold
FloatButton.TextSize = 16
FloatButton.Text = "Min/Max"

local fcorner = Instance.new("UICorner", FloatButton)
fcorner.CornerRadius = UDim.new(1,0)

local fdragging = false
local fdragStart, fstartPos
FloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        fdragging = true
        fdragStart = input.Position
        fstartPos = FloatButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                fdragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if fdragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - fdragStart
        FloatButton.Position = UDim2.new(fstartPos.X.Scale, fstartPos.X.Offset + delta.X, fstartPos.Y.Scale, fstartPos.Y.Offset + delta.Y)
    end
end)

local panelVisible = true
FloatButton.MouseButton1Click:Connect(function()
    panelVisible = not panelVisible
    MainFrame.Visible = panelVisible
end)

print("Anime Battle Rony Hub (Wize + FloatingButton) carregado com sucesso!")
