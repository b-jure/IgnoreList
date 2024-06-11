local _, iglist = ...
local ui = iglist.ui
local igldbg = iglist.debug

iglist.IgnoreList = { names = {} }
iglist.IgnoreList.eventframe = CreateFrame("Frame")
iglist.IgnoreList.eventframe.events = {}

local IgnoreList = iglist.IgnoreList
local eventframe = IgnoreList.eventframe

-- update ignore list table
local function updateigl() -- updates 'IgnoreList'
    local ignores = {}
    local len = GetNumIgnores()
    for i = 1, len, 1 do ignores[GetIgnoreName(i)] = true end
    IgnoreList.names = ignores
end

-- Get names of all group members that are on ignore
-- list.
local function getnames(matches)
    local namesstr = ""
    local len = 0
    for k, _ in pairs(matches) do
        len = len + 1
        namesstr = namesstr .. k .. "\n"
    end
    return namesstr, len
end

-- Get group members table
local function getmembers(member_cnt)
    local members = {}
    for i = 1, member_cnt, 1 do
        if IsInRaid() then
            members[(GetRaidRosterInfo(i)) or ""] = true
        else -- @in party ? Maybe it breaks if in battleground
            members[(UnitName("party" .. i)) or ""] = true
        end
    end
    return members
end

-- Get table of group members that are on ignore list
local function getmatches(members, ignores)
    local matches = {}
    for k, _ in pairs(members) do if ignores[k] == true then matches[k] = true end end
    return matches
end

-- Rescan members and set UI text accordingly
local function rescan_and_update()
    if not IsInGroup() then
        ui:set_header_text("Not in group.")
        return
    end
    local members = getmembers(GetNumGroupMembers())
    local matches = getmatches(members, IgnoreList.names)
    local text, len = getnames(matches)
    ui:set_header_text(string.format("Matched %d", len))
    ui:set_scroll_text(text)
end

-- Slash commands
iglist.commands = {
    help = function()
        igldbg:print("/igl [help] - display help (this)")
        igldbg:print("/igl toggle - toggle on/off IgnoreList UI")
        igldbg:print("/igl open   - open IgnoreList UI")
        igldbg:print("/igl close  - close IgnoreList UI")
        igldbg:print("/igl reset  - reset IgnoreList UI")
    end,
    toggle = function()
        if ui.mainframe:IsShown() then
            ui:close()
        else
            rescan_and_update()
            ui:open()
        end
    end,
    open = function()
        rescan_and_update()
        ui:open()
    end,
    close = function() ui:close() end,
    reset = function() ui:reset() end
}

-- Execute slash command
local function SlashCommand(str)
    if #str == 0 then
        iglist.commands.help()
        return
    end
    local args = {}
    local regx = "[^%s]+"
    for token in string.gmatch(str, regx) do table.insert(args, token) end
    local location = iglist.commands
    for i, arg in ipairs(args) do
        arg = string.lower(arg)
        if type(location[arg]) == "function" then -- arg holds executable function
            location[arg](unpack(args, i + 1)) -- function args are the rest of the tokens
        elseif type(location[arg]) == "table" then -- arg holds table
            location = location[arg] -- set new location to that table
        else -- commands[arg] is of invalid type (most probably nil)
            igldbg:print("unkown command")
            iglist.commands.help()
            return
        end
    end
end

-- Enables slash commands
local function enable_slash_commands()
    SLASH_IgnoreList1 = "/igl"
    SLASH_IgnoreList2 = "/ignorelist"
    SlashCmdList.IgnoreList = SlashCommand
end

-- Enable slash commands per default
enable_slash_commands()

-- set refresh button 'OnClick' handler
ui.mainframe.button_refresh:SetScript("OnClick", function(_, _, down)
    if not down then -- button is not pressed down anymore ?
        rescan_and_update()
    end
end)

-- set event handlers
function eventframe.events:PLAYER_ENTERING_WORLD()
    updateigl()
    rescan_and_update()
end
function eventframe.events:IGNORELIST_UPDATE()
    updateigl()
    rescan_and_update()
end
-- register events
for k, _ in pairs(eventframe.events) do eventframe:RegisterEvent(k) end
-- set event handlers to run on each event trigger
eventframe:SetScript("OnEvent", function(self, event, ...) eventframe.events[event](self, ...) end)
