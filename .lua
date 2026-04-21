--[[
    ZakyHub V4 - Ultimate Mobile Edition
    PARTE 1: CONFIGURAÇÕES E ESTRUTURA BASE
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// 1. SISTEMA DE TRADUÇÃO E CONFIGURAÇÃO
local _G = getgenv and getgenv() or _G
_G.ZakySettings = {
    Lang = "PT", -- "PT" ou "EN"
    ESP_Enabled = false, ESP_Names = false, ESP_Health = false, ESP_Box = false,
    ESP_Color = Color3.fromRGB(138, 43, 226),
    WalkSpeed = 16, JumpPower = 50, InfJump = false, Noclip = false,
    AutoParkour = false,
    TargetPlayer = nil,
    LockCamera = false
}

local LangTable = {
    PT = {
        Player = "Jogador", Visual = "Visual", EB = "Hacks EB", Settings = "Configs",
        Speed = "Velocidade", Jump = "Pulo", InfJump = "Pulo Infinito", Noclip = "Noclip",
        Parkour = "Auto Parkour (Pare e Analise)", ESP = "Ligar ESP", Names = "Nomes",
        Health = "Barra de Vida", Box = "Caixas", LangSel = "Idioma", ThemeColor = "Cor do ESP",
        Aimbot = "Travar Câmera", Analysis = "Analisando Obstáculo...", JumpExec = "Executando Pulo!"
    },
    EN = {
        Player = "Player", Visual = "Visual", EB = "EB Hacks", Settings = "Settings",
        Speed = "WalkSpeed", Jump = "JumpPower", InfJump = "Infinite Jump", Noclip = "Noclip",
        Parkour = "Auto Parkour (Stop to Analyze)", ESP = "Enable ESP", Names = "Names",
        Health = "Health Bar", Box = "Boxes", LangSel = "Language", ThemeColor = "ESP Color",
        Aimbot = "Target Lock", Analysis = "Analyzing Obstacle...", JumpExec = "Executing Jump!"
    }
}

-- Limpeza
if CoreGui:FindFirstChild("ZakyHub_V4") then CoreGui.ZakyHub_V4:Destroy() end

--// 2. INTERFACE MODERNA
local ZakyHub = Instance.new("ScreenGui", CoreGui)
ZakyHub.Name = "ZakyHub_V4"

local MainFrame = Instance.new("Frame", ZakyHub)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = _G.ZakySettings.ESP_Color
MainStroke.Thickness = 2

-- HUD de Análise do Parkour
local AnalysisHud = Instance.new("TextLabel", ZakyHub)
AnalysisHud.Size = UDim2.new(0, 200, 0, 40)
AnalysisHud.Position = UDim2.new(0.5, -100, 0.2, 0)
AnalysisHud.BackgroundTransparency = 1
AnalysisHud.TextColor3 = Color3.new(1, 1, 1)
AnalysisHud.Font = Enum.Font.GothamBold
AnalysisHud.TextSize = 18
AnalysisHud.Text = ""
AnalysisHud.Visible = false--// 2. CONTINUAÇÃO: BARRA LATERAL (SIDEBAR)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, -10)
Sidebar.Position = UDim2.new(0, 5, 0, 5)
Sidebar.BackgroundTransparency = 1
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)

local Container = Instance.new("Frame", MainFrame)
Container.Position = UDim2.new(0, 140, 0, 10)
Container.Size = UDim2.new(1, -150, 1, -20)
Container.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name, id)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = name
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    btn.TextSize = 14
    Instance.new("UICorner", btn)

    local page = Instance.new("ScrollingFrame", Container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.P.Visible = false t.B.BackgroundColor3 = Color3.fromRGB(25, 25, 35) end
        page.Visible = true
        btn.BackgroundColor3 = _G.ZakySettings.ESP_Color
    end)

    Tabs[id] = {B = btn, P = page}
    return page
end

--// COMPONENTES (Input e Toggle)
local function CreateToggle(parent, id, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -10, 0, 35)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Instance.new("UICorner", f)
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.Text = "  " .. id
    l.TextColor3 = Color3.new(1, 1, 1)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 40, 0, 20)
    b.Position = UDim2.new(1, -45, 0.5, -10)
    b.Text = ""
    b.BackgroundColor3 = default and _G.ZakySettings.ESP_Color or Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

    b.MouseButton1Click:Connect(function()
        local state = b.BackgroundColor3 == Color3.fromRGB(50, 50, 60)
        b.BackgroundColor3 = state and _G.ZakySettings.ESP_Color or Color3.fromRGB(50, 50, 60)
        callback(state)
    end)
    parent.CanvasSize = UDim2.new(0, 0, 0, parent.UIListLayout.AbsoluteContentSize.Y + 10)
end

local function CreateInput(parent, label, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -10, 0, 35)
    f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Text = label
    l.Size = UDim2.new(0.6, 0, 1, 0)
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left

    local i = Instance.new("TextBox", f)
    i.Size = UDim2.new(0, 60, 0, 25)
    i.Position = UDim2.new(1, -65, 0.5, -12)
    i.Text = tostring(default)
    i.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    i.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", i)
    i.FocusLost:Connect(function() callback(i.Text) end)
end--// 3. CRIAR CONTEÚDO DAS ABAS
local pPlayer = CreateTab("Jogador", "Player")
local pVisual = CreateTab("Visual", "Visual")
local pTarget = CreateTab("Aimbot", "Aimbot")
local pSettings = CreateTab("Configurações", "Settings")

--// PÁGINA JOGADOR
CreateInput(pPlayer, "Velocidade", 16, function(t) _G.ZakySettings.WalkSpeed = tonumber(t) or 16 end)
CreateInput(pPlayer, "Pulo", 50, function(t) _G.ZakySettings.JumpPower = tonumber(t) or 50 end)
CreateToggle(pPlayer, "Pulo Infinito", false, function(v) _G.ZakySettings.InfJump = v end)
CreateToggle(pPlayer, "Noclip", false, function(v) _G.ZakySettings.Noclip = v end)
CreateToggle(pPlayer, "Auto Parkour", false, function(v) _G.ZakySettings.AutoParkour = v end)

--// PÁGINA VISUAL
CreateToggle(pVisual, "Ligar ESP", false, function(v) _G.ZakySettings.ESP_Enabled = v end)
CreateToggle(pVisual, "Nomes", false, function(v) _G.ZakySettings.ESP_Names = v end)
CreateToggle(pVisual, "Vida", false, function(v) _G.ZakySettings.ESP_Health = v end)
CreateToggle(pVisual, "Caixas", false, function(v) _G.ZakySettings.ESP_Box = v end)

--// PÁGINA AIMBOT (TARGET)
local PlayerDropdown = Instance.new("TextBox", pTarget)
PlayerDropdown.Size = UDim2.new(1, -10, 0, 35)
PlayerDropdown.PlaceholderText = "Nome do Jogador..."
PlayerDropdown.Text = ""
PlayerDropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
PlayerDropdown.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", PlayerDropdown)

CreateToggle(pTarget, "Travar Câmera", false, function(v)
    _G.ZakySettings.LockCamera = v
    for _, p in pairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), string.lower(PlayerDropdown.Text)) then
            _G.ZakySettings.TargetPlayer = p
            break
        end
    end
end)

--// PÁGINA CONFIGS
local LangBtn = Instance.new("TextButton", pSettings)
LangBtn.Size = UDim2.new(1, -10, 0, 35)
LangBtn.Text = "Idioma: PT"
LangBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
LangBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", LangBtn)
LangBtn.MouseButton1Click:Connect(function()
    _G.ZakySettings.Lang = (_G.ZakySettings.Lang == "PT") and "EN" or "PT"
    LangBtn.Text = "Idioma: " .. _G.ZakySettings.Lang
end)

local ColorInput = Instance.new("TextBox", pSettings)
ColorInput.Size = UDim2.new(1, -10, 0, 35)
ColorInput.PlaceholderText = "Cor R,G,B (Ex: 255,0,0)"
ColorInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ColorInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ColorInput)
ColorInput.FocusLost:Connect(function()
    local r, g, b = ColorInput.Text:match("(%d+),(%d+),(%d+)")
    if r and g and b then
        _G.ZakySettings.ESP_Color = Color3.fromRGB(r, g, b)
        MainStroke.Color = _G.ZakySettings.ESP_Color
    end
end)

--// LÓGICA DO AUTO PARKOUR INTELIGENTE
local analysisTimer = 0
local isJumping = false

RS.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char or not _G.ZakySettings.AutoParkour or isJumping then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    if hrp.Velocity.Magnitude < 1 then
        local ray = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 5, RaycastParams.new())
        if ray and ray.Instance.CanCollide then
            analysisTimer = analysisTimer + dt
            AnalysisHud.Visible = true
            AnalysisHud.Text = LangTable[_G.ZakySettings.Lang].Analysis .. " (" .. math.floor((analysisTimer/1.5)*100) .. "%)"
            
            if analysisTimer >= 1.5 then
                isJumping = true
                AnalysisHud.Text = LangTable[_G.ZakySettings.Lang].JumpExec
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.1)
                hrp.Velocity = (hrp.CFrame.LookVector * -15) + Vector3.new(0, hum.JumpPower, 0)
                task.wait(0.2)
                hrp.Velocity = (hrp.CFrame.LookVector * 30) + Vector3.new(0, 20, 0)
                task.wait(0.5)
                analysisTimer = 0
                isJumping = false
                AnalysisHud.Visible = false
            end
        else
            analysisTimer = 0
            AnalysisHud.Visible = false
        end
    else
        analysisTimer = 0
        AnalysisHud.Visible = false
    end
end)--// 4. LÓGICA DO ESP MELHORADO
local function CreateESP(p)
    local bg = Instance.new("BillboardGui", CoreGui)
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 100, 0, 50)
    bg.Name = "ZakyESP_" .. p.Name

    local nameL = Instance.new("TextLabel", bg)
    nameL.Size = UDim2.new(1, 0, 0.4, 0)
    nameL.BackgroundTransparency = 1
    nameL.TextColor3 = _G.ZakySettings.ESP_Color
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 12

    local healthBar = Instance.new("Frame", bg)
    healthBar.Size = UDim2.new(0.8, 0, 0, 4)
    healthBar.Position = UDim2.new(0.1, 0, 0.5, 0)
    healthBar.BackgroundColor3 = Color3.new(1, 0, 0)

    local healthIn = Instance.new("Frame", healthBar)
    healthIn.Size = UDim2.new(1, 0, 1, 0)
    healthIn.BackgroundColor3 = Color3.new(0, 1, 0)

    RS.RenderStepped:Connect(function()
        if _G.ZakySettings.ESP_Enabled and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            bg.Adornee = p.Character.HumanoidRootPart
            bg.Enabled = true
            nameL.Visible = _G.ZakySettings.ESP_Names
            nameL.Text = p.Name .. " [" .. math.floor((p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
            
            healthBar.Visible = _G.ZakySettings.ESP_Health
            healthIn.Size = UDim2.new(p.Character.Humanoid.Health / p.Character.Humanoid.MaxHealth, 0, 1, 0)
        else
            bg.Enabled = false
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

--// 5. TARGET LOCK (AIMBOT) E LOOP PRINCIPAL
RS.RenderStepped:Connect(function()
    if _G.ZakySettings.LockCamera and _G.ZakySettings.TargetPlayer and _G.ZakySettings.TargetPlayer.Character then
        local targetPos = _G.ZakySettings.TargetPlayer.Character.HumanoidRootPart.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.ZakySettings.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = _G.ZakySettings.JumpPower
    end
end)

-- Draggable Functionality
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

-- Inicializa o Menu
Tabs.Player.B.BackgroundColor3 = _G.ZakySettings.ESP_Color
Tabs.Player.P.Visible = true
