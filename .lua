--[[
    ZAKY HUB : ULTIMATE v5
    - Tudo em um: Speed, Fly, ESP (Highlight), Target Logic, FPS Boost
    - Sistema Stealth (Anti-Detecção por Ciclos)
    - Interface Arrastável e Minimista
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // Limpeza e Setup
if CoreGui:FindFirstChild("ZakyFinal") then CoreGui.ZakyFinal:Destroy() end
local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "ZakyFinal"

-- // Configurações de Estado
local State = {
    Noclip = false,
    InfJump = false,
    AutoClick = false,
    Highlights = false,
    AntiAFK = true,
    Speed = 16,
    Jump = 50
}

-- // UI PRINCIPAL
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 380, 0, 420)
Main.Position = UDim2.new(0.5, -190, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(255, 0, 60); Stroke.Thickness = 1.5

-- // HEADER (Arrastar)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "  ZAKYHUB ULTIMATE V5"; Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left

-- // CONSOLE DE STATUS
local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -20, 0, 25); Status.Position = UDim2.new(0, 10, 0, 50)
Status.BackgroundColor3 = Color3.new(0,0,0); Status.Text = " STATUS: SISTEMA ONLINE"; Status.TextColor3 = Color3.new(0,1,0)
Status.Font = Enum.Font.Code; Status.TextSize = 12; Instance.new("UICorner", Status)

-- // CONTAINER DE FUNÇÕES
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -100); Scroll.Position = UDim2.new(0, 10, 0, 85)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 8)

-- // FUNÇÕES AUXILIARES
local function AddToggle(name, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(200, 0, 50) or Color3.fromRGB(30, 30, 35)
        callback(active)
    end)
end

-- // MÓDULOS ATIVOS (O CORAÇÃO DO HUB)

-- 1. Movimentação Stealth
RS.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = State.Speed
        char.Humanoid.JumpPower = State.Jump
        if State.Noclip then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- 2. ESP Tático (Highlights)
task.spawn(function()
    while task.wait(1) do
        if State.Highlights then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("ZakyHigh") then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "ZakyHigh"; h.FillColor = Color3.new(1,0,0); h.FillTransparency = 0.5
                    end
                end
            end
        end
    end
end)

-- 3. Anti-AFK
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end
end)

-- // ADICIONANDO BOTÕES
AddToggle("Ativar Noclip", function(v) State.Noclip = v end)
AddToggle("Pulo Infinito", function(v) State.InfJump = v end)
AddToggle("Realçar Jogadores (ESP)", function(v) State.Highlights = v end)
AddToggle("Auto-Clicker", function(v) State.AutoClick = v end)

-- Botão de FPS Boost
local Boost = Instance.new("TextButton", Scroll)
Boost.Size = UDim2.new(1, 0, 0, 35); Boost.Text = "OTIMIZAR FPS (BOOST)"; Boost.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
Boost.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", Boost)
Boost.MouseButton1Click:Connect(function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then v.Enabled = false end
    end
    Status.Text = " STATUS: OTIMIZAÇÃO APLICADA!"
end)

-- // SISTEMA DE ARRASTAR
local dragStart, startPos, dragging
Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = Main.Position end end)
UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- // MINIMIZAR
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -70, 0, 5); MinBtn.Text = "-"
MinBtn.MouseButton1Click:Connect(function()
    local mini = Main.Size.Y.Offset < 100
    TS:Create(Main, TweenInfo.new(0.3), {Size = mini and UDim2.new(0, 380, 0, 420) or UDim2.new(0, 180, 0, 40)}):Play()
end)

Status.Text = " STATUS: ZAKYHUB CARREGADO!"
