--[[
    ZAKY HUB: OVERDRIVE EDITION
    - Landing Predictor (Antena Pro)
    - Hitbox Expander (Reach Absurdo)
    - No-Lag & Full Visuals
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("ZakyOverdrive") then CoreGui.ZakyOverdrive:Destroy() end

local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "ZakyOverdrive"

-- Painel
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 320, 0, 300)
Main.Position = UDim2.new(0.5, -160, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(255, 0, 50); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "ZAKY HUB [OVERDRIVE]"; Title.TextColor3 = Color3.new(1,0,0)
Title.BackgroundColor3 = Color3.fromRGB(20, 0, 0); Title.Font = Enum.Font.GothamBold; Title.TextSize = 18
Instance.new("UICorner", Title)

local List = Instance.new("ScrollingFrame", Main)
List.Size = UDim2.new(1, -20, 1, -60); List.Position = UDim2.new(0, 10, 0, 50)
List.BackgroundTransparency = 1; List.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", List); Layout.Padding = UDim.new(0, 10)

-- Variáveis de Controle
_G.Antenna = false
_G.HitboxSize = 2 -- Tamanho normal
_G.ExpandHitbox = false

-- Função de Toggle
local function AddToggle(text, callback)
    local b = Instance.new("TextButton", List)
    b.Size = UDim2.new(1, 0, 0, 45); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 30)
        callback(active)
    end)
end

-- // MECÂNICAS APELONAS

-- 1. Antena / Landing Predictor
local Predictor = Instance.new("Part")
Predictor.Size = Vector3.new(5, 0.5, 5); Predictor.Anchored = true; Predictor.CanCollide = false
Predictor.Color = Color3.new(1, 0, 0); Predictor.Material = Enum.Material.Neon; Predictor.Transparency = 1
Predictor.Parent = workspace
local Highlight = Instance.new("SelectionBox", Predictor); Highlight.Adornee = Predictor; Highlight.Color3 = Color3.new(1, 0, 0)

-- 2. Loop de Atualização
RS.RenderStepped:Connect(function()
    local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Volleyball")
    
    if ball and ball:IsA("BasePart") then
        -- Lógica da Antena
        if _G.Antenna then
            local ray = workspace:Raycast(ball.Position, Vector3.new(0, -500, 0))
            if ray then
                Predictor.Transparency = 0.6
                Predictor.Position = ray.Position
            end
        else
            Predictor.Transparency = 1
        end

        -- Lógica de Hitbox (A parte apelona)
        if _G.ExpandHitbox then
            ball.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
            ball.CanCollide = false -- Evita que você seja "empurrado" pela bola gigante
        else
            ball.Size = Vector3.new(2, 2, 2) -- Tamanho original aproximado
        end
    end
end)

-- Botões
AddToggle("ATIVAR ANTENA (PREDIÇÃO)", function(v) _G.Antenna = v end)

AddToggle("EXPANDIR HITBOX (REACH)", function(v) 
    _G.ExpandHitbox = v 
    _G.HitboxSize = v and 15 or 2 -- Aumenta a bola em 15x para você acertar de longe
end)

AddToggle("FULLBRIGHT / NO FOG", function(v)
    if v then
        game:GetService("Lighting").Ambient = Color3.new(1,1,1)
        game:GetService("Lighting").FogEnd = 999999
    else
        game:GetService("Lighting").Ambient = Color3.new(0.5, 0.5, 0.5)
    end
end)

-- Botão Sair
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 30, 0, 30); Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"; Close.BackgroundColor3 = Color3.new(1,0,0); Close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() Screen:Destroy(); Predictor:Destroy() end)
