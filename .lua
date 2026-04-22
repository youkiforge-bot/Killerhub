--[[ ZakyHub - Parte 1/3: Estrutura base da interface e abas ]]

-- ==================== SERVIÇOS ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== REMOVER INTERFACE ANTIGA ====================
if playerGui:FindFirstChild("ZakyHub") then
    playerGui.ZakyHub:Destroy()
end

-- ==================== CRIAÇÃO DA SCREENGUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZakyHub"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ==================== VARIÁVEIS GLOBAIS ====================
local mainFrame
local floatButton
local isMinimized = false
local originalPosition = UDim2.new(0.05, 0, 0.1, 0)

-- Configurações do ESP
local espSettings = {
    enabled = false,
    box = true,
    name = true,
    distance = true,
    health = true,
    avatar = true,
    tracer = false,
    maxDistance = 500,
    boxColor = Color3.fromRGB(255, 255, 255),
    tracerColor = Color3.fromRGB(255, 0, 0)
}
local espObjects = {}

-- Variáveis de funções
local flyEnabled = false
local flySpeed = 50
local speedEnabled = false
local walkSpeed = 16
local jumpEnabled = false
local infiniteJump = false
local autoFarmEnabled = false

-- ==================== FUNÇÃO DE NOTIFICAÇÃO ====================
local function notify(title, text, duration)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.12, 0)
    frame.Position = UDim2.new(0.1, 0, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 50, 255)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.5, 0)
    textLabel.Position = UDim2.new(0, 0, 0.35, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.Parent = frame

    if duration then
        task.wait(duration)
        frame:Destroy()
    end
end

-- ==================== FUNÇÃO PARA CRIAR A INTERFACE PRINCIPAL ====================
local function createMainUI()
    -- Frame principal
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
    mainFrame.Position = originalPosition
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(100, 50, 255)
    mainStroke.Thickness = 2
    mainStroke.Parent = mainFrame

    -- Animação de entrada
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    local tweenIn = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.9, 0, 0.8, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tweenIn:Play()
    mainFrame.AnchorPoint = Vector2.new(0, 0)

    -- Barra superior
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0.12, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = topBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ZakyHub"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    -- Botão minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
    minimizeBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    minimizeBtn.Text = "–"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 24
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = topBar
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeBtn

    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
    closeBtn.Position = UDim2.new(0.82, 0, 0.15, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = topBar
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    -- Abas
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 0.1, 0)
    tabFrame.Position = UDim2.new(0, 0, 0.12, 0)
    tabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = mainFrame

    local tabs = {"Home", "Player", "Visual", "World", "Scripts"}
    local tabButtons = {}
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0.2, 0, 0.04, 0)
    indicator.Position = UDim2.new(0, 0, 0.96, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    indicator.BorderSizePixel = 0
    indicator.Parent = tabFrame
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 4)
    indCorner.Parent = indicator

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.2, 0, 1, 0)
        btn.Position = UDim2.new((i-1)*0.2, 0, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = name
        btn.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
        btn.TextSize = 16
        btn.Font = i == 1 and Enum.Font.GothamBold or Enum.Font.Gotham
        btn.Parent = tabFrame
        tabButtons[name] = btn
    end

    -- Conteúdo das abas
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 0.78, 0)
    contentFrame.Position = UDim2.new(0, 0, 0.22, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local pages = {}
    for _, name in ipairs(tabs) do
        local page = Instance.new("Frame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = (name == "Home")
        page.Parent = contentFrame
        pages[name] = page
    end
    --[[ ZakyHub - Parte 2/3: Conteúdo das abas, sliders, checkboxes e lógica de eventos ]]

-- Continuação da função createMainUI() (dentro da mesma função)

    -- ========== PREENCHER PÁGINAS ==========

    -- HOME
    local homePage = pages["Home"]
    local welcome = Instance.new("TextLabel")
    welcome.Size = UDim2.new(0.9, 0, 0.15, 0)
    welcome.Position = UDim2.new(0.05, 0, 0.05, 0)
    welcome.BackgroundTransparency = 1
    welcome.Text = "Bem-vindo ao ZakyHub!"
    welcome.TextColor3 = Color3.fromRGB(255, 255, 255)
    welcome.TextSize = 22
    welcome.Font = Enum.Font.GothamBold
    welcome.TextXAlignment = Enum.TextXAlignment.Left
    welcome.Parent = homePage

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
    statusLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
    statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    statusLabel.Text = "Status: Pronto"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 16
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = homePage
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusLabel

    -- PLAYER
    local playerPage = pages["Player"]
    local function addSlider(parent, y, text, min, max, default, callback)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.9, 0, 0.1, 0)
        label.Position = UDim2.new(0.05, 0, y, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 16
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = parent

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.9, 0, 0.05, 0)
        slider.Position = UDim2.new(0.05, 0, y + 0.12, 0)
        slider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        slider.Parent = parent
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 4)
        sliderCorner.Parent = slider

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 4)
        fillCorner.Parent = fill

        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0.06, 0, 1.5, 0)
        knob.Position = UDim2.new((default - min)/(max - min) - 0.03, 0, -0.25, 0)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Text = ""
        knob.Parent = slider
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(0, 10)
        knobCorner.Parent = knob

        local dragging = false
        knob.MouseButton1Down:Connect(function()
            dragging = true
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = input.Position.X - slider.AbsolutePosition.X
                local percent = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                local value = min + percent * (max - min)
                label.Text = text .. ": " .. math.floor(value)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                knob.Position = UDim2.new(percent - 0.03, 0, -0.25, 0)
                callback(value)
            end
        end)
        return label, slider
    end

    addSlider(playerPage, 0.05, "WalkSpeed", 16, 200, 16, function(v) walkSpeed = v; if speedEnabled then player.Character.Humanoid.WalkSpeed = v end end)
    addSlider(playerPage, 0.25, "JumpPower", 50, 300, 50, function(v) if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = v end end)
    addSlider(playerPage, 0.45, "Fly Speed", 20, 200, 50, function(v) flySpeed = v end)

    local flyToggle = Instance.new("TextButton")
    flyToggle.Size = UDim2.new(0.9, 0, 0.1, 0)
    flyToggle.Position = UDim2.new(0.05, 0, 0.65, 0)
    flyToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    flyToggle.Text = "Fly: OFF"
    flyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyToggle.TextSize = 18
    flyToggle.Font = Enum.Font.GothamBold
    flyToggle.Parent = playerPage
    local flyCorner = Instance.new("UICorner")
    flyCorner.CornerRadius = UDim.new(0, 8)
    flyCorner.Parent = flyToggle

    local speedToggle = Instance.new("TextButton")
    speedToggle.Size = UDim2.new(0.9, 0, 0.1, 0)
    speedToggle.Position = UDim2.new(0.05, 0, 0.78, 0)
    speedToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    speedToggle.Text = "Speed: OFF"
    speedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggle.TextSize = 18
    speedToggle.Font = Enum.Font.GothamBold
    speedToggle.Parent = playerPage
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 8)
    speedCorner.Parent = speedToggle

    local infJumpToggle = Instance.new("TextButton")
    infJumpToggle.Size = UDim2.new(0.9, 0, 0.1, 0)
    infJumpToggle.Position = UDim2.new(0.05, 0, 0.91, 0)
    infJumpToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    infJumpToggle.Text = "Infinite Jump: OFF"
    infJumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    infJumpToggle.TextSize = 18
    infJumpToggle.Font = Enum.Font.GothamBold
    infJumpToggle.Parent = playerPage
    local infCorner = Instance.new("UICorner")
    infCorner.CornerRadius = UDim.new(0, 8)
    infCorner.Parent = infJumpToggle

    -- VISUAL (ESP)
    local visualPage = pages["Visual"]
    local espToggle = Instance.new("TextButton")
    espToggle.Size = UDim2.new(0.9, 0, 0.1, 0)
    espToggle.Position = UDim2.new(0.05, 0, 0.05, 0)
    espToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    espToggle.Text = "ESP Master: OFF"
    espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    espToggle.TextSize = 18
    espToggle.Font = Enum.Font.GothamBold
    espToggle.Parent = visualPage
    local espCorner = Instance.new("UICorner")
    espCorner.CornerRadius = UDim.new(0, 8)
    espCorner.Parent = espToggle

    local checkY = 0.2
    local function addCheckbox(parent, text, default, callback)
        local box = Instance.new("TextButton")
        box.Size = UDim2.new(0.9, 0, 0.08, 0)
        box.Position = UDim2.new(0.05, 0, checkY, 0)
        box.BackgroundTransparency = 1
        box.Text = (default and "✅ " or "⬜ ") .. text
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.TextSize = 16
        box.Font = Enum.Font.Gotham
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.Parent = parent
        local state = default
        box.MouseButton1Click:Connect(function()
            state = not state
            box.Text = (state and "✅ " or "⬜ ") .. text
            callback(state)
        end)
        checkY = checkY + 0.1
        return box
    end

    addCheckbox(visualPage, "Box", true, function(v) espSettings.box = v end)
    addCheckbox(visualPage, "Nome", true, function(v) espSettings.name = v end)
    addCheckbox(visualPage, "Distância", true, function(v) espSettings.distance = v end)
    addCheckbox(visualPage, "Vida", true, function(v) espSettings.health = v end)
    addCheckbox(visualPage, "Avatar", true, function(v) espSettings.avatar = v end)
    addCheckbox(visualPage, "Tracer", false, function(v) espSettings.tracer = v end)

    addSlider(visualPage, checkY + 0.05, "Distância Max", 100, 1000, 500, function(v) espSettings.maxDistance = v end)

    -- WORLD
    local worldPage = pages["World"]
    local autoFarmToggle = Instance.new("TextButton")
    autoFarmToggle.Size = UDim2.new(0.9, 0, 0.1, 0)
    autoFarmToggle.Position = UDim2.new(0.05, 0, 0.05, 0)
    autoFarmToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    autoFarmToggle.Text = "Auto Farm: OFF"
    autoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoFarmToggle.TextSize = 18
    autoFarmToggle.Font = Enum.Font.GothamBold
    autoFarmToggle.Parent = worldPage
    local afCorner = Instance.new("UICorner")
    afCorner.CornerRadius = UDim.new(0, 8)
    afCorner.Parent = autoFarmToggle

    -- SCRIPTS
    local scriptsPage = pages["Scripts"]
    local scriptBox = Instance.new("TextBox")
    scriptBox.Size = UDim2.new(0.9, 0, 0.5, 0)
    scriptBox.Position = UDim2.new(0.05, 0, 0.05, 0)
    scriptBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    scriptBox.Text = ""
    scriptBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    scriptBox.TextSize = 14
    scriptBox.Font = Enum.Font.Code
    scriptBox.MultiLine = true
    scriptBox.TextWrapped = true
    scriptBox.TextXAlignment = Enum.TextXAlignment.Left
    scriptBox.TextYAlignment = Enum.TextYAlignment.Top
    scriptBox.PlaceholderText = "Cole seu script aqui..."
    scriptBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    scriptBox.Parent = scriptsPage
    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 8)
    sbCorner.Parent = scriptBox

    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0.4, 0, 0.1, 0)
    execBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
    execBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    execBtn.Text = "Executar"
    execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    execBtn.TextSize = 18
    execBtn.Font = Enum.Font.GothamBold
    execBtn.Parent = scriptsPage
    local execCorner = Instance.new("UICorner")
    execCorner.CornerRadius = UDim.new(0, 8)
    execCorner.Parent = execBtn

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.4, 0, 0.1, 0)
    clearBtn.Position = UDim2.new(0.55, 0, 0.6, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    clearBtn.Text = "Limpar"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.TextSize = 18
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.Parent = scriptsPage
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 8)
    clearCorner.Parent = clearBtn

    local scriptsList = Instance.new("ScrollingFrame")
    scriptsList.Size = UDim2.new(0.9, 0, 0.2, 0)
    scriptsList.Position = UDim2.new(0.05, 0, 0.75, 0)
    scriptsList.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    scriptsList.BorderSizePixel = 0
    scriptsList.ScrollBarThickness = 6
    scriptsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    scriptsList.Parent = scriptsPage
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = scriptsList

    -- Adicionar scripts pré-definidos
    local presetScripts = {
        {name = "Killerhub", url = "https://raw.githubusercontent.com/youkiforge-bot/Killerhub/refs/heads/main/.lua"},
        {name = "Fly Gui", code = "loadstring(game:HttpGet('https://pastebin.com/raw/...'))()"}
    }
    local yPos = 0.05
    for i, scriptData in ipairs(presetScripts) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0.1, 0)
        btn.Position = UDim2.new(0.05, 0, yPos, 0)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.Text = scriptData.name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Parent = scriptsList
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(function()
            if scriptData.url then
                scriptBox.Text = 'loadstring(game:HttpGet("' .. scriptData.url .. '"))()'
            else
                scriptBox.Text = scriptData.code
            end
            notify("Script", scriptData.name .. " carregado!", 2)
        end)
        yPos = yPos + 0.12
    end
    scriptsList.CanvasSize = UDim2.new(0, 0, yPos + 0.05, 0)

    -- ========== LÓGICA DE ABAS ==========
    local function switchTab(tabName)
        for name, page in pairs(pages) do
            page.Visible = (name == tabName)
        end
        for name, btn in pairs(tabButtons) do
            if name == tabName then
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.GothamBold
                local idx = table.find(tabs, name)
                TweenService:Create(indicator, TweenInfo.new(0.2), {Position = UDim2.new((idx-1)*0.2, 0, 0.96, 0)}):Play()
            else
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                btn.Font = Enum.Font.Gotham
            end
        end
    end

    for name, btn in pairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            switchTab(name)
        end)
    end

    -- ========== EVENTOS DOS BOTÕES ==========
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = true
        mainFrame.Visible = false
        if not floatButton then
            floatButton = Instance.new("TextButton")
            floatButton.Size = UDim2.new(0.12, 0, 0.08, 0)
            floatButton.Position = UDim2.new(0.8, 0, 0.2, 0)
            floatButton.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
            floatButton.Text = "Z"
            floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            floatButton.TextSize = 24
            floatButton.Font = Enum.Font.GothamBold
            floatButton.Parent = screenGui
            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 25)
            fCorner.Parent = floatButton
            local fStroke = Instance.new("UIStroke")
            fStroke.Color = Color3.fromRGB(255, 255, 255)
            fStroke.Thickness = 1
            fStroke.Parent = floatButton

            -- Arrastar botão flutuante
            local dragging = false
            local dragStart, startPos
            floatButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = floatButton.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.Touch then
                    local delta = input.Position - dragStart
                    floatButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            floatButton.MouseButton1Click:Connect(function()
                if not dragging then
                    isMinimized = false
                    floatButton:Destroy()
                    floatButton = nil
                    mainFrame.Visible = true
                    mainFrame.Position = originalPosition
                    TweenService:Create(mainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.9, 0, 0.8, 0)}):Play()
                end
            end)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    execBtn.MouseButton1Click:Connect(function()
        local code = scriptBox.Text
        if code ~= "" then
            local success, err = pcall(function()
                loadstring(code)()
            end)
            if success then
                notify("Sucesso", "Script executado!", 2)
                statusLabel.Text = "Status: Script executado"
            else
                notify("Erro", "Falha: " .. tostring(err), 3)
            end
        end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        scriptBox.Text = ""
    end)

    -- Toggles de funções
    flyToggle.MouseButton1Click:Connect(function()
        flyEnabled = not flyEnabled
        flyToggle.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
        flyToggle.BackgroundColor3 = flyEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if flyEnabled then
            notify("Fly", "Ativado! Use o joystick para voar.", 2)
        end
    end)

    speedToggle.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        speedToggle.Text = "Speed: " .. (speedEnabled and "ON" or "OFF")
        speedToggle.BackgroundColor3 = speedEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = speedEnabled and walkSpeed or 16
        end
    end)

    infJumpToggle.MouseButton1Click:Connect(function()
        infiniteJump = not infiniteJump
        infJumpToggle.Text = "Infinite Jump: " .. (infiniteJump and "ON" or "OFF")
        infJumpToggle.BackgroundColor3 = infiniteJump and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)

    espToggle.MouseButton1Click:Connect(function()
        espSettings.enabled = not espSettings.enabled
        espToggle.Text = "ESP Master: " .. (espSettings.enabled and "ON" or "OFF")
        espToggle.BackgroundColor3 = espSettings.enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if espSettings.enabled then
            startESP()
        else
            stopESP()
        end
    end)

    autoFarmToggle.MouseButton1Click:Connect(function()
        autoFarmEnabled = not autoFarmEnabled
        autoFarmToggle.Text = "Auto Farm: " .. (autoFarmEnabled and "ON" or "OFF")
        autoFarmToggle.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if autoFarmEnabled then
            notify("Auto Farm", "Procurando inimigos...", 2)
        end
    end)
end--[[ ZakyHub - Parte 3/3: Sistema ESP (Drawing), loops de funções e inicialização ]]

-- ==================== SISTEMA DE ESP (Drawing Library) ====================
function startESP()
    stopESP() -- Limpa qualquer ESP anterior
    espConnections = {}

    local function createESPForPlayer(plr)
        if plr == player then return end
        local drawings = {}
        local char = plr.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum then return end

        -- Box
        if espSettings.box then
            local box = Drawing.new("Square")
            box.Visible = false
            box.Color = espSettings.boxColor
            box.Thickness = 2
            box.Filled = false
            drawings.box = box
        end
        -- Nome
        if espSettings.name then
            local name = Drawing.new("Text")
            name.Visible = false
            name.Color = Color3.fromRGB(255, 255, 255)
            name.Size = 16
            name.Center = true
            name.Outline = true
            drawings.name = name
        end
        -- Distância
        if espSettings.distance then
            local dist = Drawing.new("Text")
            dist.Visible = false
            dist.Color = Color3.fromRGB(200, 200, 200)
            dist.Size = 14
            dist.Center = true
            dist.Outline = true
            drawings.distance = dist
        end
        -- Barra de vida
        if espSettings.health then
            local healthBar = Drawing.new("Square")
            healthBar.Visible = false
            healthBar.Color = Color3.fromRGB(0, 255, 0)
            healthBar.Filled = true
            drawings.healthBar = healthBar
            local healthBg = Drawing.new("Square")
            healthBg.Visible = false
            healthBg.Color = Color3.fromRGB(50, 50, 50)
            healthBg.Filled = true
            drawings.healthBg = healthBg
        end
        -- Avatar (não implementado diretamente via Drawing, usaremos Text com "👤")
        if espSettings.avatar then
            -- Placeholder
        end
        -- Tracer
        if espSettings.tracer then
            local tracer = Drawing.new("Line")
            tracer.Visible = false
            tracer.Color = espSettings.tracerColor
            tracer.Thickness = 1
            drawings.tracer = tracer
        end

        espObjects[plr] = drawings
    end

    local function updateESP()
        for plr, drawings in pairs(espObjects) do
            local char = plr.Character
            if not char then espObjects[plr] = nil continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            local head = char:FindFirstChild("Head")
            if not root or not hum or not head then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local distance = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and (root.Position - player.Character.HumanoidRootPart.Position).Magnitude) or 0

            if onScreen and distance <= espSettings.maxDistance then
                local scale = 1 / (distance * 0.01)
                scale = math.clamp(scale, 0.5, 2)

                if drawings.box then
                    local headPos = Camera:WorldToViewportPoint((head.CFrame * CFrame.new(0, 1.5, 0)).Position)
                    local footPos = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, -2.5, 0)).Position)
                    if headPos and footPos then
                        local size = Vector2.new((headPos.Y - footPos.Y) * 0.6, headPos.Y - footPos.Y)
                        drawings.box.Size = size
                        drawings.box.Position = Vector2.new(headPos.X - size.X/2, headPos.Y)
                        drawings.box.Visible = true
                    end
                end
                if drawings.name then
                    drawings.name.Text = plr.Name
                    drawings.name.Position = Vector2.new(pos.X, pos.Y - 30 * scale)
                    drawings.name.Size = 16 * scale
                    drawings.name.Visible = true
                end
                if drawings.distance then
                    drawings.distance.Text = string.format("%.0f m", distance)
                    drawings.distance.Position = Vector2.new(pos.X, pos.Y - 15 * scale)
                    drawings.distance.Size = 14 * scale
                    drawings.distance.Visible = true
                end
                if drawings.healthBar then
                    local healthPercent = hum.Health / hum.MaxHealth
                    local barWidth = 40 * scale
                    local barHeight = 4 * scale
                    drawings.healthBg.Size = Vector2.new(barWidth, barHeight)
                    drawings.healthBg.Position = Vector2.new(pos.X - barWidth/2, pos.Y + 20 * scale)
                    drawings.healthBg.Visible = true
                    drawings.healthBar.Size = Vector2.new(barWidth * healthPercent, barHeight)
                    drawings.healthBar.Position = Vector2.new(pos.X - barWidth/2, pos.Y + 20 * scale)
                    drawings.healthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    drawings.healthBar.Visible = true
                end
                if drawings.tracer then
                    drawings.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.tracer.To = Vector2.new(pos.X, pos.Y)
                    drawings.tracer.Visible = true
                end
            else
                for _, v in pairs(drawings) do v.Visible = false end
            end
        end
    end

    local function onPlayerAdded(plr)
        createESPForPlayer(plr)
    end
    local function onPlayerRemoving(plr)
        if espObjects[plr] then
            for _, d in pairs(espObjects[plr]) do d:Remove() end
            espObjects[plr] = nil
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        createESPForPlayer(plr)
    end
    table.insert(espConnections, Players.PlayerAdded:Connect(onPlayerAdded))
    table.insert(espConnections, Players.PlayerRemoving:Connect(onPlayerRemoving))
    table.insert(espConnections, RunService.RenderStepped:Connect(updateESP))
end

function stopESP()
    for _, conn in ipairs(espConnections) do
        conn:Disconnect()
    end
    espConnections = {}
    for plr, drawings in pairs(espObjects) do
        for _, d in pairs(drawings) do d:Remove() end
        espObjects[plr] = nil
    end
end

-- ==================== INICIAR TUDO ====================
createMainUI()
notify("ZakyHub", "Carregado com sucesso!", 3)

-- ==================== LOOPS DE FUNÇÕES ====================
-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infiniteJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Auto Farm simples (exemplo genérico)
spawn(function()
    while true do
        if autoFarmEnabled and player.Character then
            local enemies = {}
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v ~= player.Character then
                    local plr = Players:GetPlayerFromCharacter(v)
                    if not plr or plr ~= player then
                        table.insert(enemies, v)
                    end
                end
            end
            if #enemies > 0 then
                local target = enemies[1]
                local root = player.Character.HumanoidRootPart
                local targetRoot = target:FindFirstChild("HumanoidRootPart")
                if root and targetRoot then
                    root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
        task.wait(0.5)
    end
end)
