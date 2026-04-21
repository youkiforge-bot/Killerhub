--[[
    ZakyHub V3 - EB Premium Edition
    Auto-Parkour Avançado, Flicks em Torres e Funções Inativas por Padrão.
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// 1. TUDO DESATIVADO POR PADRÃO
local _G = getgenv and getgenv() or _G
_G.ZakySettings = {
    -- ESP (Tudo OFF)
    ESP_Enabled = false, ESP_Names = false, ESP_Dist = false, 
    ESP_Health = false, ESP_Box = false, ESP_Tracers = false, ESP_MaxDist = 1000,
    ESP_Color = Color3.fromRGB(138, 43, 226), 
    
    -- Player (Valores padrão do Roblox, Hacks OFF)
    WalkSpeed = 16, JumpPower = 50, InfJump = false, Noclip = false,
    
    -- EB Hacks (OFF)
    HitboxExpander = false,
    
    -- Auto Parkour (OFF)
    AutoParkour = false
}

-- Limpeza de instâncias antigas
if CoreGui:FindFirstChild("ZakyHub_V3") then
    CoreGui.ZakyHub_V3:Destroy()
end

--// FUNÇÕES AUXILIARES DE UI
local function MakeDraggable(frame, parent)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            TS:Create(parent, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

--// INTERFACE PRINCIPAL
local ZakyHub = Instance.new("ScreenGui")
ZakyHub.Name = "ZakyHub_V3"
ZakyHub.Parent = CoreGui
ZakyHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", ZakyHub)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.ClipsDescendants = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(138, 43, 226)
MainStroke.Thickness = 1.5

--// BARRA SUPERIOR
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
TopBar.BackgroundTransparency = 0.3
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)
MakeDraggable(TopBar, MainFrame)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "  ZAKY HUB V3 (EB EDITION)"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local UIGradient = Instance.new("UIGradient", Title)
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 200, 255))
}

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Text = "▼"
MinBtn.Size = UDim2.new(0, 45, 1, 0)
MinBtn.Position = UDim2.new(1, -45, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16

--// ÍCONE FLUTUANTE (Minimizado)
local FloatBtn = Instance.new("TextButton", ZakyHub)
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0, 20, 0.5, -25)
FloatBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
FloatBtn.Text = "Z"
FloatBtn.TextColor3 = Color3.new(1, 1, 1)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 24
FloatBtn.Visible = false
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", FloatBtn).Thickness = 2
MakeDraggable(FloatBtn, FloatBtn)

--// NAVEGAÇÃO
local NavBar = Instance.new("ScrollingFrame", MainFrame)
NavBar.Position = UDim2.new(0, 10, 0, 55)
NavBar.Size = UDim2.new(0, 120, 1, -65)
NavBar.BackgroundTransparency = 1
NavBar.ScrollBarThickness = 0
local NavList = Instance.new("UIListLayout", NavBar)
NavList.Padding = UDim.new(0, 6)

local Container = Instance.new("Frame", MainFrame)
Container.Position = UDim2.new(0, 140, 0, 55)
Container.Size = UDim2.new(1, -150, 1, -65)
Container.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", NavBar)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.ScrollBarThickness = 3
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
    Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 8)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do 
            t.Page.Visible = false 
            TS:Create(t.Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180), BackgroundColor3 = Color3.fromRGB(20, 20, 28)}):Play()
        end
        TabPage.Visible = true
        TS:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(138, 43, 226)}):Play()
    end)
    
    Tabs[name] = {Btn = TabBtn, Page = TabPage}
    return TabPage
end

--// COMPONENTES PREMIUM DA UI
local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Down:Connect(function()
        TS:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.95, -10, 0, 38)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TS:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 40)}):Play()
        callback()
    end)
    parent.CanvasSize = UDim2.new(0, 0, 0, parent.UIListLayout.AbsoluteContentSize.Y + 20)
end

local function CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Text = "  " .. text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 46, 0, 22)
    toggleBtn.Position = UDim2.new(1, -56, 0.5, -11)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(50, 50, 60)
    toggleBtn.Text = ""
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", toggleBtn)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local active = default
    toggleBtn.MouseButton1Click:Connect(function()
        active = not active
        TS:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(50, 50, 60)}):Play()
        TS:Create(circle, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        callback(active)
    end)
    parent.CanvasSize = UDim2.new(0, 0, 0, parent.UIListLayout.AbsoluteContentSize.Y + 20)
end

local function CreateInput(parent, text, defaultVal, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Text = "  " .. text
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0, 70, 0, 30)
    input.Position = UDim2.new(1, -80, 0.5, -15)
    input.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    input.TextColor3 = Color3.fromRGB(138, 43, 226)
    input.Font = Enum.Font.GothamBold
    input.Text = tostring(defaultVal)
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", input).Color = Color3.fromRGB(80, 80, 100)
    
    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then
            callback(val)
        else
            input.Text = tostring(defaultVal)
        end
    end)
    parent.CanvasSize = UDim2.new(0, 0, 0, parent.UIListLayout.AbsoluteContentSize.Y + 20)
end

--// CRIANDO AS PÁGINAS
local PlayerP = CreateTab("Jogador")
local VisualP = CreateTab("Visual (ESP)")
local EBP = CreateTab("Hacks (EB)")
local MiscP = CreateTab("Outros")

--// PÁGINA: JOGADOR
CreateInput(PlayerP, "Velocidade (WalkSpeed)", 16, function(v) _G.ZakySettings.WalkSpeed = v end)
CreateInput(PlayerP, "Pulo (JumpPower)", 50, function(v) _G.ZakySettings.JumpPower = v end)
CreateToggle(PlayerP, "Pulo Infinito", false, function(v) _G.ZakySettings.InfJump = v end)
CreateToggle(PlayerP, "Atravessar Paredes", false, function(v) _G.ZakySettings.Noclip = v end)
CreateToggle(PlayerP, "Auto Parkour (Torres/Gaps)", false, function(v) _G.ZakySettings.AutoParkour = v end)

CreateButton(PlayerP, "Ativar FlyGui V3", function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() end)
end)

--// PÁGINA: HACKS (EXÉRCITO BRASILEIRO)
CreateButton(EBP, "Bypass: Destruir Portas/Grades", function()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            if string.find(name, "door") or string.find(name, "porta") or string.find(name, "gate") or string.find(name, "grade") then
                obj.CanCollide = false
                obj.Transparency = 0.5
                obj.BrickColor = BrickColor.new("Bright red")
            end
        end
    end
end)

CreateToggle(EBP, "Hitbox Expander (Corpo a Corpo)", false, function(v)
    _G.ZakySettings.HitboxExpander = v
end)

CreateButton(EBP, "Click Teleport (Ctrl + Clique)", function()
    Mouse.Button1Down:Connect(function()
        if not UIS:IsKeyDown(Enum.KeyCode.LeftControl) then return end
        if Mouse.Target then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.X, Mouse.Hit.Y + 3, Mouse.Hit.Z)
            end
        end
    end)
end)

--// PÁGINA: VISUAL ESP
CreateToggle(VisualP, "Ligar ESP", false, function(v) _G.ZakySettings.ESP_Enabled = v end)
CreateToggle(VisualP, "Mostrar Nomes", false, function(v) _G.ZakySettings.ESP_Names = v end)
CreateToggle(VisualP, "Mostrar Caixas", false, function(v) _G.ZakySettings.ESP_Box = v end)

--// LÓGICA DO AUTO PARKOUR (STATE MACHINE)
local isDoingAction = false

local function HandleAutoParkour(char, hrp, hum)
    if not _G.ZakySettings.AutoParkour or isDoingAction then return end
    if hum.MoveDirection.Magnitude == 0 then return end -- Só funciona se estiver andando

    local rayOrigin = hrp.Position
    local lookVector = hrp.CFrame.LookVector
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude

    -- Raio para frente (detecta paredes/torres)
    local forwardRay = Workspace:Raycast(rayOrigin, lookVector * 3.5, params)
    
    -- Raio para baixo à frente (detecta buracos/gaps)
    local downRayOrigin = rayOrigin + (lookVector * 4)
    local downRay = Workspace:Raycast(downRayOrigin, Vector3.new(0, -6, 0), params)

    -- 1. Detecção de Torre (Parede Alta na Frente)
    if forwardRay then
        local hitPart = forwardRay.Instance
        if hitPart and hitPart.CanCollide then
            -- Inicia a manobra de Flick (Torre)
            isDoingAction = true
            task.spawn(function()
                -- Pula
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.05)
                
                -- Impulso para trás (evita bater a cabeça no degrau)
                hrp.Velocity = (lookVector * -15) + Vector3.new(0, hum.JumpPower, 0)
                task.wait(0.2)
                
                -- Impulso para frente (encaixa no andar de cima)
                hrp.Velocity = (lookVector * 25) + Vector3.new(0, hrp.Velocity.Y, 0)
                task.wait(0.4)
                isDoingAction = false
            end)
            return
        end
    end

    -- 2. Detecção de Buraco (Gap Jump)
    if not downRay then
        if hum:GetState() ~= Enum.HumanoidStateType.Freefall and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            -- Pequeno boost horizontal para garantir que chegue do outro lado
            hrp.Velocity = hrp.Velocity + (lookVector * 10)
        end
    end
end

--// LÓGICA CORE (RunService)
RS.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    -- Updates Player
    hum.WalkSpeed = _G.ZakySettings.WalkSpeed
    if hum.UseJumpPower ~= nil then hum.UseJumpPower = true end
    hum.JumpPower = _G.ZakySettings.JumpPower

    -- Noclip
    if _G.ZakySettings.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- Hitbox Expander
    if _G.ZakySettings.HitboxExpander then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(15, 15, 15)
                p.Character.HumanoidRootPart.Transparency = 0.8
                p.Character.HumanoidRootPart.BrickColor = BrickColor.new("Bright purple")
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    -- Chamada do Auto Parkour Inteligente
    HandleAutoParkour(char, hrp, hum)
end)

-- Inf Jump
UIS.JumpRequest:Connect(function()
    if _G.ZakySettings.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--// ESP SYSTEM (Highlight)
local function ManageESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char and _G.ZakySettings.ESP_Enabled then
                if not char:FindFirstChild("ZakyESP") then
                    local hl = Instance.new("Highlight", char)
                    hl.Name = "ZakyESP"
                    hl.FillColor = _G.ZakySettings.ESP_Color
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.FillTransparency = 0.5
                end
            else
                if char and char:FindFirstChild("ZakyESP") then
                    char.ZakyESP:Destroy()
                end
            end
        end
    end
end
RS.Heartbeat:Connect(ManageESP)

--// SISTEMA DE MINIMIZAR / MAXIMIZAR
MinBtn.MouseButton1Click:Connect(function()
    TS:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0), Position = FloatBtn.Position
    }):Play()
    task.wait(0.3)
    MainFrame.Visible = false
    FloatBtn.Visible = true
end)

FloatBtn.MouseButton1Click:Connect(function()
    FloatBtn.Visible = false
    MainFrame.Visible = true
    TS:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 450, 0, 320), Position = UDim2.new(0.5, -225, 0.5, -160)
    }):Play()
end)

-- Iniciar
Tabs["Jogador"].Btn:Click()
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TS:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 450, 0, 320)
}):Play()
