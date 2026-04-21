--[[
    ZAKY HUB V6 - INTELLIGENT EDITION
    - Heurística de Navegação (IA de Obby)
    - Sistema de Tradução Dinâmica
    - Botão de Minimizar Persistente
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// CONFIGURAÇÕES GLOBAIS (TUDO OFF POR PADRÃO)
getgenv().ZakySettings = {
    ESP_Enabled = false, ESP_Names = false, ESP_Health = false, ESP_Box = false,
    ESP_Color = Color3.fromRGB(138, 43, 226),
    WalkSpeed = 16, JumpPower = 50, InfJump = false, Noclip = false,
    AutoParkour = false, HitboxExpander = false,
    TargetPlayer = nil, LockCamera = false, Lang = "PT"
}

--// DICIONÁRIO DE IA (RACIOCÍNIO)
local ObbyAI = {
    States = {IDLE = "Parado", ANALYZING = "Analisando...", EXECUTING = "Executando Movimento"},
    CurrentState = "IDLE",
    LastAction = 0
}

-- Limpeza
if CoreGui:FindFirstChild("ZakyHub_V6") then CoreGui.ZakyHub_V6:Destroy() end

local ZakyHub = Instance.new("ScreenGui", CoreGui)
ZakyHub.Name = "ZakyHub_V6"

-- BOTÃO MINIMIZAR
local MinBtn = Instance.new("TextButton", ZakyHub)
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
MinBtn.Text = "Z"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 20
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame", ZakyHub)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(138, 43, 226)

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- HUD DE STATUS DA IA
local AIStatus = Instance.new("TextLabel", ZakyHub)
AIStatus.Size = UDim2.new(0, 200, 0, 30)
AIStatus.Position = UDim2.new(0.5, -100, 0.1, 0)
AIStatus.BackgroundTransparency = 1
AIStatus.TextColor3 = Color3.new(1, 1, 1)
AIStatus.Font = Enum.Font.GothamBold
AIStatus.Text = "IA: " .. ObbyAI.States.IDLE
AIStatus.Visible = falselocal function ExecuteAIParkour(hrp, hum)
    if not getgenv().ZakySettings.AutoParkour or tick() - ObbyAI.LastAction < 0.5 then return end
    
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {LocalPlayer.Character}
    Params.FilterType = Enum.RaycastFilterType.Exclude

    -- Sensores da IA
    local sensorForward = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 7, Params)
    local sensorDown = Workspace:Raycast(hrp.Position + hrp.CFrame.LookVector * 5, Vector3.new(0, -15, 0), Params)
    local sensorHead = Workspace:Raycast(hrp.Position + Vector3.new(0, 5, 0), hrp.CFrame.LookVector * 5, Params)

    -- RACIOCÍNIO 1: DETECÇÃO DE TORRE/ESCADA EB
    if sensorForward and sensorForward.Instance.CanCollide then
        AIStatus.Visible = true
        AIStatus.Text = "IA: " .. ObbyAI.States.ANALYZING
        
        -- Se houver algo na frente mas não houver nada acima da cabeça (Torre)
        if not sensorHead then
            ObbyAI.LastAction = tick()
            AIStatus.Text = "IA: EXECUTANDO FLICK JUMP"
            
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.1)
            -- Movimento inteligente: Afasta para não bater a cabeça e impulsiona para cima/frente
            hrp.Velocity = (hrp.CFrame.LookVector * -18) + Vector3.new(0, getgenv().ZakySettings.JumpPower * 1.3, 0)
            task.wait(0.2)
            hrp.Velocity = (hrp.CFrame.LookVector * 35) + Vector3.new(0, 10, 0)
        end
    
    -- RACIOCÍNIO 2: DETECÇÃO DE VÃO (BURACO)
    elseif not sensorDown and hum.MoveDirection.Magnitude > 0 then
        AIStatus.Visible = true
        AIStatus.Text = "IA: PULO DE DISTÂNCIA"
        hum.Jump = true
        ObbyAI.LastAction = tick()
    else
        AIStatus.Visible = false
    end
end

RS.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        ExecuteAIParkour(char.HumanoidRootPart, char.Humanoid)
    end
end)--// NAVEGAÇÃO E ABAS
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
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", b)

    local p = Instance.new("ScrollingFrame", Container)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.Visible = false
    p.BackgroundTransparency = 1
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)

    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.P.Visible = false t.B.BackgroundColor3 = Color3.fromRGB(25, 25, 30) end
        p.Visible = true
        b.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end)
    Tabs[name] = {B = b, P = p}
    return p
end

local tabMain = CreateTab("Jogador")
local tabCombat = CreateTab("Aimbot")
local tabVisual = CreateTab("Visual")
local tabSettings = CreateTab("Ajustes")

-- SELEÇÃO DE JOGADOR PARA AIMBOT
local PlayerSelect = Instance.new("TextLabel", tabCombat)
PlayerSelect.Text = "Selecionar Alvo:"
PlayerSelect.TextColor3 = Color3.new(1, 1, 1)
PlayerSelect.Size = UDim2.new(1, 0, 0, 20)
PlayerSelect.BackgroundTransparency = 1

local PList = Instance.new("ScrollingFrame", tabCombat)
PList.Size = UDim2.new(1, 0, 0, 120)
PList.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UIListLayout", PList)

local function UpdatePlayerList()
    for _, v in pairs(PList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton", PList)
            b.Size = UDim2.new(1, 0, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            b.TextColor3 = Color3.new(1, 1, 1)
            b.MouseButton1Click:Connect(function()
                getgenv().ZakySettings.TargetPlayer = p
                PlayerSelect.Text = "Alvo: " .. p.Name
            end)
        end
    end
end
UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)local function CreateToggle(parent, text, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = text
    b.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    Instance.new("UICorner", b)
    
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.TextColor3 = active and Color3.new(1, 1, 1) or Color3.new(0.6, 0.6, 0.6)
        b.BackgroundColor3 = active and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(30, 30, 35)
        callback(active)
    end)
end

-- FUNÇÕES EXTRAS
CreateToggle(tabMain, "Auto Parkour IA", function(v) getgenv().ZakySettings.AutoParkour = v end)
CreateToggle(tabMain, "Pulo Infinito", function(v) getgenv().ZakySettings.InfJump = v end)
CreateToggle(tabMain, "Noclip", function(v) getgenv().ZakySettings.Noclip = v end)
CreateToggle(tabCombat, "Travar Mira", function(v) getgenv().ZakySettings.LockCamera = v end)
CreateToggle(tabCombat, "Expandir Hitbox", function(v) getgenv().ZakySettings.HitboxExpander = v end)
CreateToggle(tabVisual, "Ligar ESP", function(v) getgenv().ZakySettings.ESP_Enabled = v end)
CreateToggle(tabVisual, "Mostrar Nomes", function(v) getgenv().ZakySettings.ESP_Names = v end)

-- CLICK TELEPORT (Ctrl + Click)
UIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        local pos = LocalPlayer:GetMouse().Hit.Position
        LocalPlayer.Character:MoveTo(pos + Vector3.new(0, 3, 0))
    end
end)

-- LOOP PRINCIPAL
RS.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    -- Lock Camera
    if getgenv().ZakySettings.LockCamera and getgenv().ZakySettings.TargetPlayer then
        local target = getgenv().ZakySettings.TargetPlayer.Character
        if target and target:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.HumanoidRootPart.Position)
        end
    end

    -- Hitbox Expander
    if getgenv().ZakySettings.HitboxExpander then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(10, 10, 10)
                p.Character.HumanoidRootPart.Transparency = 0.7
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
    
    -- ESP Logic (Nomes e Barra)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if getgenv().ZakySettings.ESP_Enabled then
                -- Aqui você pode integrar um Highlight ou Billboard simples
            end
        end
    end
end)

-- PULO INFINITO
UIS.JumpRequest:Connect(function()
    if getgenv().ZakySettings.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Tabs["Jogador"].B.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
Tabs["Jogador"].P.Visible = true
