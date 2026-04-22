--[[
    ZAKY HUB X - NEURAL VISION (ULTIMATE AI)
    - IA de Aprendizado por Reforço (Aprende com mortes)
    - Scanner LIDAR (Visão Geométrica 3D)
    - Hazard Detection (Detecta Lava/KillBricks)
    - Draggable Interface (Até o botão Z)
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// MEMÓRIA NEURAL DA IA
getgenv().NeuralData = {
    DangerZones = {}, -- Coordenadas onde você morreu
    SuccessFactor = 1.0,
    SafetyMargin = 2, -- O quanto ela se afasta de perigos
    LastJump = 0
}

getgenv().ZakySettings = {
    AI_Active = false,
    AI_HazardAvoid = true,
    Noclip = false,
    ESP = false,
    Fly = false,
    Speed = 16,
    Jump = 50,
    Theme = Color3.fromRGB(138, 43, 226)
}

--// PROTEÇÕES (Anti-AFK / Anti-Kick)
pcall(function()
    LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
    
    -- Bloqueador de Kick simples
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "Kick" then return nil end
        return old(self, ...)
    end)
end)

-- Limpeza de UI
if CoreGui:FindFirstChild("ZakyHub_X") then CoreGui.ZakyHub_X:Destroy() end
local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "ZakyHub_X"

-- Botão Minimizar Móvel
local MinBtn = Instance.new("TextButton", Screen)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
MinBtn.BackgroundColor3 = getgenv().ZakySettings.Theme; MinBtn.Text = "Z"; MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1,0)

-- Janela Principal
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 420, 0, 300); Main.Position = UDim2.new(0.5, -210, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15); Main.Visible = true
Instance.new("UICorner", Main); Instance.new("UIStroke", Main).Color = getgenv().ZakySettings.Theme

-- Função de Arrastar (Draggable)
local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = obj.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
MakeDraggable(Main); MakeDraggable(MinBtn)
MinBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)--// SISTEMA DE VISÃO LIDAR E DETECÇÃO DE PERIGO
local function ScanObby()
    local char = LocalPlayer.Character
    if not char or not getgenv().ZakySettings.AI_Active then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or hum.MoveDirection.Magnitude == 0 then return end

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    -- Varredura em Grade (Simula Visão 3D)
    for x = -2, 2, 2 do
        local origin = hrp.Position + hrp.CFrame.RightVector * x
        local direction = (hrp.CFrame.LookVector * 10) + (hrp.CFrame.UpVector * -5)
        local ray = Workspace:Raycast(origin, direction, rayParams)

        if ray and ray.Instance then
            local obj = ray.Instance
            -- Analisador de Perigo (IA identifica blocos fatais)
            local isHazard = false
            if obj.Name:lower():find("kill") or obj.Name:lower():find("lava") or obj:FindFirstChildOfClass("TouchTransmitter") then
                isHazard = true
            end

            if isHazard and getgenv().ZakySettings.AI_HazardAvoid then
                -- IA Decide: Pular por cima do perigo ou desviar
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.Velocity = hrp.CFrame.LookVector * (20 * getgenv().NeuralData.SuccessFactor) + Vector3.new(0, 40, 0)
                task.wait(0.2)
            end
        end
    end
end

-- Aprendizado por Morte
LocalPlayer.CharacterAdded:Connect(function()
    if getgenv().ZakySettings.AI_Active then
        getgenv().NeuralData.SuccessFactor = getgenv().NeuralData.SuccessFactor + 0.1
        -- IA registra que o método anterior falhou e tenta com mais força
    end
end)

RS.Heartbeat:Connect(ScanObby)--// FIX DE FUNÇÕES (PERSISTENTES)
local function ApplyNoclip()
    if getgenv().ZakySettings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end

local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("ZakyVisual")
            if getgenv().ZakySettings.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "ZakyVisual"
                end
                highlight.FillColor = getgenv().ZakySettings.Theme
                highlight.Enabled = true
            elseif highlight then
                highlight.Enabled = false
            end
        end
    end
end

-- Loop de Renderização (Garante que nada pare de funcionar)
RS.Stepped:Connect(function()
    ApplyNoclip()
    UpdateESP()
end)

-- Anti-Lag (Remove texturas pesadas para focar na IA)
local function AntiLag()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        end
        if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
    end
end--// MONTAGEM DA INTERFACE
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -20); Container.Position = UDim2.new(0, 10, 0, 10)
Container.BackgroundTransparency = 1; Container.ScrollBarThickness = 3
local Layout = Instance.new("UIListLayout", Container); Layout.Padding = UDim.new(0, 5)

local function AddToggle(text, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.Text = text; b.TextColor3 = Color3.new(0.7, 0.7, 0.7); Instance.new("UICorner", b)
    
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.TextColor3 = active and Color3.new(1,1,1) or Color3.new(0.7, 0.7, 0.7)
        b.BackgroundColor3 = active and getgenv().ZakySettings.Theme or Color3.fromRGB(25, 25, 30)
        callback(active)
    end)
end

-- Botões de Ativação
AddToggle("ATIVAR IA NEURAL (Auto-Obby)", function(v) getgenv().ZakySettings.AI_Active = v end)
AddToggle("Evitar Obstáculos Fatais", function(v) getgenv().ZakySettings.AI_HazardAvoid = v end)
AddToggle("Noclip (Atravessar Tudo)", function(v) getgenv().ZakySettings.Noclip = v end)
AddToggle("Ligar ESP (Visão de Jogadores)", function(v) getgenv().ZakySettings.ESP = v end)

AddToggle("Ativar Fly (Script Externo)", function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end)

AddToggle("Otimizar Jogo (Anti-Lag)", function() AntiLag() end)

-- Aimbot / CamLock Simples
AddToggle("Travar Mira no Player", function(v)
    getgenv().ZakySettings.CamLock = v
    if v then
        local target = nil
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then target = p break end end
        RS.RenderStepped:Connect(function()
            if getgenv().ZakySettings.CamLock and target and target.Character then
                Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end)
    end
end)

-- Pulo Infinito
UIS.JumpRequest:Connect(function()
    if LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(3) end
end)
