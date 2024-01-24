local _, iglist = ...
iglist.addonname = "IGL"
iglist.debug = {}

local igldbg = iglist.debug

-- Debug print
function igldbg:print(message)
    local prefix = "IgnoreList"
    DEFAULT_CHAT_FRAME:AddMessage(string.format("%s: %s", prefix, message))
end
