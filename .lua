--[[ 
    ZAKY AI: THE SOVEREIGN 
    Foco: Movimentação Autônoma e Raciocínio Espacial
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Garantir que a UI anterior seja deletada
if CoreGui:FindFirstChild("ZakySovereign") then CoreGui.ZakySovereign:Destroy() end

local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "ZakySovereign"

-- Janela de Pensamento
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 280, 0, 180)
Main.Position = UDim2.new(0.5, -140, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Main.Active = true
Main.Draggable = true -- Para mover no celular

local Corner = Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(0, 255, 255)

local Label = Instance.new("TextLabel", Main)
Label.Size = UDim2.new(1, -20, 1, -60)
Label.Position = UDim2.new(0, 10, 0, 10)
Label.BackgroundTransparency = 1
Label.TextColor3 = Color3.new(1, 1, 1)
Label.Text = "Aguardando ativação neural..."
Label.TextWrapped = true
Label.Font = Enum.Font.Code
Label.TextYAlignment = Enum.TextYAlignment.Top

-- Lógica de Inteligência
local Active = false
local function UpdateAI(msg)
    Label.Text = "🧠 CONSCIÊNCIA:\n" .. msg
end

local function GetNextStep()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    local target = nil
    local bestDist = math.huge
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide and v.Transparency < 0.5 then
            -- Filtro de perigo (Nomes comuns de blocos que matam)
            local n = v.Name:lower()
            if not n:find("lava") and not n:find("kill") and v.Color ~= Color3.new(1,0,0) then
                local dist = (hrp.Position - v.Position).Magnitude
                if dist < 150 and dist > 4 and v.Position.Y >= hrp.Position.Y - 5 then
                    if dist < bestDist then
                        bestDist = dist
                        target = v
                    end
                end
            end
        end
    end
    return target
end

local function MoveLoop()
    while Active do
        task.wait(0.1)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local target = GetNextStep()
        if target then
            UpdateAI("Alvo identificado: " .. target.Name .. "\nCalculando trajetória segura...")
            
            -- Movimentação por CFrame (Ignora obstáculos simples)
            local targetPos = target.Position + Vector3.new(0, 5, 0)
            local dist = (hrp.Position - targetPos).Magnitude
            
            local tween = TS:Create(hrp, TweenInfo.new(dist/25, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
            tween:Play()
            tween.Completed:Wait()
        else
            UpdateAI("Escaneando... Nenhuma plataforma segura encontrada no alcance.")
        end
    end
end

-- Botão
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(1, -20, 0, 40)
Btn.Position = UDim2.new(0, 10, 1, -50)
Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
Btn.Text = "DESPERTAR IA"
Btn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Btn)

Btn.MouseButton1Click:Connect(function()
    Active = not Active
    Btn.Text = Active and "IA ATIVA" or "DESPERTAR IA"
    Btn.BackgroundColor3 = Active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 100, 200)
    
    if Active then
        UpdateAI("Consciência desperta. Assumindo controle físico.")
        task.spawn(MoveLoop)
    else
        UpdateAI("Sistemas desligados.")
    end
end)
