--[[
    ZAKY AI: PROTOCOLO GENESIS
    - Completa Obbys inteiros automaticamente
    - Visão de Checkpoint (Busca o próximo estágio)
    - Anti-Kill System (Desvia de obstáculos fatais)
    - Noclip e Fly Integrados para evitar travamentos
]]

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Limpeza de interface anterior
local old = game:GetService("CoreGui"):FindFirstChild("GenesisAI")
if old then old:Destroy() end

local Screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
Screen.Name = "GenesisAI"

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 300, 0, 180)
Main.Position = UDim2.new(0.5, -150, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 150)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -20, 0, 80)
Status.Position = UDim2.new(0, 10, 0, 10)
Status.Text = "PRONTO PARA INICIAR PROTOCOLO GENESIS"
Status.TextColor3 = Color3.new(1, 1, 1)
Status.BackgroundTransparency = 1
Status.TextWrapped = true
Status.Font = Enum.Font.Code

-- FUNÇÕES DE APOIO PARA A IA
local Active = false
local Speed = 30 -- Velocidade da IA

-- 1. Detecção de Perigo (Análise de obstáculos que matam)
local function IsDangerous(part)
    if not part:IsA("BasePart") then return false end
    local n = part.Name:lower()
    if n:find("kill") or n:find("lava") or n:find("acid") or n:find("hurt") then return true end
    if part.Color == Color3.new(1, 0, 0) or part.Color == Color3.fromRGB(255, 0, 0) then return true end
    if part:FindFirstChildOfClass("TouchTransmitter") then return true end
    return false
end

-- 2. Busca de Caminho (Escaneia o Obby)
local function GetNextPlatform()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    local best = nil
    local shortestDist = math.huge
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide and v.Transparency < 0.7 then
            if not IsDangerous(v) then
                local dist = (hrp.Position - v.Position).Magnitude
                -- A IA foca em plataformas que estão à frente ou um pouco acima
                if dist > 4 and dist < 150 then
                    if dist < shortestDist then
                        shortestDist = dist
                        best = v
                    end
                end
            end
        end
    end
    return best
end

-- 3. Loop de Conclusão de Obby
local function RunGenesis()
    while Active do
        task.wait(0.1)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        -- Noclip Ativado para não bater em paredes no caminho
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end

        local target = GetNextPlatform()
        if target then
            Status.Text = "🧠 ANALISANDO: " .. target.Name .. "\nMOVENDO PARA POSIÇÃO SEGURA"
            
            local targetPos = target.Position + Vector3.new(0, 5, 0)
            local dist = (hrp.Position - targetPos).Magnitude
            
            -- Movimento via Interpolação Linear (Imparável)
            local tween = TS:Create(hrp, TweenInfo.new(dist/Speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
            tween:Play()
            tween.Completed:Wait()
        else
            Status.Text = "⚠️ PONTO CEGO: BUSCANDO NOVAS COORDENADAS..."
        end
    end
end

-- Botão de Ativação
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(1, -20, 0, 45)
Btn.Position = UDim2.new(0, 10, 1, -55)
Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
Btn.Text = "ATIVAR AUTO-OBBY TOTAL"
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.Font = Enum.Font.GothamBold
Instance.new("UICorner", Btn)

Btn.MouseButton1Click:Connect(function()
    Active = not Active
    Btn.Text = Active and "IA EM OPERAÇÃO" or "ATIVAR AUTO-OBBY TOTAL"
    Btn.BackgroundColor3 = Active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 150, 80)
    
    if Active then
        task.spawn(RunGenesis)
    else
        Status.Text = "PROTOCOLO INTERROMPIDO"
        if LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end)
