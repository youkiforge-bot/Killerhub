--[[
    ZAKY HUB - VOLLEYBALL LEGENDS
    Funcionalidades: Antena de Pouso, Hitbox Visual, FOV e Performance.
    Foco: Auxílio Visual e Tático.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Limpeza de UI anterior
if CoreGui:FindFirstChild("ZakyHub") then CoreGui.ZakyHub:Destroy() end

local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "ZakyHub"

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 350, 0, 350)
Main.Position = UDim2.new(0.5, -175, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(0, 255, 150); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🏐 ZAKY HUB - PRO VISION"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 18
Instance.new("UICorner", Title)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60); Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1; Container.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Container); Layout.Padding = UDim.new(0, 8)

-- // VARIÁVEIS DE ESTADO
local States = {
    Antenna = false,
    Hitbox = false
}

-- // FUNÇÃO PARA CRIAR TOGGLES
local function CreateToggle(name, desc, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 50); btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); btn.Text = ""
    Instance.new("UICorner", btn)
    
    local t = Instance.new("TextLabel", btn)
    t.Size = UDim2.new(1, -10, 0, 25); t.Position = UDim2.new(0, 10, 0, 5)
    t.Text = name; t.TextColor3 = Color3.new(1, 1, 1); t.Font = Enum.Font.GothamBold; t.BackgroundTransparency = 1; t.TextXAlignment = Enum.TextXAlignment.Left
    
    local d = Instance.new("TextLabel", btn)
    d.Size = UDim2.new(1, -10, 0, 20); d.Position = UDim2.new(0, 10, 0, 25)
    d.Text = desc; d.TextColor3 = Color3.fromRGB(150, 150, 150); d.Font = Enum.Font.Gotham; d.BackgroundTransparency = 1; d.TextXAlignment = Enum.TextXAlignment.Left; d.TextSize = 11

    btn.MouseButton1Click:Connect(function()
        local s = not btn:GetAttribute("Active")
        btn:SetAttribute("Active", s)
        btn.BackgroundColor3 = s and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(30, 30, 35)
        callback(s)
    end)
end

-- // LÓGICA DA ANTENA E HITBOX
local AntennaPart = Instance.new("Part")
AntennaPart.Anchored = true; AntennaPart.CanCollide = false; AntennaPart.Size = Vector3.new(4, 0.2, 4)
AntennaPart.Shape = Enum.PartType.Cylinder; AntennaPart.Color = Color3.fromRGB(0, 255, 150); AntennaPart.Transparency = 1
AntennaPart.Rotation = Vector3.new(0, 0, 90); AntennaPart.Parent = workspace

local Beam = Instance.new("SelectionPartLasso")
Beam.Color3 = Color3.fromRGB(0, 255, 150); Beam.Transparency = 0.5; Beam.Parent = AntennaPart

RS.Heartbeat:Connect(function()
    local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Volleyball")
    
    if ball and ball:IsA("BasePart") then
        -- Lógica da Antena (Previsão de Chão)
        if States.Antenna then
            local ray = workspace:Raycast(ball.Position, Vector3.new(0, -500, 0))
            if ray then
                AntennaPart.Transparency = 0.5
                AntennaPart.Position = ray.Position
                Beam.Part = ball
                Beam.Humanoid = nil -- Lasso manual
            end
        else
            AntennaPart.Transparency = 1
        end

        -- Lógica da Hitbox
        if States.Hitbox then
            local hb = ball:FindFirstChild("ZakyHitbox") or Instance.new("SelectionBox", ball)
            hb.Name = "ZakyHitbox"
            hb.Adornee = ball
            hb.Color3 = Color3.fromRGB(255, 0, 0)
            hb.LineThickness = 0.05
            ball.Transparency = 0.5 -- Torna a bola semi-transparente para ver a hitbox real
        else
            if ball:FindFirstChild("ZakyHitbox") then 
                ball.ZakyHitbox:Destroy() 
                ball.Transparency = 0 -- Reset
            end
        end
    end
end)

-- // ADICIONANDO CONTROLES
CreateToggle("Antena de Pouso", "Mostra um marcador no chão onde a bola vai cair.", function(s)
    States.Antenna = s
end)

CreateToggle("Visualizar Hitbox", "Destaca a área de colisão real da bola.", function(s)
    States.Hitbox = s
end)

CreateToggle("FOV Expandido (110)", "Melhora a visão periférica da quadra.", function(s)
    workspace.CurrentCamera.FieldOfView = s and 110 or 70
end)

CreateToggle("Modo Performance", "Remove sombras e efeitos para evitar lag.", function(s)
    Lighting.GlobalShadows = not s
end)

-- Botão Fechar
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 30, 0, 30); Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"; Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50); Close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() Screen:Destroy(); AntennaPart:Destroy() end)
