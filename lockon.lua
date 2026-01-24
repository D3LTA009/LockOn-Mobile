-- LockOn Mobile - estilo console (FINAL)
-- by D3LTA

warn("[LockOn] Script carregando...")

-- ================= CONFIG =================
local LOCK_RANGE = 200
local SMOOTHNESS = 0.15 -- menor = acompanha dash melhor
local IGNORE_TODO_ULT = true

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer.Character

-- ================= STATE =================
local LockedTarget = nil
local LockEnabled = false

-- ================= FUNÇÕES =================

local function isSameTeam(player)
    if not player or not player.Team or not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function isTodoUlt(character)
    if not IGNORE_TODO_ULT or not character then return false end

    -- nomes comuns de NPC / ult
    if character.Name and character.Name:lower():find("todo") then
        return true
    end

    return character:FindFirstChild("TodoUlt")
        or character:FindFirstChild("IceDomain")
        or character:FindFirstChild("UltActive")
end

local function isValidTarget(model)
    if not model then return false end
    if model == LocalPlayer.Character then return false end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")

    if not humanoid or humanoid.Health <= 0 or not root then
        return false
    end

    local player = Players:GetPlayerFromCharacter(model)
    if player and isSameTeam(player) then
        return false
    end

    if isTodoUlt(model) then
        return false
    end

    return true
end

local function getClosestTarget()
    local closest = nil
    local shortest = LOCK_RANGE

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and isValidTarget(obj) then
            local root = obj:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = obj
                end
            end
        end
    end

    return closest
end

-- ================= CAMERA LOCK =================
RunService.RenderStepped:Connect(function()
    if LockEnabled and LockedTarget and LockedTarget:FindFirstChild("HumanoidRootPart") then
        local root = LockedTarget.HumanoidRootPart
        local camPos = Camera.CFrame.Position
        local lookPos = root.Position + Vector3.new(0, 1.5, 0)

        local desired = CFrame.new(camPos, lookPos)
        Camera.CFrame = Camera.CFrame:Lerp(desired, SMOOTHNESS)
    end
end)

-- ================= INPUT =================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.UserInputType == Enum.UserInputType.Touch
        or input.KeyCode == Enum.KeyCode.Q then

        LockEnabled = not LockEnabled

        if LockEnabled then
            LockedTarget = getClosestTarget()
        else
            LockedTarget = nil
        end
    end
end)

-- ================= MORTE / RESET =================
local function onCharacter(char)
    local hum = char:WaitForChild("Humanoid")

    hum.Died:Connect(function()
        LockEnabled = false
        LockedTarget = nil
    end)
end

if LocalPlayer.Character then
    onCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacter)

-- ================= FINAL =================
warn("[LockOn Mobile] Carregado com sucesso 🔥")
