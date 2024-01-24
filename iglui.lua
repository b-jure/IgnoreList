local _, iglist = ...
iglist.ui = {}
local ui = iglist.ui
local addonname = iglist.addonname

local font = "Interface\\AddOns\\IgnoreList\\Font\\"
local fonts = { hack = "Hack-Regular.ttf" }
local function getfont(name) return font .. fonts[name] end

local uiframes = {
    mainframe = { template = "BasicFrameTemplate", width = 200, height = 350 },
    mainframe_scroll = { template = "UIPanelScrollFrameTemplate", width = 200, height = 320 }
}

-- Main frame
local mainui = uiframes.mainframe
ui.mainframe = ui.mainframe or CreateFrame("Frame", addonname .. "MainFrame", UIParent, mainui.template)
local mainframe = ui.mainframe
mainframe:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainframe:SetWidth(mainui.width)
mainframe:SetHeight(mainui.height)
mainframe:SetMovable(true)
mainframe:EnableMouse(true)
mainframe:RegisterForDrag("LeftButton")
mainframe:SetScript("OnDragStart", function(self) self:StartMoving() end)
mainframe:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
mainframe.title_text = mainframe.title_text or mainframe:CreateFontString(nil, "ARTWORK", "GameFontNormal")
mainframe.title_text:SetFont(getfont("hack"), 13, "OUTLINE")
mainframe.title_text:SetPoint("TOPLEFT", mainframe, "TOPLEFT", 4, -5)
mainframe.header_text = mainframe.header_text or mainframe:CreateFontString(nil, "ARTWORK", "DialogButtonNormalText")
mainframe.header_text:SetFont(getfont("hack"), 13, "OUTLINE")
mainframe.header_text:SetPoint("TOP", mainframe, "TOP", 0, -30)
local refreshbutton = mainframe.button_refresh or CreateFrame("Button", nil, mainframe, "UIPanelButtonTemplate")
refreshbutton:SetPoint("TOPLEFT", mainframe, "TOPLEFT", 2, -21)
refreshbutton:SetSize(30, 28)
refreshbutton:SetText("R")
mainframe.button_refresh = refreshbutton
-- 'OnClick' handler is set in [@igl.lua]

-- Increments scroll area height
local function increase_scrollarea(scrollchild, increment)
    local oldheight = scrollchild:GetHeight()
    scrollchild:SetHeight(oldheight + increment)
end

-- Scroll frame
local scrollui = uiframes.mainframe_scroll
ui.mainframe.scroll = ui.mainframe.scroll or
                          CreateFrame("ScrollFrame", mainframe:GetName() .. "ScrollFrame", mainframe, scrollui.template)
local scroll = ui.mainframe.scroll -- scroll frame
local scrollname = scroll:GetName()
scroll:SetPoint("TOPLEFT", mainframe, 5, -55)
scroll:SetPoint("BOTTOMRIGHT", mainframe, -5, 5)
scroll:EnableMouse(true)
scroll:SetScript("OnMouseWheel", function(self, delta)
    local max = self:GetVerticalScrollRange()
    local position = self:GetVerticalScroll() - (delta * 15)
    if position < 0 then
        position = 0
    elseif position > max then
        position = max
    end
    self:SetVerticalScroll(position)
end)
-- Scroll bar
local scrollbar = _G[scrollname .. "ScrollBar"] -- scroll bar
scrollbar:ClearAllPoints()
scrollbar:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", -1, -17)
scrollbar:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", -1, 17)
-- child frame for scroll frame
mainframe.scrollcontent = mainframe.scrollcontent or CreateFrame("Frame", scrollname .. "ContentFrame", scroll)
local scrollcontent = mainframe.scrollcontent
scroll:SetScrollChild(scrollcontent)
scrollcontent:SetWidth(scroll:GetWidth())
-- set height incrementally each time new frame is anchored to scrollcontent

-- 'Matched ignores' frame
mainframe.matches = mainframe.matches or CreateFrame("Frame", nil, scrollcontent)
local matches = mainframe.matches
matches:SetPoint("TOP", scrollcontent, "TOP", 0, 0)
matches:SetWidth(scrollcontent:GetWidth())
matches.text = matches.text or matches:CreateFontString(addonname .. "NamelistText", "ARTWORK", "DialogButtonNormalText")
matches.text:SetFont(getfont("hack"), 13, "OUTLINE")
matches.text:SetPoint("TOP", matches, "TOP", 0, 0)

--
-- @API
--

-- Set mainframe header text
function ui:set_header_text(text) mainframe.header_text:SetText(text) end
-- Set scroll content text
function ui:set_scroll_text(text)
    matches.text:SetText(text)
    matches:SetHeight(matches.text:GetStringHeight())
    increase_scrollarea(scrollcontent, matches:GetHeight())
end
-- Set mainframe title text
function ui:set_title_text(text) mainframe.title_text:SetText(text) end
-- Show mainframe
function ui:open() mainframe:Show() end
-- Hide mainframe
function ui:close() mainframe:Hide() end
-- Reset mainframe position
function ui:reset()
    mainframe:ClearAllPoints()
    mainframe:SetPoint("CENTER", nil, "CENTER", 0, 0)
end

ui:set_title_text("IgnoreList") -- default title
mainframe:Hide() -- hide per default
