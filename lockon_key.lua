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
