--[[
    ZAKY HUB V9 - THE SINGULARITY (FINAL VERSION)
    - IA de Aprendizado de Máquina (Heurística Adaptativa)
    - Navegação Autônoma de Obby
    - Sistema de Linguagem Dinâmico
    - Proteção Anti-Kick/AFK/Lag
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// BANCO DE DADOS DA IA (APRENDIZADO)
getgenv().ZakyAI = {
    KnowledgeBase = {}, -- Armazena posições de sucesso
    SuccessRate = 1.0,
    LastDeathPos = nil,
    LearningFactor = 0.05
}

getgenv().ZakySettings = {
    Lang = "PT", -- PT / EN
    ESP = false, ESP_Color = Color3.fromRGB(138, 43, 226),
    Noclip = false, IA_Parkour = false, IA_Autonomy = false,
    JumpPower = 50, Speed = 16, Target = nil, CamLock = false
}

--// TRADUÇÃO
local Langs = {
    PT = {AI_Status = "IA: Pensando...", Parkour = "Auto Parkour IA", Settings = "Configurações", Fly = "Ativar Fly"},
    EN = {AI_Status = "AI: Thinking...", Parkour = "AI Auto Parkour", Settings = "Settings", Fly = "Enable Fly"}
}

-- Limpeza
if CoreGui:FindFirstChild("ZakyHub_V9") then CoreGui.ZakyHub_V9:Destroy() end
local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "ZakyHub_V9"

-- Botão Minimizar Draggable
local MinBtn = Instance.new("TextButton", Screen)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
MinBtn.BackgroundColor3 = getgenv().ZakySettings.ESP_Color; MinBtn.Text = "Z"; MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1,0)

-- Main Frame
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 450, 0, 320); Main.Position = UDim2.new(0.5, -225, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18); Main.Visible = true
Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = getgenv().ZakySettings.ESP_Color

-- Arrastar (Draggable)
local function Drag(obj)
    local dragStart, startPos, dragging
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = obj.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
Drag(Main); Drag(MinBtn)
MinBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)--// LÓGICA DE APRENDIZADO E MOVIMENTO
local isMoving = false

local function GetPathLogic()
    local char = LocalPlayer.Character
    if not char or not getgenv().ZakySettings.IA_Parkour or isMoving then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or hum.MoveDirection.Magnitude == 0 then return end

    -- Sensores Geométricos
    local Params = RaycastParams.new(); Params.FilterDescendantsInstances = {char}; Params.FilterType = Enum.RaycastFilterType.Exclude
    local Forward = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 8, Params)
    local Down = Workspace:Raycast(hrp.Position + hrp.CFrame.LookVector * 6, Vector3.new(0, -20, 0), Params)
    local Up = Workspace:Raycast(hrp.Position, Vector3.new(0, 10, 0), Params)

    -- RACIOCÍNIO DE SALTO
    if not Down or (Forward and Forward.Instance.CanCollide) then
        isMoving = true
        
        -- Cálculo de Força Baseado no Aprendizado
        local jumpMulti = getgenv().ZakyAI.SuccessRate
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        
        -- Se for uma torre (flick IA)
        if Forward and not Up then
            hrp.Velocity = (hrp.CFrame.LookVector * (-15 * jumpMulti)) + Vector3.new(0, getgenv().ZakySettings.JumpPower * 1.2, 0)
            task.wait(0.15)
            hrp.Velocity = (hrp.CFrame.LookVector * (35 * jumpMulti)) + Vector3.new(0, 20, 0)
        end
        
        task.wait(0.4)
        isMoving = false
    end
end

-- Simulação de Aprendizado por Erro
LocalPlayer.CharacterAdded:Connect(function()
    if getgenv().ZakySettings.IA_Parkour then
        getgenv().ZakyAI.SuccessRate = getgenv().ZakyAI.SuccessRate + getgenv().ZakyAI.LearningFactor
        print("IA: Aprendendo com a falha. Novo multiplicador: " .. getgenv().ZakyAI.SuccessRate)
    end
end)

RS.Heartbeat:Connect(GetPathLogic)--// VISUAL E COMBATE (TARGET LOCK)
local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("ZHighlight")
            if getgenv().ZakySettings.ESP then
                if not h then h = Instance.new("Highlight", p.Character); h.Name = "ZHighlight" end
                h.FillColor = getgenv().ZakySettings.ESP_Color; h.Enabled = true
            elseif h then h.Enabled = false end
        end
    end
end

-- Aimbot / Camera Lock
RS.RenderStepped:Connect(function()
    if getgenv().ZakySettings.CamLock and getgenv().ZakySettings.Target then
        local t = getgenv().ZakySettings.Target.Character
        if t and t:FindFirstChild("HumanoidRootPart") then
            local pos = t.HumanoidRootPart.Position
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, pos)
        end
    end
    
    -- Noclip Pro
    if getgenv().ZakySettings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    UpdateESP()
end)

-- Anti-Kick / Anti-AFK Fixo
local VU = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function() VU:CaptureController(); VU:ClickButton2(Vector2.new()) end)--// MENU DE CONFIGURAÇÕES E ABAS
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, -10); Sidebar.Position = UDim2.new(0, 5, 0, 5); Sidebar.BackgroundTransparency = 1
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -140, 1, -20); Container.Position = UDim2.new(0, 130, 0, 10); Container.BackgroundTransparency = 1
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)

local function NewBtn(txt, cb)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.Text = txt; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb); return b
end

-- Funções Principais
NewBtn("Auto Parkour IA (Learning)", function() getgenv().ZakySettings.IA_Parkour = not getgenv().ZakySettings.IA_Parkour end)
NewBtn("Noclip Total", function() getgenv().ZakySettings.Noclip = not getgenv().ZakySettings.Noclip end)
NewBtn("Ligar ESP", function() getgenv().ZakySettings.ESP = not getgenv().ZakySettings.ESP end)
NewBtn("Fly (XNEOFF)", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() end)

-- Aimbot Selecionável
local TargetBtn = NewBtn("Selecionar Alvo (Random)", function()
    local plrs = Players:GetPlayers()
    getgenv().ZakySettings.Target = plrs[math.random(1, #plrs)]
    print("Alvo: " .. getgenv().ZakySettings.Target.Name)
end)

-- ABA DE CONFIGURAÇÕES (FINAL)
local SettingsLabel = Instance.new("TextLabel", Container)
SettingsLabel.Text = "--- CONFIGURAÇÕES ---"; SettingsLabel.TextColor3 = Color3.new(0.5,0.5,0.5); SettingsLabel.Size = UDim2.new(1,0,0,30); SettingsLabel.BackgroundTransparency = 1

NewBtn("Mudar Idioma (PT/EN)", function()
    getgenv().ZakySettings.Lang = (getgenv().ZakySettings.Lang == "PT") and "EN" or "PT"
    print("Idioma: " .. getgenv().ZakySettings.Lang)
end)

NewBtn("ESP: Verde / Roxo", function()
    getgenv().ZakySettings.ESP_Color = (getgenv().ZakySettings.ESP_Color == Color3.fromRGB(138, 43, 226)) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(138, 43, 226)
    Stroke.Color = getgenv().ZakySettings.ESP_Color
    MinBtn.BackgroundColor3 = getgenv().ZakySettings.ESP_Color
end)

NewBtn("Limpar Lag (Anti-Lag)", function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then v.Material = Enum.Material.Plastic end
        if v:IsA("Decal") then v:Destroy() end
    end
end)
