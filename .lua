--[[
    ZAKY HUB - ULTRA INTERFACE
    - Sistema de Arrastar e Minimizar
    - Animações Suaves (Tween)
    - Menu de Confirmação de Saída
    - Lista de Jogadores e Input de Velocidade (Visual)
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Limpeza de UI antiga
if CoreGui:FindFirstChild("ZakyHubUltra") then CoreGui.ZakyHubUltra:Destroy() end

local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "ZakyHubUltra"

-- // TWEEN CONFIG
local tInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- // JANELA PRINCIPAL
local Main = Instance.new("Frame", Screen)
Main.Name = "Main"
Main.Size = UDim2.new(0, 380, 0, 400)
Main.Position = UDim2.new(0.5, -190, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.ClipsDescendants = true
Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(0, 255, 150); Stroke.Thickness = 2

-- // SISTEMA DE ARRASTAR
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Main.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- // BOTÃO MINIMIZAR
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.Text = "-"; MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TS:Create(Main, tInfo, {Size = UDim2.new(0, 150, 0, 40)}):Play()
        MinBtn.Text = "+"
    else
        TS:Create(Main, tInfo, {Size = UDim2.new(0, 380, 0, 400)}):Play()
        MinBtn.Text = "-"
    end
end)

-- // INPUT DE VELOCIDADE
local SpeedBox = Instance.new("TextBox", Main)
SpeedBox.Size = UDim2.new(0, 100, 0, 30); SpeedBox.Position = UDim2.new(0, 20, 0, 60)
SpeedBox.PlaceholderText = "Velocidade..."; SpeedBox.Text = ""
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35); SpeedBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SpeedBox)

SpeedBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(SpeedBox.Text)
        if val then
            print("Velocidade alterada para: " .. val)
            -- Aqui você aplicaria a lógica de velocidade se desejado
        end
    end
end)

-- // LISTA DE JOGADORES (AIMBOT SELECTION VISUAL)
local PlayerList = Instance.new("ScrollingFrame", Main)
PlayerList.Size = UDim2.new(1, -40, 0, 150); PlayerList.Position = UDim2.new(0, 20, 0, 100)
PlayerList.BackgroundTransparency = 1; PlayerList.ScrollBarThickness = 2
Instance.new("UIListLayout", PlayerList).Padding = UDim.new(0, 5)

local function UpdatePlayers()
    for _, v in pairs(PlayerList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", PlayerList)
            pBtn.Size = UDim2.new(1, 0, 0, 30); pBtn.Text = p.Name; pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            pBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", pBtn)
            pBtn.MouseButton1Click:Connect(function() print("Alvo selecionado: " .. p.Name) end)
        end
    end
end
UpdatePlayers(); Players.PlayerAdded:Connect(UpdatePlayers); Players.PlayerRemoving:Connect(UpdatePlayers)

-- // MENU DE CONFIRMAÇÃO DE FECHAMENTO
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", CloseBtn)

local ConfirmFrame = Instance.new("Frame", Screen)
ConfirmFrame.Size = UDim2.new(0, 200, 0, 100); ConfirmFrame.Position = UDim2.new(0.5, -100, 0.4, 0)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); ConfirmFrame.Visible = false
Instance.new("UICorner", ConfirmFrame); Instance.new("UIStroke", ConfirmFrame).Color = Color3.new(1,1,1)

local ConfirmText = Instance.new("TextLabel", ConfirmFrame)
ConfirmText.Size = UDim2.new(1, 0, 0, 40); ConfirmText.Text = "Deseja fechar?"; ConfirmText.TextColor3 = Color3.new(1,1,1); ConfirmText.BackgroundTransparency = 1

local Yes = Instance.new("TextButton", ConfirmFrame)
Yes.Size = UDim2.new(0, 80, 0, 30); Yes.Position = UDim2.new(0.1, 0, 0.6, 0); Yes.Text = "Sim"; Yes.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
local No = Instance.new("TextButton", ConfirmFrame)
No.Size = UDim2.new(0, 80, 0, 30); No.Position = UDim2.new(0.5, 0, 0.6, 0); No.Text = "Não"; No.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

CloseBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = true end)
No.MouseButton1Click:Connect(function() ConfirmFrame.Visible = false end)
Yes.MouseButton1Click:Connect(function() Screen:Destroy() end)
