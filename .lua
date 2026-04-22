--[[
    ZAKY HUB - FINAL BOSS EDITION (UNIVERSAL)
    - UI Animada & Customizável
    - Sistema de Minimize Arrastável
    - Speed & Jump Modifiers (Input)
    - Noclip & Fly (Physics Based)
    - Target Selector (Base para Aimbot)
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Limpeza
if CoreGui:FindFirstChild("ZakyFinalBoss") then CoreGui.ZakyFinalBoss:Destroy() end

local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "ZakyFinalBoss"

-- // CONFIGURAÇÕES DE TWEEN
local tInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- // JANELA PRINCIPAL
local Main = Instance.new("Frame", Screen)
Main.Name = "Main"
Main.Size = UDim2.new(0, 400, 0, 450)
Main.Position = UDim2.new(0.5, -200, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(255, 0, 80); Stroke.Thickness = 2

-- // SISTEMA DE ARRASTAR (Mestre)
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then
        local delta = input.Position - dragStart
        obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
end
MakeDraggable(Main)

-- // BOTÃO MINIMIZAR
local Minimized = false
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.Text = "-"; MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        TS:Create(Main, tInfo, {Size = UDim2.new(0, 150, 0, 40)}):Play()
        MinBtn.Text = "+"
    else
        TS:Create(Main, tInfo, {Size = UDim2.new(0, 400, 0, 450)}):Play()
        MinBtn.Text = "-"
    end
end)

-- // TÍTULO
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "ZAKY HUB : FINAL BOSS"; Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold; Title.TextSize = 16

-- // CONTAINER SCROLLING
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60); Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1; Container.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Container); Layout.Padding = UDim.new(0, 10)

-- // FUNÇÕES DE MOVIMENTO
local function AddInput(placeholder, callback)
    local box = Instance.new("TextBox", Container)
    box.Size = UDim2.new(1, 0, 0, 40); box.PlaceholderText = placeholder; box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 30); box.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function(enter) if enter then callback(tonumber(box.Text)) end end)
end

AddInput("Ajustar Velocidade (Speed)", function(val)
    if val and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

AddInput("Ajustar Pulo (Jump)", function(val)
    if val and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

-- // NOCLIP & FLY
local Noclip = false
RS.Stepped:Connect(function()
    if Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

local function AddToggle(text, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(30, 30, 35); b.Text = text
    b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and Color3.fromRGB(255, 0, 80) or Color3.fromRGB(30, 30, 35)
        callback(active)
    end)
end

AddToggle("Ativar Noclip", function(v) Noclip = v end)

-- // TARGET SELECTOR (AIMBOT UI)
local TargetLabel = Instance.new("TextLabel", Container)
TargetLabel.Size = UDim2.new(1, 0, 0, 20); TargetLabel.Text = "SELECIONAR ALVO:"; TargetLabel.TextColor3 = Color3.new(1,1,1); TargetLabel.BackgroundTransparency = 1

local PlayerList = Instance.new("Frame", Container)
PlayerList.Size = UDim2.new(1, 0, 0, 100); PlayerList.BackgroundTransparency = 0.9
local PListScroll = Instance.new("ScrollingFrame", PlayerList)
PListScroll.Size = UDim2.new(1, 0, 1, 0); PListScroll.BackgroundTransparency = 1; PListScroll.ScrollBarThickness = 2
Instance.new("UIListLayout", PListScroll)

local SelectedTarget = nil
local function RefreshPlayers()
    for _, v in pairs(PListScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", PListScroll)
            pBtn.Size = UDim2.new(1, 0, 0, 25); pBtn.Text = p.Name; pBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            pBtn.TextColor3 = Color3.new(1,1,1)
            pBtn.MouseButton1Click:Connect(function() 
                SelectedTarget = p
                TargetLabel.Text = "ALVO: " .. p.Name
                print("Aimbot focado em: " .. p.Name)
            end)
        end
    end
end
RefreshPlayers(); Players.PlayerAdded:Connect(RefreshPlayers); Players.PlayerRemoving:Connect(RefreshPlayers)

-- // CONFIRMAÇÃO DE FECHAMENTO
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", CloseBtn)

local Confirm = Instance.new("Frame", Screen)
Confirm.Size = UDim2.new(0, 250, 0, 120); Confirm.Position = UDim2.new(0.5, -125, 0.4, 0)
Confirm.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Confirm.Visible = false; Confirm.ZIndex = 10
Instance.new("UICorner", Confirm); local s2 = Instance.new("UIStroke", Confirm); s2.Color = Color3.new(1,1,1)

local Msg = Instance.new("TextLabel", Confirm)
Msg.Size = UDim2.new(1, 0, 0, 50); Msg.Text = "REALMENTE DESEJA SAIR?"; Msg.TextColor3 = Color3.new(1,1,1); Msg.BackgroundTransparency = 1

local Yes = Instance.new("TextButton", Confirm)
Yes.Size = UDim2.new(0, 100, 0, 40); Yes.Position = UDim2.new(0, 20, 0, 60); Yes.Text = "SIM"; Yes.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
local No = Instance.new("TextButton", Confirm)
No.Size = UDim2.new(0, 100, 0, 40); No.Position = UDim2.new(1, -120, 0, 60); No.Text = "NÃO"; No.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

CloseBtn.MouseButton1Click:Connect(function() Confirm.Visible = true end)
No.MouseButton1Click:Connect(function() Confirm.Visible = false end)
Yes.MouseButton1Click:Connect(function() Screen:Destroy() end)
