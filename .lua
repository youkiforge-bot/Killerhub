--[[
    ZAKY HUB V7 - ULTRA SMART EDITION
    - IA de Parkour 2.0 (Varredura de Geometria)
    - ESP & Noclip Fix (Physics Override)
    - Anti-AFK, Anti-Kick, Anti-Lag
    - Fly Integrado (XNEOFF)
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

getgenv().ZakySettings = {
    ESP_Enabled = false, ESP_Names = false, ESP_Color = Color3.fromRGB(138, 43, 226),
    WalkSpeed = 16, JumpPower = 50, InfJump = false, Noclip = false,
    AutoParkour = false, TargetPlayer = nil, LockCamera = false
}

--// FUNÇÃO DRAGGABLE (PARA MENU E BOTÃO)
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = obj.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    obj.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

--// ANTI-KICK & ANTI-AFK
pcall(function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
    
    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if self == LocalPlayer and method == "Kick" then return nil end
        return old(self, ...)
    end)
end)

-- Limpeza e UI
if CoreGui:FindFirstChild("ZakyHub_V7") then CoreGui.ZakyHub_V7:Destroy() end
local ZakyHub = Instance.new("ScreenGui", CoreGui); ZakyHub.Name = "ZakyHub_V7"

local MinBtn = Instance.new("TextButton", ZakyHub)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226); MinBtn.Text = "Z"; MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1,0); MakeDraggable(MinBtn)

local Main = Instance.new("Frame", ZakyHub)
Main.Size = UDim2.new(0, 450, 0, 320); Main.Position = UDim2.new(0.5, -225, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Main.Visible = true
Instance.new("UICorner", Main); MakeDraggable(Main)

MinBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)--// IA DE PARKOUR AVANÇADA (SCANNER)
local isActing = false
local function SmartParkour()
    local char = LocalPlayer.Character
    if not char or not getgenv().ZakySettings.AutoParkour or isActing then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or hum.MoveDirection.Magnitude == 0 then return end

    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {char}
    Params.FilterType = Enum.RaycastFilterType.Exclude

    -- Varredura Multi-Point
    local rayF = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 6, Params) -- Frente
    local rayLow = Workspace:Raycast(hrp.Position - Vector3.new(0,2,0), hrp.CFrame.LookVector * 5, Params) -- Pés
    local rayDown = Workspace:Raycast(hrp.Position + hrp.CFrame.LookVector * 5, Vector3.new(0, -12, 0), Params) -- Chão à frente
    local rayHigh = Workspace:Raycast(hrp.Position + Vector3.new(0, 6, 0), hrp.CFrame.LookVector * 6, Params) -- Cabeça

    -- Decisão: Buraco (Gap)
    if not rayDown then
        isActing = true
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.4)
        isActing = false
        return
    end

    -- Decisão: Torre ou Parede Alta
    if rayF and rayF.Instance.CanCollide then
        isActing = true
        if not rayHigh then -- É uma torre/obstáculo escalável
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.Velocity = (hrp.CFrame.LookVector * -15) + Vector3.new(0, getgenv().ZakySettings.JumpPower * 1.2, 0)
            task.wait(0.15)
            hrp.Velocity = (hrp.CFrame.LookVector * 30) + Vector3.new(0, 15, 0)
        else -- Parede total (tenta pular normal)
            hum.Jump = true
        end
        task.wait(0.3)
        isActing = false
    end
end

RS.Heartbeat:Connect(SmartParkour)--// FIX ESP & NOCLIP
local function ApplyESP(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function(char)
        if getgenv().ZakySettings.ESP_Enabled then
            local h = char:FindFirstChild("ZHighlight") or Instance.new("Highlight", char)
            h.Name = "ZHighlight"
            h.FillColor = getgenv().ZakySettings.ESP_Color
            h.OutlineTransparency = 0
        end
    end)
end

--// ANTI-LAG SIMPLES
local function Optimize()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            if v.Material ~= Enum.Material.Plastic then v.Material = Enum.Material.Plastic end
        end
        if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
    end
    settings().Rendering.QualityLevel = 1
end

--// FLY SCRIPT
local function RunFly()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end

-- Loop de Colisão (Noclip Fix)
RS.Stepped:Connect(function()
    if getgenv().ZakySettings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)--// CRIAÇÃO DAS ABAS
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, -10); Sidebar.Position = UDim2.new(0, 5, 0, 5); Sidebar.BackgroundTransparency = 1
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 130, 0, 10); Container.Size = UDim2.new(1, -140, 1, -20); Container.BackgroundTransparency = 1

local function CreateBtn(parent, text, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = text; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- Adicionando Funções
CreateBtn(Sidebar, "Auto Parkour IA", function() 
    getgenv().ZakySettings.AutoParkour = not getgenv().ZakySettings.AutoParkour 
end)

CreateBtn(Sidebar, "Noclip (FIXED)", function() 
    getgenv().ZakySettings.Noclip = not getgenv().ZakySettings.Noclip 
end)

CreateBtn(Sidebar, "Ligar ESP", function() 
    getgenv().ZakySettings.ESP_Enabled = not getgenv().ZakySettings.ESP_Enabled
    for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end
end)

CreateBtn(Sidebar, "Ativar FLY", RunFly)

CreateBtn(Sidebar, "Anti-Lag", Optimize)

-- Aimbot Target Select
local TargetBtn = CreateBtn(Sidebar, "Selecionar Alvo", function()
    local players = Players:GetPlayers()
    getgenv().ZakySettings.TargetPlayer = players[math.random(1, #players)]
    print("Alvo Selecionado: " .. getgenv().ZakySettings.TargetPlayer.Name)
end)

-- Lock Camera Loop
RS.RenderStepped:Connect(function()
    if getgenv().ZakySettings.LockCamera and getgenv().ZakySettings.TargetPlayer then
        local t = getgenv().ZakySettings.TargetPlayer.Character
        if t and t:FindFirstChild("HumanoidRootPart") then
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, t.HumanoidRootPart.Position)
        end
    end
end)
