--[[
    ZakyHub - Mobile Edition
    Desenvolvido para máxima performance e usabilidade em telas touch.
    Compatível com: Delta, Hydrogen, Fluxus, Codex, etc.
]]

--// SERVIÇOS
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--// VARIÁVEIS LOCAIS
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// ESTADOS DO HUB
local _G = getgenv and getgenv() or _G
_G.ZakySettings = {
    ESP_Enabled = false,
    ESP_Names = true,
    ESP_Dist = true,
    ESP_Health = true,
    ESP_Box = true,
    ESP_Tracers = false,
    ESP_Avatars = true,
    ESP_MaxDist = 500,
    ESP_Color = Color3.fromRGB(100, 50, 255),
    
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    FlySpeed = 50,
    Flying = false,
    Noclip = false
}

--// FUNÇÕES AUXILIARES DE UI
local function MakeDraggable(frame, parent)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// CRIAÇÃO DA INTERFACE PRINCIPAL
local ZakyHub = Instance.new("ScreenGui")
ZakyHub.Name = "ZakyHub"
ZakyHub.Parent = CoreGui
ZakyHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ZakyHub
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(100, 50, 255)
MainStroke.Thickness = 2

--// BARRA SUPERIOR
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MakeDraggable(TopBar, MainFrame)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = " ZAKY HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Text = "—"
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Position = UDim2.new(1, -40, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20

--// BOTÃO MINIMIZADO (FLUTUANTE)
local FloatBtn = Instance.new("ImageButton", ZakyHub)
FloatBtn.Name = "FloatBtn"
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0, 20, 0.5, -25)
FloatBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
FloatBtn.Visible = false
FloatBtn.Image = "rbxassetid://6031068433" -- Logo Z

local FloatCorner = Instance.new("UICorner", FloatBtn)
FloatCorner.CornerRadius = UDim.new(1, 0)
MakeDraggable(FloatBtn, FloatBtn)

--// NAVEGAÇÃO
local NavBar = Instance.new("Frame", MainFrame)
NavBar.Position = UDim2.new(0, 10, 0, 45)
NavBar.Size = UDim2.new(0, 100, 1, -55)
NavBar.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", NavBar)
UIList.Padding = UDim.new(0, 5)

local Container = Instance.new("Frame", MainFrame)
Container.Position = UDim2.new(0, 120, 0, 45)
Container.Size = UDim2.new(1, -130, 1, -55)
Container.BackgroundTransparency = 1

local TabIndicator = Instance.new("Frame", NavBar)
TabIndicator.Size = UDim2.new(0, 2, 0, 30)
TabIndicator.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
TabIndicator.Position = UDim2.new(0, -5, 0, 0)

--// SISTEMA DE ABAS
local Tabs = {}
local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton", NavBar)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.ScrollBarThickness = 2
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 8)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Page.Visible = false t.Btn.TextColor3 = Color3.new(0.8, 0.8, 0.8) end
        TabPage.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(100, 50, 255)
        TS:Create(TabIndicator, TweenInfo.new(0.3), {Position = UDim2.new(0, -5, 0, TabBtn.Position.Y.Offset)}):Play()
    end)
    
    Tabs[name] = {Btn = TabBtn, Page = TabPage}
    return TabPage
end

--// COMPONENTES DE UI (MOBILE FRIENDLY)
local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    parent.CanvasSize = UDim2.new(0, 0, 0, parent.UIListLayout.AbsoluteContentSize.Y + 10)
end

local function CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Instance.new("UICorner", frame)
    
    local label = Instance.new("TextLabel", frame)
    label.Text = " " .. text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 50, 0, 24)
    toggle.Position = UDim2.new(1, -60, 0.5, -12)
    toggle.BackgroundColor3 = default and Color3.fromRGB(100, 50, 255) or Color3.fromRGB(50, 50, 60)
    toggle.Text = ""
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", toggle)
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local active = default
    toggle.MouseButton1Click:Connect(function()
        active = not active
        TS:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(100, 50, 255) or Color3.fromRGB(50, 50, 60)}):Play()
        TS:Create(circle, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
        callback(active)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Text = text .. ": " .. default
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    
    local slideBack = Instance.new("Frame", frame)
    slideBack.Size = UDim2.new(1, 0, 0, 6)
    slideBack.Position = UDim2.new(0, 0, 0, 30)
    slideBack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    
    local slideMain = Instance.new("Frame", slideBack)
    slideMain.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    slideMain.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    
    local function UpdateSlide(input)
        local pos = math.clamp((input.Position.X - slideBack.AbsolutePosition.X) / slideBack.AbsoluteSize.X, 0, 1)
        slideMain.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + (max - min) * pos)
        label.Text = text .. ": " .. value
        callback(value)
    end
    
    slideBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            UpdateSlide(input)
            local con; con = UIS.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    UpdateSlide(input)
                else con:Disconnect() end
            end)
        end
    end)
end

--// CRIAÇÃO DAS PÁGINAS
local HomeP = CreateTab("Home")
local PlayerP = CreateTab("Player")
local VisualP = CreateTab("Visual")
local WorldP = CreateTab("World")
local ScriptsP = CreateTab("Scripts")

--// HOME PAGE
local Welcome = Instance.new("TextLabel", HomeP)
Welcome.Text = "Bem-vindo ao ZakyHub!\nStatus: Ativo\nUsuario: " .. LocalPlayer.Name
Welcome.Size = UDim2.new(1, 0, 0, 60)
Welcome.BackgroundTransparency = 1
Welcome.TextColor3 = Color3.new(1, 1, 1)
Welcome.Font = Enum.Font.GothamBold
Welcome.TextSize = 16

CreateButton(HomeP, "Injetar ESP Máximo", function() Tabs["Visual"].Btn:Click() end)

--// PLAYER PAGE
CreateSlider(PlayerP, "WalkSpeed", 16, 250, 16, function(v) _G.ZakySettings.WalkSpeed = v end)
CreateSlider(PlayerP, "JumpPower", 50, 500, 50, function(v) _G.ZakySettings.JumpPower = v end)
CreateToggle(PlayerP, "Infinite Jump", false, function(v) _G.ZakySettings.InfJump = v end)
CreateToggle(PlayerP, "Fly", false, function(v) _G.ZakySettings.Flying = v end)
CreateToggle(PlayerP, "Noclip", false, function(v) _G.ZakySettings.Noclip = v end)

--// VISUAL PAGE (ESP SETTINGS)
CreateToggle(VisualP, "Ativar ESP Global", false, function(v) _G.ZakySettings.ESP_Enabled = v end)
CreateToggle(VisualP, "Mostrar Nomes", true, function(v) _G.ZakySettings.ESP_Names = v end)
CreateToggle(VisualP, "Mostrar Distancia", true, function(v) _G.ZakySettings.ESP_Dist = v end)
CreateToggle(VisualP, "Barra de Vida", true, function(v) _G.ZakySettings.ESP_Health = v end)
CreateToggle(VisualP, "Caixas (Box)", true, function(v) _G.ZakySettings.ESP_Box = v end)
CreateToggle(VisualP, "Tracers", false, function(v) _G.ZakySettings.ESP_Tracers = v end)
CreateSlider(VisualP, "Distancia Max", 100, 5000, 500, function(v) _G.ZakySettings.ESP_MaxDist = v end)

--// SCRIPTS PAGE
local CustomCode = Instance.new("TextBox", ScriptsP)
CustomCode.Size = UDim2.new(1, -10, 0, 100)
CustomCode.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
CustomCode.Text = "-- Cole seu script aqui"
CustomCode.TextColor3 = Color3.new(1, 1, 1)
CustomCode.ClearTextOnFocus = false
CustomCode.MultiLine = true
CustomCode.TextYAlignment = Enum.TextYAlignment.Top
Instance.new("UICorner", CustomCode)

CreateButton(ScriptsP, "Executar Código", function()
    local success, err = pcall(function()
        loadstring(CustomCode.Text)()
    end)
    if not success then warn("Erro ZakyHub: " .. err) end
end)

--// SISTEMA DE MINIMIZAR
MinBtn.MouseButton1Click:Connect(function()
    TS:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0), Position = FloatBtn.Position}):Play()
    task.wait(0.3)
    MainFrame.Visible = false
    FloatBtn.Visible = true
end)

FloatBtn.MouseButton1Click:Connect(function()
    FloatBtn.Visible = false
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    TS:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 400, 0, 300), Position = UDim2.new(0.5, -200, 0.5, -150)}):Play()
end)

--// LÓGICA DE MOVIMENTAÇÃO (FLY, SPEED, JUMP)
RS.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            char.Humanoid.WalkSpeed = _G.ZakySettings.WalkSpeed
            char.Humanoid.JumpPower = _G.ZakySettings.JumpPower
            
            if _G.ZakySettings.Noclip then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)
end)

UIS.JumpRequest:Connect(function()
    if _G.ZakySettings.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

--// SISTEMA DE ESP (OPTIMIZED DRAWING / BILLBOARD)
local function CreatePlayerESP(p)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Tracer = Drawing.new("Line")
    
    local function RemoveESP()
        Box:Remove(); Name:Remove(); Tracer:Remove()
    end
    
    local updater; updater = RS.RenderStepped:Connect(function()
        if _G.ZakySettings.ESP_Enabled and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= LocalPlayer then
            local hrp = p.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            
            if onScreen and dist <= _G.ZakySettings.ESP_MaxDist then
                if _G.ZakySettings.ESP_Box then
                    Box.Visible = true
                    Box.Size = Vector2.new(2000/dist, 2500/dist)
                    Box.Position = Vector2.new(pos.X - Box.Size.X/2, pos.Y - Box.Size.Y/2)
                    Box.Color = _G.ZakySettings.ESP_Color
                    Box.Thickness = 1
                else Box.Visible = false end
                
                if _G.ZakySettings.ESP_Names then
                    Name.Visible = true
                    Name.Text = string.format("%s\n[%d m]", p.Name, math.floor(dist))
                    Name.Position = Vector2.new(pos.X, pos.Y - (2500/dist)/2 - 25)
                    Name.Center = true
                    Name.Outline = true
                    Name.Size = 14
                    Name.Color = Color3.new(1, 1, 1)
                else Name.Visible = false end
                
                if _G.ZakySettings.ESP_Tracers then
                    Tracer.Visible = true
                    Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(pos.X, pos.Y)
                    Tracer.Color = _G.ZakySettings.ESP_Color
                else Tracer.Visible = false end
            else
                Box.Visible = false; Name.Visible = false; Tracer.Visible = false
            end
        else
            Box.Visible = false; Name.Visible = false; Tracer.Visible = false
            if not p.Parent then RemoveESP() updater:Disconnect() end
        end
    end)
end

-- Inicializar ESP para todos
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreatePlayerESP(p) end
end
Players.PlayerAdded:Connect(CreatePlayerESP)

--// ANIMAÇÃO DE ENTRADA
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1
TS:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 400, 0, 300), BackgroundTransparency = 0}):Play()

-- Selecionar primeira aba
Tabs["Home"].Btn:Click()

print("ZakyHub Carregado com Sucesso!")
