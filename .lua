--[[
    ZAKY AI - THE AUTONOMOUS BOT
    - Foco 100% em Navegação e Tomada de Decisão
    - Terminal de Pensamento em Tempo Real
    - Lógica de Máquina de Estados (State Machine)
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local Pathfinding = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

getgenv().ZakyAI = {
    Active = false,
    State = "STANDBY",
    Target = nil,
    LogHistory = {}
}

--// CRIAÇÃO DO TERMINAL DE CONSCIÊNCIA
local Screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
Screen.Name = "ZakyAITerminal"

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 350, 0, 250); Main.Position = UDim2.new(0.05, 0, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main); Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 255)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30); Title.BackgroundTransparency = 1
Title.Text = "🧠 ZAKY AI: CÓRTEX DE DECISÃO"; Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBold

local LogScreen = Instance.new("ScrollingFrame", Main)
LogScreen.Size = UDim2.new(1, -20, 1, -80); LogScreen.Position = UDim2.new(0, 10, 0, 35)
LogScreen.BackgroundColor3 = Color3.fromRGB(5, 5, 8); LogScreen.ScrollBarThickness = 2
Instance.new("UIListLayout", LogScreen).Padding = UDim.new(0, 2)

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(1, -20, 0, 35); ToggleBtn.Position = UDim2.new(0, 10, 1, -40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150); ToggleBtn.Text = "INICIAR CONSCIÊNCIA"
ToggleBtn.TextColor3 = Color3.new(1,1,1); ToggleBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", ToggleBtn)

-- Função para a IA "Falar"
local function AILog(text)
    if #getgenv().ZakyAI.LogHistory > 20 then
        getgenv().ZakyAI.LogHistory[1]:Destroy()
        table.remove(getgenv().ZakyAI.LogHistory, 1)
    end
    local msg = Instance.new("TextLabel", LogScreen)
    msg.Size = UDim2.new(1, 0, 0, 15); msg.BackgroundTransparency = 1
    msg.Text = "> " .. text; msg.TextColor3 = Color3.new(0.8, 0.8, 0.8); msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Font = Enum.Font.Code
    table.insert(getgenv().ZakyAI.LogHistory, msg)
    LogScreen.CanvasPosition = Vector2.new(0, 9999)
end--// SISTEMA DE PERCEPÇÃO VISUAL DA IA
local function EvaluatePart(part, myPos)
    -- Filtros de segurança da IA
    if not part.CanCollide or part.Transparency == 1 then return false end
    local name = part.Name:lower()
    if name:find("kill") or name:find("lava") or part:FindFirstChildOfClass("TouchTransmitter") then return false end
    
    -- Avaliação de "Melhor Caminho" (Avançar no eixo principal do Obby)
    local dir = (part.Position - myPos).Unit
    local dist = (part.Position - myPos).Magnitude
    
    -- IA ignora coisas muito distantes, muito abaixo, ou atrás dela
    if dist > 60 or dist < 5 or part.Position.Y < myPos.Y - 10 then return false end
    
    return true
end

local function FindNextObjective()
    AILog("Raciocinando: Escaneando ambiente ao redor...")
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char.HumanoidRootPart
    
    local bestTarget = nil
    local bestScore = -math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and EvaluatePart(obj, hrp.Position) then
            -- Calcula a "pontuação" da plataforma (Prioriza altura e distância moderada)
            local score = obj.Position.Y - ((obj.Position - hrp.Position).Magnitude * 0.5)
            if score > bestScore then
                bestScore = score
                bestTarget = obj
            end
        end
    end
    
    if bestTarget then AILog("Raciocinando: Alvo definido -> " .. bestTarget.Name) end
    return bestTarget
    end--// LÓGICA DE MOVIMENTAÇÃO E VONTADE PRÓPRIA
local function ExecuteAI()
    if not getgenv().ZakyAI.Active then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hum = char.Humanoid
    local hrp = char.HumanoidRootPart
    
    -- Se não tem alvo, procura um
    if not getgenv().ZakyAI.Target or (hrp.Position - getgenv().ZakyAI.Target.Position).Magnitude < 4 then
        getgenv().ZakyAI.Target = FindNextObjective()
        if not getgenv().ZakyAI.Target then
            AILog("Aviso: Nenhum caminho seguro encontrado. Aguardando...")
            hum:MoveTo(hrp.Position)
            task.wait(1)
            return
        end
    end

    -- Toma a decisão de mover
    local targetPos = getgenv().ZakyAI.Target.Position + Vector3.new(0, 2, 0)
    hum:MoveTo(targetPos)
    
    -- Sensores Anti-Colisão (LIDAR)
    local rayF = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 5)
    local rayD = Workspace:Raycast(hrp.Position + hrp.CFrame.LookVector * 4, Vector3.new(0, -10, 0))
    
    if rayF and rayF.Instance then
        AILog("Ação: Obstáculo detectado! Calculando salto...")
        hum.Jump = true
    elseif not rayD then
        AILog("Ação: Vão livre detectado! Impulsionando para frente.")
        hum.Jump = true
        hrp.Velocity = hrp.CFrame.LookVector * 30 + Vector3.new(0, 20, 0)
        task.wait(0.3) -- Espera o pulo acontecer
    else
        getgenv().ZakyAI.State = "MOVENDO"
    end
end

-- Ativação via Botão
ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().ZakyAI.Active = not getgenv().ZakyAI.Active
    if getgenv().ZakyAI.Active then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        ToggleBtn.Text = "DESATIVAR IA"
        AILog("SISTEMA INICIADO. Assumindo controle do avatar.")
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
        ToggleBtn.Text = "INICIAR CONSCIÊNCIA"
        AILog("SISTEMA DESLIGADO. Controle retornado ao jogador.")
        if LocalPlayer.Character then LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position) end
    end
end)

-- Loop de Pensamento da IA (Roda 4 vezes por segundo para evitar lag)
task.spawn(function()
    while true do
        task.wait(0.25)
        if getgenv().ZakyAI.Active then
            pcall(ExecuteAI)
        end
    end
end)
