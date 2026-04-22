--[[
    ZAKY AI - NEURAL STAR (FINAL EVOLUTION)
    - Sensor 360° (Evita efeito "ping-pong")
    - Inteligência de Navegação Estelar
    - Auto-Correção de Trajetória
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

getgenv().ZakyAI = {
    Active = false,
    Thinking = false,
    LastTarget = nil,
    Speed = 30
}

--// TERMINAL DE CONSCIÊNCIA
local Screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 320, 0, 200); Main.Position = UDim2.new(0, 20, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15); Main.Active = true; Main.Draggable = true
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 255)

local Display = Instance.new("TextLabel", Main)
Display.Size = UDim2.new(1, -20, 1, -60); Display.Position = UDim2.new(0, 10, 0, 10)
Display.TextColor3 = Color3.new(0, 1, 0.5); Display.Text = "Sistemas Prontos..."; Display.TextWrapped = true
Display.Font = Enum.Font.Code; Display.BackgroundTransparency = 1; Display.TextYAlignment = Enum.TextYAlignment.Top

local function Log(txt)
    Display.Text = "🧠 IA PENSANDO:\n" .. txt
endlocal function GetSafeDirection(targetPos)
    local char = LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    
    local finalDir = (targetPos - hrp.Position).Unit
    local obstacleFound = false

    -- Escaneamento Estelar (8 direções ao redor)
    for i = 1, 8 do
        local angle = math.rad(i * 45)
        local dir = Vector3.new(math.cos(angle), 0, math.sin(angle))
        local ray = workspace:Raycast(hrp.Position, dir * 5, rayParams)
        
        if ray and ray.Instance and ray.Instance.CanCollide then
            -- Se detectar parede, gera um vetor de repulsão
            finalDir = finalDir + (ray.Normal * 2)
            obstacleFound = true
        end
    end
    
    return finalDir.Unit, obstacleFound
end

local function FindBestPlatform()
    local char = LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    local best = nil
    local minDist = 300
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide and v.Transparency < 0.5 then
            local n = v.Name:lower()
            -- Ignora perigos
            if not n:find("lava") and not n:find("kill") and v.Color ~= Color3.new(1,0,0) then
                local dist = (hrp.Position - v.Position).Magnitude
                -- Prioriza peças que estão à frente no Obby
                if dist < minDist and dist > 5 and v.Position.Y >= hrp.Position.Y - 5 then
                    minDist = dist
                    best = v
                end
            end
        end
    end
    return best
    endlocal function RunAI()
    if not getgenv().ZakyAI.Active then return end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    local target = FindBestPlatform()
    if target then
        local safeDir, hasObstacle = GetSafeDirection(target.Position)
        local destination = hrp.Position + (safeDir * 10)
        
        if hasObstacle then
            Log("Obstáculo detectado! Recalculando rota de desvio...")
        else
            Log("Caminho livre. Avançando para: " .. target.Name)
        end
        
        -- Movimento Suave via CFrame
        local moveTween = TS:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(hrp.Position, hrp.Position + safeDir) * CFrame.new(0, 0, -getgenv().ZakyAI.Speed * 0.3)
        })
        moveTween:Play()
    else
        Log("Analisando... Procurando próxima plataforma segura.")
    end
end

--// BOTÃO DE ATIVAÇÃO
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(1, -20, 0, 40); Btn.Position = UDim2.new(0, 10, 1, -50)
Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150); Btn.Text = "ATIVAR SUPER IA"
Btn.TextColor3 = Color3.new(0,0,0); Btn.Font = Enum.Font.GothamBold; Instance.new("UICorner", Btn)

Btn.MouseButton1Click:Connect(function()
    getgenv().ZakyAI.Active = not getgenv().ZakyAI.Active
    Btn.Text = getgenv().ZakyAI.Active and "IA OPERANDO..." or "ATIVAR SUPER IA"
    Btn.BackgroundColor3 = getgenv().ZakyAI.Active and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 150)
    
    if getgenv().ZakyAI.Active then
        Log("Consciência Neural Ativada.")
        task.spawn(function()
            while getgenv().ZakyAI.Active do
                RunAI()
                task.wait(0.1)
            end
        end)
    end
end)
