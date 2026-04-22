--[[
    ZAKY HUB V10 - NEURAL MESH (FINAL)
    - Navegação por Escaneamento de Malha (Não usa Pathfinding padrão)
    - IA de Aprendizado Adaptativo (Evolui com o mapa)
    - Detector de Kill-Parts via Heurística de Nome/Cor/Script
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

getgenv().NeuralCore = {
    Active = false,
    LearningTable = {},
    CurrentTarget = nil,
    StuckTimer = 0,
    JumpPowerMult = 1.0,
    FailurePoints = {}
}

getgenv().ZakySettings = {
    Speed = 22,
    Jump = 55,
    Noclip = false,
    ESP = false,
    AutoObby = false
}

-- Interface Principal
local Screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 450, 0, 320); Main.Position = UDim2.new(0.5, -225, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Main.Visible = true
Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(0, 255, 150); Stroke.Thickness = 2

local MinBtn = Instance.new("TextButton", Screen)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150); MinBtn.Text = "AI"; MinBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1,0)

-- Função Arrastar
local function Drag(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = obj.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
Drag(Main); Drag(MinBtn)
MinBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)--// IA DE NAVEGAÇÃO AVANÇADA
local function IsPartSafe(part)
    if not part:IsA("BasePart") or not part.CanCollide then return false end
    -- Identifica KillParts por Cor (Vermelho vivo), Nome ou Presença de Scripts de dano
    local name = part.Name:lower()
    if name:find("kill") or name:find("lava") or name:find("dead") or name:find("danger") then return false end
    if part.Color == Color3.fromRGB(255, 0, 0) or part.Color == Color3.fromRGB(255, 80, 80) then return false end
    if part:FindFirstChildOfClass("TouchTransmitter") then return false end
    return true
end

local function FindNextPlatform()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char.HumanoidRootPart
    
    local bestPart = nil
    local minDist = 50 -- Raio de visão da IA
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and IsPartSafe(v) then
            local dist = (hrp.Position - v.Position).Magnitude
            -- IA foca em partes que estão à frente ou acima dela
            if dist < minDist and v.Position.Y >= hrp.Position.Y - 5 then
                local vectorToPart = (v.Position - hrp.Position).Unit
                if vectorToPart.Z < 0 or vectorToPart.Y > 0 then -- Prioriza seguir em frente (eixo Z negativo)
                    minDist = dist
                    bestPart = v
                end
            end
        end
    end
    return bestPart
end

local function AutoObbyLogic()
    if not getgenv().ZakySettings.AutoObby then return end
    local char = LocalPlayer.Character
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    local target = FindNextPlatform()
    if target then
        local pos = target.Position + Vector3.new(0, 3, 0)
        hum:MoveTo(pos)
        
        -- Inteligência de Salto: Se houver um vácuo entre eu e o alvo
        local ray = Workspace:Raycast(hrp.Position, (pos - hrp.Position).Unit * 10)
        if not ray or (pos.Y > hrp.Position.Y + 2) or (pos - hrp.Position).Magnitude > 8 then
            hum.Jump = true
            -- Impulso Neural (Evolução)
            hrp.Velocity = (pos - hrp.Position).Unit * getgenv().ZakySettings.Speed + Vector3.new(0, 10, 0)
        end
    end
end--// SISTEMA DE APRENDIZADO
LocalPlayer.CharacterAdded:Connect(function()
    if getgenv().ZakySettings.AutoObby then
        -- Se morreu, a IA entende que precisa de mais força ou velocidade
        getgenv().NeuralCore.JumpPowerMult = getgenv().NeuralCore.JumpPowerMult + 0.1
        print("IA: Evoluindo... Novo multiplicador de potência: " .. getgenv().NeuralCore.JumpPowerMult)
    end
end)

-- Loop de Execução da IA
task.spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().ZakySettings.AutoObby then
            pcall(AutoObbyLogic)
        end
    end
end)

-- Noclip e Speed Persistente
RS.Stepped:Connect(function()
    if getgenv().ZakySettings.AutoObby and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then 
            hum.WalkSpeed = getgenv().ZakySettings.Speed 
            hum.JumpPower = getgenv().ZakySettings.Jump * getgenv().NeuralCore.JumpPowerMult
        end
        
        if getgenv().ZakySettings.Noclip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)--// PAINEL DE CONTROLE
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -20); Container.Position = UDim2.new(0, 10, 0, 10)
Container.BackgroundTransparency = 1; Container.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Container); Layout.Padding = UDim.new(0, 5)

local function NewToggle(txt, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, -10, 0, 40); b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.Text = txt; b.TextColor3 = Color3.new(0.8, 0.8, 0.8); b.Font = Enum.Font.GothamBold; Instance.new("UICorner", b)
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(25, 25, 30)
        b.TextColor3 = active and Color3.new(0,0,0) or Color3.new(0.8, 0.8, 0.8)
        callback(active)
    end)
end

-- Botões
NewToggle("IA: COMPLETAR OBBY (AUTO-PLAY)", function(v) getgenv().ZakySettings.AutoObby = v end)
NewToggle("NOCLIP (ATRAVESSAR TUDO)", function(v) getgenv().ZakySettings.Noclip = v end)
NewToggle("ATIVAR FLY (GUI XNEOFF)", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() end)
NewToggle("ANTI-LAG (LIMPAR MAPA)", function() 
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.Plastic v.CastShadow = false end
        if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
    end
end)

-- ESP de Jogadores
NewToggle("ESP (VER PLAYERS)", function(v)
    getgenv().ZakySettings.ESP = v
    while getgenv().ZakySettings.ESP do
        task.wait(1)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                h.FillColor = Color3.fromRGB(0, 255, 150)
            end
        end
    end
end)
