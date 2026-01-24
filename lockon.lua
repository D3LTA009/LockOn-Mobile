warn("Lock On carregado")
--[[ 
 LockOn Mobile - estilo console
 by D3LTA
]]

-- CONFIG
local LOCK_RANGE = 200
local SMOOTHNESS = 0.18 -- quanto menor, mais preciso
local IGNORE_TODO_ULT = true

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- STATE
local LockedTarget = nil
local LockEnabled = false

-- FUNÇÕES AUXILIARES

local function isSameTeam(player)
    if not player or not player.Team or not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function isTodoUlt(character)
    if not IGNORE_TODO_ULT then return false end
    if not character then return false end

    -- ajuste esse nome se no seu jogo for diferente
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

    -- Player check
    local player = Players:GetPlayerFromCharacter(model)
    if player then
        if isSameTeam(player) then return false end
    end

    -- Ignorar ult do Todo
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

-- LOCK SYSTEM
RunService.RenderStepped:Connect(function()
    if LockEnabled and LockedTarget and LockedTarget:FindFirstChild("HumanoidRootPart") then
        local root = LockedTarget.HumanoidRootPart
        local targetPos = root.Position + Vector3.new(0, 1.5, 0)

        local newCFrame = CFrame.new(
            Camera.CFrame.Position,
            Camera.CFrame.Position:Lerp(targetPos, SMOOTHNESS)
        )

        Camera.CFrame = newCFrame
    end
end)

-- INPUT (MOBILE + PC)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- Mobile (toque)
    if input.UserInputType == Enum.UserInputType.Touch then
        LockEnabled = not LockEnabled

        if LockEnabled then
            LockedTarget = getClosestTarget()
        else
            LockedTarget = nil
        end
    end

    -- PC (Q)
    if input.KeyCode == Enum.KeyCode.Q then
        LockEnabled = not LockEnabled

        if LockEnabled then
            LockedTarget = getClosestTarget()
        else
            LockedTarget = nil
        end
    end
end)

-- FEEDBACK
warn("[LockOn Mobile] Carregado com sucesso 🔥")
