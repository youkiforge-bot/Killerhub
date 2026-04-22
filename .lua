--[[
    ZAKY AI - GOD MODE (AUTONOMOUS NAVIGATION)
    - Sistema de Movimentação por CFrame (Anti-Block)
    - Varredura de Alvos via Magnitude Pura
    - Terminal de Telemetria Integrado
]]

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

getgenv().ZakyGod = {
    Enabled = false,
    Speed = 35, -- Velocidade do deslocamento
    AvoidList = {},
    CurrentIndex = 1
}

--// TERMINAL DE TELEMETRIA
local Screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 300, 0, 200); Main.Position = UDim2.new(0, 20, 0.5, -100)
Main.BackgroundColor3 = Color3.fromRGB(10, 0, 20); Main.Active = true; Main.Draggable = true
Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 255, 255)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 40); Status.Text = "IA: AGUARDANDO COMANDO"; Status.TextColor3 = Color3.new(1, 1, 1)
Status.BackgroundTransparency = 1; Status.Font = Enum.Font.Code

local Log = Instance.new("TextLabel", Main)
Log.Size = UDim2.new(1, -20, 1, -60); Log.Position = UDim2.new(0, 10, 0, 50)
Log.Text = "Pronto para iniciar..."; Log.TextColor3 = Color3.fromRGB(0, 255, 0)
Log.TextWrapped = true; Log.BackgroundTransparency = 1; Log.TextYAlignment = Enum.TextYAlignment.Top

local function SetStatus(txt, logTxt)
    Status.Text = "IA: " .. txt
    Log.Text = "> " .. (logTxt or "Processando...")
end--// FILTRO DE PEÇAS SEGURAS
local function IsValidPlatform(v)
    if not v:IsA("BasePart") or v.Transparency > 0.7 or not v.CanCollide then return false end
    local n = v.Name:lower()
    -- Filtro de perigo agressivo
    if n:find("lava") or n:find("kill") or n:find("acid") or v.Color == Color3.new(1, 0, 0) then return false end
    if v:FindFirstChildOfClass("TouchTransmitter") then return false end
    return true
end

local function GetMapRoute()
    local route = {}
    local char = LocalPlayer.Character
    if not char then return route end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local allParts = workspace:GetDescendants()
    
    for _, v in pairs(allParts) do
        if IsValidPlatform(v) then
            -- Só pega peças que estão à frente ou perto do nível atual
            local dist = (root.Position - v.Position).Magnitude
            if dist < 300 then
                table.insert(route, v)
            end
        end
    end
    
    -- Ordena as peças para criar um caminho lógico (do início ao fim)
    table.sort(route, function(a, b)
        return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
    end)
    
    return route
    end--// EXECUÇÃO DO AUTO-OBBY
local function StartAutonomousMode()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    
    SetStatus("ESCANEANDO", "Calculando rota de plataformas seguras...")
    local route = GetMapRoute()
    
    if #route == 0 then
        SetStatus("ERRO", "Nenhuma plataforma segura detectada próxima.")
        return
    end

    for i, target in ipairs(route) do
        if not getgenv().ZakyGod.Enabled then break end
        
        local targetPos = target.Position + Vector3.new(0, 4, 0)
        local distance = (root.Position - targetPos).Magnitude
        local duration = distance / getgenv().ZakyGod.Speed
        
        SetStatus("MOVENDO", "Indo para: " .. target.Name .. " [" .. i .. "/" .. #route .. "]")
        
        -- Movimento via Tween (Suave e Imparável)
        local tween = TS:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
        tween:Play()
        tween.Completed:Wait()
        
        task.wait(0.1) -- Pequena pausa para a IA "respirar" e estabilizar
    end
    
    SetStatus("CONCLUÍDO", "Cheguei ao fim da rota escaneada.")
    getgenv().ZakyGod.Enabled = false
end

--// BOTÃO DE ATIVAÇÃO
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(1, -20, 0, 40); Btn.Position = UDim2.new(0, 10, 1, -50)
Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200); Btn.Text = "INICIAR AUTO-COMPLETAR"
Btn.TextColor3 = Color3.new(1, 1, 1); Btn.Font = Enum.Font.Code; Instance.new("UICorner", Btn)

Btn.MouseButton1Click:Connect(function()
    getgenv().ZakyGod.Enabled = not getgenv().ZakyGod.Enabled
    Btn.Text = getgenv().ZakyGod.Enabled and "PARAR IA" or "INICIAR AUTO-COMPLETAR"
    Btn.BackgroundColor3 = getgenv().ZakyGod.Enabled and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 100, 200)
    
    if getgenv().ZakyGod.Enabled then
        task.spawn(StartAutonomousMode)
    end
end)
