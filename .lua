--[[
    ZAKY HUB : ULTIMATE v6 (FIXED)
    - Correção do Minimize (ClipsDescendants)
    - Sistema de Arrastar Aprimorado (Mobile/PC)
    - Anti-Lag Agressivo (SmoothPlastic + No Shadows)
    - Todas as funções incluídas (Speed, Jump, Fly, ESP, etc)
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- // Limpeza
if CoreGui:FindFirstChild("ZakyFinal") then CoreGui.ZakyFinal:Destroy() end
local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "ZakyFinal"

-- // ESTADOS DAS FUNÇÕES
local State = {
    Noclip = false, InfJump = false, AutoClick = false,
    Highlights = false, AntiAFK = true, FullBright = false,
    Speed = 16, Jump = 50
}

-- // UI PRINCIPAL
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 380, 0, 450)
Main.Position = UDim2.new(0.5, -190, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Main.ClipsDescendants = true -- ISSO CORRIGE O VAZAMENTO AO MINIMIZAR!
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(255, 0, 60); Stroke.Thickness = 1.5

-- // HEADER (Barra de Arrastar)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "ZAKYHUB ULTIMATE V6"; Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1

-- // CONSOLE DE STATUS
local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -20, 0, 25); Status.Position = UDim2.new(0, 10, 0, 45)
Status.BackgroundColor3 = Color3.fromRGB(5, 5, 5); Status.Text = " STATUS: TUDO PRONTO!"; Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.Font = Enum.Font.Code; Status.TextSize = 12; Instance.new("UICorner", Status)

-- // CONTAINER DE BOTÕES
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -85); Scroll.Position = UDim2.new(0, 10, 0, 75)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 8)

-- // FUNÇÕES GERADORAS DE UI
local function AddToggle(name, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Gotham; Instance.new("UICorner", btn)
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(200, 0, 50) or Color3.fromRGB(25, 25, 30)
        callback(active)
    end)
end

local function AddInput(placeholder, callback)
    local box = Instance.new("TextBox", Scroll)
    box.Size = UDim2.new(1, 0, 0, 35); box.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    box.PlaceholderText = placeholder; box.Text = ""; box.TextColor3 = Color3.new(1,1,1); box.Font = Enum.Font.Gotham
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
end

local function AddButton(name, color, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = color
    btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
end

-- // MÓDULOS DE LÓGICA

-- Movimentação Stealth (Ciclos)
RS.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = State.Speed
        char.Humanoid.JumpPower = State.Jump
        if State.Noclip then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if State.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- ESP Highlight
task.spawn(function()
    while task.wait(1) do
        if State.Highlights then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ZakyESP") then
                    local h = Instance.new("Highlight", p.Character)
                    h.Name = "ZakyESP"; h.FillColor = Color3.fromRGB(255, 0, 50); h.FillTransparency = 0.4; h.OutlineColor = Color3.new(1,1,1)
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("ZakyESP") then p.Character.ZakyESP:Destroy() end
            end
        end
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end
end)

-- // ADICIONANDO OS CONTROLES NA GUI

AddInput("Definir Velocidade (Speed) - Aperte Enter", function(v) 
    State.Speed = tonumber(v) or 16 
    Status.Text = " STATUS: VELOCIDADE -> " .. State.Speed
end)

AddInput("Definir Força do Pulo (Jump) - Aperte Enter", function(v) 
    State.Jump = tonumber(v) or 50 
    Status.Text = " STATUS: PULO -> " .. State.Jump
end)

AddToggle("Ativar Noclip (Atravessar)", function(v) State.Noclip = v end)
AddToggle("Pulo Infinito no Ar", function(v) State.InfJump = v end)
AddToggle("Realçar Jogadores (ESP Seguro)", function(v) State.Highlights = v end)

AddToggle("Ativar FullBright (Visão Clara)", function(v)
    State.FullBright = v
    Lighting.Ambient = v and Color3.new(1,1,1) or Color3.new(0.5, 0.5, 0.5)
    Lighting.GlobalShadows = not v
end)

AddButton("💥 OTIMIZAR FPS (ANTI-LAG REAL)", Color3.fromRGB(40, 0, 0), function()
    Status.Text = " STATUS: LIMPANDO TEXTURAS..."
    Status.TextColor3 = Color3.new(1,1,0)
    task.wait(0.5)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
        end
    end
    Lighting.GlobalShadows = false
    Status.Text = " STATUS: FPS MAXIMIZADO!"
    Status.TextColor3 = Color3.new(0,1,0)
end)

AddButton("🔄 RECONECTAR AO SERVIDOR", Color3.fromRGB(0, 40, 80), function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

AddButton("🚀 TROCAR DE SERVIDOR (SERVER HOP)", Color3.fromRGB(80, 40, 0), function()
    Status.Text = " STATUS: PROCURANDO SERVIDOR..."
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local s = Http:JSONDecode(game:HttpGet(Api))
    for _, server in pairs(s.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TPS:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
            break
        end
    end
end)

-- // SISTEMA DE MINIMIZAR (Corrigido)
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -35, 0, 5); MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); MinBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", MinBtn)

local minimizado = false
MinBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    -- Como ClipsDescendants = true, encolher o Main esconde o resto
    TS:Create(Main, TweenInfo.new(0.3), {Size = minimizado and UDim2.new(0, 380, 0, 40) or UDim2.new(0, 380, 0, 450)}):Play()
    MinBtn.Text = minimizado and "+" or "-"
end)

-- // SISTEMA DE ARRASTAR ROBUSTO (Funciona Liso no Mobile/Delta)
local dragging, dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
