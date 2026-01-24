-- LOCK ON MOBILE + KEY SYSTEM (TEMPORÁRIA)
-- by D3LTA

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer

-- ================= CONFIG =================
local AUTH_URL = "https://raw.githubusercontent.com/D3LTA009/LockOn-Mobile/refs/heads/main/auth.txt"
local LINKVERTISE_URL = "https://link-hub.net/3053424/bnME7R5BTulk"

-- ================= KEY CHECK =================
local function checkKey(inputKey)
    local data = game:HttpGet(AUTH_URL)

    if not data:find("STATUS=ON") then
        return false, "Script desligado"
    end

    local now = os.time()

    for line in data:gmatch("[^\r\n]+") do
        local uid, key, exp = line:match("(%d+)|([^|]+)|(%d+)")
        if uid and key and exp then
            if tonumber(uid) == LP.UserId and key == inputKey then
                if now <= tonumber(exp) then
                    return true
                else
                    return false, "Key expirada"
                end
            end
        end
    end

    return false, "Key inválida"
end

-- ================= KEY UI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "KeyUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,160)
frame.Position = UDim2.new(0.5,-130,0.5,-80)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BackgroundTransparency = 0.15
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.Text = "LOCK ON - KEY"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(1,-20,0,40)
box.Position = UDim2.new(0,10,0,50)
box.PlaceholderText = "Digite sua Key"
box.Text = ""
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(30,30,30)
box.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

local confirm = Instance.new("TextButton", frame)
confirm.Size = UDim2.new(1,-20,0,35)
confirm.Position = UDim2.new(0,10,0,100)
confirm.Text = "CONFIRMAR"
confirm.TextScaled = true
confirm.BackgroundColor3 = Color3.fromRGB(120,0,0)
confirm.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", confirm).CornerRadius = UDim.new(0,8)

local getKey = Instance.new("TextButton", frame)
getKey.Size = UDim2.new(1,-20,0,25)
getKey.Position = UDim2.new(0,10,0,138)
getKey.Text = "GET KEY"
getKey.TextScaled = true
getKey.BackgroundTransparency = 1
getKey.TextColor3 = Color3.fromRGB(0,170,255)

getKey.MouseButton1Click:Connect(function()
    setclipboard(LINKVERTISE_URL)
end)

confirm.MouseButton1Click:Connect(function()
    local ok, msg = checkKey(box.Text)
    if ok then
        gui:Destroy()
        _G.KEY_OK = true
    else
        confirm.Text = msg
        task.wait(1.5)
        confirm.Text = "CONFIRMAR"
    end
end)

-- ================= BLOQUEIO =================
repeat task.wait() until _G.KEY_OK
--[[
 Lock On Mobile - HUD estilo console (FINAL)
 - DUMMY SEMPRE FUNCIONA
 - IGNORA NPC DA ULT DO TODO
 - IGNORA MESMO TIME
 - HUD pequeno e transparente
 - INDICADOR SÓ CONTORNO (transparente)
 - ALTA PRECISÃO (dash/prediction)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer
repeat task.wait() until LP.Character

-- ================= CONFIG =================
local LOCK_RANGE = 120
local CAMERA_DISTANCE = 13
local CAMERA_HEIGHT = 3.5
local SMOOTHNESS = 0.18
local PREDICTION_TIME = 0.18
local DASH_SENSITIVITY = 0.35
local MIN_CAM_DISTANCE = 11

-- ================= STATE =================
local Char, HRP, Humanoid
local lockOn = false
local targetHRP
local ring
local currentCF = Camera.CFrame

-- ================= FUNÇÕES LOCK =================
local function disableLock()
    lockOn = false
    targetHRP = nil
    if ring then ring:Destroy() ring=nil end
    Camera.CameraType = Enum.CameraType.Custom
    if infoFrame then infoFrame.Visible = false end
end

local function isDummy(model)
    local name = model.Name:lower()
    return name:find("dummy") or name:find("training")
end

local function isTodoUltNPC(model)
    if model == Char or not HRP then return true end
    if isDummy(model) then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return false end
    if (hrp.Position - HRP.Position).Magnitude < 6 then return true end
    if hum.FloorMaterial == Enum.Material.Air then return true end
    if hum.AutoRotate == false then return true end
    if hrp.CanCollide == false then return true end
    return false
end

local function isSameTeam(model)
    local plr = Players:GetPlayerFromCharacter(model)
    return plr and LP.Team and plr.Team == LP.Team
end

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

-- ================= INDICADOR =================
local function createRing(model)
    if ring then ring:Destroy() end
    ring = Instance.new("SelectionBox")
    ring.Adornee = model
    ring.LineThickness = 0.06
    ring.Color3 = Color3.fromRGB(255,0,0)
    ring.SurfaceTransparency = 1 -- interior totalmente transparente
    ring.Parent = game.CoreGui
end

-- ================= HUD =================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LockOnHUD"

local infoFrame = Instance.new("Frame", gui)
infoFrame.Size = UDim2.new(0,140,0,50)
infoFrame.Position = UDim2.new(0.75,0,0.05,0)
infoFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
infoFrame.BackgroundTransparency = 0.7
infoFrame.Visible = false
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0,10)

local nameLabel = Instance.new("TextLabel", infoFrame)
nameLabel.Size = UDim2.new(1,0,0.4,0)
nameLabel.Position = UDim2.new(0,0,0,0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
nameLabel.TextScaled = true
nameLabel.Text = "Nome"

local hpLabel = Instance.new("TextLabel", infoFrame)
hpLabel.Size = UDim2.new(1,0,0.3,0)
hpLabel.Position = UDim2.new(0,0,0.4,0)
hpLabel.BackgroundTransparency = 1
hpLabel.TextColor3 = Color3.fromRGB(0,255,0)
hpLabel.TextScaled = true
hpLabel.Text = "HP"

local distLabel = Instance.new("TextLabel", infoFrame)
distLabel.Size = UDim2.new(1,0,0.3,0)
distLabel.Position = UDim2.new(0,0,0.7,0)
distLabel.BackgroundTransparency = 1
distLabel.TextColor3 = Color3.fromRGB(255,255,255)
distLabel.TextScaled = true
distLabel.Text = "Dist"

-- ================= CAMERA =================
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
    local camPos = HRP.Position - dir.Unit * math.clamp(dist, MIN_CAM_DISTANCE, CAMERA_DISTANCE) + Vector3.new(0,CAMERA_HEIGHT,0)
    local lookPos = predicted + Vector3.new(0,1.4,0)
    local lerpAlpha = math.clamp(SMOOTHNESS + (vel.Magnitude * DASH_SENSITIVITY * dt), SMOOTHNESS,0.45)
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos,lookPos), lerpAlpha)

    -- atualizar HUD
    if targetHRP then
        local targetHum = targetHRP.Parent:FindFirstChildOfClass("Humanoid")
        infoFrame.Visible = true
        nameLabel.Text = targetHRP.Parent.Name
        hpLabel.Text = "HP: "..math.floor(targetHum.Health)
        distLabel.Text = "Dist: "..math.floor((HRP.Position - targetHRP.Position).Magnitude)
    end
end)

-- ================= BOTÃO =================
local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,120,0,40)
btn.Position = UDim2.new(0.75,0,0.85,0)
btn.Text = "LOCK OFF"
btn.TextScaled = true
btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
btn.BackgroundTransparency = 0.7
btn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

btn.MouseButton1Click:Connect(function()
    lockOn = not lockOn
    if lockOn then
        targetHRP = getClosestTarget()
        if targetHRP then
            createRing(targetHRP.Parent)
            currentCF = Camera.CFrame
            btn.Text = "LOCK ON"
            btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
            btn.BackgroundTransparency = 0.5
        else
            lockOn = false
        end
    else
        disableLock()
        btn.Text = "LOCK OFF"
        btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        btn.BackgroundTransparency = 0.7
    end
end)

-- ================= CHARACTER =================
local function onCharacter(char)
    Char = char
    HRP = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    disableLock()
    Humanoid.Died:Connect(disableLock)
end

if LP.Character then onCharacter(LP.Character) end
LP.CharacterAdded:Connect(onCharacter)

warn("[LockOn HUD] Carregado ✅ Transparente e minimalista")
