--[[
                                                               
  ▄▄▄                              ▄▄▄▄▄                       
 █▀██  ██  ██▀▀ █▄                ██▀▀▀▀█▄                  █▄ 
   ██  ██  ██   ██                ▀██▄  ▄▀       ▄         ▄██▄
   ██  ██  ██   ████▄ ▄███▄ ▄██▀█   ▀██▄▄  ▄███▀ ████▄████▄ ██ 
   ██▄ ██▄ ██   ██ ██ ██ ██ ▀███▄ ▄   ▀██▄ ██    ██   ██ ██ ██ 
   ▀████▀███▀  ▄██ ██▄▀███▀█▄▄██▀ ▀██████▀▄▀███▄▄█▀  ▄████▀▄██ 
                                                      ██       
                                                      ▀          
]]--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local mode = "none"  -- "none", "outline", "fill", "wall"
local currentColor = Color3.fromRGB(255, 0, 0)
local fillTransparency = 0.5  -- New variable for fill transparency
local crosshairEnabled = false
local panelFocus = "side" -- "side" or "palette"
local featureIndex = 1
local featureItems = {}
local disabled = false
local toggleNvg

local theme = {
	bg = Color3.fromRGB(6, 6, 8),
	panel = Color3.fromRGB(12, 12, 16),
	panelGlow = Color3.fromRGB(24, 255, 200),
	card = Color3.fromRGB(20, 20, 26),
	sidebar = Color3.fromRGB(8, 8, 10),
	text = Color3.fromRGB(230, 230, 230),
	muted = Color3.fromRGB(170, 170, 170),
	accent = Color3.fromRGB(0, 255, 190),
	accentDim = Color3.fromRGB(0, 120, 90),
	accentHot = Color3.fromRGB(255, 60, 150)
}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local existingMain = playerGui:FindFirstChild("MainESPUI")
if existingMain then
	existingMain:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainESPUI"
screenGui.IgnoreGuiInset = true -- 🔥 FIX CENTER
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 10
screenGui.Parent = playerGui

local function playIntro()
	local existingIntro = playerGui:FindFirstChild("ESPIntroUI")
	if existingIntro then
		existingIntro:Destroy()
	end

	local introGui = Instance.new("ScreenGui")
	introGui.Name = "ESPIntroUI"
	introGui.IgnoreGuiInset = true
	introGui.ResetOnSpawn = false
	introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	introGui.DisplayOrder = 20
	introGui.Parent = playerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = theme.bg
	backdrop.BackgroundTransparency = 1
	backdrop.Parent = introGui

	local glow = Instance.new("Frame")
	glow.Size = UDim2.fromOffset(420, 140)
	glow.Position = UDim2.fromScale(0.5, 0.5)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.BackgroundColor3 = theme.accent
	glow.BackgroundTransparency = 0.7
	glow.BorderSizePixel = 0
	glow.Parent = introGui
	Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 28)

	local glowGradient = Instance.new("UIGradient")
	glowGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.accentHot),
		ColorSequenceKeypoint.new(1, theme.accent)
	})
	glowGradient.Rotation = 20
	glowGradient.Parent = glow

	local introText = Instance.new("TextLabel")
	introText.Size = UDim2.new(0.9, 0, 0, 100)
	introText.Position = UDim2.fromScale(0.5, 0.5)
	introText.AnchorPoint = Vector2.new(0.5, 0.5)
	introText.BackgroundTransparency = 1
	introText.TextColor3 = theme.text
	introText.Font = Enum.Font.GothamBlack
	introText.TextSize = 40
	introText.TextXAlignment = Enum.TextXAlignment.Center
	introText.TextYAlignment = Enum.TextYAlignment.Center
	introText.TextWrapped = true
	introText.TextTransparency = 1
	introText.Text = "WHOSSCRPT"
	introText.Parent = introGui

	local subText = Instance.new("TextLabel")
	subText.Size = UDim2.new(0.9, 0, 0, 40)
	subText.Position = UDim2.fromScale(0.5, 0.5)
	subText.AnchorPoint = Vector2.new(0.5, -1.2)
	subText.BackgroundTransparency = 1
	subText.TextColor3 = theme.muted
	subText.Font = Enum.Font.Code
	subText.TextSize = 14
	subText.TextXAlignment = Enum.TextXAlignment.Center
	subText.TextYAlignment = Enum.TextYAlignment.Center
	subText.TextWrapped = true
	subText.TextTransparency = 1
	subText.Text = "SCRIPT READY"
	subText.Parent = introGui

	local fadeIn = TweenService:Create(introText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
	local subFadeIn = TweenService:Create(subText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
	local fadeOut = TweenService:Create(introText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1})
	local subFadeOut = TweenService:Create(subText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1})

	fadeIn:Play()
	subFadeIn:Play()
	task.delay(1.4, function()
		fadeOut:Play()
		subFadeOut:Play()
		fadeOut.Completed:Wait()
		introGui:Destroy()
	end)
end

playIntro()


-- Crosshair
local crosshairH = Instance.new("Frame")
crosshairH.Size = UDim2.new(0, 20, 0, 1)
crosshairH.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshairH.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairH.BackgroundColor3 = Color3.new(1 - currentColor.R, 1 - currentColor.G, 1 - currentColor.B)
crosshairH.BackgroundTransparency = 0
crosshairH.Parent = screenGui
crosshairH.Visible = false

local crosshairV = Instance.new("Frame")
crosshairV.Size = UDim2.new(0, 1, 0, 20)
crosshairV.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshairV.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairV.BackgroundColor3 = Color3.new(1 - currentColor.R, 1 - currentColor.G, 1 - currentColor.B)
crosshairV.BackgroundTransparency = 0
crosshairV.Parent = screenGui
crosshairV.Visible = false

local function updateCrosshair()
	local invertedColor = Color3.new(1 - currentColor.R, 1 - currentColor.G, 1 - currentColor.B)
	crosshairH.BackgroundColor3 = invertedColor
	crosshairV.BackgroundColor3 = invertedColor
	crosshairH.Visible = mode ~= "none" and crosshairEnabled
	crosshairV.Visible = mode ~= "none" and crosshairEnabled
end

local function showNotification(text)
	local notif = Instance.new("TextLabel")
	notif.Parent = screenGui
	notif.Size = UDim2.new(0, 400, 0, 50)
	notif.Position = UDim2.new(0.5, -200, 0.5, -25)
	notif.Text = text
	notif.BackgroundTransparency = 1
	notif.TextColor3 = Color3.new(1, 1, 1)
	notif.Font = Enum.Font.SourceSansBold
	notif.TextSize = 24
	notif.TextTransparency = 0
	local tween = TweenService:Create(notif, TweenInfo.new(2), {TextTransparency = 1})
	tween:Play()
	task.delay(2, function()
		notif:Destroy()
	end)
end

-- Extend colors to 25
local colors = {}
for i = 0, 24 do
    colors[i+1] = Color3.fromHSV(i/25, 1, 1)
end

local buttons = {}
local selectedIndex = 1

-- Main container (redesigned again)
local rect = Instance.new("Frame")
rect.Size = UDim2.fromOffset(620, 420)
rect.Position = UDim2.fromScale(0.5, 0.55)
rect.AnchorPoint = Vector2.new(0.5, 0.5)
rect.BackgroundColor3 = theme.panel
rect.BorderSizePixel = 0
rect.Visible = false
rect.Parent = screenGui
Instance.new("UICorner", rect).CornerRadius = UDim.new(0, 20)

local rectStroke = Instance.new("UIStroke")
rectStroke.Color = theme.accentDim
rectStroke.Thickness = 1
rectStroke.Parent = rect

local rectGradient = Instance.new("UIGradient")
rectGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 16)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 34))
})
rectGradient.Rotation = 25
rectGradient.Parent = rect

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundColor3 = theme.bg
header.BackgroundTransparency = 0.05
header.BorderSizePixel = 0
header.Parent = rect
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 20)

local headerAccent = Instance.new("Frame")
headerAccent.Size = UDim2.new(1, 0, 0, 2)
headerAccent.Position = UDim2.fromOffset(0, 54)
headerAccent.BackgroundColor3 = theme.accent
headerAccent.BorderSizePixel = 0
headerAccent.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -160, 1, 0)
title.Position = UDim2.fromOffset(18, 0)
title.BackgroundTransparency = 1
title.Text = "WHOSSCRPT CONTROL"
title.TextColor3 = theme.text
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, -160, 0, 18)
subTitle.Position = UDim2.fromOffset(18, 32)
subTitle.BackgroundTransparency = 1
subTitle.Text = "ESP visual tuning"
subTitle.TextColor3 = theme.muted
subTitle.Font = Enum.Font.Gotham
subTitle.TextSize = 12
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(32, 32)
closeBtn.Position = UDim2.new(1, -44, 0, 12)
closeBtn.AnchorPoint = Vector2.new(0, 0)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = theme.accentHot
closeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
closeBtn.BackgroundTransparency = 0.1
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, -24, 1, -76)
body.Position = UDim2.fromOffset(12, 64)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.Parent = rect

local infoPanel = Instance.new("Frame")
infoPanel.Size = UDim2.new(0, 190, 1, 0)
infoPanel.BackgroundColor3 = theme.sidebar
infoPanel.BorderSizePixel = 0
infoPanel.Parent = body
Instance.new("UICorner", infoPanel).CornerRadius = UDim.new(0, 16)

local infoStroke = Instance.new("UIStroke")
infoStroke.Color = theme.accentDim
infoStroke.Thickness = 1
infoStroke.Parent = infoPanel

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(1, -20, 0, 36)
brand.Position = UDim2.fromOffset(10, 10)
brand.BackgroundTransparency = 1
brand.Text = "WHOSSCRPT"
brand.TextColor3 = theme.text
brand.Font = Enum.Font.Code
brand.TextSize = 16
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.Parent = infoPanel

local statusDivider = Instance.new("Frame")
statusDivider.Size = UDim2.new(1, -20, 0, 1)
statusDivider.Position = UDim2.fromOffset(10, 50)
statusDivider.BackgroundColor3 = theme.accentDim
statusDivider.BorderSizePixel = 0
statusDivider.Parent = infoPanel

local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(1, -20, 0, 24)
modeLabel.Position = UDim2.fromOffset(10, 64)
modeLabel.BackgroundTransparency = 1
modeLabel.TextColor3 = theme.accent
modeLabel.Font = Enum.Font.GothamBold
modeLabel.TextSize = 14
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.Parent = infoPanel

local transLabel = Instance.new("TextLabel")
transLabel.Size = UDim2.new(1, -20, 0, 22)
transLabel.Position = UDim2.fromOffset(10, 90)
transLabel.BackgroundTransparency = 1
transLabel.TextColor3 = theme.muted
transLabel.Font = Enum.Font.Gotham
transLabel.TextSize = 13
transLabel.TextXAlignment = Enum.TextXAlignment.Left
transLabel.Parent = infoPanel

local featureTitle = Instance.new("TextLabel")
featureTitle.Size = UDim2.new(1, -20, 0, 18)
featureTitle.Position = UDim2.fromOffset(10, 126)
featureTitle.BackgroundTransparency = 1
featureTitle.TextColor3 = theme.text
featureTitle.Font = Enum.Font.GothamBold
featureTitle.TextSize = 12
featureTitle.TextXAlignment = Enum.TextXAlignment.Left
featureTitle.Text = "OPACITY"
featureTitle.Parent = infoPanel

local featureList = Instance.new("Frame")
featureList.Size = UDim2.new(1, -20, 0, 160)
featureList.Position = UDim2.fromOffset(10, 150)
featureList.BackgroundTransparency = 1
featureList.BorderSizePixel = 0
featureList.Parent = infoPanel

local featureLayout = Instance.new("UIListLayout")
featureLayout.Padding = UDim.new(0, 4)
featureLayout.FillDirection = Enum.FillDirection.Vertical
featureLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
featureLayout.SortOrder = Enum.SortOrder.LayoutOrder
featureLayout.Parent = featureList

local function createFeatureRow(text)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 22)
	row.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
	row.BackgroundTransparency = 0.7
	row.BorderSizePixel = 0
	row.Parent = featureList
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.7, -6, 1, 0)
	nameLabel.Position = UDim2.fromOffset(6, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = theme.muted
	nameLabel.Font = Enum.Font.Code
	nameLabel.TextSize = 11
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = text
	nameLabel.Parent = row

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0.3, -6, 1, 0)
	statusLabel.Position = UDim2.new(0.7, 0, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.TextColor3 = theme.accent
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 11
	statusLabel.TextXAlignment = Enum.TextXAlignment.Right
	statusLabel.Text = "OFF"
	statusLabel.Parent = row

	local stroke = Instance.new("UIStroke")
	stroke.Color = theme.accent
	stroke.Thickness = 0
	stroke.Parent = row

	featureItems[#featureItems + 1] = {
		row = row,
		status = statusLabel
	}
end

createFeatureRow("[NUM1] OUTLINE ESP")
createFeatureRow("[NUM2/HOME] OPEN PANEL")
createFeatureRow("[NUM3] FILL COLOR")
createFeatureRow("[NUM4] FILL ESP")
createFeatureRow("[NUM5] NVG OVERLAY")
createFeatureRow("[NUM6] CROSSHAIR")

local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, -20, 0, 26)
hintLabel.Position = UDim2.fromOffset(10, 314)
hintLabel.BackgroundTransparency = 1
hintLabel.TextColor3 = theme.muted
hintLabel.Font = Enum.Font.Code
hintLabel.TextSize = 11
hintLabel.TextXAlignment = Enum.TextXAlignment.Left
hintLabel.TextYAlignment = Enum.TextYAlignment.Top
hintLabel.TextWrapped = true
hintLabel.Text = "USE ARROW AND ENTER TO\nENABLE / DISABLE FEATURES"
hintLabel.Parent = infoPanel

local palettePanel = Instance.new("Frame")
palettePanel.Size = UDim2.new(1, -206, 1, 0)
palettePanel.Position = UDim2.fromOffset(206, 0)
palettePanel.BackgroundColor3 = theme.card
palettePanel.BorderSizePixel = 0
palettePanel.Parent = body
Instance.new("UICorner", palettePanel).CornerRadius = UDim.new(0, 16)

local paletteStroke = Instance.new("UIStroke")
paletteStroke.Color = theme.accentDim
paletteStroke.Thickness = 1
paletteStroke.Parent = palettePanel

local paletteTitle = Instance.new("TextLabel")
paletteTitle.Size = UDim2.new(1, -20, 0, 28)
paletteTitle.Position = UDim2.fromOffset(12, 8)
paletteTitle.BackgroundTransparency = 1
paletteTitle.Text = "PALETTE"
paletteTitle.TextColor3 = theme.text
paletteTitle.Font = Enum.Font.GothamBold
paletteTitle.TextSize = 14
paletteTitle.TextXAlignment = Enum.TextXAlignment.Left
paletteTitle.Parent = palettePanel

local paletteDivider = Instance.new("Frame")
paletteDivider.Size = UDim2.new(1, -24, 0, 1)
paletteDivider.Position = UDim2.fromOffset(12, 34)
paletteDivider.BackgroundColor3 = theme.accentDim
paletteDivider.BorderSizePixel = 0
paletteDivider.Parent = palettePanel

local card = Instance.new("Frame")
card.Size = UDim2.new(1, -24, 1, -92)
card.Position = UDim2.fromOffset(12, 48)
card.BackgroundTransparency = 1
card.BorderSizePixel = 0
card.Parent = palettePanel

local cardLayout = Instance.new("UIListLayout")
cardLayout.Padding = UDim.new(0, 10)
cardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
cardLayout.Parent = card

local buttonIndex = 1
local function setSelectedIndex(newIndex)
	if buttons[selectedIndex] and buttons[selectedIndex]:FindFirstChild("UIStroke") then
		buttons[selectedIndex].UIStroke.Thickness = 0
	end
	selectedIndex = newIndex
	if buttons[selectedIndex] and buttons[selectedIndex]:FindFirstChild("UIStroke") then
		buttons[selectedIndex].UIStroke.Thickness = 2
	end
end

-- Button creator
local function createButton(parent)
	local index = buttonIndex
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(52, 40)
	btn.BackgroundColor3 = colors[index]
	btn.BorderColor3 = Color3.fromRGB(243, 243, 243)
	btn.Text = tostring(index)
	btn.TextColor3 = Color3.new(1 - colors[index].R, 1 - colors[index].G, 1 - colors[index].B)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke")
	stroke.Parent = btn
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Thickness = 0
	btn.MouseButton1Click:Connect(function()
		currentColor = colors[index]
		showNotification("Color changed to " .. index)
		rect.Visible = false
		updateHighlights()
		updateCrosshair()
	end)
	buttons[index] = btn
	buttonIndex = index + 1
	return btn
end

-- Row creator (centered)
local function createRow()
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundTransparency = 1
	row.Parent = card

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = row

	for _ = 1, 5 do
		createButton(row)
	end
end

-- Rows
createRow()
for _ = 1, 4 do
	createRow()
end

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -20, 0, 20)
subtitle.Position = UDim2.new(0, 10, 1, -30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Use Arrow + Enter"
subtitle.TextColor3 = theme.muted
subtitle.Font = Enum.Font.Code
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Center
subtitle.Parent = palettePanel

local function setFeatureIndex(newIndex)
	if featureItems[featureIndex] and featureItems[featureIndex].row:FindFirstChild("UIStroke") then
		featureItems[featureIndex].row.UIStroke.Thickness = 0
	end
	featureIndex = newIndex
	if featureItems[featureIndex] and featureItems[featureIndex].row:FindFirstChild("UIStroke") then
		featureItems[featureIndex].row.UIStroke.Thickness = 2
	end
end

local function updateFocusStyles()
	if panelFocus == "side" then
		infoStroke.Thickness = 2
		paletteStroke.Thickness = 1
	else
		infoStroke.Thickness = 1
		paletteStroke.Thickness = 2
	end
end

local function updateFeatureStatus()
	if featureItems[1] then
		featureItems[1].status.Text = (mode == "outline") and "ON" or "OFF"
	end
	if featureItems[2] then
		featureItems[2].status.Text = rect.Visible and "ON" or "OFF"
	end
	if featureItems[3] then
		featureItems[3].status.Text = (mode == "fill") and "ON" or "OFF"
	end
	if featureItems[4] then
		featureItems[4].status.Text = (mode == "wall") and "ON" or "OFF"
	end
	if featureItems[5] then
		featureItems[5].status.Text = (not disabled) and "ON" or "OFF"
	end
	if featureItems[6] then
		featureItems[6].status.Text = crosshairEnabled and "ON" or "OFF"
	end
end

local function updateStatusText()
	modeLabel.Text = "MODE: " .. string.upper(mode)
	transLabel.Text = "FILL: " .. tostring(math.floor((1 - fillTransparency) * 100)) .. "% [+/-]"
	updateFeatureStatus()
end

updateStatusText()
setFeatureIndex(1)
updateFocusStyles()

local highlightedObjects = {}  -- Cache for objects to highlight
local maxHighlights = 200  -- Limit to prevent performance issues
local highlightCount = 0

local function applyHighlightStyle(highlight)
	if mode == "fill" then
		highlight.OutlineTransparency = 1
		highlight.FillTransparency = fillTransparency
		highlight.FillColor = currentColor
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	elseif mode == "wall" then
		highlight.OutlineTransparency = 1
		highlight.FillTransparency = fillTransparency
		highlight.FillColor = currentColor
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	elseif mode == "outline" then
		highlight.OutlineTransparency = 0.8
		highlight.FillTransparency = 1
		highlight.OutlineColor = currentColor
	end
end

local function isValidObject(obj)
	return obj.Name == "Male" and obj:FindFirstChild("Humanoid")
end

local function addHighlight(obj)
	if highlightCount < maxHighlights and not highlightedObjects[obj] and isValidObject(obj) then
		highlightedObjects[obj] = true
		highlightCount = highlightCount + 1
		if mode ~= "none" then
			local newHighlight = Instance.new("Highlight")
			newHighlight.Parent = obj
			newHighlight.Adornee = obj
			newHighlight.Enabled = true
			applyHighlightStyle(newHighlight)
		end
	end
end

local function removeHighlight(obj)
	if highlightedObjects[obj] then
		highlightedObjects[obj] = nil
		highlightCount = highlightCount - 1
		local highlight = obj:FindFirstChild("Highlight")
		if highlight then
			highlight:Destroy()
		end
	end
end

local function updateHighlights()
	for obj in pairs(highlightedObjects) do
		local highlight = obj:FindFirstChild("Highlight")
		if mode ~= "none" then
			if not highlight then
				local newHighlight = Instance.new("Highlight")
				newHighlight.Parent = obj
				newHighlight.Adornee = obj
				newHighlight.Enabled = true
				applyHighlightStyle(newHighlight)
			else
				applyHighlightStyle(highlight)
			end
		else
			if highlight then
				highlight:Destroy()
			end
		end
	end
end

-- Initial scan
task.spawn(function()
	for _, desc in Workspace:GetDescendants() do
		addHighlight(desc)
	end
end)

-- Handle new descendants
Workspace.DescendantAdded:Connect(function(desc)
	addHighlight(desc)
end)

-- Handle removed descendants (optional, but for cleanup)
Workspace.DescendantRemoving:Connect(function(desc)
	removeHighlight(desc)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.KeypadOne and not gameProcessed then
		if mode == "outline" then
			mode = "none"
			showNotification("Outline Highlight Disabled")
		else
			mode = "outline"
			showNotification("Outline Highlight Enabled")
		end
		updateHighlights()
		updateCrosshair()
		updateStatusText()
	elseif (input.KeyCode == Enum.KeyCode.KeypadTwo or input.KeyCode == Enum.KeyCode.Home) and not gameProcessed then
		rect.Visible = not rect.Visible
		panelFocus = "side"
		setSelectedIndex(1)
		setFeatureIndex(1)
		updateFocusStyles()
		updateFeatureStatus()
	elseif (input.KeyCode == Enum.KeyCode.KeypadThree) and not gameProcessed then
		if mode == "fill" then
			mode = "none"
			showNotification("Fill Highlight Disabled")
		else
			mode = "fill"
			showNotification("Fill Highlight Enabled")
		end
		updateHighlights()
		updateCrosshair()
		updateStatusText()
	elseif (input.KeyCode == Enum.KeyCode.KeypadFour) and not gameProcessed then
		if mode == "wall" then
			mode = "none"
			showNotification("Wall Highlight Disabled")
		else
			mode = "wall"
			showNotification("Wall Highlight Enabled")
		end
		updateHighlights()
		updateCrosshair()
		updateStatusText()
	elseif input.KeyCode == Enum.KeyCode.Equals and not gameProcessed then
		fillTransparency = math.max(fillTransparency - 0.1, 0)
		showNotification("Fill Transparency: " .. tostring(math.floor((1 - fillTransparency) * 100)) .. "%")
		updateHighlights()
		updateStatusText()
	elseif input.KeyCode == Enum.KeyCode.Minus and not gameProcessed then
		fillTransparency = math.min(fillTransparency + 0.1, 1)
		showNotification("Fill Transparency: " .. tostring(math.floor((1 - fillTransparency) * 100)) .. "%")
		updateHighlights()
		updateStatusText()
	elseif input.KeyCode == Enum.KeyCode.KeypadSix and not gameProcessed then
		if mode == "none" then
			showNotification("Enable ESP first")
		else
			crosshairEnabled = not crosshairEnabled
			showNotification("Crosshair: " .. (crosshairEnabled and "ON" or "OFF"))
			updateCrosshair()
			updateFeatureStatus()
		end
	elseif rect.Visible and not gameProcessed then
		if input.KeyCode == Enum.KeyCode.Right and panelFocus == "side" then
			panelFocus = "palette"
			updateFocusStyles()
			return
		elseif input.KeyCode == Enum.KeyCode.Left and panelFocus == "palette" then
			panelFocus = "side"
			updateFocusStyles()
			return
		end

		if panelFocus == "side" then
			local nextFeature = featureIndex
			if input.KeyCode == Enum.KeyCode.Up then
				nextFeature = math.max(1, featureIndex - 1)
			elseif input.KeyCode == Enum.KeyCode.Down then
				nextFeature = math.min(#featureItems, featureIndex + 1)
			elseif input.KeyCode == Enum.KeyCode.Return then
				if featureIndex == 1 then
					if mode == "outline" then
						mode = "none"
						showNotification("Outline Highlight Disabled")
					else
						mode = "outline"
						showNotification("Outline Highlight Enabled")
					end
					updateHighlights()
					updateCrosshair()
					updateStatusText()
				elseif featureIndex == 2 then
					rect.Visible = not rect.Visible
					updateFeatureStatus()
				elseif featureIndex == 3 then
					if mode == "fill" then
						mode = "none"
						showNotification("Fill Highlight Disabled")
					else
						mode = "fill"
						showNotification("Fill Highlight Enabled")
					end
					updateHighlights()
					updateCrosshair()
					updateStatusText()
				elseif featureIndex == 4 then
					if mode == "wall" then
						mode = "none"
						showNotification("Wall Highlight Disabled")
					else
						mode = "wall"
						showNotification("Wall Highlight Enabled")
					end
					updateHighlights()
					updateCrosshair()
					updateStatusText()
				elseif featureIndex == 5 then
					if toggleNvg then
						toggleNvg()
					end
					updateFeatureStatus()
				elseif featureIndex == 6 then
					if mode == "none" then
						showNotification("Enable ESP first")
					else
						crosshairEnabled = not crosshairEnabled
						showNotification("Crosshair: " .. (crosshairEnabled and "ON" or "OFF"))
						updateCrosshair()
						updateFeatureStatus()
					end
				end
			end
			setFeatureIndex(nextFeature)
		else
			local column = ((selectedIndex - 1) % 5) + 1
			local nextIndex = selectedIndex
			if input.KeyCode == Enum.KeyCode.Up then
				if selectedIndex > 5 then
					nextIndex = selectedIndex - 5
				end
			elseif input.KeyCode == Enum.KeyCode.Down then
				if selectedIndex <= 20 then
					nextIndex = selectedIndex + 5
				end
			elseif input.KeyCode == Enum.KeyCode.Left then
				if column > 1 then
					nextIndex = selectedIndex - 1
				end
			elseif input.KeyCode == Enum.KeyCode.Right then
				if column < 5 then
					nextIndex = selectedIndex + 1
				end
			elseif input.KeyCode == Enum.KeyCode.Return then
				currentColor = colors[selectedIndex]
				showNotification("Color changed to " .. selectedIndex)
				rect.Visible = false
				updateHighlights()
				updateCrosshair()
				updateStatusText()
			end
			setSelectedIndex(nextIndex)
		end
	end
end)

-- UI Setup
local existingNVG = playerGui:FindFirstChild("NVGDisableUI")
if existingNVG then
	existingNVG:Destroy()
end

local nvgGui = Instance.new("ScreenGui")
nvgGui.Name = "NVGDisableUI"
nvgGui.IgnoreGuiInset = true
nvgGui.ResetOnSpawn = false
nvgGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
nvgGui.DisplayOrder = 30
nvgGui.Parent = playerGui


local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 200, 0, 50)
textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = theme.text
textLabel.TextScaled = true
textLabel.Font = Enum.Font.SourceSansBold
textLabel.TextTransparency = 1
textLabel.Parent = nvgGui


local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fadeIn = TweenService:Create(textLabel, tweenInfo, {TextTransparency = 0})
local fadeOut = TweenService:Create(textLabel, tweenInfo, {TextTransparency = 1})

local function showMessage(message)
    textLabel.Text = message
    fadeIn:Play()
    task.spawn(function()
        task.wait(2)
        fadeOut:Play()
    end)
end

local nvgInterface = player.PlayerGui:FindFirstChild("NVGInterface")

local function getColorCorrection()
	local effect = Lighting:FindFirstChild("ColorCorrection")
	if effect and effect:IsA("ColorCorrectionEffect") then
		return effect
	end
	local firstEffect = Lighting:FindFirstChildWhichIsA("ColorCorrectionEffect")
	return firstEffect
end

toggleNvg = function()
    disabled = not disabled
    if nvgInterface then
        nvgInterface.Enabled = not disabled
    end
	local colorCorrection = getColorCorrection()
	if colorCorrection then
		colorCorrection.Enabled = not disabled
	else
		showMessage("ColorCorrection not found")
	end
    showMessage("NVG and ColorCorrection: " .. (disabled and "OFF" or "ON"))
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.KeypadFive then
		toggleNvg()
		updateFeatureStatus()
    end
end)
