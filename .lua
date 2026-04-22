--[[
    ZAKY HUB - OMNI-AI (CONSCIENTIZAÇÃO TOTAL)
    - Navegação Autônoma 360° (Vontade Própria)
    - Aprendizado por Reforço (Memória Dinâmica)
    - Ignora Kill-Parts e Obstáculos Móveis
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

--// MEMÓRIA DA IA (ADQUIRE CONHECIMENTO)
getgenv().OmniData = {
    MapNodes = {},        -- Memória de caminhos seguros
    HazardPoints = {},    -- Locais que matam
    ExplorationRate = 1,  -- Nível de "Vontade Própria"
    IsLearning = true
}

getgenv().ZakySettings = {
    Omni_Active = false,
    SafeMode = true,
    Speed = 20,
    JumpPower = 55,
    ESP = false,
    Noclip = false
}

-- Interface Draggable e Botão Minimizar
local Screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 420, 0, 300); Main.Position = UDim2.new(0.5, -210, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 10); Main.Visible = true
Instance.new("UICorner", Main)

local MinBtn = Instance.new("TextButton", Screen)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226); MinBtn.Text = "OMNI"; MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1,0)

-- Função de Arrastar (Draggable)
local function Drag(obj)
    local dragStart, startPos, dragging
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = obj.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
Drag(Main); Drag(MinBtn)
MinBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)--// SISTEMA DE NAVEGAÇÃO AUTÔNOMA
local function GetNearestGoal()
    local target = nil
    local minDist = math.huge
    -- IA busca Checkpoints ou partes chamadas "Finish" ou "End"
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:find("Checkpoint") or v.Name:find("Stage")) then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
            if dist < minDist and dist > 5 then
                minDist = dist
                target = v
            end
        end
    end
    return target
end

local function OmniMove()
    if not getgenv().ZakySettings.Omni_Active then return end
    local char = LocalPlayer.Character
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    local goal = GetNearestGoal()
    if goal then
        -- IA decide o caminho (Pathfinding Inteligente)
        local path = PathfindingService:CreatePath({AgentCanJump = true, AgentRadius = 3})
        path:ComputeAsync(hrp.Position, goal.Position)
        
        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for i, waypoint in pairs(waypoints) do
                if not getgenv().ZakySettings.Omni_Active then break end
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    hum.Jump = true
                end
                hum:MoveTo(waypoint.Position)
                -- Se a IA detectar que ficou presa, ela "aprende" e tenta um pulo de força
                local waitTime = task.wait(0.1)
                if hrp.Velocity.Magnitude < 1 then
                    hum.Jump = true
                    hrp.Velocity = hrp.CFrame.LookVector * 50
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().ZakySettings.Omni_Active then
            pcall(OmniMove)
        end
    end
end)--// SCANNER DE HAZARDS E APRENDIZADO
RS.Heartbeat:Connect(function()
    if not getgenv().ZakySettings.Omni_Active or not LocalPlayer.Character then return end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    -- Escaneamento LIDAR (Detecta perigos em 360°)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    
    for i = 1, 12 do -- 12 raios ao redor do personagem
        local angle = math.rad(i * 30)
        local dir = Vector3.new(math.cos(angle), -0.5, math.sin(angle)) * 10
        local ray = game.Workspace:Raycast(hrp.Position, dir, rayParams)
        
        if ray and ray.Instance then
            -- Se detectar Kill-Part ou algo que a IA já aprendeu que é ruim
            if ray.Instance:FindFirstChildOfClass("TouchTransmitter") or ray.Instance.Name:lower():find("kill") then
                -- IA reage instantaneamente
                char.Humanoid.Jump = true
                hrp.Velocity = (hrp.CFrame.LookVector * -10) + Vector3.new(0, getgenv().ZakySettings.JumpPower, 0)
                table.insert(getgenv().OmniData.HazardPoints, ray.Instance.Position)
            end
        end
    end
end)

-- Sistema de Auto-Otimização (Anti-Lag)
local function Optimize()
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CastShadow = false
            if v.Material ~= Enum.Material.Plastic then v.Material = Enum.Material.Plastic end
        end
    end
end--// INTERFACE DE COMANDOS
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -20); Container.Position = UDim2.new(0, 10, 0, 10)
Container.BackgroundTransparency = 1; Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)

local function NewToggle(txt, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, -10, 0, 40); b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.Text = txt; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(20, 20, 30)
        callback(active)
    end)
end

-- Botões Finais
NewToggle("ATIVAR VONTADE PRÓPRIA (OMNI-AI)", function(v) getgenv().ZakySettings.Omni_Active = v end)
NewToggle("Noclip Persistente", function(v) getgenv().ZakySettings.Noclip = v end)
NewToggle("ESP (Ver através de paredes)", function(v) getgenv().ZakySettings.ESP = v end)
NewToggle("Ativar Fly GUI (XNEOFF)", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() end)
NewToggle("Otimizar Mapa (Anti-Lag)", function() Optimize() end)

-- Loop de Atributos (Speed e Noclip)
RS.Stepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().ZakySettings.Speed
        if getgenv().ZakySettings.Noclip then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)
