--[[
    Executor Hub - Versão Funcional Otimizada
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Removendo versões antigas para evitar sobreposição
if playerGui:FindFirstChild("ExecutorHub") then
    playerGui.ExecutorHub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExecutorHub"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true -- Faz a UI ocupar a tela inteira se necessário

-- ==================== FUNÇÃO DE ARRASTAR (DRAG) ====================
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==================== NOTIFICAÇÕES ====================
local function createNotification(title, text, duration)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 250, 0, 80)
    notifFrame.Position = UDim2.new(1, 10, 0.8, 0) -- Começa fora da tela
    notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    notifFrame.Parent = screenGui
    
    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", notifFrame)
    stroke.Color = Color3.fromRGB(100, 50, 255)
    
    local tLabel = Instance.new("TextLabel", notifFrame)
    tLabel.Size = UDim2.new(1, -20, 0.4, 0)
    tLabel.Position = UDim2.new(0, 10, 0, 5)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = Color3.new(1,1,1)
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 14
    tLabel.TextXAlignment = "Left"

    local dLabel = Instance.new("TextLabel", notifFrame)
    dLabel.Size = UDim2.new(1, -20, 0.5, 0)
    dLabel.Position = UDim2.new(0, 10, 0.4, 0)
    dLabel.BackgroundTransparency = 1
    dLabel.Text = text
    dLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    dLabel.Font = Enum.Font.Gotham
    dLabel.TextSize = 12
    dLabel.TextWrapped = true
    dLabel.TextXAlignment = "Left"

    -- Animação de entrada
    notifFrame:TweenPosition(UDim2.new(1, -260, 0.8, 0), "Out", "Quad", 0.4, true)
    
    task.delay(duration or 3, function()
        if notifFrame then
            notifFrame:TweenPosition(UDim2.new(1, 10, 0.8, 0), "In", "Quad", 0.4, true, function()
                notifFrame:Destroy()
            end)
        end
    end)
end

-- ==================== UI PRINCIPAL ====================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 300)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.Parent = screenGui
makeDraggable(mainFrame)

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(80, 40, 200)
mainStroke.Thickness = 2

-- Barra de Título
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", topBar)

local title = Instance.new("TextLabel", topBar)
title.Text = "  EXECUTOR HUB v1.0"
title.Size = UDim2.new(0.7, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextXAlignment = "Left"

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 35, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Botão de Abrir (Flutuante)
local openBtn = Instance.new("TextButton", screenGui)
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 20, 0.5, -25)
openBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 200)
openBtn.Text = "HUB"
openBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
makeDraggable(openBtn)

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- ==================== SISTEMA DE ABAS ====================
local content = Instance.new("Frame", mainFrame)
content.Size = UDim2.new(1, 0, 1, -85)
content.Position = UDim2.new(0, 0, 0, 85)
content.BackgroundTransparency = 1

local tabs = Instance.new("Frame", mainFrame)
tabs.Size = UDim2.new(1, 0, 0, 40)
tabs.Position = UDim2.new(0, 0, 0, 45)
tabs.BackgroundTransparency = 1

local function createTabBtn(name, pos)
    local btn = Instance.new("TextButton", tabs)
    btn.Size = UDim2.new(0.33, -5, 1, 0)
    btn.Position = UDim2.new(pos, 0, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    return btn
end

local bHome = createTabBtn("Home", 0)
local bScripts = createTabBtn("Scripts", 0.33)
local bEditor = createTabBtn("Editor", 0.66)

-- Containers das Abas
local fHome = Instance.new("Frame", content)
fHome.Size = UDim2.new(1, 0, 1, 0)
fHome.BackgroundTransparency = 1

local fScripts = Instance.new("ScrollingFrame", content)
fScripts.Size = UDim2.new(1, -20, 1, 0)
fScripts.Position = UDim2.new(0, 10, 0, 0)
fScripts.BackgroundTransparency = 1
fScripts.Visible = false
fScripts.CanvasSize = UDim2.new(0,0,2,0)

local fEditor = Instance.new("Frame", content)
fEditor.Size = UDim2.new(1, 0, 1, 0)
fEditor.BackgroundTransparency = 1
fEditor.Visible = false

-- Conteúdo Home
local welcome = Instance.new("TextLabel", fHome)
welcome.Size = UDim2.new(1, 0, 1, 0)
welcome.Text = "Aguardando comandos...\n\nStatus: Online\nExecutor: Suportado"
welcome.TextColor3 = Color3.new(0.7, 0.7, 0.7)
welcome.BackgroundTransparency = 1
welcome.Font = Enum.Font.Gotham

-- Conteúdo Editor
local editor = Instance.new("TextBox", fEditor)
editor.Size = UDim2.new(0.9, 0, 0.7, 0)
editor.Position = UDim2.new(0.05, 0, 0, 0)
editor.MultiLine = true
editor.TextXAlignment = "Left"
editor.TextYAlignment = "Top"
editor.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
editor.TextColor3 = Color3.new(1,1,1)
editor.ClearTextOnFocus = false
editor.Text = ""

local execBtn = Instance.new("TextButton", fEditor)
execBtn.Size = UDim2.new(0.4, 0, 0.2, 0)
execBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
execBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
execBtn.Text = "EXECUTAR"
execBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", execBtn)

execBtn.MouseButton1Click:Connect(function()
    local code = editor.Text
    if code ~= "" then
        -- Tenta executar usando loadstring (comum em exploits)
        local success, err = pcall(function()
            local func = loadstring(code)
            if func then func() else error("Falha ao carregar script") end
        end)
        
        if success then
            createNotification("Sucesso", "Script executado!", 2)
        else
            createNotification("Erro", "Falha: " .. tostring(err), 5)
        end
    end
end)

-- Lógica de Troca de Aba
local function showTab(tabName)
    fHome.Visible = (tabName == "Home")
    fScripts.Visible = (tabName == "Scripts")
    fEditor.Visible = (tabName == "Editor")
end

bHome.MouseButton1Click:Connect(function() showTab("Home") end)
bScripts.MouseButton1Click:Connect(function() showTab("Scripts") end)
bEditor.MouseButton1Click:Connect(function() showTab("Editor") end)

-- Inicialização
createNotification("Hub Ativado", "Bem-vindo, " .. player.Name, 4)
