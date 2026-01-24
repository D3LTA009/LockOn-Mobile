--[[
 Lock On Mobile - FINAL
 - DUMMY SEMPRE FUNCIONA
 - IGNORA APENAS NPC DA ULT DO TODO
 - IGNORA MESMO TIME
 - ALTA PRECISÃO (DASH / PREDICTION)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer

-- =============================
-- CONFIG
-- =============================
local LOCK_RANGE = 120
local CAMERA_DISTANCE = 13
local CAMERA_HEIGHT = 3.5
local SMOOTHNESS = 0.18

local PREDICTION_TIME = 0.18
local DASH_SENSITIVITY = 0.35
local MIN_CAM_DISTANCE = 11

-- =============================
-- VARIÁVEIS
-- =============================
local Char, HRP, Humanoid
local lockOn = false
local targetHRP
local ring
local currentCF = Camera.CFrame

-- =============================
-- DESLIGAR LOCK
-- =============================
local function disableLock()
    lockOn = false
    targetHRP = nil
    if ring then ring:Destroy() ring = nil end
    Camera.CameraType = Enum.CameraType.Custom
end

-- =============================
-- IDENTIFICAR DUMMY (WHITELIST)
-- =============================
local function isDummy(model)
    local name = model.Name:lower()
    if name:find("dummy") or name:find("training") then
        return true
    end
    return false
end

-- =============================
-- IDENTIFICAR NPC DA ULT DO TODO
-- =============================
local function isTodoUltNPC(model)
    if model == Char or not HRP then return true end

    -- ❗ SE FOR DUMMY, NUNCA IGNORA
    if isDummy(model) then
        return false
    end

    -- nunca bloquear players
    if Players:GetPlayerFromCharacter(model) then
        return false
    end

    local hum = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return false end

    -- NPC da ult do Todo: segue + voa + fica colado
    if (hrp.Position - HRP.Position).Magnitude < 6 then
        return true
    end

    if hum.FloorMaterial == Enum.Material.Air then
        return true
    end

    if hum.AutoRotate == false then
        return true
    end

    if hrp.CanCollide == false then
        return true
    end

    return false
end

-- =============================
-- IGNORAR MESMO TIME
-- =============================
local function isSameTeam(model)
    local plr = Players:GetPlayerFromCharacter(model)
    if plr and LP.Team then
        return plr.Team == LP.Team
    end
    return false
end

-- =============================
-- ACHAR ALVO
-- =============================
local function getClosestTarget()
    if not HRP then return nil end

    local closest, shortest = nil, LOCK_RANGE

    for _, m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") and not isTodoUltNPC(m) and not isSameTeam(m) then
            local hum = m:FindFirstChildOfClass("Humanoid")
            local hrp = m:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 then
                local dist = (HRP.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = hrp
                end
            end
        end
    end

    return closest
end

-- =============================
-- INDICADOR
-- =============================
local function createRing(model)
    if ring then ring:Destroy() end
    ring = Instance.new("SelectionBox")
    ring.Adornee = model
    ring.LineThickness = 0.06
    ring.Color3 = Color3.fromRGB(255,0,0)
    ring.SurfaceTransparency = 1
    ring.Parent = game.CoreGui
end

-- =============================
-- CÂMERA (PRECISA)
-- =============================
RunService.RenderStepped:Connect(function(dt)
    if not lockOn or not targetHRP or not HRP then return end
    if not targetHRP.Parent then disableLock() return end

    local hum = targetHRP.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        disableLock()
        return
    end

    Camera.CameraType = Enum.CameraType.Scriptable

    local vel = targetHRP.AssemblyLinearVelocity
    local predicted = targetHRP.Position + vel * PREDICTION_TIME

    local dir = predicted - HRP.Position
    local dist = math.max(dir.Magnitude, MIN_CAM_DISTANCE)
    local camPos =
        HRP.Position
        - dir.Unit * math.clamp(dist, MIN_CAM_DISTANCE, CAMERA_DISTANCE)
        + Vector3.new(0, CAMERA_HEIGHT, 0)

    local lookPos = predicted + Vector3.new(0,1.4,0)

    local lerpAlpha = math.clamp(
        SMOOTHNESS + (vel.Magnitude * DASH_SENSITIVITY * dt),
        SMOOTHNESS,
        0.45
    )

    currentCF = currentCF:Lerp(CFrame.new(camPos, lookPos), lerpAlpha)
    Camera.CFrame = currentCF
end)

-- =============================
-- GUI MOBILE
-- =============================
local gui = Instance.new("ScreenGui", game.CoreGui)
local btn = Instance.new("TextButton", gui)

btn.Size = UDim2.new(0,140,0,50)
btn.Position = UDim2.new(0.7,0,0.75,0)
btn.Text = "LOCK OFF"
btn.TextScaled = true
btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.BorderSizePixel = 0
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

btn.MouseButton1Click:Connect(function()
    lockOn = not lockOn
    if lockOn then
        targetHRP = getClosestTarget()
        if targetHRP then
            createRing(targetHRP.Parent)
            currentCF = Camera.CFrame
            btn.Text = "LOCK ON"
            btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
        else
            lockOn = false
        end
    else
        disableLock()
        btn.Text = "LOCK OFF"
        btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    end
end)

-- =============================
-- CHARACTER
-- =============================
local function onCharacter(char)
    Char = char
    HRP = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    disableLock()
    Humanoid.Died:Connect(disableLock)
end

if LP.Character then onCharacter(LP.Character) end
LP.CharacterAdded:Connect(onCharacter)
