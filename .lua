--[[
    ZAKY HUB V8 - REBIRTH EDITION
    - IA de Navegação Preditiva (2x mais inteligente)
    - Fix Total: Noclip, ESP e Fly
    - Draggable HUD (Botão e Menu)
    - Anti-Kick & Anti-AFK Mobile
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Configurações Persistentes
getgenv().ZakySettings = {
    ESP = false, Noclip = false, ParkourIA = false,
    Jump = 50, Speed = 16, InfJump = false,
    Target = nil, CamLock = false, Color = Color3.fromRGB(138, 43, 226)
}

-- Anti-Kick & AFK (Proteção de Sessão)
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Função de Arrastar (Mobile/PC)
local function MakeDraggable(frame)
    local dragStart, startPos, dragging
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- UI Setup
if CoreGui:FindFirstChild("ZakyHub_V8") then CoreGui.ZakyHub_V8:Destroy() end
local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "ZakyHub_V8"

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 420, 0, 300); Main.Position = UDim2.new(0.5, -210, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15); Main.Visible = true
Instance.new("UICorner", Main); MakeDraggable(Main)

local MinBtn = Instance.new("TextButton", Screen)
MinBtn.Size = UDim2.new(0, 50, 0, 50); MinBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
MinBtn.BackgroundColor3 = getgenv().ZakySettings.Color; MinBtn.Text = "Z"; MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1,0); MakeDraggable(MinBtn)
MinBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)--// IA DE PARKOUR INTELIGENTE (PREDITIVA)
local isJumping = false
local function ThinkParkour()
    local char = LocalPlayer.Character
    if not char or not getgenv().ZakySettings.ParkourIA or isJumping then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or hum.MoveDirection.Magnitude == 0 then return end

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    -- Sensores Avançados
    local wallDist = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 7, rayParams)
    local floorAhead = Workspace:Raycast(hrp.Position + hrp.CFrame.LookVector * 6, Vector3.new(0, -15, 0), rayParams)
    local headClear = Workspace:Raycast(hrp.Position + Vector3.new(0, 5, 0), hrp.CFrame.LookVector * 6, rayParams)

    -- Lógica de Decisão
    if not floorAhead then -- Detectou um buraco
        isJumping = true
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.5)
        isJumping = false
    elseif wallDist and wallDist.Instance.CanCollide then -- Detectou obstáculo
        isJumping = true
        if not headClear then -- É uma torre/degrau
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.Velocity = (hrp.CFrame.LookVector * -12) + Vector3.new(0, getgenv().ZakySettings.Jump * 1.2, 0)
            task.wait(0.15)
            hrp.Velocity = (hrp.CFrame.LookVector * 30) + Vector3.new(0, 15, 0)
        else
            hum.Jump = true
        end
        task.wait(0.4)
        isJumping = false
    end
end

RS.Heartbeat:Connect(ThinkParkour)--// FIX TOTAL: ESP & NOCLIP
local function ManageESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("ZakyESP")
            if getgenv().ZakySettings.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "ZakyESP"
                end
                highlight.FillColor = getgenv().ZakySettings.Color
                highlight.Enabled = true
            elseif highlight then
                highlight.Enabled = false
            end
        end
    end
end

-- Fix de Colisão (Noclip Persistente)
RS.Stepped:Connect(function()
    if getgenv().ZakySettings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    ManageESP()
end)

-- Anti-Lag
local function CleanMap()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("PostProcessEffect") or v:IsA("Explosion") then v:Destroy() end
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Material = Enum.Material.Plastic
        end
    end
end--// INTERFACE DE COMANDO
local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0, 120, 1, -10); Side.Position = UDim2.new(0, 5, 0, 5); Side.BackgroundTransparency = 1
Instance.new("UIListLayout", Side).Padding = UDim.new(0, 5)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -140, 1, -20); Scroll.Position = UDim2.new(0, 130, 0, 10); Scroll.BackgroundTransparency = 1

local function AddToggle(name, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, -10, 0, 35); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(30,30,40)
    b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and getgenv().ZakySettings.Color or Color3.fromRGB(30,30,40)
        callback(active)
    end)
    Scroll.CanvasSize = UDim2.new(0,0,0, Scroll.UIListLayout.AbsoluteContentSize.Y)
end

Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 5)

-- Botões
AddToggle("Parkour IA (2x Smart)", function(v) getgenv().ZakySettings.ParkourIA = v end)
AddToggle("Noclip (Fixed)", function(v) getgenv().ZakySettings.Noclip = v end)
AddToggle("Ligar ESP", function(v) getgenv().ZakySettings.ESP = v end)
AddToggle("Pulo Infinito", function(v) getgenv().ZakySettings.InfJump = v end)

AddToggle("Ativar Fly", function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end)

AddToggle("Anti-Lag", function() CleanMap() end)

-- Aimbot / CamLock
AddToggle("Travar Mira (Lock)", function(v) getgenv().ZakySettings.CamLock = v end)

RS.RenderStepped:Connect(function()
    if getgenv().ZakySettings.CamLock and getgenv().ZakySettings.Target then
        local t = getgenv().ZakySettings.Target.Character
        if t and t:FindFirstChild("HumanoidRootPart") then
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, t.HumanoidRootPart.Position)
        end
    end
end)

-- Pulo Infinito Logic
UIS.JumpRequest:Connect(function()
    if getgenv().ZakySettings.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(3)
    end
end)
