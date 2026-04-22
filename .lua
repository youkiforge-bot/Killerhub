--[[ PARTE 1 - SETUP E UI PRINCIPAL ]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Limpeza de GUI antiga
if CoreGui:FindFirstChild("ZakyFinalBoss") then
    CoreGui.ZakyFinalBoss:Destroy()
end

local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "ZakyFinalBoss"
Screen.ResetOnSpawn = false

-- TweenInfo para animações
local tInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Janela Principal
local Main = Instance.new("Frame", Screen)
Main.Name = "Main"
Main.Size = UDim2.new(0, 400, 0, 450)
Main.Position = UDim2.new(0.5, -200, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.ClipsDescendants = true
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 0, 80)
Stroke.Thickness = 2

-- Sistema de Arrastar (funciona em qualquer tamanho)
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end
MakeDraggable(Main)--[[ PARTE 2 - BOTÕES, TÍTULO E SCROLL ]]

-- Botão Minimizar / Restaurar
local Minimized = false
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.BorderSizePixel = 0
Instance.new("UICorner", MinBtn)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        TS:Create(Main, tInfo, {Size = UDim2.new(0, 150, 0, 40)}):Play()
        MinBtn.Text = "+"
    else
        TS:Create(Main, tInfo, {Size = UDim2.new(0, 400, 0, 450)}):Play()
        MinBtn.Text = "-"
    end
end)

-- Título
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "ZAKY HUB : FINAL BOSS"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BorderSizePixel = 0

-- Container com Scroll
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 0
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)--[[ PARTE 3 - SPEED, JUMP, NOCLIP E FLY ]]

-- Função auxiliar para criar inputs
local function AddInput(placeholder, callback)
    local box = Instance.new("TextBox", Container)
    box.Size = UDim2.new(1, 0, 0, 40)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BorderSizePixel = 0
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function(enter)
        if enter then
            callback(tonumber(box.Text))
        end
    end)
end

-- Ajustar Velocidade
AddInput("Ajustar Velocidade (Speed)", function(val)
    if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

-- Ajustar Pulo
AddInput("Ajustar Pulo (Jump)", function(val)
    if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

-- Função para criar Toggle
local function AddToggle(text, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b)
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and Color3.fromRGB(255, 0, 80) or Color3.fromRGB(30, 30, 35)
        callback(active)
    end)
end

-- Noclip
local Noclip = false
RS.Stepped:Connect(function()
    if Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)
AddToggle("Ativar Noclip", function(v) Noclip = v end)

-- Fly (físico com BodyVelocity e BodyGyro)
local FlyEnabled = false
local FlyBodyVel, FlyBodyGyro
local FlySpeed = 50
local FlyKeys = {W = false, A = false, S = false, D = false, Space = false, Ctrl = false}

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then FlyKeys.W = true
    elseif input.KeyCode == Enum.KeyCode.A then FlyKeys.A = true
    elseif input.KeyCode == Enum.KeyCode.S then FlyKeys.S = true
    elseif input.KeyCode == Enum.KeyCode.D then FlyKeys.D = true
    elseif input.KeyCode == Enum.KeyCode.Space then FlyKeys.Space = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl then FlyKeys.Ctrl = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then FlyKeys.W = false
    elseif input.KeyCode == Enum.KeyCode.A then FlyKeys.A = false
    elseif input.KeyCode == Enum.KeyCode.S then FlyKeys.S = false
    elseif input.KeyCode == Enum.KeyCode.D then FlyKeys.D = false
    elseif input.KeyCode == Enum.KeyCode.Space then FlyKeys.Space = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl then FlyKeys.Ctrl = false
    end
end)

local function UpdateFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    if FlyEnabled then
        if not FlyBodyVel then
            FlyBodyVel = Instance.new("BodyVelocity")
            FlyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            FlyBodyVel.Velocity = Vector3.zero
            FlyBodyVel.Parent = root
        end
        if not FlyBodyGyro then
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            FlyBodyGyro.CFrame = root.CFrame
            FlyBodyGyro.Parent = root
        end
        hum.PlatformStand = true

        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero
        if FlyKeys.W then moveDir = moveDir + cam.CFrame.LookVector end
        if FlyKeys.S then moveDir = moveDir - cam.CFrame.LookVector end
        if FlyKeys.A then moveDir = moveDir - cam.CFrame.RightVector end
        if FlyKeys.D then moveDir = moveDir + cam.CFrame.RightVector end
        if FlyKeys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if FlyKeys.Ctrl then moveDir = moveDir + Vector3.new(0, -1, 0) end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * FlySpeed
        end
        FlyBodyVel.Velocity = moveDir
        FlyBodyGyro.CFrame = cam.CFrame
    else
        if FlyBodyVel then FlyBodyVel:Destroy(); FlyBodyVel = nil end
        if FlyBodyGyro then FlyBodyGyro:Destroy(); FlyBodyGyro = nil end
        hum.PlatformStand = false
    end
end

RS.Heartbeat:Connect(UpdateFly)
AddToggle("Ativar Fly (WASD, Space, Ctrl)", function(v) FlyEnabled = v end)--[[ PARTE 4 - TARGET SELECTOR (AIMBOT UI) ]]

-- Label de status
local TargetLabel = Instance.new("TextLabel", Container)
TargetLabel.Size = UDim2.new(1, 0, 0, 20)
TargetLabel.Text = "SELECIONAR ALVO:"
TargetLabel.TextColor3 = Color3.new(1, 1, 1)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Font = Enum.Font.GothamSemibold
TargetLabel.TextSize = 14
TargetLabel.BorderSizePixel = 0

-- Lista de jogadores
local PlayerList = Instance.new("Frame", Container)
PlayerList.Size = UDim2.new(1, 0, 0, 100)
PlayerList.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
PlayerList.BorderSizePixel = 0
Instance.new("UICorner", PlayerList)

local PListScroll = Instance.new("ScrollingFrame", PlayerList)
PListScroll.Size = UDim2.new(1, 0, 1, 0)
PListScroll.BackgroundTransparency = 1
PListScroll.ScrollBarThickness = 2
PListScroll.BorderSizePixel = 0
PListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local PLayout = Instance.new("UIListLayout", PListScroll)
PLayout.Padding = UDim.new(0, 2)
PLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PListScroll.CanvasSize = UDim2.new(0, 0, 0, PLayout.AbsoluteContentSize.Y + 5)
end)

local SelectedTarget = nil
local function RefreshPlayers()
    for _, v in pairs(PListScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", PListScroll)
            pBtn.Size = UDim2.new(1, 0, 0, 25)
            pBtn.Text = p.Name
            pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            pBtn.TextColor3 = Color3.new(1, 1, 1)
            pBtn.BorderSizePixel = 0
            Instance.new("UICorner", pBtn)
            pBtn.MouseButton1Click:Connect(function()
                SelectedTarget = p
                TargetLabel.Text = "ALVO: " .. p.Name
                print("Aimbot focado em: " .. p.Name)
                -- Feedback visual: destaca o botão selecionado
                for _, btn in pairs(PListScroll:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                    end
                end
                pBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 80)
            end)
        end
    end
end
RefreshPlayers()
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

-- Exemplo de utilização do alvo (base para aimbot)
-- Pode ser chamado em um loop para mirar na cabeça do SelectedTarget
local function AimbotLoop()
    while true do
        RS.Heartbeat:Wait()
        if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("Head") then
            -- Implementação de aimbot (opcional)
            -- LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(...)
        end
    end
end
-- coroutine.wrap(AimbotLoop)() -- Descomente para ativar aimbot automático--[[ PARTE 5 - BOTÃO FECHAR E CONFIRMAÇÃO ]]

-- Botão Fechar
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn)

-- Popup de confirmação
local Confirm = Instance.new("Frame", Screen)
Confirm.Size = UDim2.new(0, 250, 0, 120)
Confirm.Position = UDim2.new(0.5, -125, 0.4, 0)
Confirm.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Confirm.Visible = false
Confirm.ZIndex = 10
Confirm.BorderSizePixel = 0
Instance.new("UICorner", Confirm)
local s2 = Instance.new("UIStroke", Confirm)
s2.Color = Color3.new(1, 1, 1)
s2.Thickness = 1.5

local Msg = Instance.new("TextLabel", Confirm)
Msg.Size = UDim2.new(1, 0, 0, 50)
Msg.Text = "REALMENTE DESEJA SAIR?"
Msg.TextColor3 = Color3.new(1, 1, 1)
Msg.BackgroundTransparency = 1
Msg.Font = Enum.Font.GothamBold
Msg.TextSize = 14
Msg.BorderSizePixel = 0

local Yes = Instance.new("TextButton", Confirm)
Yes.Size = UDim2.new(0, 100, 0, 40)
Yes.Position = UDim2.new(0, 20, 0, 60)
Yes.Text = "SIM"
Yes.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Yes.TextColor3 = Color3.new(1, 1, 1)
Yes.BorderSizePixel = 0
Instance.new("UICorner", Yes)

local No = Instance.new("TextButton", Confirm)
No.Size = UDim2.new(0, 100, 0, 40)
No.Position = UDim2.new(1, -120, 0, 60)
No.Text = "NÃO"
No.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
No.TextColor3 = Color3.new(1, 1, 1)
No.BorderSizePixel = 0
Instance.new("UICorner", No)

CloseBtn.MouseButton1Click:Connect(function()
    Confirm.Visible = true
end)
No.MouseButton1Click:Connect(function()
    Confirm.Visible = false
end)
Yes.MouseButton1Click:Connect(function()
    Screen:Destroy()
end)

-- Garantir que o popup suma se clicar fora (opcional)
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Confirm.Visible then
        -- Se clicar fora do popup, fecha ele
        -- (implementação simples: se o objeto alvo não for filho do Confirm)
        -- Deixamos comentado para não complicar
    end
end)
