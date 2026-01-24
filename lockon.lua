--[[ 
 LockOn Mobile - FINAL DEFINITIVO
 Estilo console | Mobile | Estável
 by D3LTA
]]

warn("[LockOn] Iniciando...")

-- ================= CONFIG =================
local LOCK_RANGE = 220
local SMOOTHNESS = 0.12
local CAMERA_DISTANCE = 6
local IGNORE_TODO_ULT = true

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
repeat task.wait() until LocalPlayer.Character

-- ================= STATE =================
local LockedTarget = nil
local LockEnabled = false
local Indicator = nil

-- ================= UI =================
local gui = Instance.new("ScreenGui")
gui.Name = "LockOnUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromScale(0.18, 0.08)
button.Position = UDim2.fromScale(0.75, 0.75)
button.Text = "LOCK"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(25,25,25)
button.TextColor3 = Color3.fromRGB(255,0,0)
button.Active = true
button.Draggable = true
button.Parent = gui

-- ================= FUNÇÕES =================
local function isSameTeam(player)
    return player and LocalPlayer.Team and player.Team == LocalPlayer.Team
end

local function isTodoUlt(model)
    if not IGNORE_TODO_ULT or not model then return false end
    return model.Name:lower():find("todo") and not Players:GetPlayerFromCharacter(model)
end

local function isValidTarget(model)
    if not model or model == LocalPlayer.Character then return false end

    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not root then return false end

    local plr = Players:GetPlayerFromCharacter(model)
    if plr and isSameTeam(plr) then return false end

    if isTodoUlt(model) then return false end

    return true
end

local function getClosestTarget()
    local closest, dist = nil, LOCK_RANGE
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and isValidTarget(obj) then
            local root = obj:FindFirstChild("HumanoidRootPart")
            local d = (Camera.CFrame.Position - root.Position).Magnitude
            if d < dist then
                dist = d
                closest = obj
            end
        end
    end
    return closest
end

-- ================= INDICADOR =================
local function createIndicator(target)
    if Indicator then Indicator:Destroy() end
    local box = Instance.new("SelectionBox")
    box.Adornee = target
    box.LineThickness = 0.05
    box.Color3 = Color3.fromRGB(255,255,255)
    box.Parent = target
    Indicator = box
end

local function clearIndicator()
    if Indicator then
        Indicator:Destroy()
        Indicator = nil
    end
end

-- ================= CAMERA =================
RunService.RenderStepped:Connect(function()
    if LockEnabled and LockedTarget and LockedTarget:FindFirstChild("HumanoidRootPart") then
        local root = LockedTarget.HumanoidRootPart
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local myRoot = char.HumanoidRootPart
        local camPos = myRoot.Position - (myRoot.CFrame.LookVector * CAMERA_DISTANCE) + Vector3.new(0,2,0)
        local lookAt = root.Position + Vector3.new(0,1.5,0)

        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(camPos, lookAt),
            SMOOTHNESS
        )
    end
end)

-- ================= BOTÃO =================
button.MouseButton1Click:Connect(function()
    LockEnabled = not LockEnabled

    if LockEnabled then
        LockedTarget = getClosestTarget()
        if LockedTarget then
            createIndicator(LockedTarget)
            button.Text = "LOCK ON"
            button.TextColor3 = Color3.fromRGB(0,255,0)
        else
            LockEnabled = false
        end
    else
        LockedTarget = nil
        clearIndicator()
        button.Text = "LOCK"
        button.TextColor3 = Color3.fromRGB(255,0,0)
    end
end)

-- ================= MORTE / RESET =================
local function onCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        LockEnabled = false
        LockedTarget = nil
        clearIndicator()
        button.Text = "LOCK"
        button.TextColor3 = Color3.fromRGB(255,0,0)
    end)
end

onCharacter(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(onCharacter)

warn("[LockOn] Carregado com sucesso 🔥")
