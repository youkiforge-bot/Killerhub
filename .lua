--[[
    ZAKY AI: PROJETO ÔMEGA (VERSÃO DEFINITIVA)
    - Sistema de Memória de Progressão (Fim do efeito Ping-Pong)
    - Bloqueio de Retorno (Nunca volta para trás)
    - Filtro de Altura e Perigo Aprimorado
]]

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Limpa execuções antigas para o Delta não bugar
if CoreGui:FindFirstChild("ZakyOmega") then CoreGui.ZakyOmega:Destroy() end

local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "ZakyOmega"

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 300, 0, 180)
Main.Position = UDim2.new(0.5, -150, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 215, 0) -- Dourado Ômega

local LogText = Instance.new("TextLabel", Main)
LogText.Size = UDim2.new(1, -20, 0, 80)
LogText.Position = UDim2.new(0, 10, 0, 10)
LogText.BackgroundTransparency = 1
LogText.TextColor3 = Color3.new(1, 1, 1)
LogText.TextWrapped = true
LogText.Text = "SISTEMA ÔMEGA PRONTO.\nAguardando inicialização..."
LogText.Font = Enum.Font.Code

--// NÚCLEO DE INTELIGÊNCIA E MEMÓRIA
local Active = false
local Speed = 35
getgenv().VisitedBlocks = {} -- O CÉREBRO: Guarda onde já pisou

-- Se você morrer, a IA limpa a memória para poder refazer o caminho
LocalPlayer.CharacterAdded:Connect(function()
    getgenv().VisitedBlocks = {}
    LogText.Text = "Reset detectado. Memória limpa."
end)

local function IsDangerous(part)
    if not part:IsA("BasePart") then return false end
    local n = part.Name:lower()
    if n:find("kill") or n:find("lava") or n:find("acid") or n:find("hurt") then return true end
    if part.Color == Color3.new(1, 0, 0) or part.Color == Color3.fromRGB(255, 0, 0) then return true end
    if part:FindFirstChildOfClass("TouchTransmitter") then return true end
    return false
end

local function GetNextPlatform()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local bestPart = nil
    local bestScore = -math.huge

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide and v.Transparency < 0.8 then
            -- REGRA DE OURO: Se já visitou, ou se mata, IGNORA COMPLETAMENTE.
            if not getgenv().VisitedBlocks[v] and not IsDangerous(v) then
                local dist = (hrp.Position - v.Position).Magnitude
                
                -- Limita a visão para não tentar ir pro final do mapa de uma vez e não pular no abismo
                if dist > 3 and dist < 120 and v.Position.Y >= (hrp.Position.Y - 10) then
                    -- Calcula a pontuação: prefere coisas que estão perto, mas ligeiramente mais altas (caminho natural do obby)
                    local score = -dist + (v.Position.Y * 1.5)
                    
                    if score > bestScore then
                        bestScore = score
                        bestPart = v
                    end
                end
            end
        end
    end
    return bestPart
end

local function RunOmega()
    while Active do
        task.wait(0.1)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        -- Liga o Noclip para não bater nas paredes enquanto voa
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end

        local target = GetNextPlatform()
        if target then
            LogText.Text = "🧠 Progresso:\nIgnorando blocos antigos.\nAvançando para: " .. target.Name
            
            local targetPos = target.Position + Vector3.new(0, 4, 0)
            local dist = (hrp.Position - targetPos).Magnitude
            
            local tweenInfo = TweenInfo.new(dist / Speed, Enum.EasingStyle.Linear)
            local tween = TS:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
            
            tween:Play()
            tween.Completed:Wait()
            
            -- SALVA NA MEMÓRIA: "Já pisei aqui, nunca mais volte"
            getgenv().VisitedBlocks[target] = true
            
            -- Pausa dramática pro roblox processar que você chegou (evita anti-cheat)
            task.wait(0.2)
        else
            LogText.Text = "⚠️ Analisando...\nNão vejo caminho novo. Limpando memória antiga para tentar destravamento."
            -- Se travar de vez, ela esquece os blocos velhos para tentar achar uma saída
            task.wait(2)
            getgenv().VisitedBlocks = {} 
        end
    end
end

--// INTERFACE E CONTROLE
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(1, -20, 0, 45)
Btn.Position = UDim2.new(0, 10, 1, -55)
Btn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
Btn.Text = "INICIAR PROJETO ÔMEGA"
Btn.TextColor3 = Color3.new(0, 0, 0)
Btn.Font = Enum.Font.GothamBold
Instance.new("UICorner", Btn)

Btn.MouseButton1Click:Connect(function()
    Active = not Active
    Btn.Text = Active and "PARAR IA ÔMEGA" or "INICIAR PROJETO ÔMEGA"
    Btn.BackgroundColor3 = Active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(200, 150, 0)
    Btn.TextColor3 = Color3.new(1, 1, 1)
    
    if Active then
        -- Registra o chão atual na memória antes de começar, pra não ficar preso logo de cara
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local ray = workspace:Raycast(char.HumanoidRootPart.Position, Vector3.new(0, -10, 0))
            if ray and ray.Instance then getgenv().VisitedBlocks[ray.Instance] = true end
        end
        
        task.spawn(RunOmega)
    else
        LogText.Text = "Sistemas parados. Controle devolvido."
        if LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end)
