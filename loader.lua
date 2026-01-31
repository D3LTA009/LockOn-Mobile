-- LOADER PUBLICO

local linkvertise = "https://link-hub.net/3053424/bnME7R5BTulk"

local function copy(txt)
    if setclipboard then
        setclipboard(txt)
    elseif toclipboard then
        toclipboard(txt)
    end
end

copy(linkvertise)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Lock On Script",
    Text = "Link copiado! Complete o Linkvertise para pegar o script.",
    Duration = 6
})

warn("Complete o Linkvertise para obter o script.")
