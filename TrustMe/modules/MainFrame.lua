local L		= GUI_L
local CL	= CORE_L
local DEBUG = DEBUG

local CreateFrame = CreateFrame


local frame = _G["GUI_OptionsFrame"]
table.insert(_G["UISpecialFrames"], frame:GetName())

frame:SetFrameStrata("DIALOG")
frame:SetPoint("CENTER")
frame:SetSize(800, 600)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetResizable(true)
frame:SetClampedToScreen(true)
frame:SetUserPlaced(true)
frame:RegisterForDrag("LeftButton")
frame:SetFrameLevel(frame:GetFrameLevel() + 4)
frame:SetMinResize(800, 400)
frame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
frame:Show()

frame:SetBackdrop({
	bgFile		= "Interface\\DialogFrame\\UI-DialogBox-Background", -- 131071
	edgeFile	= "Interface\\DialogFrame\\UI-DialogBox-Border", -- 131072
	tile		= true,
	tileSize	= 32,
	edgeSize	= 32,
	insets		= { left = 11, right = 12, top = 12, bottom = 11 }
})
frame.firstshow = true
frame:SetScript("OnShow", function(self)
	if self.firstshow then
		self.firstshow = false
		self:ShowTab(1)
	end
end)
frame:SetScript("OnHide", function()
	_G["GUI_DropDown"]:Hide()
end)
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	--local point, _, _, x, y = self:GetPoint(1)
	--DBM.Options.GUIPoint = point
	--DBM.Options.GUIX = x
	--DBM.Options.GUIY = y
end)
frame:SetScript("OnSizeChanged", function(self)
	self:UpdateMenuFrame()
	if GUI.currentViewing then
		self:DisplayFrame(GUI.currentViewing)
	end
end)
frame:SetScript("OnMouseUp", function(self)
	self:StopMovingOrSizing()
end)
frame.tabs = {}

local frameResize = CreateFrame("Frame", nil, frame)
frameResize:SetSize(10, 10)
frameResize:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
frameResize:EnableMouse(true)
frameResize:SetScript("OnMouseDown", function()
	frame:StartSizing("BOTTOMRIGHT")
end)
frameResize:SetScript("OnMouseUp", function()
	frame:StopMovingOrSizing()
	--DBM.Options.GUIWidth = frame:GetWidth()
	--DBM.Options.GUIHeight = frame:GetHeight()
end)

local frameHeader = frame:CreateTexture("$parentHeader", "ARTWORK")
frameHeader:SetPoint("TOP", 0, 12)
frameHeader:SetTexture(131080) -- "Interface\\DialogFrame\\UI-DialogBox-Header"
frameHeader:SetSize(300, 68)

local frameHeaderText = frame:CreateFontString("$parentHeaderText", "ARTWORK", "GameFontNormal")
frameHeaderText:SetPoint("TOP", frameHeader, 0, -14)
frameHeaderText:SetText(L.MainFrame)

local frameRevision = frame:CreateFontString("$parentRevision", "ARTWORK", "GameFontDisableSmall")
frameRevision:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 18)


local frameOkay = CreateFrame("Button", "$parentOkay", frame, "UIPanelButtonTemplate")
frameOkay:SetSize(96, 22)
frameOkay:SetPoint("BOTTOMRIGHT", -16, 14)
frameOkay:SetText(CLOSE)
frameOkay:SetScript("OnClick", function()
	frame:Hide()
end)

local frameWebsite = frame:CreateFontString("$parentWebsite", "ARTWORK", "GameFontNormal")
frameWebsite:SetPoint("BOTTOMLEFT", frameRevision, "TOPLEFT", 0, 15)
frameWebsite:SetPoint("RIGHT", frameOkay, "RIGHT")
frameWebsite:SetText(L.Website)

local lockUI = CreateFrame("CheckButton", "$parentLockUI", frame, 'OptionsBaseCheckButtonTemplate')
lockUI:SetPoint("BOTTOMLEFT", frameRevision, "TOPLEFT", 0, -7)
lockUI:SetHitRectInsets(0, 0, 0, 0)
lockUI:SetScript("OnClick", function ( self )
	if DEBUG then
		print('lock button clicked')
	end
end)

local frameLock = frame:CreateFontString("$parentLock", "ARTWORK", "GameFontNormal")
frameLock:SetPoint("LEFT", lockUI, "RIGHT")
frameLock:SetText(L.LockUI)


--local frameWebsiteButtonA = CreateFrame("Frame", nil, frame)
--frameWebsiteButtonA:SetAllPoints(frameWebsite)
--frameWebsiteButtonA:SetScript("OnMouseUp", function()
--	--DBM:ShowUpdateReminder(nil, nil, CL.COPY_URL_DIALOG, "https://discord.gg/deadlybossmods")
--end)

--local frameWebsiteButton = CreateFrame("Button", "$parentWebsiteButton", frame, "UIPanelButtonTemplate")
--frameWebsiteButton:SetSize(96, 22)
--frameWebsiteButton:SetPoint("BOTTOMRIGHT", frameOkay, "BOTTOMLEFT", -20, 0)
--frameWebsiteButton:SetText(L.WebsiteButton)
--frameWebsiteButton:SetScript("OnClick", function()
--	DBM:ShowUpdateReminder(nil, nil, CL.COPY_URL_DIALOG)
--end)


-- 添加tab
local bossMods = CreateFrame("Frame", "$parentBossMods", frame)
bossMods.name = L.OTabBosses
frame:CreateTab(bossMods)

--local DBMOptions = CreateFrame("Frame", "$parentOptions", frame)
--DBMOptions.name = L.OTabOptions
--frame:CreateTab(DBMOptions)


local hack = OptionsList_OnLoad
function OptionsList_OnLoad(self, ...)
	if self:GetName() ~= frame:GetName() .. "List" then
		hack(self, ...)
	end
end
local frameList = CreateFrame("Frame", "$parentList", frame, "OptionsFrameListTemplate")
frameList:SetWidth(205)
frameList:SetPoint("TOPLEFT", 22, -40)
frameList:SetPoint("BOTTOMLEFT", frameWebsite, "TOPLEFT", 0, 5)
frameList:SetScript("OnShow", function()
	frame:UpdateMenuFrame()
end)
frameList.offset = 0
frameList:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
frameList.buttons = {}
for i = 1, math.floor(UIParent:GetHeight() / 18) do
	local button = CreateFrame("Button", "$parentButton" .. i, frameList)
	button:SetHeight(18)
	button.text = button:CreateFontString("$parentText", "ARTWORK", "GameFontNormalSmall")
	button:RegisterForClicks("LeftButtonUp")
	button:SetScript("OnClick", function(self)
		frame:ClearSelection()
		frame.tabs[frame.tab].selection = self.element
		self:LockHighlight()
		frame:DisplayFrame(self.element)
	end)
	if i == 1 then
		button:SetPoint("TOPLEFT", frameList, 0, -8)
	else
		button:SetPoint("TOPLEFT", frameList.buttons[i - 1], "BOTTOMLEFT")
	end
	local buttonHighlight = button:CreateTexture("$parentHighlight")
	buttonHighlight:SetTexture(136809) -- "Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
	buttonHighlight:SetBlendMode("ADD")
	buttonHighlight:SetPoint("TOPLEFT", 0, 1)
	buttonHighlight:SetPoint("BOTTOMRIGHT", 0, 1)
	buttonHighlight:SetVertexColor(0.196, 0.388, 0.8)
	button:SetHighlightTexture(buttonHighlight)
	frameList.buttons[i] = button
	local buttonToggle = CreateFrame("Button", "$parentToggle", button, "UIPanelButtonTemplate")
	button.toggle = buttonToggle
	buttonToggle:SetSize(14, 14)
	buttonToggle:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -1)
	buttonToggle:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	buttonToggle:SetScript("OnClick", function()
		button.element.showSub = not button.element.showSub
		frame:UpdateMenuFrame()
	end)
end

--right
local frameListList = _G[frameList:GetName() .. "List"]
frameListList:SetBackdrop({
	edgeFile	= "Interface\\Tooltips\\UI-Tooltip-Border", -- 137057
	tile		= true,
	tileSize	= 16,
	edgeSize	= 12,
	insets		= { left = 0, right = 0, top = 5, bottom = 5 }
})
frameListList:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.6)
frameListList:SetScript("OnVerticalScroll", function(self, offset)
	local scrollbar = _G[self:GetName() .. "ScrollBar"]
	local _, max = scrollbar:GetMinMaxValues()
	scrollbar:SetValue(offset)
	_G[self:GetName() .. "ScrollBarScrollUpButton"]:SetEnabled(offset ~= 0)
	_G[self:GetName() .. "ScrollBarScrollDownButton"]:SetEnabled(scrollbar:GetValue() - max ~= 0)
	frameList.offset = math.floor((offset / 18) + 0.5)
	frame:UpdateMenuFrame()
end)
local frameListScrollBar = _G[frameListList:GetName() .. "ScrollBar"]
frameListScrollBar:SetMinMaxValues(0, 11)
frameListScrollBar:SetValueStep(18)
frameListScrollBar:SetValue(0)
frameList:SetScript("OnMouseWheel", function(_, delta)
	frameListScrollBar:SetValue(frameListScrollBar:GetValue() - (delta * 18))
end)
local scrollUpButton = _G[frameListScrollBar:GetName() .. "ScrollUpButton"]
scrollUpButton:Disable()
scrollUpButton:SetScript("OnClick", function(self)
	self:GetParent():SetValue(self:GetParent():GetValue() - 18)
end)
local scrollDownButton = _G[frameListScrollBar:GetName() .. "ScrollDownButton"]
scrollDownButton:Enable()
scrollDownButton:SetScript("OnClick", function(self)
	self:GetParent():SetValue(self:GetParent():GetValue() + 18)
end)

local frameContainer = CreateFrame("ScrollFrame", "$parentPanelContainer", frame)
frameContainer:SetPoint("TOPLEFT", frameList, "TOPRIGHT", 16, 0)
frameContainer:SetPoint("BOTTOMLEFT", frameList, "BOTTOMRIGHT", 16, 0)
frameContainer:SetPoint("RIGHT", -22, 0)
frameContainer:SetBackdrop({
	edgeFile	= "Interface\\Tooltips\\UI-Tooltip-Border", -- 137057
	edgeSize	= 16,
	tileEdge	= true
})
frameContainer:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

local frameContainerHeaderText = frameContainer:CreateFontString("$parentHeaderText", "BACKGROUND", "GameFontHighlightSmall")
frameContainerHeaderText:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 10, 1)

local frameContainerFOV = CreateFrame("ScrollFrame", "$parentFOV", frameContainer, "FauxScrollFrameTemplate")
frameContainerFOV:Hide()
frameContainerFOV:SetPoint("TOPLEFT", frameContainer, "TOPLEFT", 0, -5)
frameContainerFOV:SetPoint("BOTTOMRIGHT", frameContainer, "BOTTOMRIGHT", 0, 5)

_G[frameContainerFOV:GetName() .. "ScrollBarScrollUpButton"]:Disable()
_G[frameContainerFOV:GetName() .. "ScrollBarScrollDownButton"]:Enable()

local frameContainerScrollBar = _G[frameContainerFOV:GetName() .. "ScrollBar"]
frameContainerScrollBar:ClearAllPoints()
frameContainerScrollBar:SetPoint("TOPRIGHT", -4, -15)
frameContainerScrollBar:SetPoint("BOTTOMRIGHT", 0, 15)

local frameContainerScrollBarBackdrop = CreateFrame("Frame", nil, frameContainerScrollBar)
frameContainerScrollBarBackdrop:SetPoint("TOPLEFT", -4, 20)
frameContainerScrollBarBackdrop:SetPoint("BOTTOMRIGHT", 4, -20)
frameContainerScrollBarBackdrop:SetBackdrop({
	edgeFile	= "Interface\\Tooltips\\UI-Tooltip-Border", -- 137057
	tile		= true,
	tileSize	= 16,
	edgeSize	= 16,
	insets		= { left = 0, right = 0, top = 5, bottom = 5 }
})
frameContainerScrollBarBackdrop:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.6)
