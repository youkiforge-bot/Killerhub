--[[
    ZAKY AI: SINGULARITY (VONTADE PRÓPRIA TOTAL)
    - Navegação Heurística de Alta Complexidade
    - Terminal de Consciência em Tempo Real
    - Auto-Adaptação Pós-Falha
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

getgenv().ZakySingularity = {
    Active = false,
    CurrentObjective = nil,
    ConfidenceLevel = 1.0,
    Memory = {}, -- Guarda locais de morte para evitar
    ActionLog = {}
}

--// INTERFACE DO TERMINAL NEURAL
local Screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 380, 0, 280); Main.Position = UDim2.new(0.02, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 12); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main); Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 200, 255)

local LogBox = Instance.new("ScrollingFrame", Main)
LogBox.Size = UDim2.new(1, -20, 1, -80); LogBox.Position = UDim2.new(0, 10, 0, 10)
LogBox.BackgroundTransparency = 1; LogBox.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", LogBox); Layout.Padding = UDim.new(0, 2)

local function NeuralLog(msg)
    local t = Instance.new("TextLabel", LogBox)
    t.Size = UDim2.new(1, 0, 0, 18); t.BackgroundTransparency = 1
    t.Text = "🧠 [LOG]: " .. msg; t.TextColor3 = Color3.new(0, 1, 1); t.Font = Enum.Font.Code
    t.TextXAlignment = Enum.TextXAlignment.Left; t.TextScaled = true
    if #LogBox:GetChildren() > 25 then LogBox:GetChildren()[2]:Destroy() end
    LogBox.CanvasPosition = Vector2.new(0, 9999)
end--// SCANNER DE GEOMETRIA COMPLEXA
local function IsSafe(part)
    if not part:IsA("BasePart") or not part.CanCollide or part.Transparency > 0.5 then return false end
    local n = part.Name:lower()
    if n:find("kill") or n:find("lava") or part.Color == Color3.new(1, 0, 0) then return false end
    for _, failPos in pairs(getgenv().ZakySingularity.Memory) do
        if (part.Position - failPos).Magnitude < 5 then return false end
    end
    return true
end

local function GetBestNextStep()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char.HumanoidRootPart
    
    local best = nil
    local highscore = -math.huge
    
    -- Escaneamento em profundidade (LIDAR 3D)
    local parts = Workspace:FindPartInRegion3(Region3.new(hrp.Position - Vector3.new(40,20,40), hrp.Position + Vector3.new(40,40,40)), char, 100)
    
    for _, part in pairs(parts) do
        if IsSafe(part) then
            -- Heurística: Prioriza partes que estão mais à frente (Z negativo) e mais altas (Y positivo)
            local score = (part.Position.Y * 2) - (part.Position - hrp.Position).Magnitude
            if score > highscore and (part.Position - hrp.Position).Magnitude > 3 then
                highscore = score
                best = part
            end
        end
    end
    return best
    end--// NÚCLEO DE MOVIMENTAÇÃO AUTÔNOMA
local function ThinkAndMove()
    if not getgenv().ZakySingularity.Active then return end
    local char = LocalPlayer.Character
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")

    -- Busca novo objetivo se o atual for atingido ou nulo
    if not getgenv().ZakySingularity.CurrentObjective or (hrp.Position - getgenv().ZakySingularity.CurrentObjective.Position).Magnitude < 4 then
        NeuralLog("Analisando topografia do terreno...")
        getgenv().ZakySingularity.CurrentObjective = GetBestNextStep()
    end

    local target = getgenv().ZakySingularity.CurrentObjective
    if target then
        NeuralLog("Objetivo: " .. target.Name .. " | Distância: " .. math.floor((hrp.Position - target.Position).Magnitude))
        hum:MoveTo(target.Position)
        
        -- CÁLCULO DE SALTO COMPLEXO
        local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(target.Position.X, target.Position.Z)).Magnitude
        local heightDiff = target.Position.Y - hrp.Position.Y
        
        if dist > 6 or heightDiff > 1 then
            NeuralLog("Detectado GAP. Calculando vetor de impulso...")
            hum.Jump = true
            -- Aplica um pequeno "boost" para garantir que alcance a plataforma
            hrp.Velocity = (target.Position - hrp.Position).Unit * 25 + Vector3.new(0, 35, 0)
            task.wait(0.3)
        end
    else
        NeuralLog("Ponto cego detectado. Tentando exploração lateral...")
        hum:MoveTo(hrp.Position + hrp.CFrame.RightVector * 5)
    end
end

-- Monitor de Morte (Aprendizado por Reforço)
LocalPlayer.CharacterAdded:Connect(function(char)
    if getgenv().ZakySingularity.Active then
        local hrp = char:WaitForChild("HumanoidRootPart")
        table.insert(getgenv().ZakySingularity.Memory, hrp.Position)
        NeuralLog("Falha registrada. Ponto evitado na próxima iteração.")
    end
end)--// INTERFACE FINAL
local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(1, -20, 0, 45); Toggle.Position = UDim2.new(0, 10, 1, -55)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 60, 100); Toggle.Text = "DESPERTAR IA (SINGULARITY)"
Toggle.TextColor3 = Color3.new(1,1,1); Toggle.Font = Enum.Font.GothamBold; Instance.new("UICorner", Toggle)

Toggle.MouseButton1Click:Connect(function()
    getgenv().ZakySingularity.Active = not getgenv().ZakySingularity.Active
    Toggle.Text = getgenv().ZakySingularity.Active and "DESATIVAR CONSCIÊNCIA" or "DESPERTAR IA (SINGULARITY)"
    Toggle.BackgroundColor3 = getgenv().ZakySingularity.Active and Color3.fromRGB(150, 0, 50) or Color3.fromRGB(0, 60, 100)
    
    if getgenv().ZakySingularity.Active then
        NeuralLog("Consciência desperta. Iniciando análise autônoma.")
    end
end)

-- Ciclo Neural (Alta frequência para obbys rápidos)
task.spawn(function()
    while true do
        task.wait(0.15)
        if getgenv().ZakySingularity.Active then
            pcall(ThinkAndMove)
        end
    end
end)
