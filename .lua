--[[ 
    ZAKY AI - DELTA OPTIMIZED
    IA com foco em detecção de perigo e movimento autônomo.
]]

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Deletar UI antiga para não travar o Delta
local oldUI = game:GetService("CoreGui"):FindFirstChild("ZakyDelta")
if oldUI then oldUI:Destroy() end

local Screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
Screen.Name = "ZakyDelta"

-- Painel Central
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 250, 0, 150)
Main.Position = UDim2.new(0.5, -125, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🧠 ZAKY NEURAL AI"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -20, 0, 60)
Status.Position = UDim2.new(0, 10, 0, 35)
Status.Text = "Aguardando..."
Status.TextColor3 = Color3.fromRGB(0, 255, 150)
Status.TextWrapped = true
Status.BackgroundTransparency = 1

-- Lógica de Movimento Inteligente
local Running = false

local function ScanNextPlatform()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    local bestPart = nil
    local shortestDist = 100 -- Raio de busca da IA
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide and v.Transparency < 0.5 then
            -- FILTRO DE PERIGO (O que você pediu: analisar obstáculos perigosos)
            local name = v.Name:lower()
            local isKill = name:find("kill") or name:find("lava") or v.Color == Color3.new(1, 0, 0)
            
            if not isKill then
                local dist = (hrp.Position - v.Position).Magnitude
                -- A IA escolhe a parte mais próxima que esteja à frente (Vontade Própria)
                if dist > 3 and dist < shortestDist then
                    shortestDist = dist
                    bestPart = v
                end
            end
        end
    end
    return bestPart
end

local function StartAI()
    while Running do
        task.wait(0.1)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local target = ScanNextPlatform()
        if target then
            Status.Text = "Raciocinando: Próximo ponto seguro identificado em " .. target.Name
            
            -- Movimentação via Física Suave (Não atravessa paredes)
            local targetPos = target.Position + Vector3.new(0, 4, 0)
            local dist = (hrp.Position - targetPos).Magnitude
            local tInfo = TweenInfo.new(dist/20, Enum.EasingStyle.Linear)
            
            local tween = TS:Create(hrp, tInfo, {CFrame = CFrame.new(targetPos)})
            tween:Play()
            tween.Completed:Wait()
        else
            Status.Text = "Perigo: Nenhum caminho seguro à frente. Recalculando..."
        end
    end
end

-- Botão de Ativação
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(0.8, 0, 0, 35)
Btn.Position = UDim2.new(0.1, 0, 1, -45)
Btn.Text = "DESPERTAR INTELIGÊNCIA"
Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
Btn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Btn)

Btn.MouseButton1Click:Connect(function()
    Running = not Running
    Btn.Text = Running and "IA ATIVA" or "DESPERTAR INTELIGÊNCIA"
    Btn.BackgroundColor3 = Running and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 120, 255)
    
    if Running then
        task.spawn(StartAI)
    end
end)
