--[[
    ZAKY HUB V5 - SUPREMACIA EB
    - Auto Parkour com Sistema de Raciocínio (Analisa altura e distância)
    - Botão Minimizar Fixo
    - Aimbot com Lista de Jogadores do Servidor
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// CONFIGURAÇÕES GLOBAIS
getgenv().ZakySettings = {
    ESP_Enabled = false, ESP_Names = false, ESP_Health = false,
    ESP_Color = Color3.fromRGB(138, 43, 226),
    WalkSpeed = 16, JumpPower = 50, 
    InfJump = false, Noclip = false,
    AutoParkour = false, 
    TargetPlayer = nil, LockCamera = false,
    Lang = "PT"
}

-- Limpeza de UI antiga
if CoreGui:FindFirstChild("ZakyHub_V5") then CoreGui.ZakyHub_V5:Destroy() end

local ZakyHub = Instance.new("ScreenGui", CoreGui)
ZakyHub.Name = "ZakyHub_V5"

--// BOTÃO MINIMIZAR (FLOAT)
local MinButton = Instance.new("TextButton", ZakyHub)
MinButton.Size = UDim2.new(0, 45, 0, 45)
MinButton.Position = UDim2.new(0.1, 0, 0.1, 0)
MinButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
MinButton.Text = "Z"
MinButton.TextColor3 = Color3.new(1, 1, 1)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 25
Instance.new("UICorner", MinButton).CornerRadius = UDim.new(1, 0)

--// MAIN FRAME
local MainFrame = Instance.new("Frame", ZakyHub)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Visible = true
Instance.new("UICorner", MainFrame)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(138, 43, 226)
Stroke.Thickness = 2

-- Alternar visibilidade
MinButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)--// SIDEBAR E CONTAINER
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, -10)
Sidebar.Position = UDim2.new(0, 5, 0, 5)
Sidebar.BackgroundTransparency = 1
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

local Container = Instance.new("Frame", MainFrame)
Container.Position = UDim2.new(0, 130, 0, 10)
Container.Size = UDim2.new(1, -140, 1, -20)
Container.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, 0, 0, 35)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", b)

    local p = Instance.new("ScrollingFrame", Container)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.Visible = false
    p.BackgroundTransparency = 1
    p.ScrollBarThickness = 2
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)

    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.P.Visible = false t.B.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end
        p.Visible = true
        b.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end)
    Tabs[name] = {B = b, P = p}
    return p
end

local function NewToggle(parent, text, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -10, 0, 35)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", f)
    local l = Instance.new("TextLabel", f)
    l.Text = " " .. text
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.TextColor3 = Color3.new(1, 1, 1)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 40, 0, 20)
    b.Position = UDim2.new(1, -45, 0.5, -10)
    b.Text = ""
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.BackgroundColor3 = state and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(50, 50, 50)
        callback(state)
    end)
end

-- Setup de Abas
local pMain = CreateTab("Principal")
local pVisual = CreateTab("Visual")
local pCombat = CreateTab("Aimbot")

NewToggle(pMain, "Auto Parkour (IA)", function(v) getgenv().ZakySettings.AutoParkour = v end)
NewToggle(pMain, "Noclip", function(v) getgenv().ZakySettings.Noclip = v end)
NewToggle(pMain, "Pulo Infinito", function(v) getgenv().ZakySettings.InfJump = v end)--// LÓGICA DO AUTO PARKOUR INTELIGENTE
local isAnalyzing = false

local function RaciocinarObstaculo(hrp, hum)
    if isAnalyzing then return end
    
    -- Raycasts: Frente, Chão e Cabeça
    local forwardParams = RaycastParams.new()
    forwardParams.FilterDescendantsInstances = {LocalPlayer.Character}
    forwardParams.FilterType = Enum.RaycastFilterType.Exclude

    local rayF = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 6, forwardParams)
    local rayDown = Workspace:Raycast(hrp.Position + hrp.CFrame.LookVector * 5, Vector3.new(0, -10, 0), forwardParams)
    
    -- Raciocínio 1: Buraco (Vão) à frente
    if not rayDown and hum.MoveDirection.Magnitude > 0 then
        isAnalyzing = true
        hum.Jump = true
        task.wait(0.3)
        isAnalyzing = false
    end

    -- Raciocínio 2: Parede ou Obstáculo alto
    if rayF and rayF.Instance.CanCollide then
        isAnalyzing = true
        local dist = (hrp.Position - rayF.Position).Magnitude
        
        if dist < 4 then
            -- Se for EB Parkour (Flick), ele faz o movimento de recuo
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.Velocity = (hrp.CFrame.LookVector * -12) + Vector3.new(0, getgenv().ZakySettings.JumpPower * 1.2, 0)
            task.wait(0.15)
            hrp.Velocity = (hrp.CFrame.LookVector * 35) + Vector3.new(0, 10, 0)
        end
        task.wait(0.4)
        isAnalyzing = false
    end
end

RS.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and getgenv().ZakySettings.AutoParkour then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if hrp and hum then
            RaciocinarObstaculo(hrp, hum)
        end
    end
end)--// PÁGINA AIMBOT - LISTA DE JOGADORES
local SelectedPlayerLabel = Instance.new("TextLabel", pCombat)
SelectedPlayerLabel.Size = UDim2.new(1, -10, 0, 30)
SelectedPlayerLabel.Text = "Alvo: Nenhum"
SelectedPlayerLabel.TextColor3 = Color3.new(1, 1, 1)
SelectedPlayerLabel.BackgroundTransparency = 1

local PlayerList = Instance.new("ScrollingFrame", pCombat)
PlayerList.Size = UDim2.new(1, -10, 0, 150)
PlayerList.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UIListLayout", PlayerList)

local function AtualizarLista()
    for _, v in pairs(PlayerList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton", PlayerList)
            b.Size = UDim2.new(1, 0, 0, 30)
            b.Text = p.Name
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            b.TextColor3 = Color3.new(1, 1, 1)
            b.MouseButton1Click:Connect(function()
                getgenv().ZakySettings.TargetPlayer = p
                SelectedPlayerLabel.Text = "Alvo: " .. p.Name
            end)
        end
    end
end
AtualizarLista()
NewToggle(pCombat, "Travar Câmera (Lock)", function(v) getgenv().ZakySettings.LockCamera = v end)

--// LOOP PRINCIPAL (NOCLIP, SPEED, LOCK)
RS.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Speed/Jump
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = getgenv().ZakySettings.WalkSpeed
        hum.JumpPower = getgenv().ZakySettings.JumpPower
    end

    -- Noclip
    if getgenv().ZakySettings.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- Camera Lock
    if getgenv().ZakySettings.LockCamera and getgenv().ZakySettings.TargetPlayer then
        local tChar = getgenv().ZakySettings.TargetPlayer.Character
        if tChar and tChar:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, tChar.HumanoidRootPart.Position)
        end
    end
end)

-- Pulo Infinito
UIS.JumpRequest:Connect(function()
    if getgenv().ZakySettings.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Tabs["Principal"].B.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
Tabs["Principal"].P.Visible = true
