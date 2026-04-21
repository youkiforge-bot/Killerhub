--[[
    Executor Hub - Powerups Update
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variáveis de Estado
local infJumpEnabled = false
local espEnabled = false

-- Limpeza de UI antiga
if player.PlayerGui:FindFirstChild("ExecutorHub") then
    player.PlayerGui.ExecutorHub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExecutorHub"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- ==================== FUNÇÕES TÉCNICAS ====================

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Sistema de ESP
local function createESP(plr)
    local function applyESP(char)
        if not char:FindFirstChild("ESPHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Parent = char
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.Enabled = espEnabled
        end
    end
    if plr.Character then applyESP(plr.Character) end
    plr.CharacterAdded:Connect(applyESP)
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= player then createESP(p) end
end
Players.PlayerAdded:Connect(createESP)

-- ==================== INTERFACE ====================

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 500, 0, 350)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", mainFrame)

-- Sidebar de Navegação
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 120, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", sidebar)

local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, -130, 1, -10)
container.Position = UDim2.new(0, 125, 0, 5)
container.BackgroundTransparency = 1

-- Gerenciador de Abas
local pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame", container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 2, 0)
    page.ScrollBarThickness = 2
    pages[name] = page
    
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, (#sidebar:GetChildren()-1) * 45 + 10)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        page.Visible = true
    end)
    return page
end

-- ==================== CONTEÚDO DAS ABAS ====================

local pPower = createPage("Powerups")
local pEditor = createPage("Editor")
pages["Powerups"].Visible = true -- Padrão

-- Função para criar Toggles (Botões de Ligar/Desligar)
local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    Instance.new("UIListLayout", parent).Padding = UDim.new(0, 10)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(200, 50, 50)
        callback(state)
    end)
end

-- Botões de Powerup
createToggle(pPower, "Infinite Jump", function(v) infJumpEnabled = v end)
createToggle(pPower, "ESP Players", function(v) 
    espEnabled = v 
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("ESPHighlight") then
            p.Character.ESPHighlight.Enabled = v
        end
    end
end)

-- Sliders simples para Speed e Jump
local function createSlider(parent, text, min, max, default, callback)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(0.9, 0, 0, 20)
    label.Text = text .. ": " .. default
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)

    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Text = "Ajustar (Clique p/ +10)"
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)

    local current = default
    btn.MouseButton1Click:Connect(function()
        current = current + 10
        if current > max then current = min end
        label.Text = text .. ": " .. current
        callback(current)
    end)
end

createSlider(pPower, "WalkSpeed", 16, 200, 16, function(v)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = v
    end
end)

createSlider(pPower, "JumpPower", 50, 500, 50, function(v)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.UseJumpPower = true
        player.Character.Humanoid.JumpPower = v
    end
end)

-- Botão de Fechar
local close = Instance.new("TextButton", mainFrame)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Draggable (Arrastar)
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
