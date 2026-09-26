--[[ 94 Menu by ch94 ]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local Stats            = game:GetService("Stats")
local TweenService     = game:GetService("TweenService")

local lp            = Players.LocalPlayer
local camera        = workspace.CurrentCamera
local uiParent      = (gethui and gethui()) or lp:WaitForChild("PlayerGui")
local CONFIG_FILE   = "94menu_settings.json"
local PRESET_PREFIX = "94menu_preset_"

local ui       = {}
local fn       = {}
local cache    = {}
local state    = {}
local refs     = {}
local cfg      = {}

cfg.version = 4
cfg.defaults = {
	espEnabled      = false,
	espTracers      = false,
	espHealthBar    = false,
	espRange        = 1500,
	triggerEnabled  = false,
	teamCheck       = true,
	triggerJitter   = true,
	holdRightClick  = false,
	enemyHudEnabled = true,
	enemyHudRange   = 1500,
	triggerKey      = "Y",
	espKey          = "U",
	triggerDistance = 750,
	triggerDelay    = 0,
	rightClickDelay = 0,
	targetPart      = "Any",
	accentColor     = { 190, 100, 0 },
	enemyColor      = { 0, 0, 0 },
	teamColor       = { 255, 140, 0 },
	aimEnabled      = false,
	aimKey          = "E",
	aimToggleKey    = "K",
	aimFOV          = 40,
	aimSmoothing    = 0.20,
	aimStrength     = 0.25,
	aimHumanize     = 0.8,
	aimPart         = "Head",
	aimVisibleOnly  = true,
	aimTeamCheck    = true,
	aimHoldMode     = true,
	aimMaxDist      = 500,
	aimSmoothCurve  = false,
	aimLockSingle   = true,
	panicKey        = "P",
	menuKey         = "RightShift",
	visualToggleKey = "L",
	showFpsPing     = false,
	watermarkEnabled = true,
	notificationsEnabled = true,
	fovCircleState  = false,
	thirdPerson     = false,
	freeCamEnabled  = false,
	freeCamKey      = "F4",
	ragebotEnabled  = false,
	ragebotKey      = "F5",
	ragebotMaxDist  = 1500,
	ragebotMode     = "Orbit",
	orbitSpeed      = 3,
	orbitDistance   = 6,
	flyEnabled      = false,
	flyKey          = "F6",
	flySpeed        = 50,
	walkEnabled     = false,
	walkSpeed       = 16,
	noclipEnabled   = false,
	noclipKey       = "F7",
	menuPosX              = 0,
	menuPosY              = 0,
}

fn.loadConfig = function()
	local data = {}
	if readfile and isfile then
		local exists = false
		pcall(function() exists = isfile(CONFIG_FILE) end)
		if exists then
			local ok, contents = pcall(readfile, CONFIG_FILE)
			if ok and contents and contents ~= "" then
				local ok2, decoded = pcall(function() return HttpService:JSONDecode(contents) end)
				if ok2 and type(decoded) == "table" then
					data = decoded
				end
			end
		end
	end

	-- version guard: incompatible old config gets wiped
	if data.version ~= cfg.version then
		data = {}
	end

	local out = {}
	for k, v in pairs(cfg.defaults) do
		local s = data[k]
		if s == nil then
			out[k] = v
		elseif type(v) == "table" then
			out[k] = (type(s) == "table") and s or v
		else
			out[k] = s
		end
	end
	return out
end

local saved = fn.loadConfig()

state.espEnabled      = saved.espEnabled == true
state.espTracers      = saved.espTracers == true
state.espHealthBar    = saved.espHealthBar == true
state.espRange        = tonumber(saved.espRange) or 1500
state.triggerEnabled  = saved.triggerEnabled == true
state.teamCheck       = saved.teamCheck ~= false
state.triggerJitter   = saved.triggerJitter ~= false
state.holdRightClick  = saved.holdRightClick == true
state.enemyHudEnabled = saved.enemyHudEnabled ~= false
state.enemyHudRange   = tonumber(saved.enemyHudRange) or 1500
state.triggerKey      = Enum.KeyCode[saved.triggerKey] or Enum.KeyCode.Y
state.espKey          = Enum.KeyCode[saved.espKey] or Enum.KeyCode.U
state.triggerDistance = tonumber(saved.triggerDistance) or 750
state.triggerDelay    = tonumber(saved.triggerDelay) or 0
state.rightClickDelay = tonumber(saved.rightClickDelay) or 0
state.targetPart      = saved.targetPart or "Any"
state.menuOpen        = true
state.infoOpen        = false
state.unloaded        = false
state.debugEnabled    = false
state.aimEnabled      = saved.aimEnabled == true
state.aimKey          = Enum.KeyCode.E
state.aimKeyIsMouse   = false
state.aimToggleKey    = Enum.KeyCode[saved.aimToggleKey] or Enum.KeyCode.K
state.aimFOV          = tonumber(saved.aimFOV) or 40
state.aimSmoothing    = tonumber(saved.aimSmoothing) or 0.20
state.aimStrength     = tonumber(saved.aimStrength) or 0.25
state.aimHumanize     = tonumber(saved.aimHumanize) or 0.8
state.aimPart         = saved.aimPart or "Head"
state.aimVisibleOnly  = saved.aimVisibleOnly ~= false
state.aimTeamCheck    = saved.aimTeamCheck ~= false
state.aimHoldMode     = true
state.aimMaxDist      = tonumber(saved.aimMaxDist) or 500
state.aimSmoothCurve  = saved.aimSmoothCurve == true
state.aimLockSingle   = true
state.panicKey        = Enum.KeyCode[saved.panicKey] or Enum.KeyCode.P
state.menuKey         = Enum.KeyCode[saved.menuKey] or Enum.KeyCode.RightShift
state.visualToggleKey = Enum.KeyCode[saved.visualToggleKey] or Enum.KeyCode.L
state.showFpsPing     = saved.showFpsPing == true
state.watermarkEnabled = saved.watermarkEnabled ~= false
state.notificationsEnabled = saved.notificationsEnabled ~= false
state.fovCircleState  = saved.fovCircleState == true
state.thirdPerson     = saved.thirdPerson == true
state.freeCamEnabled  = saved.freeCamEnabled == true
state.freeCamKey      = Enum.KeyCode[saved.freeCamKey] or Enum.KeyCode.F4
state.ragebotEnabled  = saved.ragebotEnabled == true
state.ragebotKey      = Enum.KeyCode[saved.ragebotKey] or Enum.KeyCode.F5
state.ragebotMaxDist  = tonumber(saved.ragebotMaxDist) or 1500
state.ragebotMode     = saved.ragebotMode or "Orbit"
state.orbitSpeed      = tonumber(saved.orbitSpeed) or 3
state.orbitDistance   = tonumber(saved.orbitDistance) or 6
state.flyEnabled      = saved.flyEnabled == true
state.flyKey          = Enum.KeyCode[saved.flyKey] or Enum.KeyCode.F6
state.flySpeed        = tonumber(saved.flySpeed) or 50
state.walkEnabled     = saved.walkEnabled == true
state.walkSpeed       = tonumber(saved.walkSpeed) or 16
state.noclipEnabled   = saved.noclipEnabled == true
state.noclipKey       = Enum.KeyCode[saved.noclipKey] or Enum.KeyCode.F7
state.menuPosX           = tonumber(saved.menuPosX) or 0
state.menuPosY           = tonumber(saved.menuPosY) or 0

if saved.aimKey == "Mouse1" then
	state.aimKey = Enum.UserInputType.MouseButton1
	state.aimKeyIsMouse = true
elseif saved.aimKey == "Mouse2" then
	state.aimKey = Enum.UserInputType.MouseButton2
	state.aimKeyIsMouse = true
elseif saved.aimKey and saved.aimKey ~= "" then
	local ok, kc = pcall(function() return Enum.KeyCode[saved.aimKey] end)
	if ok and kc then
		state.aimKey = kc
		state.aimKeyIsMouse = false
	end
end

cache.accent = Color3.fromRGB(
	tonumber(saved.accentColor[1]) or 190,
	tonumber(saved.accentColor[2]) or 100,
	tonumber(saved.accentColor[3]) or 0
)
cache.enemyColor = Color3.fromRGB(
	tonumber(saved.enemyColor[1]) or 0,
	tonumber(saved.enemyColor[2]) or 0,
	tonumber(saved.enemyColor[3]) or 0
)
cache.teamColor = Color3.fromRGB(
	tonumber(saved.teamColor[1]) or 255,
	tonumber(saved.teamColor[2]) or 140,
	tonumber(saved.teamColor[3]) or 0
)
cache.connections = {}
cache.accents = {}
cache.playerFlags = {}

fn.keep = function(conn)
	table.insert(cache.connections, conn)
	return conn
end

fn.dropAll = function()
	for _, c in ipairs(cache.connections) do
		pcall(function() c:Disconnect() end)
	end
	table.clear(cache.connections)
end

fn.aimKeyName = function()
	if not state.aimKey then return "E" end
	if state.aimKeyIsMouse then
		if state.aimKey == Enum.UserInputType.MouseButton2 then return "Mouse2" end
		if state.aimKey == Enum.UserInputType.MouseButton3 then return "Mouse3" end
		return "Mouse1"
	end
	return state.aimKey.Name
end

fn.snapshot = function()
	return {
		version         = cfg.version,
		espEnabled      = state.espEnabled,
		espTracers      = state.espTracers,
		espHealthBar    = state.espHealthBar,
		espRange        = state.espRange,
		triggerEnabled  = state.triggerEnabled,
		teamCheck       = state.teamCheck,
		triggerJitter   = state.triggerJitter,
		holdRightClick  = state.holdRightClick,
		enemyHudEnabled = state.enemyHudEnabled,
		enemyHudRange   = state.enemyHudRange,
		triggerKey      = state.triggerKey.Name,
		espKey          = state.espKey.Name,
		triggerDistance = state.triggerDistance,
		triggerDelay    = state.triggerDelay,
		rightClickDelay = state.rightClickDelay,
		targetPart      = state.targetPart,
		aimEnabled      = state.aimEnabled,
		aimKey          = fn.aimKeyName(),
		aimToggleKey    = state.aimToggleKey.Name,
		aimFOV          = state.aimFOV,
		aimSmoothing    = state.aimSmoothing,
		aimStrength     = state.aimStrength,
		aimHumanize     = state.aimHumanize,
		aimPart         = state.aimPart,
		aimVisibleOnly  = state.aimVisibleOnly,
		aimTeamCheck    = state.aimTeamCheck,
		aimHoldMode     = true,
		aimMaxDist      = state.aimMaxDist,
		aimSmoothCurve  = state.aimSmoothCurve,
		aimLockSingle   = true,
		panicKey        = state.panicKey.Name,
		menuKey         = state.menuKey.Name,
		visualToggleKey = state.visualToggleKey.Name,
		showFpsPing     = state.showFpsPing,
		watermarkEnabled = state.watermarkEnabled,
		notificationsEnabled = state.notificationsEnabled,
		fovCircleState  = state.fovCircleState,
		thirdPerson     = state.thirdPerson,
		freeCamEnabled  = state.freeCamEnabled,
		freeCamKey      = state.freeCamKey.Name,
		ragebotEnabled  = state.ragebotEnabled,
		ragebotKey      = state.ragebotKey.Name,
		ragebotMaxDist  = state.ragebotMaxDist,
		ragebotMode     = state.ragebotMode,
		orbitSpeed      = state.orbitSpeed,
		orbitDistance   = state.orbitDistance,
		flyEnabled      = state.flyEnabled,
		flyKey          = state.flyKey.Name,
		flySpeed        = state.flySpeed,
		walkEnabled     = state.walkEnabled,
		walkSpeed       = state.walkSpeed,
		noclipEnabled   = state.noclipEnabled,
		noclipKey       = state.noclipKey.Name,
		menuPosX           = state.menuPosX,
		menuPosY           = state.menuPosY,
		accentColor     = {
			math.floor(cache.accent.R * 255),
			math.floor(cache.accent.G * 255),
			math.floor(cache.accent.B * 255),
		},
		enemyColor      = {
			math.floor(cache.enemyColor.R * 255),
			math.floor(cache.enemyColor.G * 255),
			math.floor(cache.enemyColor.B * 255),
		},
		teamColor       = {
			math.floor(cache.teamColor.R * 255),
			math.floor(cache.teamColor.G * 255),
			math.floor(cache.teamColor.B * 255),
		},
	}
end

fn.save = function()
	if not writefile then return end
	local ok, enc = pcall(function() return HttpService:JSONEncode(fn.snapshot()) end)
	if ok and enc then pcall(writefile, CONFIG_FILE, enc) end
end

fn.import = function(data)
	if type(data) ~= "table" then return end

	local function safeKey(name, fallback)
		if type(name) ~= "string" then return fallback end
		local ok, kc = pcall(function() return Enum.KeyCode[name] end)
		return (ok and kc) or fallback
	end
	local function safeNum(v, fallback)
		local n = tonumber(v)
		if n == nil then return fallback end
		return n
	end
	local function safeBool(v, fallback)
		if v == nil then return fallback end
		return v == true
	end
	local function safeStr(v, fallback)
		if type(v) ~= "string" then return fallback end
		return v
	end

	state.espEnabled      = safeBool(data.espEnabled, state.espEnabled)
	state.espTracers      = safeBool(data.espTracers, state.espTracers)
	state.espHealthBar    = safeBool(data.espHealthBar, state.espHealthBar)
	state.espRange        = safeNum(data.espRange, state.espRange)
	state.triggerEnabled  = safeBool(data.triggerEnabled, state.triggerEnabled)
	state.teamCheck       = (data.teamCheck == nil) and state.teamCheck or (data.teamCheck == true)
	state.triggerJitter   = (data.triggerJitter == nil) and state.triggerJitter or (data.triggerJitter == true)
	state.holdRightClick  = safeBool(data.holdRightClick, state.holdRightClick)
	state.enemyHudEnabled = (data.enemyHudEnabled == nil) and state.enemyHudEnabled or (data.enemyHudEnabled == true)
	state.enemyHudRange   = safeNum(data.enemyHudRange, state.enemyHudRange)
	state.triggerKey      = safeKey(data.triggerKey, state.triggerKey)
	state.espKey          = safeKey(data.espKey, state.espKey)
	state.triggerDistance = safeNum(data.triggerDistance, state.triggerDistance)
	state.triggerDelay    = safeNum(data.triggerDelay, state.triggerDelay)
	state.rightClickDelay = safeNum(data.rightClickDelay, state.rightClickDelay)
	state.targetPart      = safeStr(data.targetPart, state.targetPart)
	state.aimEnabled      = safeBool(data.aimEnabled, state.aimEnabled)
	state.aimToggleKey    = safeKey(data.aimToggleKey, state.aimToggleKey)
	state.aimFOV          = safeNum(data.aimFOV, state.aimFOV)
	state.aimSmoothing    = safeNum(data.aimSmoothing, state.aimSmoothing)
	state.aimStrength     = safeNum(data.aimStrength, state.aimStrength)
	state.aimHumanize     = safeNum(data.aimHumanize, state.aimHumanize)
	state.aimPart         = safeStr(data.aimPart, state.aimPart)
	state.aimVisibleOnly  = (data.aimVisibleOnly == nil) and state.aimVisibleOnly or (data.aimVisibleOnly == true)
	state.aimTeamCheck    = (data.aimTeamCheck == nil) and state.aimTeamCheck or (data.aimTeamCheck == true)
	state.aimHoldMode     = true
	state.aimMaxDist      = safeNum(data.aimMaxDist, state.aimMaxDist)
	state.aimSmoothCurve  = safeBool(data.aimSmoothCurve, state.aimSmoothCurve)
	state.aimLockSingle   = true
	state.panicKey        = safeKey(data.panicKey, state.panicKey)
	state.menuKey         = safeKey(data.menuKey, state.menuKey)
	state.visualToggleKey = safeKey(data.visualToggleKey, state.visualToggleKey)
	state.showFpsPing     = safeBool(data.showFpsPing, state.showFpsPing)
	state.watermarkEnabled = (data.watermarkEnabled == nil) and state.watermarkEnabled or (data.watermarkEnabled == true)
	state.notificationsEnabled = (data.notificationsEnabled == nil) and state.notificationsEnabled or (data.notificationsEnabled == true)
	state.fovCircleState  = safeBool(data.fovCircleState, state.fovCircleState)
	state.thirdPerson     = safeBool(data.thirdPerson, state.thirdPerson)
	state.freeCamEnabled  = safeBool(data.freeCamEnabled, state.freeCamEnabled)
	state.freeCamKey      = safeKey(data.freeCamKey, state.freeCamKey)
	state.ragebotEnabled  = safeBool(data.ragebotEnabled, state.ragebotEnabled)
	state.ragebotKey      = safeKey(data.ragebotKey, state.ragebotKey)
	state.ragebotMaxDist  = safeNum(data.ragebotMaxDist, state.ragebotMaxDist)
	state.ragebotMode     = safeStr(data.ragebotMode, state.ragebotMode)
	state.orbitSpeed      = safeNum(data.orbitSpeed, state.orbitSpeed)
	state.orbitDistance   = safeNum(data.orbitDistance, state.orbitDistance)
	state.flyEnabled      = safeBool(data.flyEnabled, state.flyEnabled)
	state.flyKey          = safeKey(data.flyKey, state.flyKey)
	state.flySpeed        = safeNum(data.flySpeed, state.flySpeed)
	state.walkEnabled     = safeBool(data.walkEnabled, state.walkEnabled)
	state.walkSpeed       = safeNum(data.walkSpeed, state.walkSpeed)
	state.noclipEnabled   = safeBool(data.noclipEnabled, state.noclipEnabled)
	state.noclipKey       = safeKey(data.noclipKey, state.noclipKey)
	state.menuPosX           = safeNum(data.menuPosX, state.menuPosX)
	state.menuPosY           = safeNum(data.menuPosY, state.menuPosY)

	if data.aimKey == "Mouse1" then
		state.aimKey = Enum.UserInputType.MouseButton1
		state.aimKeyIsMouse = true
	elseif data.aimKey == "Mouse2" then
		state.aimKey = Enum.UserInputType.MouseButton2
		state.aimKeyIsMouse = true
	elseif data.aimKey == "Mouse3" then
		state.aimKey = Enum.UserInputType.MouseButton3
		state.aimKeyIsMouse = true
	elseif type(data.aimKey) == "string" and data.aimKey ~= "" then
		local ok, kc = pcall(function() return Enum.KeyCode[data.aimKey] end)
		if ok and kc then
			state.aimKey = kc
			state.aimKeyIsMouse = false
		end
	end

	if type(data.accentColor) == "table" and #data.accentColor >= 3 then
		cache.accent = Color3.fromRGB(
			tonumber(data.accentColor[1]) or 190,
			tonumber(data.accentColor[2]) or 100,
			tonumber(data.accentColor[3]) or 0
		)
	end
	if type(data.enemyColor) == "table" and #data.enemyColor >= 3 then
		cache.enemyColor = Color3.fromRGB(
			tonumber(data.enemyColor[1]) or 0,
			tonumber(data.enemyColor[2]) or 0,
			tonumber(data.enemyColor[3]) or 0
		)
	end
	if type(data.teamColor) == "table" and #data.teamColor >= 3 then
		cache.teamColor = Color3.fromRGB(
			tonumber(data.teamColor[1]) or 255,
			tonumber(data.teamColor[2]) or 140,
			tonumber(data.teamColor[3]) or 0
		)
	end

	if fn.refreshAll then fn.refreshAll() end
	task.defer(function()
		if fn.refreshAll then fn.refreshAll() end
		if ui.fovCircle then ui.fovCircle.Visible = state.fovCircleState end
		if ui.fovStroke then ui.fovStroke.Color = cache.accent end
	end)
end

fn.teamKey = function(plr)
	if not plr then return nil end
	local ok1, teamId = pcall(function() return plr:GetAttribute("TeamID") end)
	if ok1 and teamId ~= nil and teamId ~= "" then return "rivals_" .. tostring(teamId) end
	if plr.Team and plr.Team.Name ~= "" then return "team_" .. plr.Team.Name end
	local ok2, attr = pcall(function() return plr:GetAttribute("Team") end)
	if ok2 and attr ~= nil and attr ~= "" then return "attr_" .. tostring(attr) end
	local ls = plr:FindFirstChild("leaderstats")
	if ls then
		for _, child in ipairs(ls:GetChildren()) do
			local n = child.Name:lower()
			if n == "team" or n == "side" or n == "faction" then
				local ok3, v = pcall(function() return tostring(child.Value) end)
				if ok3 and v ~= "" and v ~= "nil" then return "ls_" .. v end
			end
		end
	end
	local cls = plr:FindFirstChild("CustomLeaderstats")
	if cls then
		for _, child in ipairs(cls:GetChildren()) do
			local n = child.Name:lower()
			if n == "team" or n == "teamid" or n == "side" or n == "faction" then
				local ok4, v = pcall(function() return tostring(child.Value) end)
				if ok4 and v ~= "" and v ~= "nil" then return "cls_" .. v end
			end
		end
	end
	return nil
end

fn.sameTeam = function(a, b)
	if not a or not b then return false end
	if a == b then return true end
	local ka, kb = fn.teamKey(a), fn.teamKey(b)
	if not ka or not kb then return false end
	return ka == kb
end

-- ============================================================
-- GUI
-- ============================================================
local SURFACE      = Color3.fromRGB(20, 20, 20)
local SURFACE_TOP  = Color3.fromRGB(255, 255, 255)
local SURFACE_BOT  = Color3.fromRGB(140, 140, 140)
local TRANSPARENCY = 0.35
local MENU_W       = 420
local MENU_H       = 300
local TITLE_H      = 26
local TAB_H        = 24
local EDGE         = 16
local INFO_W       = 195
local INFO_GAP     = 10

ui.gui = Instance.new("ScreenGui")
ui.gui.Name = "94MenuGui"
ui.gui.ResetOnSpawn = false
ui.gui.IgnoreGuiInset = true
ui.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ui.gui.Parent = uiParent

fn.trackAccent        = function(o) table.insert(cache.accents, o) end
fn.trackToggleAccent  = function(b, g, off) table.insert(cache.accents, {kind="toggle", btn=b, get=g, off=off or Color3.fromRGB(60,60,60)}) end
fn.trackPlayerAccent  = function(b, f, k) table.insert(cache.accents, {kind="playerToggle", btn=b, flags=f, key=k, off=Color3.fromRGB(30,30,30)}) end
fn.trackTabAccent     = function(b, a) table.insert(cache.accents, {kind="tab", btn=b, active=a, off=Color3.fromRGB(50,50,50)}) end

fn.applyAccent = function()
	for _, slot in ipairs(cache.accents) do
		if type(slot) == "table" then
			if slot.kind == "toggle" then
				slot.btn.BackgroundColor3 = slot.get() and cache.accent or slot.off
			elseif slot.kind == "playerToggle" then
				slot.btn.BackgroundColor3 = slot.flags[slot.key] and cache.accent or slot.off
			elseif slot.kind == "tab" then
				slot.btn.BackgroundColor3 = slot.active() and cache.accent or slot.off
			end
		else
			pcall(function()
				if slot:IsA("TextButton") or slot:IsA("Frame") then
					slot.BackgroundColor3 = cache.accent
				elseif slot:IsA("TextLabel") then
					slot.TextColor3 = cache.accent
				elseif slot:IsA("UIStroke") then
					slot.Color = cache.accent
				elseif slot:IsA("ScrollingFrame") then
					slot.ScrollBarImageColor3 = cache.accent
				end
			end)
		end
	end
end

-- Free the mouse when the menu is open, lock it back when closed
fn.setMenuOpen = function(open)
	state.menuOpen = open
	ui.panel.Visible = open
	ui.shadow.Visible = open
	if open then
		pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = false -- we draw our own
		end)
	else
		-- intentionally do nothing: leave the cursor free and visible
		pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
	end
end

fn.keep(UserInputService:GetPropertyChangedSignal("MouseIconEnabled"):Connect(function()
	if state.unloaded then return end
	if state.menuOpen and UserInputService.MouseIconEnabled then
		pcall(function() UserInputService.MouseIconEnabled = false end)
	end
end))

ui.shadow = Instance.new("Frame")
ui.shadow.Size = UDim2.new(0, MENU_W, 0, MENU_H)
ui.shadow.Position = UDim2.new(1, -(MENU_W + EDGE) + 4 + state.menuPosX, 0.5, -MENU_H/2 + 4 + state.menuPosY)
ui.shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ui.shadow.BackgroundTransparency = 0.75
ui.shadow.BorderSizePixel = 0
ui.shadow.ZIndex = -1
ui.shadow.Parent = ui.gui

-- ============================================================
-- CUSTOM CURSOR (shown while the menu is open)
-- ============================================================
ui.cursor = Instance.new("Frame")
ui.cursor.Size = UDim2.new(0, 18, 0, 18)
ui.cursor.BackgroundTransparency = 1
ui.cursor.BorderSizePixel = 0
ui.cursor.ZIndex = 900
ui.cursor.Visible = false
ui.cursor.Parent = ui.gui

local curDot = Instance.new("Frame")
curDot.Size = UDim2.new(0, 6, 0, 6)
curDot.Position = UDim2.new(0.5, -3, 0.5, -3)
curDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
curDot.BorderSizePixel = 0
curDot.ZIndex = 901
curDot.Parent = ui.cursor
Instance.new("UICorner", curDot).CornerRadius = UDim.new(1, 0)

local curRing = Instance.new("Frame")
curRing.Size = UDim2.new(1, 0, 1, 0)
curRing.BackgroundTransparency = 1
curRing.ZIndex = 901
curRing.Parent = ui.cursor
local curRingStroke = Instance.new("UIStroke", curRing)
curRingStroke.Color = Color3.fromRGB(255, 255, 255)
curRingStroke.Thickness = 1.5
curRingStroke.Transparency = 0.15
Instance.new("UICorner", curRing).CornerRadius = UDim.new(1, 0)

fn.keep(RunService.RenderStepped:Connect(function()
	if state.unloaded then return end
	if not state.menuOpen then
		if ui.cursor.Visible then ui.cursor.Visible = false end
		return
	end
	local m = UserInputService:GetMouseLocation()
	ui.cursor.Position = UDim2.new(0, m.X - 9, 0, m.Y - 9)
	ui.cursor.Visible = true
end))

ui.panel = Instance.new("Frame")
ui.panel.Size = UDim2.new(0, MENU_W, 0, MENU_H)
ui.panel.Position = UDim2.new(1, -(MENU_W + EDGE) + state.menuPosX, 0.5, -MENU_H/2 + state.menuPosY)
ui.panel.BackgroundColor3 = SURFACE
ui.panel.BackgroundTransparency = TRANSPARENCY
ui.panel.BorderSizePixel = 0
ui.panel.ZIndex = 1
ui.panel.Parent = ui.gui

ui.panelGrad = Instance.new("UIGradient")
ui.panelGrad.Color = ColorSequence.new(SURFACE_TOP, SURFACE_BOT)
ui.panelGrad.Rotation = 90
ui.panelGrad.Parent = ui.panel

ui.titleBar = Instance.new("Frame")
ui.titleBar.Size = UDim2.new(1, 0, 0, TITLE_H)
ui.titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ui.titleBar.BackgroundTransparency = 0.15
ui.titleBar.BorderSizePixel = 0
ui.titleBar.Parent = ui.panel

ui.titleLabel = Instance.new("TextLabel")
ui.titleLabel.Size = UDim2.new(1, -60, 1, 0)
ui.titleLabel.Position = UDim2.new(0, 8, 0, 0)
ui.titleLabel.BackgroundTransparency = 1
ui.titleLabel.Text = "Gator hub"
ui.titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.titleLabel.TextSize = 14
ui.titleLabel.Font = Enum.Font.GothamBold
ui.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
ui.titleLabel.Parent = ui.titleBar

ui.minBtn = Instance.new("TextButton")
ui.minBtn.Size = UDim2.new(0, 20, 0, 20)
ui.minBtn.Position = UDim2.new(1, -24, 0, 3)
ui.minBtn.BackgroundColor3 = cache.accent
ui.minBtn.BorderSizePixel = 0
ui.minBtn.Text = "-"
ui.minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.minBtn.TextSize = 16
ui.minBtn.Font = Enum.Font.GothamBold
ui.minBtn.Parent = ui.titleBar
fn.trackAccent(ui.minBtn)

ui.tabBar = Instance.new("ScrollingFrame")
ui.tabBar.Size = UDim2.new(1, -16, 0, TAB_H)
ui.tabBar.Position = UDim2.new(0, 8, 0, TITLE_H + 6)
ui.tabBar.BackgroundTransparency = 1
ui.tabBar.BorderSizePixel = 0
ui.tabBar.ScrollBarThickness = 3
ui.tabBar.ScrollBarImageColor3 = cache.accent
ui.tabBar.ScrollingDirection = Enum.ScrollingDirection.X
ui.tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
ui.tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
ui.tabBar.ScrollBarImageTransparency = 0.3
ui.tabBar.Parent = ui.panel

ui.tabLayout = Instance.new("UIListLayout")
ui.tabLayout.FillDirection = Enum.FillDirection.Horizontal
ui.tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
ui.tabLayout.Padding = UDim.new(0, 4)
ui.tabLayout.Parent = ui.tabBar

ui.content = Instance.new("Frame")
ui.content.Size = UDim2.new(1, -16, 1, -(TITLE_H + TAB_H + 16))
ui.content.Position = UDim2.new(0, 8, 0, TITLE_H + TAB_H + 12)
ui.content.BackgroundTransparency = 1
ui.content.ClipsDescendants = true
ui.content.Parent = ui.panel

local TAB_NAMES = {"triggerbot", "aimbot", "visuals", "rage", "keybinds", "settings"}
cache.tabs = {}
state.activeTab = "triggerbot"

local tabWidth = 78
local TAB_H_INNER = 22

fn.switchTab = function(name)
	state.activeTab = name
	for tabName, page in pairs(cache.tabs) do
		page.Visible = (tabName == name)
	end
	fn.applyAccent()
end

for _, name in ipairs(TAB_NAMES) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, tabWidth, 0, TAB_H_INNER)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamBold
	btn.Parent = ui.tabBar

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = cache.accent
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = ui.content

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout.Parent = page

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = page

	cache.tabs[name] = page

	fn.trackTabAccent(btn, function() return state.activeTab == name end)
	fn.keep(btn.MouseButton1Click:Connect(function() fn.switchTab(name) end))
end

-- ============================================================
-- WIDGETS
-- ============================================================
local ROW_H   = 24
local BTN_W   = 60
local BTN_H   = 20
local FONT    = Enum.Font.Gotham
local FONT_B  = Enum.Font.GothamBold
local SMALL   = 11
local NORMAL  = 12

refs.toggles = {}
refs.sliders = {}
refs.cycles  = {}
refs.binds   = {}
refs.rows    = {}

fn.row = function(parent, name, height)
	local r = Instance.new("Frame")
	r.Size = UDim2.new(1, 0, 0, height or ROW_H)
	r.BackgroundTransparency = 1
	r.Parent = parent
	r.Name = "row_" .. name

	local hover = Instance.new("Frame")
	hover.Size = UDim2.new(1, 0, 1, 0)
	hover.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hover.BackgroundTransparency = 1
	hover.BorderSizePixel = 0
	hover.ZIndex = -1
	hover.Parent = r

	r.MouseEnter:Connect(function() hover.BackgroundTransparency = 0.93 end)
	r.MouseLeave:Connect(function() hover.BackgroundTransparency = 1 end)

	table.insert(refs.rows, { frame = r, name = name:lower() })
	return r
end

fn.toggleRow = function(parent, text, read, onChange)
	local row = fn.row(parent, text, ROW_H)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = NORMAL
	label.Font = FONT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
	btn.Position = UDim2.new(1, -BTN_W, 0.5, -BTN_H/2)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = NORMAL
	btn.Font = FONT_B
	btn.Parent = row

	local function paint()
		local on = read()
		btn.Text = on and "ON" or "OFF"
		btn.BackgroundColor3 = on and cache.accent or Color3.fromRGB(60, 60, 60)
	end
	paint()

	fn.trackToggleAccent(btn, read)
	table.insert(refs.toggles, paint)

	fn.keep(btn.MouseButton1Click:Connect(function()
		onChange(not read())
		paint()
		fn.save()
	end))

	return row, btn
end

fn.sliderRow = function(parent, text, minV, maxV, read, isInt, suffix, onChange)
	local holder = fn.row(parent, text, 34)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 14)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = SMALL
	label.Font = FONT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 8)
	bar.Position = UDim2.new(0, 0, 0, 20)
	bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	bar.BorderSizePixel = 0
	bar.Parent = holder

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = cache.accent
	fill.BorderSizePixel = 0
	fill.Parent = bar

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = bar

	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

	fn.trackAccent(fill)

	local function paint()
		local v = read()
		local t = math.clamp((v - minV) / (maxV - minV), 0, 1)
		fill.Size = UDim2.new(t, 0, 1, 0)
		knob.Position = UDim2.new(t, 0, 0.5, 0)
		label.Text = text .. ": " .. tostring(v) .. (suffix or "")
	end
	paint()

	table.insert(refs.sliders, paint)

	local dragging = false
	local function move(x)
		local ratio = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local val = minV + (maxV - minV) * ratio
		if isInt then val = math.floor(val + 0.5) end
		onChange(val)
		paint()
	end

	fn.keep(bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			move(input.Position.X)
		end
	end))

	fn.keep(UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			move(input.Position.X)
		end
	end))

	fn.keep(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			fn.save()
		end
	end))

	return holder
end

fn.cycleRow = function(parent, text, options, read, onChange)
	local row = fn.row(parent, text, ROW_H)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = NORMAL
	label.Font = FONT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
	btn.Position = UDim2.new(1, -BTN_W, 0.5, -BTN_H/2)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = NORMAL
	btn.Font = FONT_B
	btn.Parent = row

	local function paint()
		btn.Text = tostring(read())
	end
	paint()

	table.insert(refs.cycles, paint)

	fn.keep(btn.MouseButton1Click:Connect(function()
		local cur = read()
		local i = 1
		for idx, opt in ipairs(options) do
			if opt == cur then i = idx break end
		end
		i = i + 1
		if i > #options then i = 1 end
		onChange(options[i])
		paint()
		fn.save()
	end))

	return row, btn
end

fn.bindRow = function(parent, text, labelFn, onChange)
	local row = fn.row(parent, text, ROW_H)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = NORMAL
	label.Font = FONT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
	btn.Position = UDim2.new(1, -BTN_W, 0.5, -BTN_H/2)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = NORMAL
	btn.Font = FONT_B
	btn.Parent = row

	local function paint()
		btn.Text = labelFn()
	end
	paint()

	table.insert(refs.binds, paint)

	local listening = false
	local capture

	local function stop()
		listening = false
		cache.binding = false
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		if capture then capture:Disconnect() capture = nil end
	end

	fn.keep(btn.MouseButton1Click:Connect(function()
		if listening then stop() return end
		listening = true
		cache.binding = true
		btn.Text = "..."
		btn.BackgroundColor3 = cache.accent

		capture = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				onChange("key", input.KeyCode)
				paint()
				stop()
				fn.save()
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				onChange("mouse", "Mouse1")
				paint()
				stop()
				fn.save()
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				onChange("mouse", "Mouse2")
				paint()
				stop()
				fn.save()
			elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
				onChange("mouse", "Mouse3")
				paint()
				stop()
				fn.save()
			end
		end)
	end))

	return row, btn
end

fn.sectionTitle = function(parent, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 16)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = cache.accent
	l.TextSize = 12
	l.Font = FONT_B
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	fn.trackAccent(l)
	return l
end

-- ============================================================
-- TABS CONTENT
-- ============================================================
local trigPage = cache.tabs["triggerbot"]
fn.toggleRow(trigPage, "triggerbot", function() return state.triggerEnabled end, function(v) state.triggerEnabled = v end)
fn.toggleRow(trigPage, "trigger jitter", function() return state.triggerJitter end, function(v) state.triggerJitter = v end)
fn.toggleRow(trigPage, "hold right click", function() return state.holdRightClick end, function(v) state.holdRightClick = v end)
fn.cycleRow(trigPage, "target part", {"Any", "Head", "Torso"}, function() return state.targetPart end, function(v) state.targetPart = v end)
fn.sliderRow(trigPage, "trigger distance", 100, 2000, function() return state.triggerDistance end, true, nil, function(v) state.triggerDistance = v end)
fn.sliderRow(trigPage, "trigger delay", 0, 500, function() return state.triggerDelay end, true, " ms", function(v) state.triggerDelay = v end)
fn.sliderRow(trigPage, "rightclick delay", 0, 500, function() return state.rightClickDelay end, true, " ms", function(v) state.rightClickDelay = v end)

local aimPage = cache.tabs["aimbot"]
fn.toggleRow(aimPage, "aimbot", function() return state.aimEnabled end, function(v) state.aimEnabled = v end)
fn.toggleRow(aimPage, "team check", function() return state.aimTeamCheck end, function(v) state.aimTeamCheck = v end)
fn.toggleRow(aimPage, "wall check", function() return state.aimVisibleOnly end, function(v) state.aimVisibleOnly = v end)
fn.cycleRow(aimPage, "aim part", {"Head", "Torso", "Closest"}, function() return state.aimPart end, function(v) state.aimPart = v end)
fn.toggleRow(aimPage, "smooth curve", function() return state.aimSmoothCurve end, function(v) state.aimSmoothCurve = v end)

cache.fovCircleOn = state.fovCircleState

ui.fovCircle = Instance.new("Frame")
ui.fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
ui.fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
ui.fovCircle.BackgroundTransparency = 1
ui.fovCircle.BorderSizePixel = 0
ui.fovCircle.Visible = state.fovCircleState
ui.fovCircle.ZIndex = 60
ui.fovCircle.Parent = ui.gui

local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(1, 0)
fc.Parent = ui.fovCircle

ui.fovStroke = Instance.new("UIStroke")
ui.fovStroke.Thickness = 1.5
ui.fovStroke.Color = cache.accent
ui.fovStroke.Transparency = 0.4
ui.fovStroke.Parent = ui.fovCircle

fn.toggleRow(aimPage, "show fov circle", function() return state.fovCircleState end, function(v)
	state.fovCircleState = v
	cache.fovCircleOn = v
	ui.fovCircle.Visible = v
end)

fn.sliderRow(aimPage, "fov", 5, 400, function() return state.aimFOV end, true, nil, function(v) state.aimFOV = v end)
fn.sliderRow(aimPage, "smoothing %", 1, 100, function() return math.floor(state.aimSmoothing * 100) end, true, nil, function(v) state.aimSmoothing = v / 100 end)
fn.sliderRow(aimPage, "strength %", 5, 100, function() return math.floor(state.aimStrength * 100) end, true, nil, function(v) state.aimStrength = v / 100 end)
fn.sliderRow(aimPage, "humanize x10", 0, 50, function() return math.floor(state.aimHumanize * 10) end, true, nil, function(v) state.aimHumanize = v / 10 end)
fn.sliderRow(aimPage, "max distance", 50, 2000, function() return state.aimMaxDist end, true, nil, function(v) state.aimMaxDist = v end)

-- ============================================================
-- VISUALS TAB
-- ============================================================
local visPage = cache.tabs["visuals"]
fn.toggleRow(visPage, "esp", function() return state.espEnabled end, function(v)
	state.espEnabled = v
	if fn.refreshESP then fn.refreshESP() end
	if fn.refreshTracers then fn.refreshTracers() end
	if fn.refreshHealthBars then fn.refreshHealthBars() end
end)
fn.toggleRow(visPage, "esp tracers", function() return state.espTracers end, function(v)
	state.espTracers = v
	if fn.refreshTracers then fn.refreshTracers() end
end)
fn.toggleRow(visPage, "esp health bar", function() return state.espHealthBar end, function(v)
	state.espHealthBar = v
	if fn.refreshHealthBars then fn.refreshHealthBars() end
end)
fn.toggleRow(visPage, "team check", function() return state.teamCheck end, function(v)
	state.teamCheck = v
	if fn.refreshESPColors then fn.refreshESPColors() end
end)
fn.toggleRow(visPage, "enemy hud", function() return state.enemyHudEnabled end, function(v) state.enemyHudEnabled = v end)
fn.sliderRow(visPage, "enemy hud range", 100, 1500, function() return state.enemyHudRange end, true, " studs", function(v) state.enemyHudRange = v end)
fn.sliderRow(visPage, "esp range", 100, 1500, function() return state.espRange end, true, " studs", function(v) state.espRange = v end)

cache.colourRowEsp = Instance.new("Frame")
cache.colourRowEsp.Size = UDim2.new(1, 0, 0, 22)
cache.colourRowEsp.BackgroundTransparency = 1
cache.colourRowEsp.Parent = visPage

cache.colourRowEspLabel = Instance.new("TextLabel")
cache.colourRowEspLabel.Size = UDim2.new(0, 80, 1, 0)
cache.colourRowEspLabel.BackgroundTransparency = 1
cache.colourRowEspLabel.Text = "enemy"
cache.colourRowEspLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
cache.colourRowEspLabel.TextSize = 11
cache.colourRowEspLabel.Font = FONT
cache.colourRowEspLabel.TextXAlignment = Enum.TextXAlignment.Left
cache.colourRowEspLabel.Parent = cache.colourRowEsp

cache.colourRowEspList = Instance.new("Frame")
cache.colourRowEspList.Size = UDim2.new(1, -85, 1, 0)
cache.colourRowEspList.Position = UDim2.new(0, 85, 0, 0)
cache.colourRowEspList.BackgroundTransparency = 1
cache.colourRowEspList.Parent = cache.colourRowEsp

cache.colourRowEspLayout = Instance.new("UIListLayout")
cache.colourRowEspLayout.FillDirection = Enum.FillDirection.Horizontal
cache.colourRowEspLayout.SortOrder = Enum.SortOrder.LayoutOrder
cache.colourRowEspLayout.Padding = UDim.new(0, 4)
cache.colourRowEspLayout.Parent = cache.colourRowEspList

cache.colourRowTeam = Instance.new("Frame")
cache.colourRowTeam.Size = UDim2.new(1, 0, 0, 22)
cache.colourRowTeam.BackgroundTransparency = 1
cache.colourRowTeam.Parent = visPage

cache.colourRowTeamLabel = Instance.new("TextLabel")
cache.colourRowTeamLabel.Size = UDim2.new(0, 80, 1, 0)
cache.colourRowTeamLabel.BackgroundTransparency = 1
cache.colourRowTeamLabel.Text = "teammate"
cache.colourRowTeamLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
cache.colourRowTeamLabel.TextSize = 11
cache.colourRowTeamLabel.Font = FONT
cache.colourRowTeamLabel.TextXAlignment = Enum.TextXAlignment.Left
cache.colourRowTeamLabel.Parent = cache.colourRowTeam

cache.colourRowTeamList = Instance.new("Frame")
cache.colourRowTeamList.Size = UDim2.new(1, -85, 1, 0)
cache.colourRowTeamList.Position = UDim2.new(0, 85, 0, 0)
cache.colourRowTeamList.BackgroundTransparency = 1
cache.colourRowTeamList.Parent = cache.colourRowTeam

cache.colourRowTeamLayout = Instance.new("UIListLayout")
cache.colourRowTeamLayout.FillDirection = Enum.FillDirection.Horizontal
cache.colourRowTeamLayout.SortOrder = Enum.SortOrder.LayoutOrder
cache.colourRowTeamLayout.Padding = UDim.new(0, 4)
cache.colourRowTeamLayout.Parent = cache.colourRowTeamList

local ESP_SWATCHES = {
	Color3.fromRGB(0, 0, 0),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 60, 60),
	Color3.fromRGB(255, 140, 0),
	Color3.fromRGB(255, 220, 40),
	Color3.fromRGB(60, 220, 60),
	Color3.fromRGB(60, 180, 255),
	Color3.fromRGB(180, 80, 255),
}

for _, colour in ipairs(ESP_SWATCHES) do
	local sw = Instance.new("TextButton")
	sw.Size = UDim2.new(0, 18, 0, 18)
	sw.BackgroundColor3 = colour
	sw.BorderSizePixel = 0
	sw.Text = ""
	sw.AutoButtonColor = true
	sw.Parent = cache.colourRowEspList
	sw.MouseButton1Click:Connect(function()
		cache.enemyColor = colour
		fn.refreshESPColors()
		fn.save()
	end)
end

for _, colour in ipairs(ESP_SWATCHES) do
	local sw = Instance.new("TextButton")
	sw.Size = UDim2.new(0, 18, 0, 18)
	sw.BackgroundColor3 = colour
	sw.BorderSizePixel = 0
	sw.Text = ""
	sw.AutoButtonColor = true
	sw.Parent = cache.colourRowTeamList
	sw.MouseButton1Click:Connect(function()
		cache.teamColor = colour
		fn.refreshESPColors()
		fn.save()
	end)
end

-- RAGE TAB
local ragePage = cache.tabs["rage"]
fn.toggleRow(ragePage, "ragebot", function() return state.ragebotEnabled end, function(v)
	state.ragebotEnabled = v
	if not v then fn.resetRageCamera() end
end)
fn.sliderRow(ragePage, "ragebot max distance", 100, 1500, function() return state.ragebotMaxDist end, true, " studs", function(v) state.ragebotMaxDist = v end)
fn.cycleRow(ragePage, "rage mode", {"Orbit", "Behind", "Above"}, function() return state.ragebotMode end, function(v)
	state.ragebotMode = v
	cache.orbitAngle = 0
end)
fn.sliderRow(ragePage, "orbit speed", 1, 20, function() return state.orbitSpeed end, true, " x", function(v) state.orbitSpeed = v end)
fn.sliderRow(ragePage, "orbit distance", 1, 20, function() return state.orbitDistance end, true, " studs", function(v) state.orbitDistance = v end)

fn.toggleRow(ragePage, "fly", function() return state.flyEnabled end, function(v)
	state.flyEnabled = v
	if not v then
		local char = lp.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.Velocity = Vector3.new(0, 0, 0)
		end
	end
end)
fn.sliderRow(ragePage, "fly speed", 10, 300, function() return state.flySpeed end, true, nil, function(v) state.flySpeed = v end)
fn.toggleRow(ragePage, "walkspeed", function() return state.walkEnabled end, function(v)
	state.walkEnabled = v
	fn.applyWalkSpeed()
end)
fn.sliderRow(ragePage, "walk speed", 8, 200, function() return state.walkSpeed end, true, nil, function(v)
	state.walkSpeed = v
	fn.applyWalkSpeed()
end)
fn.toggleRow(ragePage, "noclip", function() return state.noclipEnabled end, function(v)
	state.noclipEnabled = v
	if v then fn.applyNoclip() else fn.disableNoclip() end
end)

-- KEYBINDS TAB
local keyPage = cache.tabs["keybinds"]

fn.sectionTitle(keyPage, "combat")
fn.bindRow(keyPage, "aimbot toggle key", function() return state.aimToggleKey.Name end, function(k, key)
	if k == "key" then state.aimToggleKey = key end
end)
fn.bindRow(keyPage, "aim key (hold)", function()
	if state.aimKeyIsMouse then
		if state.aimKey == Enum.UserInputType.MouseButton2 then return "Mouse2" end
		if state.aimKey == Enum.UserInputType.MouseButton3 then return "Mouse3" end
		return "Mouse1"
	end
	return state.aimKey.Name
end, function(k, key)
	if k == "key" then
		state.aimKey = key
		state.aimKeyIsMouse = false
	elseif k == "mouse" then
		if key == "Mouse1" then state.aimKey = Enum.UserInputType.MouseButton1
		elseif key == "Mouse2" then state.aimKey = Enum.UserInputType.MouseButton2
		elseif key == "Mouse3" then state.aimKey = Enum.UserInputType.MouseButton3
		end
		state.aimKeyIsMouse = true
	end
end)

fn.bindRow(keyPage, "triggerbot key", function() return state.triggerKey.Name end, function(k, key)
	if k == "key" then state.triggerKey = key end
end)
fn.bindRow(keyPage, "ragebot key", function() return state.ragebotKey.Name end, function(k, key)
	if k == "key" then state.ragebotKey = key end
end)

fn.sectionTitle(keyPage, "visuals")
fn.bindRow(keyPage, "esp key", function() return state.espKey.Name end, function(k, key)
	if k == "key" then state.espKey = key end
end)
fn.bindRow(keyPage, "visual toggle key", function() return state.visualToggleKey.Name end, function(k, key)
	if k == "key" then state.visualToggleKey = key end
end)
fn.bindRow(keyPage, "free cam key", function() return state.freeCamKey.Name end, function(k, key)
	if k == "key" then state.freeCamKey = key end
end)

fn.sectionTitle(keyPage, "others")
fn.bindRow(keyPage, "menu key", function() return state.menuKey.Name end, function(k, key)
	if k == "key" then state.menuKey = key end
end)
fn.bindRow(keyPage, "panic key", function() return state.panicKey.Name end, function(k, key)
	if k == "key" then state.panicKey = key end
end)
fn.bindRow(keyPage, "fly key", function() return state.flyKey.Name end, function(k, key)
	if k == "key" then state.flyKey = key end
end)
fn.bindRow(keyPage, "noclip key", function() return state.noclipKey.Name end, function(k, key)
	if k == "key" then state.noclipKey = key end
end)

-- SETTINGS TAB
local setPage = cache.tabs["settings"]

-- Search button placeholder row (positioned just above info, and search button appended below presets/colour)
fn.sectionTitle(setPage, "search")

ui.searchBtn = Instance.new("TextButton")
ui.searchBtn.Size = UDim2.new(1, 0, 0, 24)
ui.searchBtn.BackgroundColor3 = cache.accent
ui.searchBtn.BorderSizePixel = 0
ui.searchBtn.Text = "search"
ui.searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.searchBtn.TextSize = NORMAL
ui.searchBtn.Font = FONT_B
ui.searchBtn.Parent = setPage
fn.trackAccent(ui.searchBtn)

cache.presetHeader = Instance.new("TextLabel")
cache.presetHeader.Size = UDim2.new(1, 0, 0, 16)
cache.presetHeader.BackgroundTransparency = 1
cache.presetHeader.Text = "presets"
cache.presetHeader.TextColor3 = cache.accent
cache.presetHeader.TextSize = 12
cache.presetHeader.Font = FONT_B
cache.presetHeader.TextXAlignment = Enum.TextXAlignment.Left
cache.presetHeader.Parent = setPage
fn.trackAccent(cache.presetHeader)

cache.presetRow = Instance.new("Frame")
cache.presetRow.Size = UDim2.new(1, 0, 0, 54)
cache.presetRow.BackgroundTransparency = 1
cache.presetRow.Parent = setPage

cache.leftCol = Instance.new("Frame")
cache.leftCol.Size = UDim2.new(1/3, -3, 1, 0)
cache.leftCol.BackgroundTransparency = 1
cache.leftCol.Parent = cache.presetRow

ui.nameBox = Instance.new("TextBox")
ui.nameBox.Size = UDim2.new(1, 0, 0, 24)
ui.nameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ui.nameBox.BackgroundTransparency = 0.2
ui.nameBox.BorderSizePixel = 0
ui.nameBox.Text = ""
ui.nameBox.PlaceholderText = "preset name..."
ui.nameBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
ui.nameBox.TextColor3 = Color3.fromRGB(230, 230, 230)
ui.nameBox.TextSize = 12
ui.nameBox.Font = FONT
ui.nameBox.ClearTextOnFocus = false
ui.nameBox.Parent = cache.leftCol

ui.savePresetBtn = Instance.new("TextButton")
ui.savePresetBtn.Size = UDim2.new(1, 0, 0, 24)
ui.savePresetBtn.Position = UDim2.new(0, 0, 0, 28)
ui.savePresetBtn.BackgroundColor3 = cache.accent
ui.savePresetBtn.BorderSizePixel = 0
ui.savePresetBtn.Text = "save"
ui.savePresetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.savePresetBtn.TextSize = 12
ui.savePresetBtn.Font = FONT_B
ui.savePresetBtn.Parent = cache.leftCol
fn.trackAccent(ui.savePresetBtn)

cache.rightCol = Instance.new("Frame")
cache.rightCol.Size = UDim2.new(2/3, -3, 1, 0)
cache.rightCol.Position = UDim2.new(1/3, 3, 0, 0)
cache.rightCol.BackgroundTransparency = 1
cache.rightCol.Parent = cache.presetRow

ui.displayBox = Instance.new("TextBox")
ui.displayBox.Size = UDim2.new(1, 0, 0, 24)
ui.displayBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ui.displayBox.BackgroundTransparency = 0.2
ui.displayBox.BorderSizePixel = 0
ui.displayBox.Text = ""
ui.displayBox.PlaceholderText = "no preset selected"
ui.displayBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
ui.displayBox.TextColor3 = Color3.fromRGB(230, 230, 230)
ui.displayBox.TextSize = 12
ui.displayBox.Font = FONT
ui.displayBox.TextEditable = false
ui.displayBox.ClearTextOnFocus = false
ui.displayBox.TextXAlignment = Enum.TextXAlignment.Left
ui.displayBox.Parent = cache.rightCol

ui.arrowBtn = Instance.new("TextButton")
ui.arrowBtn.Size = UDim2.new(0, 24, 0, 24)
ui.arrowBtn.Position = UDim2.new(1, -24, 0, 0)
ui.arrowBtn.BackgroundColor3 = cache.accent
ui.arrowBtn.BorderSizePixel = 0
ui.arrowBtn.Text = "v"
ui.arrowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.arrowBtn.TextSize = 10
ui.arrowBtn.Font = FONT_B
ui.arrowBtn.ZIndex = 2
ui.arrowBtn.Parent = cache.rightCol
fn.trackAccent(ui.arrowBtn)

ui.deletePresetBtn = Instance.new("TextButton")
ui.deletePresetBtn.Size = UDim2.new(1/3, -2, 0, 24)
ui.deletePresetBtn.Position = UDim2.new(0, 0, 0, 28)
ui.deletePresetBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
ui.deletePresetBtn.BorderSizePixel = 0
ui.deletePresetBtn.Text = "delete"
ui.deletePresetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.deletePresetBtn.TextSize = 12
ui.deletePresetBtn.Font = FONT_B
ui.deletePresetBtn.Parent = cache.rightCol

ui.replacePresetBtn = Instance.new("TextButton")
ui.replacePresetBtn.Size = UDim2.new(1/3, -2, 0, 24)
ui.replacePresetBtn.Position = UDim2.new(1/3, 0, 0, 28)
ui.replacePresetBtn.BackgroundColor3 = Color3.fromRGB(190, 140, 30)
ui.replacePresetBtn.BorderSizePixel = 0
ui.replacePresetBtn.Text = "replace"
ui.replacePresetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.replacePresetBtn.TextSize = 11
ui.replacePresetBtn.Font = FONT_B
ui.replacePresetBtn.Parent = cache.rightCol

ui.loadPresetBtn = Instance.new("TextButton")
ui.loadPresetBtn.Size = UDim2.new(1/3, -2, 0, 24)
ui.loadPresetBtn.Position = UDim2.new(2/3, 2, 0, 28)
ui.loadPresetBtn.BackgroundColor3 = cache.accent
ui.loadPresetBtn.BorderSizePixel = 0
ui.loadPresetBtn.Text = "load"
ui.loadPresetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.loadPresetBtn.TextSize = 12
ui.loadPresetBtn.Font = FONT_B
ui.loadPresetBtn.Parent = cache.rightCol
fn.trackAccent(ui.loadPresetBtn)

ui.presetStatus = Instance.new("TextLabel")
ui.presetStatus.Size = UDim2.new(1, 0, 0, 14)
ui.presetStatus.BackgroundTransparency = 1
ui.presetStatus.Text = ""
ui.presetStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
ui.presetStatus.TextSize = 10
ui.presetStatus.Font = FONT
ui.presetStatus.TextXAlignment = Enum.TextXAlignment.Left
ui.presetStatus.Parent = setPage

cache.presetList = nil
cache.presetBlocker = nil
cache.presetOpen = false

fn.status = function(t, c)
	ui.presetStatus.Text = t
	ui.presetStatus.TextColor3 = c or Color3.fromRGB(150, 150, 150)
end

fn.listPresets = function()
	local list = {}
	if listfiles and isfile then
		local ok, entries = pcall(function() return listfiles(".") end)
		if ok and type(entries) == "table" then
			for _, path in ipairs(entries) do
				local nm = path:match(PRESET_PREFIX .. "(.-)%.json")
				if nm then table.insert(list, nm) end
			end
		end
	end
	table.sort(list)
	return list
end

fn.presetExists = function(name)
	if not isfile then return false end
	local ok, v = pcall(function() return isfile(PRESET_PREFIX .. name .. ".json") end)
	return ok and v
end

fn.closePresetList = function()
	if cache.presetList then
		cache.presetList:Destroy()
		cache.presetList = nil
	end
	if cache.presetBlocker then
		cache.presetBlocker:Destroy()
		cache.presetBlocker = nil
	end
	cache.presetOpen = false
	ui.arrowBtn.Text = "v"
end

fn.openPresetList = function()
	fn.closePresetList()
	cache.presetOpen = true
	ui.arrowBtn.Text = "^"

	local blocker = Instance.new("TextButton")
	blocker.Size = UDim2.new(1, 0, 1, 0)
	blocker.BackgroundTransparency = 1
	blocker.Text = ""
	blocker.ZIndex = 200
	blocker.Parent = ui.gui
	blocker.MouseButton1Click:Connect(function()
		fn.closePresetList()
	end)
	cache.presetBlocker = blocker

	local list = Instance.new("Frame")
	list.Size = UDim2.new(0, 220, 0, 0)
	list.AutomaticSize = Enum.AutomaticSize.Y
	list.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	list.BackgroundTransparency = 0.05
	list.BorderSizePixel = 0
	list.ZIndex = 210
	list.Parent = ui.gui

	local arrowPos = ui.arrowBtn.AbsolutePosition
	local arrowSize = ui.arrowBtn.AbsoluteSize
	list.Position = UDim2.new(0, arrowPos.X - 196, 0, arrowPos.Y + arrowSize.Y + 4)

	local ll = Instance.new("UIListLayout")
	ll.SortOrder = Enum.SortOrder.LayoutOrder
	ll.Padding = UDim.new(0, 2)
	ll.Parent = list

	local names = fn.listPresets()
	if #names == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, 22)
		empty.BackgroundTransparency = 1
		empty.Text = "  no presets saved"
		empty.TextColor3 = Color3.fromRGB(150, 150, 150)
		empty.TextSize = 11
		empty.Font = FONT
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.ZIndex = 211
		empty.Parent = list
	else
		for _, name in ipairs(names) do
			local entry = Instance.new("TextButton")
			entry.Size = UDim2.new(1, 0, 0, 22)
			entry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			entry.BackgroundTransparency = 0.3
			entry.BorderSizePixel = 0
			entry.Text = "  " .. name
			entry.TextColor3 = Color3.fromRGB(220, 220, 220)
			entry.TextSize = 12
			entry.Font = FONT
			entry.TextXAlignment = Enum.TextXAlignment.Left
			entry.ZIndex = 211
			entry.Parent = list
			entry.MouseButton1Click:Connect(function()
				ui.displayBox.Text = name
				ui.nameBox.Text = name
				fn.closePresetList()
			end)
		end
	end

	cache.presetList = list
end

fn.savePreset = function(name)
	if not writefile then fn.status("writefile not available", Color3.fromRGB(255, 100, 100)) return end
	if not name or name == "" then fn.status("enter a name first", Color3.fromRGB(255, 100, 100)) return end
	if fn.presetExists(name) then fn.status("'" .. name .. "' already exists", Color3.fromRGB(255, 100, 100)) return end
	local ok, enc = pcall(function() return HttpService:JSONEncode(fn.snapshot()) end)
	if not ok or not enc then fn.status("failed to encode", Color3.fromRGB(255, 100, 100)) return end
	local wrote = pcall(writefile, PRESET_PREFIX .. name .. ".json", enc)
	if wrote then
		fn.status("saved '" .. name .. "'", Color3.fromRGB(100, 220, 100))
		ui.displayBox.Text = name
		if fn.notify then fn.notify("preset saved: " .. name, Color3.fromRGB(50, 210, 90)) end
	else
		fn.status("failed to write", Color3.fromRGB(255, 100, 100))
	end
end

fn.replacePreset = function(name)
	if not writefile then fn.status("writefile not available", Color3.fromRGB(255, 100, 100)) return end
	if not name or name == "" then fn.status("select a preset first", Color3.fromRGB(255, 100, 100)) return end
	if not fn.presetExists(name) then fn.status("'" .. name .. "' not found", Color3.fromRGB(255, 100, 100)) return end
	local ok, enc = pcall(function() return HttpService:JSONEncode(fn.snapshot()) end)
	if not ok or not enc then fn.status("failed to encode", Color3.fromRGB(255, 100, 100)) return end
	local wrote = pcall(writefile, PRESET_PREFIX .. name .. ".json", enc)
	if wrote then
		fn.status("replaced '" .. name .. "'", Color3.fromRGB(190, 140, 30))
	else
		fn.status("failed to write", Color3.fromRGB(255, 100, 100))
	end
end

fn.loadPreset = function(name)
	if not readfile then fn.status("readfile not available", Color3.fromRGB(255, 100, 100)) return end
	if not name or name == "" then fn.status("select a preset first", Color3.fromRGB(255, 100, 100)) return end
	local path = PRESET_PREFIX .. name .. ".json"
	local ok, contents = pcall(readfile, path)
	if not ok or not contents or contents == "" then fn.status("'" .. name .. "' not found", Color3.fromRGB(255, 100, 100)) return end
	local ok2, decoded = pcall(function() return HttpService:JSONDecode(contents) end)
	if ok2 and type(decoded) == "table" then
		fn.import(decoded)
		fn.save()
		fn.status("loaded '" .. name .. "'", Color3.fromRGB(100, 220, 100))
		if fn.notify then fn.notify("preset loaded: " .. name, Color3.fromRGB(50, 210, 90)) end
		task.spawn(function()
			task.wait()
			if fn.refreshAll then fn.refreshAll() end
		end)
	else
		fn.status("failed to decode", Color3.fromRGB(255, 100, 100))
	end
end

fn.deletePreset = function(name)
	if not delfile then fn.status("delfile not available", Color3.fromRGB(255, 100, 100)) return end
	if not name or name == "" then fn.status("select a preset first", Color3.fromRGB(255, 100, 100)) return end
	if not fn.presetExists(name) then fn.status("'" .. name .. "' not found", Color3.fromRGB(255, 100, 100)) return end
	pcall(delfile, PRESET_PREFIX .. name .. ".json")
	fn.status("deleted '" .. name .. "'", Color3.fromRGB(220, 180, 100))
	if ui.displayBox.Text == name then ui.displayBox.Text = "" end
end

fn.doubleConfirm = function(btn, idleText, onConfirm)
	local armed = false
	local deadline = 0
	local conn
	btn.MouseButton1Click:Connect(function()
		if not armed then
			armed = true
			deadline = tick() + 0.5
			btn.Text = "confirm?"
			if conn then conn:Disconnect() end
			conn = RunService.Heartbeat:Connect(function()
				if not armed then
					conn:Disconnect()
					conn = nil
					return
				end
				local remaining = deadline - tick()
				if remaining <= 0 then
					armed = false
					btn.Text = idleText
					conn:Disconnect()
					conn = nil
				else
					btn.Text = string.format("confirm (%.1fs)", remaining)
				end
			end)
		else
			armed = false
			btn.Text = idleText
			if conn then conn:Disconnect() conn = nil end
			onConfirm()
		end
	end)
end

ui.savePresetBtn.MouseButton1Click:Connect(function() fn.savePreset(ui.nameBox.Text) end)
ui.arrowBtn.MouseButton1Click:Connect(function()
	if cache.presetOpen then fn.closePresetList() else fn.openPresetList() end
end)
ui.loadPresetBtn.MouseButton1Click:Connect(function() fn.loadPreset(ui.displayBox.Text) end)
fn.doubleConfirm(ui.deletePresetBtn, "delete", function() fn.deletePreset(ui.displayBox.Text) end)
fn.doubleConfirm(ui.replacePresetBtn, "replace", function() fn.replacePreset(ui.displayBox.Text) end)

cache.colourLabel = Instance.new("TextLabel")
cache.colourLabel.Size = UDim2.new(1, 0, 0, 16)
cache.colourLabel.BackgroundTransparency = 1
cache.colourLabel.Text = "colour settings"
cache.colourLabel.TextColor3 = cache.accent
cache.colourLabel.TextSize = 12
cache.colourLabel.Font = FONT_B
cache.colourLabel.TextXAlignment = Enum.TextXAlignment.Left
cache.colourLabel.Parent = setPage
fn.trackAccent(cache.colourLabel)

cache.colourRow = Instance.new("Frame")
cache.colourRow.Size = UDim2.new(1, 0, 0, 22)
cache.colourRow.BackgroundTransparency = 1
cache.colourRow.Parent = setPage

cache.colourLayout = Instance.new("UIListLayout")
cache.colourLayout.FillDirection = Enum.FillDirection.Horizontal
cache.colourLayout.SortOrder = Enum.SortOrder.LayoutOrder
cache.colourLayout.Padding = UDim.new(0, 4)
cache.colourLayout.Parent = cache.colourRow

for _, colour in ipairs({
	Color3.fromRGB(190, 100, 0),
	Color3.fromRGB(230, 40, 40),
	Color3.fromRGB(220, 50, 180),
	Color3.fromRGB(130, 60, 220),
	Color3.fromRGB(50, 110, 230),
	Color3.fromRGB(40, 200, 220),
	Color3.fromRGB(50, 210, 90),
	Color3.fromRGB(230, 220, 50),
}) do
	local sw = Instance.new("TextButton")
	sw.Size = UDim2.new(0, 20, 0, 20)
	sw.BackgroundColor3 = colour
	sw.BorderSizePixel = 0
	sw.Text = ""
	sw.AutoButtonColor = true
	sw.Parent = cache.colourRow
	sw.MouseButton1Click:Connect(function()
		cache.accent = colour
		ui.fovStroke.Color = colour
		fn.applyAccent()
		fn.save()
	end)
end

fn.toggleRow(setPage, "watermark", function() return state.watermarkEnabled end, function(v)
	state.watermarkEnabled = v
	if fn.setWatermarkVisible then fn.setWatermarkVisible(v) end
	if fn.notify then fn.notify(v and "watermark enabled" or "watermark disabled", v and Color3.fromRGB(50, 210, 90) or Color3.fromRGB(255, 80, 80)) end
end)
fn.toggleRow(setPage, "notifications", function() return state.notificationsEnabled end, function(v)
	state.notificationsEnabled = v
	if v and fn.notify then
		task.wait(0.05)
		fn.notify("notifications enabled", Color3.fromRGB(50, 210, 90))
	end
end)
fn.toggleRow(setPage, "- hyper fov (just funs)", function() return state.thirdPerson end, function(v)
	state.thirdPerson = v
	if not v then
		pcall(function()
			camera.CameraType = Enum.CameraType.Custom
			local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if hum then camera.CameraSubject = hum end
		end)
	end
end)

cache.spacer = Instance.new("Frame")
cache.spacer.Size = UDim2.new(1, 0, 0, 8)
cache.spacer.BackgroundTransparency = 1
cache.spacer.Parent = setPage

-- Search button at the bottom (right above info)
ui.searchBtn2 = Instance.new("TextButton")
ui.searchBtn2.Size = UDim2.new(1, 0, 0, 24)
ui.searchBtn2.BackgroundColor3 = cache.accent
ui.searchBtn2.BorderSizePixel = 0
ui.searchBtn2.Text = "search"
ui.searchBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.searchBtn2.TextSize = NORMAL
ui.searchBtn2.Font = FONT_B
ui.searchBtn2.Parent = setPage
fn.trackAccent(ui.searchBtn2)

ui.infoBtn = Instance.new("TextButton")
ui.infoBtn.Size = UDim2.new(1, 0, 0, 24)
ui.infoBtn.BackgroundColor3 = cache.accent
ui.infoBtn.BorderSizePixel = 0
ui.infoBtn.Text = "info"
ui.infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.infoBtn.TextSize = NORMAL
ui.infoBtn.Font = FONT_B
ui.infoBtn.Parent = setPage
fn.trackAccent(ui.infoBtn)

ui.unloadBtn = Instance.new("TextButton")
ui.unloadBtn.Size = UDim2.new(1, 0, 0, 24)
ui.unloadBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
ui.unloadBtn.BorderSizePixel = 0
ui.unloadBtn.Text = "unload"
ui.unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.unloadBtn.TextSize = NORMAL
ui.unloadBtn.Font = FONT_B
ui.unloadBtn.Parent = setPage

-- Reorder: push searchBtn2 & info & unload to layout end
ui.searchBtn2.LayoutOrder = 100
ui.infoBtn.LayoutOrder = 101
ui.unloadBtn.LayoutOrder = 102

-- remove the top search button (keep the bottom one only)
ui.searchBtn:Destroy()
ui.searchBtn = ui.searchBtn2

fn.refreshAll = function()
	if state.unloaded then return end
	for _, f in ipairs(refs.toggles) do pcall(f) end
	for _, f in ipairs(refs.sliders) do pcall(f) end
	for _, f in ipairs(refs.cycles) do pcall(f) end
	for _, f in ipairs(refs.binds) do pcall(f) end
	fn.applyAccent()

	if ui.fovCircle then ui.fovCircle.Visible = state.fovCircleState end
	if ui.watermark then ui.watermark.Visible = state.watermarkEnabled end
	if fn.refreshESP then fn.refreshESP() end
	if fn.refreshTracers then fn.refreshTracers() end
	if fn.refreshHealthBars then fn.refreshHealthBars() end
	if fn.refreshHotkeys then fn.refreshHotkeys() end
end

fn.switchTab("triggerbot")
fn.applyAccent()

-- ============================================================
-- SEARCH GUI
-- ============================================================
cache.searchOpen = false
cache.searchItems = {}   -- { {label=..., row=..., tab=...}, ... }

-- Build search index by scanning tab pages for visible rows/sections
fn.buildSearchIndex = function()
	cache.searchItems = {}
	for tabName, page in pairs(cache.tabs) do
		for _, child in ipairs(page:GetChildren()) do
			if child:IsA("Frame") and child.Name:sub(1,4) == "row_" then
				local label = nil
				for _, sub in ipairs(child:GetChildren()) do
					if sub:IsA("TextLabel") and sub.Text ~= "" then
						label = sub.Text
						break
					end
				end
				if label then
					table.insert(cache.searchItems, {
						label = label,
						row = child,
						tab = tabName,
					})
				end
			elseif child:IsA("TextLabel") and child.Text ~= "" and child.TextSize <= 12 then
				table.insert(cache.searchItems, {
					label = child.Text,
					row = child,
					tab = tabName,
					isSection = true,
				})
			end
		end
	end
end

ui.searchOverlay = Instance.new("Frame")
ui.searchOverlay.Size = UDim2.new(1, 0, 1, 0)
ui.searchOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ui.searchOverlay.BackgroundTransparency = 1
ui.searchOverlay.BorderSizePixel = 0
ui.searchOverlay.Visible = false
ui.searchOverlay.ZIndex = 500
ui.searchOverlay.Parent = ui.gui

ui.searchDim = Instance.new("Frame")
ui.searchDim.Size = UDim2.new(1, 0, 1, 0)
ui.searchDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ui.searchDim.BackgroundTransparency = 0.5
ui.searchDim.BorderSizePixel = 0
ui.searchDim.ZIndex = 500
ui.searchDim.Parent = ui.searchOverlay

ui.searchPanel = Instance.new("Frame")
ui.searchPanel.Size = UDim2.new(0, 360, 0, 320)
ui.searchPanel.Position = UDim2.new(0.5, -180, 0.5, -160)
ui.searchPanel.BackgroundColor3 = SURFACE
ui.searchPanel.BackgroundTransparency = 0.05
ui.searchPanel.BorderSizePixel = 0
ui.searchPanel.ZIndex = 501
ui.searchPanel.Parent = ui.searchOverlay

local searchGrad = Instance.new("UIGradient")
searchGrad.Color = ColorSequence.new(SURFACE_TOP, SURFACE_BOT)
searchGrad.Rotation = 90
searchGrad.Parent = ui.searchPanel

ui.searchTitle = Instance.new("TextLabel")
ui.searchTitle.Size = UDim2.new(1, -36, 0, 28)
ui.searchTitle.Position = UDim2.new(0, 8, 0, 0)
ui.searchTitle.BackgroundTransparency = 1
ui.searchTitle.Text = "search"
ui.searchTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.searchTitle.TextSize = 14
ui.searchTitle.Font = FONT_B
ui.searchTitle.TextXAlignment = Enum.TextXAlignment.Left
ui.searchTitle.ZIndex = 502
ui.searchTitle.Parent = ui.searchPanel

ui.searchClose = Instance.new("TextButton")
ui.searchClose.Size = UDim2.new(0, 22, 0, 22)
ui.searchClose.Position = UDim2.new(1, -28, 0, 3)
ui.searchClose.BackgroundColor3 = cache.accent
ui.searchClose.BorderSizePixel = 0
ui.searchClose.Text = "X"
ui.searchClose.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.searchClose.TextSize = 12
ui.searchClose.Font = FONT_B
ui.searchClose.ZIndex = 502
ui.searchClose.Parent = ui.searchPanel
fn.trackAccent(ui.searchClose)

ui.searchBox = Instance.new("TextBox")
ui.searchBox.Size = UDim2.new(1, -16, 0, 26)
ui.searchBox.Position = UDim2.new(0, 8, 0, 34)
ui.searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ui.searchBox.BackgroundTransparency = 0.2
ui.searchBox.BorderSizePixel = 0
ui.searchBox.Text = ""
ui.searchBox.PlaceholderText = "type to search..."
ui.searchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
ui.searchBox.TextColor3 = Color3.fromRGB(230, 230, 230)
ui.searchBox.TextSize = 13
ui.searchBox.Font = FONT
ui.searchBox.ClearTextOnFocus = false
ui.searchBox.TextXAlignment = Enum.TextXAlignment.Left
ui.searchBox.ZIndex = 502
ui.searchBox.Parent = ui.searchPanel

local searchPad = Instance.new("UIPadding")
searchPad.PaddingLeft = UDim.new(0, 8)
searchPad.PaddingRight = UDim.new(0, 8)
searchPad.Parent = ui.searchBox

ui.searchResults = Instance.new("ScrollingFrame")
ui.searchResults.Size = UDim2.new(1, -16, 1, -74)
ui.searchResults.Position = UDim2.new(0, 8, 0, 66)
ui.searchResults.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ui.searchResults.BackgroundTransparency = 0.4
ui.searchResults.BorderSizePixel = 0
ui.searchResults.ScrollBarThickness = 4
ui.searchResults.ScrollBarImageColor3 = cache.accent
ui.searchResults.CanvasSize = UDim2.new(0, 0, 0, 0)
ui.searchResults.AutomaticCanvasSize = Enum.AutomaticSize.Y
ui.searchResults.ZIndex = 502
ui.searchResults.Parent = ui.searchPanel

local searchListLayout = Instance.new("UIListLayout")
searchListLayout.SortOrder = Enum.SortOrder.LayoutOrder
searchListLayout.Padding = UDim.new(0, 2)
searchListLayout.Parent = ui.searchResults

fn.closeSearch = function()
	cache.searchOpen = false
	ui.searchOverlay.Visible = false
	ui.searchBox.Text = ""
	for _, c in ipairs(ui.searchResults:GetChildren()) do
		if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
	end
end

fn.openSearch = function()
	fn.buildSearchIndex()
	cache.searchOpen = true
	ui.searchOverlay.Visible = true
	ui.searchBox.Text = ""
	for _, c in ipairs(ui.searchResults:GetChildren()) do
		if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
	end
end

fn.renderSearchResults = function(query)
	for _, c in ipairs(ui.searchResults:GetChildren()) do
		if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
	end
	local q = (query or ""):lower()
	local i = 0
	for _, item in ipairs(cache.searchItems) do
		local lbl = item.label:lower()
		if q == "" or lbl:find(q, 1, true) then
			i = i + 1
			local entry = Instance.new("TextButton")
			entry.Size = UDim2.new(1, 0, 0, 26)
			entry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			entry.BackgroundTransparency = 0.3
			entry.BorderSizePixel = 0
			entry.Text = "  " .. item.label
			entry.TextColor3 = Color3.fromRGB(220, 220, 220)
			entry.TextSize = 12
			entry.Font = FONT
			entry.TextXAlignment = Enum.TextXAlignment.Left
			entry.LayoutOrder = i
			entry.ZIndex = 503
			entry.Parent = ui.searchResults

			local tabTag = Instance.new("TextLabel")
			tabTag.Size = UDim2.new(0, 90, 1, 0)
			tabTag.Position = UDim2.new(1, -94, 0, 0)
			tabTag.BackgroundTransparency = 1
			tabTag.Text = item.tab
			tabTag.TextColor3 = cache.accent
			tabTag.TextSize = 10
			tabTag.Font = FONT_B
			tabTag.TextXAlignment = Enum.TextXAlignment.Right
			tabTag.ZIndex = 504
			tabTag.Parent = entry

			entry.MouseButton1Click:Connect(function()
				fn.switchTab(item.tab)
				fn.closeSearch()
				if fn.notify then fn.notify("jumped to: " .. item.label, Color3.fromRGB(50, 210, 90)) end
			end)
		end
	end
	if i == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, 26)
		empty.BackgroundTransparency = 1
		empty.Text = "  no matches"
		empty.TextColor3 = Color3.fromRGB(150, 150, 150)
		empty.TextSize = 12
		empty.Font = FONT
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.ZIndex = 503
		empty.Parent = ui.searchResults
	end
end

ui.searchBtn.MouseButton1Click:Connect(fn.openSearch)
ui.searchClose.MouseButton1Click:Connect(fn.closeSearch)

ui.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	if cache.searchOpen then
		fn.renderSearchResults(ui.searchBox.Text)
	end
end)

ui.searchBox.Focused:Connect(function()
	fn.renderSearchResults(ui.searchBox.Text)
end)

ui.searchDim.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		fn.closeSearch()
	end
end)

-- ============================================================
-- OVERLAYS
-- ============================================================
ui.watermark = Instance.new("Frame")
ui.watermark.Size = UDim2.new(0, 260, 0, 26)
ui.watermark.AnchorPoint = Vector2.new(0, 0)
ui.watermark.Position = UDim2.new(0, 170, 0, 8)
ui.watermark.BackgroundColor3 = SURFACE
ui.watermark.BackgroundTransparency = TRANSPARENCY
ui.watermark.BorderSizePixel = 0
ui.watermark.Visible = state.watermarkEnabled
ui.watermark.ZIndex = 80
ui.watermark.Parent = ui.gui

ui.watermarkGrad = Instance.new("UIGradient")
ui.watermarkGrad.Color = ColorSequence.new(SURFACE_TOP, SURFACE_BOT)
ui.watermarkGrad.Rotation = 90
ui.watermarkGrad.Parent = ui.watermark

ui.watermarkAccent = Instance.new("Frame")
ui.watermarkAccent.Size = UDim2.new(0, 3, 1, 0)
ui.watermarkAccent.BackgroundColor3 = cache.accent
ui.watermarkAccent.BorderSizePixel = 0
ui.watermarkAccent.ZIndex = 81
ui.watermarkAccent.Parent = ui.watermark
fn.trackAccent(ui.watermarkAccent)

ui.watermarkLabel = Instance.new("TextLabel")
ui.watermarkLabel.Size = UDim2.new(1, -16, 1, 0)
ui.watermarkLabel.Position = UDim2.new(0, 10, 0, 0)
ui.watermarkLabel.BackgroundTransparency = 1
ui.watermarkLabel.Text = "Gator hub"
ui.watermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.watermarkLabel.TextSize = 12
ui.watermarkLabel.Font = FONT_B
ui.watermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
ui.watermarkLabel.ZIndex = 81
ui.watermarkLabel.Parent = ui.watermark

ui.watermarkStats = Instance.new("TextLabel")
ui.watermarkStats.Size = UDim2.new(0, 130, 1, 0)
ui.watermarkStats.Position = UDim2.new(1, -134, 0, 0)
ui.watermarkStats.BackgroundTransparency = 1
ui.watermarkStats.Text = ""
ui.watermarkStats.TextColor3 = Color3.fromRGB(220, 220, 220)
ui.watermarkStats.TextSize = 11
ui.watermarkStats.Font = FONT
ui.watermarkStats.TextXAlignment = Enum.TextXAlignment.Right
ui.watermarkStats.ZIndex = 81
ui.watermarkStats.Parent = ui.watermark

cache.watermarkTween = nil
fn.setWatermarkVisible = function(v)
	if cache.watermarkTween then
		pcall(function() cache.watermarkTween:Cancel() end)
	end
	cache.watermarkTween = TweenService:Create(
		ui.watermark,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = v and TRANSPARENCY or 1 }
	)
	cache.watermarkTween:Play()
	if v then ui.watermark.Visible = true end
	task.delay(0.26, function()
		if not state.watermarkEnabled then ui.watermark.Visible = false end
	end)
end

ui.notifHolder = Instance.new("Frame")
ui.notifHolder.Size = UDim2.new(0, 260, 0, 400)
ui.notifHolder.AnchorPoint = Vector2.new(1, 1)
ui.notifHolder.Position = UDim2.new(1, -12, 1, -12)
ui.notifHolder.BackgroundTransparency = 1
ui.notifHolder.ZIndex = 90
ui.notifHolder.Parent = ui.gui

ui.notifList = Instance.new("UIListLayout")
ui.notifList.SortOrder = Enum.SortOrder.LayoutOrder
ui.notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
ui.notifList.HorizontalAlignment = Enum.HorizontalAlignment.Right
ui.notifList.Padding = UDim.new(0, 6)
ui.notifList.Parent = ui.notifHolder

cache.notifOrder = 0

fn.notify = function(text, color)
	if not state.notificationsEnabled then return end

	-- cap stack at 4
	local frames = {}
	for _, c in ipairs(ui.notifHolder:GetChildren()) do
		if c:IsA("Frame") then table.insert(frames, c) end
	end
	if #frames >= 4 then
		local oldest = nil
		for _, c in ipairs(frames) do
			if not oldest or c.LayoutOrder < oldest.LayoutOrder then
				oldest = c
			end
		end
		if oldest then pcall(function() oldest:Destroy() end) end
	end

	cache.notifOrder = cache.notifOrder + 1
	local order = cache.notifOrder

	local card = Instance.new("Frame")
	card.Size = UDim2.new(0, 240, 0, 30)
	card.BackgroundColor3 = SURFACE
	card.BackgroundTransparency = TRANSPARENCY
	card.BorderSizePixel = 0
	card.ZIndex = 91
	card.LayoutOrder = order
	card.Parent = ui.notifHolder

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(SURFACE_TOP, SURFACE_BOT)
	grad.Rotation = 90
	grad.Parent = card

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 3, 1, 0)
	accent.BackgroundColor3 = color or cache.accent
	accent.BorderSizePixel = 0
	accent.ZIndex = 92
	accent.Parent = card

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -16, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
	lbl.TextSize = 12
	lbl.Font = FONT
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 92
	lbl.Parent = card

	card.Position = UDim2.new(1, 20, 0, 0)
	local slideIn = TweenService:Create(
		card,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0, 0, 0, 0) }
	)
	slideIn:Play()

	task.delay(1.8, function()
		if not card.Parent then return end
		local fadeOut = TweenService:Create(
			card,
			TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ BackgroundTransparency = 1, Position = UDim2.new(0, 24, 0, 0) }
		)
		fadeOut:Play()
		TweenService:Create(lbl, TweenInfo.new(0.24), { TextTransparency = 1 }):Play()
		TweenService:Create(accent, TweenInfo.new(0.24), { BackgroundTransparency = 1 }):Play()
		task.wait(0.3)
		pcall(function() card:Destroy() end)
	end)
end

cache.statusBox = Instance.new("Frame")
cache.statusBox.Size = UDim2.new(0, 200, 0, 70)
cache.statusBox.Position = UDim2.new(0.5, -100, 1, -80)
cache.statusBox.BackgroundTransparency = 1
cache.statusBox.BorderSizePixel = 0
cache.statusBox.ZIndex = 71
cache.statusBox.Parent = ui.gui

cache.statusLayout = Instance.new("UIListLayout")
cache.statusLayout.SortOrder = Enum.SortOrder.LayoutOrder
cache.statusLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
cache.statusLayout.Padding = UDim.new(0, 2)
cache.statusLayout.Parent = cache.statusBox

fn.statusLabel = function(text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 20)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(255, 255, 255)
	l.TextSize = 14
	l.Font = Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Center
	l.TextTransparency = 1
	l.TextStrokeTransparency = 1
	l.ZIndex = 72
	l.Parent = cache.statusBox
	return l
end

cache.statusEsp  = fn.statusLabel("esp")
cache.statusTrig = fn.statusLabel("trigger")
cache.statusAim  = fn.statusLabel("aimbot")

-- ============================================================
-- INFO PANEL
-- ============================================================
ui.infoShadow = Instance.new("Frame")
ui.infoShadow.Size = UDim2.new(0, INFO_W, 0, 200)
ui.infoShadow.Position = UDim2.new(0, -(INFO_W + INFO_GAP) + 4, 0, 4)
ui.infoShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ui.infoShadow.BackgroundTransparency = 0.75
ui.infoShadow.BorderSizePixel = 0
ui.infoShadow.Visible = false
ui.infoShadow.ZIndex = -1
ui.infoShadow.Parent = ui.panel

ui.info = Instance.new("Frame")
ui.info.Size = UDim2.new(0, INFO_W, 0, 0)
ui.info.AutomaticSize = Enum.AutomaticSize.Y
ui.info.Position = UDim2.new(0, -(INFO_W + INFO_GAP), 0, 0)
ui.info.BackgroundColor3 = SURFACE
ui.info.BackgroundTransparency = TRANSPARENCY
ui.info.BorderSizePixel = 0
ui.info.ClipsDescendants = true
ui.info.Visible = false
ui.info.ZIndex = 2
ui.info.Parent = ui.panel

ui.infoGrad = Instance.new("UIGradient")
ui.infoGrad.Color = ColorSequence.new(SURFACE_TOP, SURFACE_BOT)
ui.infoGrad.Rotation = 90
ui.infoGrad.Parent = ui.info

ui.infoTitleBar = Instance.new("Frame")
ui.infoTitleBar.Size = UDim2.new(1, 0, 0, TITLE_H)
ui.infoTitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ui.infoTitleBar.BackgroundTransparency = 0.15
ui.infoTitleBar.BorderSizePixel = 0
ui.infoTitleBar.Parent = ui.info

ui.infoTitle = Instance.new("TextLabel")
ui.infoTitle.Size = UDim2.new(1, -30, 1, 0)
ui.infoTitle.Position = UDim2.new(0, 8, 0, 0)
ui.infoTitle.BackgroundTransparency = 1
ui.infoTitle.Text = "info"
ui.infoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.infoTitle.TextSize = 13
ui.infoTitle.Font = FONT_B
ui.infoTitle.TextXAlignment = Enum.TextXAlignment.Left
ui.infoTitle.Parent = ui.infoTitleBar

ui.infoClose = Instance.new("TextButton")
ui.infoClose.Size = UDim2.new(0, 20, 0, 20)
ui.infoClose.Position = UDim2.new(1, -24, 0, 3)
ui.infoClose.BackgroundColor3 = cache.accent
ui.infoClose.BorderSizePixel = 0
ui.infoClose.Text = "X"
ui.infoClose.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.infoClose.TextSize = 12
ui.infoClose.Font = FONT_B
ui.infoClose.Parent = ui.infoTitleBar
fn.trackAccent(ui.infoClose)

ui.infoContent = Instance.new("Frame")
ui.infoContent.Size = UDim2.new(1, -12, 0, 0)
ui.infoContent.Position = UDim2.new(0, 6, 0, TITLE_H + 4)
ui.infoContent.BackgroundTransparency = 1
ui.infoContent.AutomaticSize = Enum.AutomaticSize.Y
ui.infoContent.Parent = ui.info

ui.infoList = Instance.new("UIListLayout")
ui.infoList.SortOrder = Enum.SortOrder.LayoutOrder
ui.infoList.Padding = UDim.new(0, 2)
ui.infoList.Parent = ui.infoContent

ui.infoPad = Instance.new("UIPadding")
ui.infoPad.PaddingBottom = UDim.new(0, 8)
ui.infoPad.Parent = ui.infoContent

fn.infoLine = function(text, colour, size)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, size or 12)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = colour or Color3.fromRGB(200, 200, 200)
	l.TextSize = 10
	l.Font = FONT
	l.TextWrapped = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = ui.infoContent
	return l
end

cache.hkH = fn.infoLine("hotkeys", cache.accent, 13) fn.trackAccent(cache.hkH)
cache.hk1 = fn.infoLine("", nil, 11)
cache.hk2 = fn.infoLine("", nil, 11)
cache.hk3 = fn.infoLine("", nil, 11)
cache.hk4 = fn.infoLine("", nil, 11)
cache.hk5 = fn.infoLine("", nil, 11)
cache.hk6 = fn.infoLine("", nil, 11)
cache.hk7 = fn.infoLine("", nil, 11)
fn.infoLine("", nil, 4)
cache.cH = fn.infoLine("credits", cache.accent, 13) fn.trackAccent(cache.cH)
fn.infoLine("by : ch94", nil, 11)
fn.infoLine("", nil, 6)

ui.debugBtn = Instance.new("TextButton")
ui.debugBtn.Size = UDim2.new(1, 0, 0, 22)
ui.debugBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ui.debugBtn.BorderSizePixel = 0
ui.debugBtn.Text = "debug: OFF"
ui.debugBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ui.debugBtn.TextSize = 11
ui.debugBtn.Font = FONT_B
ui.debugBtn.Parent = ui.infoContent

cache.dbg = {
	fps    = fn.infoLine("fps: -", Color3.fromRGB(200, 200, 200), 11),
	ping   = fn.infoLine("ping: -", Color3.fromRGB(200, 200, 200), 11),
	match  = fn.infoLine("in match: -", Color3.fromRGB(200, 200, 200), 11),
	enem   = fn.infoLine("enemies: -", Color3.fromRGB(200, 200, 200), 11),
	aimbot = fn.infoLine("aimbot: -", Color3.fromRGB(200, 200, 200), 11),
	aimTgt = fn.infoLine("aim target: -", Color3.fromRGB(200, 200, 200), 11),
	rage   = fn.infoLine("ragebot: -", Color3.fromRGB(200, 200, 200), 11),
	fly    = fn.infoLine("fly: -", Color3.fromRGB(200, 200, 200), 11),
	noclip = fn.infoLine("noclip: -", Color3.fromRGB(200, 200, 200), 11),
}

cache.debugList = {
	cache.dbg.fps, cache.dbg.ping, cache.dbg.match, cache.dbg.enem,
	cache.dbg.aimbot, cache.dbg.aimTgt,
	cache.dbg.rage, cache.dbg.fly, cache.dbg.noclip,
}

fn.setDebugVisible = function(v)
	for _, l in ipairs(cache.debugList) do l.Visible = v end
end
fn.setDebugVisible(false)

cache.debugOn = false
fn.trackToggleAccent(ui.debugBtn, function() return cache.debugOn end)

ui.debugBtn.MouseButton1Click:Connect(function()
	cache.debugOn = not cache.debugOn
	ui.debugBtn.Text = cache.debugOn and "debug: ON" or "debug: OFF"
	ui.debugBtn.BackgroundColor3 = cache.debugOn and cache.accent or Color3.fromRGB(60, 60, 60)
	fn.setDebugVisible(cache.debugOn)
end)

fn.refreshHotkeys = function()
	cache.hk1.Text = string.format("%s - hold aimbot", fn.aimKeyName())
	cache.hk2.Text = string.format("%s - toggle esp", state.espKey.Name)
	cache.hk3.Text = string.format("%s - toggle triggerbot", state.triggerKey.Name)
	cache.hk4.Text = string.format("%s - toggle aimbot", state.aimToggleKey.Name)
	cache.hk5.Text = string.format("%s - free cam", state.freeCamKey.Name)
	cache.hk6.Text = string.format("%s - ragebot", state.ragebotKey.Name)
	cache.hk7.Text = string.format("%s - fly | %s - noclip | %s - hide visuals",
		state.flyKey.Name, state.noclipKey.Name, state.visualToggleKey.Name)
end
fn.refreshHotkeys()

ui.infoClose.MouseButton1Click:Connect(function()
	state.infoOpen = false
	ui.info.Visible = false
	ui.infoShadow.Visible = false
end)

ui.infoBtn.MouseButton1Click:Connect(function()
	state.infoOpen = not state.infoOpen
	ui.info.Visible = state.infoOpen
	ui.infoShadow.Visible = state.infoOpen
end)

-- ============================================================
-- DRAGGING
-- ============================================================
fn.draggable = function(frame, handle)
	local dragging, dragStart, startPos = false, nil, nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
			ui.shadow.Position = UDim2.new(
				frame.Position.X.Scale, frame.Position.X.Offset + 4,
				frame.Position.Y.Scale, frame.Position.Y.Offset + 4
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
			dragging = false
			state.menuPosX = frame.Position.X.Offset - (MENU_W + EDGE) * -1 - MENU_W + MENU_W - (MENU_W + EDGE) -- placeholder, corrected below
			-- safer: recompute from current position
			state.menuPosX = frame.Position.X.Offset + (MENU_W + EDGE) - (MENU_W)
			state.menuPosY = frame.Position.Y.Offset + MENU_H / 2
			fn.save()
		end
	end)
end

fn.draggable(ui.panel, ui.titleBar)

state.minimized = false

ui.minBtn.MouseButton1Click:Connect(function()
	state.minimized = not state.minimized
	if state.minimized then
		ui.tabBar.Visible = false
		ui.content.Visible = false
		ui.panel.Size = UDim2.new(0, MENU_W, 0, TITLE_H)
		ui.shadow.Size = UDim2.new(0, MENU_W, 0, TITLE_H)
		ui.minBtn.Text = "+"
		if state.infoOpen then
			ui.info.Visible = false
			ui.infoShadow.Visible = false
		end
	else
		ui.tabBar.Visible = true
		ui.content.Visible = true
		ui.panel.Size = UDim2.new(0, MENU_W, 0, MENU_H)
		ui.shadow.Size = UDim2.new(0, MENU_W, 0, MENU_H)
		ui.minBtn.Text = "-"
		if state.infoOpen then
			ui.info.Visible = true
			ui.infoShadow.Visible = true
		end
	end
end)

-- ============================================================
-- ESP
-- ============================================================
cache.espCache = {}

fn.destroyESP = function(plr)
	local data = cache.espCache[plr]
	if not data then return end
	if data.highlight then
		data.highlight.Adornee = nil
		data.highlight.Parent = nil
		data.highlight:Destroy()
	end
	cache.espCache[plr] = nil
end

fn.paintESP = function(plr)
	local data = cache.espCache[plr]
	if not data or not data.highlight then return end
	if state.teamCheck and fn.sameTeam(lp, plr) then
		data.highlight.FillColor = cache.teamColor
		data.highlight.OutlineColor = cache.teamColor
	else
		data.highlight.FillColor = cache.enemyColor
		data.highlight.OutlineColor = cache.enemyColor
	end
end

fn.buildESP = function(plr)
	if plr == lp then return end
	if cache.playerFlags[plr] and cache.playerFlags[plr].esp == false then
		fn.destroyESP(plr)
		return
	end

	local myChar = lp.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if myRoot then
		local tChar = plr.Character
		local tRoot = tChar and (tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Head"))
		if tRoot and (myRoot.Position - tRoot.Position).Magnitude > state.espRange then
			fn.destroyESP(plr)
			return
		end
	end

	local char = plr.Character
	if not char or not char:FindFirstChildOfClass("Humanoid") then return end

	local data = cache.espCache[plr]
	if data and data.highlight then
		if data.highlight.Adornee ~= char then
			data.highlight.Adornee = char
		end
		fn.paintESP(plr)
		return
	end

	local hl = Instance.new("Highlight")
	hl.Name = "94ESP"
	hl.FillTransparency = 0.5
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = char
	hl.Parent = ui.gui

	cache.espCache[plr] = { highlight = hl }
	fn.paintESP(plr)
end

fn.refreshESP = function()
	if state.unloaded then return end
	if not state.espEnabled then
		for plr in pairs(cache.espCache) do fn.destroyESP(plr) end
		return
	end
	for _, plr in ipairs(Players:GetPlayers()) do fn.buildESP(plr) end
end

fn.refreshESPColors = function()
	for plr in pairs(cache.espCache) do fn.paintESP(plr) end
end

fn.wirePlayerESP = function(plr)
	if plr == lp then return end
	plr.CharacterAdded:Connect(function()
		if state.espEnabled then
			task.defer(function() fn.buildESP(plr) end)
		end
	end)
	plr.CharacterRemoving:Connect(function()
		fn.destroyESP(plr)
	end)
end

for _, plr in ipairs(Players:GetPlayers()) do fn.wirePlayerESP(plr) end
Players.PlayerAdded:Connect(fn.wirePlayerESP)
Players.PlayerRemoving:Connect(function(plr) fn.destroyESP(plr) end)

fn.keep(RunService.Heartbeat:Connect(function()
	if state.unloaded or not state.espEnabled then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then fn.buildESP(plr) end
	end
end))

if state.espEnabled then task.defer(fn.refreshESP) end

-- ============================================================
-- TRACERS
-- ============================================================
cache.tracers = {}

fn.destroyTracer = function(plr)
	local line = cache.tracers[plr]
	if not line then return end
	pcall(function() line:Remove() end)
	cache.tracers[plr] = nil
end

fn.clearTracers = function()
	for plr in pairs(cache.tracers) do
		fn.destroyTracer(plr)
	end
end

fn.refreshTracers = function()
	if state.unloaded then return end
	if not (state.espEnabled and state.espTracers) then
		fn.clearTracers()
		return
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then fn.buildTracer(plr) end
	end
end

fn.buildTracer = function(plr)
	if plr == lp then return end
	if not (state.espEnabled and state.espTracers) then
		fn.destroyTracer(plr)
		return
	end
	if state.teamCheck and fn.sameTeam(lp, plr) then
		fn.destroyTracer(plr)
		return
	end
	if cache.playerFlags[plr] and cache.playerFlags[plr].esp == false then
		fn.destroyTracer(plr)
		return
	end

	local char = plr.Character
	if not char then
		fn.destroyTracer(plr)
		return
	end
	local targetPart = char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("Head")
		or char:FindFirstChildWhichIsA("BasePart")
	if not targetPart then
		fn.destroyTracer(plr)
		return
	end

	local line = cache.tracers[plr]
	if not line then
		line = Drawing.new("Line")
		line.Thickness = 1
		line.Transparency = 1
		line.Visible = false
		cache.tracers[plr] = line
	end

	line.Color = cache.enemyColor
	line.Visible = true
end

fn.updateTracers = function()
	if state.unloaded then return end
	if not (state.espEnabled and state.espTracers) then
		for plr, line in pairs(cache.tracers) do
			if line then line.Visible = false end
		end
		return
	end

	local vp = camera.ViewportSize
	local startX = vp.X / 2
	local startY = vp.Y

	for _, plr in ipairs(Players:GetPlayers()) do
		local line = cache.tracers[plr]
		if not line then
			if plr ~= lp then
				fn.buildTracer(plr)
				line = cache.tracers[plr]
			end
		end

		if line then
			local skip = false
			if plr == lp then skip = true end
			if state.teamCheck and fn.sameTeam(lp, plr) then skip = true end
			if cache.playerFlags[plr] and cache.playerFlags[plr].esp == false then skip = true end

			local myCharX = lp.Character
			local myRootX = myCharX and myCharX:FindFirstChild("HumanoidRootPart")
			if myRootX then
				local tCharX = plr.Character
				local tRootX = tCharX and (tCharX:FindFirstChild("HumanoidRootPart") or tCharX:FindFirstChild("Head"))
				if tRootX and (myRootX.Position - tRootX.Position).Magnitude > state.espRange then
					skip = true
				end
			end

			local char = plr.Character
			local targetPart = char and (char:FindFirstChild("HumanoidRootPart")
				or char:FindFirstChild("Head")
				or char:FindFirstChildWhichIsA("BasePart"))
			if not targetPart then skip = true end

			if skip then
				line.Visible = false
			else
				local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
				if onScreen then
					line.From = Vector2.new(startX, startY)
					line.To = Vector2.new(screenPos.X, screenPos.Y)
					if state.teamCheck and fn.sameTeam(lp, plr) then
						line.Color = cache.teamColor
					else
						line.Color = cache.enemyColor
					end
					line.Visible = true
				else
					line.Visible = false
				end
			end
		end
	end

	for plr, line in pairs(cache.tracers) do
		if not plr.Parent then
			if line then pcall(function() line:Remove() end) end
			cache.tracers[plr] = nil
		end
	end
end

fn.keep(RunService.RenderStepped:Connect(fn.updateTracers))

-- ============================================================
-- ESP HEALTH BARS
-- ============================================================
cache.healthBars = {}

fn.destroyHealthBar = function(plr)
	local bar = cache.healthBars[plr]
	if not bar then return end
	if bar.bgRed then pcall(function() bar.bgRed:Remove() end) end
	if bar.fill then pcall(function() bar.fill:Remove() end) end
	cache.healthBars[plr] = nil
end

fn.clearHealthBars = function()
	for plr in pairs(cache.healthBars) do fn.destroyHealthBar(plr) end
end

fn.refreshHealthBars = function()
	if state.unloaded then return end
	if not (state.espEnabled and state.espHealthBar) then
		fn.clearHealthBars()
	end
end

fn.updateHealthBars = function()
	if state.unloaded then return end
	if not (state.espEnabled and state.espHealthBar) then
		for plr, bar in pairs(cache.healthBars) do
			if bar.fill then bar.fill.Visible = false end
			if bar.bgRed then bar.bgRed.Visible = false end
		end
		return
	end

	local myChar = lp.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for _, plr in ipairs(Players:GetPlayers()) do
		local entry = cache.healthBars[plr]
		local skip = false
		if plr == lp then skip = true end
		if state.teamCheck and fn.sameTeam(lp, plr) then skip = true end
		if cache.playerFlags[plr] and cache.playerFlags[plr].esp == false then skip = true end

		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
		if not (hum and root) then skip = true end

		if not skip and myRoot and root then
			if (myRoot.Position - root.Position).Magnitude > state.espRange then
				skip = true
			end
		end

		if skip then
			if entry then
				if entry.fill then entry.fill.Visible = false end
				if entry.bgRed then entry.bgRed.Visible = false end
			end
		else
			if not entry then
				entry = {}
				entry.bgRed = Drawing.new("Line")
				entry.bgRed.Thickness = 3
				entry.bgRed.Color = Color3.fromRGB(180, 40, 40)
				entry.bgRed.Transparency = 1
				entry.bgRed.Visible = false
				entry.fill = Drawing.new("Line")
				entry.fill.Thickness = 3
				entry.fill.Color = Color3.fromRGB(40, 220, 40)
				entry.fill.Transparency = 1
				entry.fill.Visible = false
				cache.healthBars[plr] = entry
			end

			local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
			if onScreen then
				local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
				local barHeight = 26
				local barX = screenPos.X - 28
				local yTop = screenPos.Y - barHeight / 2
				local yBottom = yTop + barHeight
				local ySplit = yBottom - barHeight * pct

				entry.bgRed.From = Vector2.new(barX, yTop)
				entry.bgRed.To = Vector2.new(barX, yBottom)
				entry.bgRed.Visible = true

				if pct > 0 then
					entry.fill.From = Vector2.new(barX, ySplit)
					entry.fill.To = Vector2.new(barX, yBottom)
					entry.fill.Visible = true
				else
					entry.fill.Visible = false
				end
			else
				if entry.fill then entry.fill.Visible = false end
				if entry.bgRed then entry.bgRed.Visible = false end
			end
		end
	end

	for plr in pairs(cache.healthBars) do
		if not plr.Parent then fn.destroyHealthBar(plr) end
	end
end

fn.keep(RunService.RenderStepped:Connect(fn.updateHealthBars))

-- ============================================================
-- ENEMY HUD
-- ============================================================
ui.enemyHud = Instance.new("Frame")
ui.enemyHud.Size = UDim2.new(0, 140, 0, 400)
ui.enemyHud.Position = UDim2.new(1, -160, 0.5, -200)
ui.enemyHud.BackgroundTransparency = 1
ui.enemyHud.BorderSizePixel = 0
ui.enemyHud.Visible = false
ui.enemyHud.ZIndex = 50
ui.enemyHud.Parent = ui.gui

ui.enemyList = Instance.new("UIListLayout")
ui.enemyList.SortOrder = Enum.SortOrder.LayoutOrder
ui.enemyList.Padding = UDim.new(0, 6)
ui.enemyList.Parent = ui.enemyHud

cache.enemyCards = {}
cache.thumbCache = {}

fn.portraitFor = function(userId)
	if cache.thumbCache[userId] then return cache.thumbCache[userId] end
	local url = ""
	pcall(function()
		url = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	cache.thumbCache[userId] = url
	return url
end

fn.buildCard = function(plr)
	if cache.enemyCards[plr] then return cache.enemyCards[plr] end

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 60)
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.ZIndex = 51
	card.Parent = ui.enemyHud

	local hpBg = Instance.new("Frame")
	hpBg.Size = UDim2.new(0, 6, 1, 0)
	hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	hpBg.BorderSizePixel = 0
	hpBg.ZIndex = 52
	hpBg.Parent = card

	local hpFill = Instance.new("Frame")
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	hpFill.BorderSizePixel = 0
	hpFill.ZIndex = 53
	hpFill.Parent = hpBg

	local portrait = Instance.new("ImageLabel")
	portrait.Size = UDim2.new(0, 50, 0, 50)
	portrait.Position = UDim2.new(0, 10, 0, 0)
	portrait.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	portrait.BorderSizePixel = 0
	portrait.Image = fn.portraitFor(plr.UserId)
	portrait.ZIndex = 52
	portrait.Parent = card

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1, -65, 0, 14)
	nameLbl.Position = UDim2.new(0, 64, 0, 36)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = plr.Name
	nameLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
	nameLbl.TextSize = 11
	nameLbl.Font = FONT_B
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.ZIndex = 52
	nameLbl.Parent = card

	local hpText = Instance.new("TextLabel")
	hpText.Size = UDim2.new(1, -65, 0, 12)
	hpText.Position = UDim2.new(0, 64, 0, 22)
	hpText.BackgroundTransparency = 1
	hpText.Text = "100"
	hpText.TextColor3 = Color3.fromRGB(200, 200, 200)
	hpText.TextSize = 10
	hpText.Font = FONT
	hpText.TextXAlignment = Enum.TextXAlignment.Left
	hpText.ZIndex = 52
	hpText.Parent = card

	cache.enemyCards[plr] = { card = card, hpFill = hpFill, hpText = hpText, portrait = portrait }
	return cache.enemyCards[plr]
end

fn.dropCard = function(plr)
	local entry = cache.enemyCards[plr]
	if not entry then return end
	entry.card:Destroy()
	cache.enemyCards[plr] = nil
end

fn.tickEnemyHud = function()
	if state.unloaded then return end

	local pg = lp:FindFirstChild("PlayerGui")
	local inMatch = pg and pg:FindFirstChild("DuelsBoardGui") ~= nil

	if not state.enemyHudEnabled or not inMatch then
		ui.enemyHud.Visible = false
		for plr in pairs(cache.enemyCards) do fn.dropCard(plr) end
		return
	end

	local myChar = lp.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then
			local char = plr.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					if not (state.teamCheck and fn.sameTeam(lp, plr)) then
						local include = true
						if myRoot then
							local tRoot = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
							if tRoot and (myRoot.Position - tRoot.Position).Magnitude > state.enemyHudRange then
								include = false
							end
						end
						if include then table.insert(list, plr) end
					end
				end
			end
		end
	end

	for plr in pairs(cache.enemyCards) do
		local present = false
		for _, e in ipairs(list) do
			if e == plr then present = true break end
		end
		if not present then fn.dropCard(plr) end
	end

	for i, plr in ipairs(list) do
		local entry = fn.buildCard(plr)
		entry.card.LayoutOrder = i
		entry.card.Visible = true

		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
			entry.hpFill.Size = UDim2.new(1, 0, pct, 0)
			entry.hpFill.Position = UDim2.new(0, 0, 1 - pct, 0)
			entry.hpFill.BackgroundColor3 = Color3.fromRGB(
				math.floor(255 * (1 - pct)),
				math.floor(200 * pct),
				0
			)
			entry.hpText.Text = string.format("%d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
		end

		if entry.portrait.Image == "" then
			entry.portrait.Image = fn.portraitFor(plr.UserId)
		end
	end

	ui.enemyHud.Visible = true
end

task.spawn(function()
	while not state.unloaded do
		pcall(fn.tickEnemyHud)
		task.wait(0.1)
	end
end)

Players.PlayerRemoving:Connect(fn.dropCard)

-- ============================================================
-- AIMBOT
-- ============================================================
cache.aimHeld = false
cache.aimTarget = nil
cache.aimSeed = 0
cache.aimLocked = nil

fn.isAimInput = function(input)
	if state.aimKeyIsMouse then
		return input.UserInputType == state.aimKey
	end
	return input.KeyCode == state.aimKey
end

cache.npcCache = {}
cache.npcCacheAt = 0

fn.refreshNpcCache = function()
	local now = tick()
	if now - cache.npcCacheAt < 1 then return end
	cache.npcCacheAt = now
	cache.npcCache = {}
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
			if Players:GetPlayerFromCharacter(obj) == nil and obj ~= lp.Character then
				table.insert(cache.npcCache, obj)
			end
		elseif obj:IsA("Folder") then
			for _, sub in ipairs(obj:GetChildren()) do
				if sub:IsA("Model") and sub:FindFirstChildOfClass("Humanoid") then
					if Players:GetPlayerFromCharacter(sub) == nil and sub ~= lp.Character then
						table.insert(cache.npcCache, sub)
					end
				end
			end
		end
	end
end

fn.collectAimTargets = function()
	local out = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then
			local flags = cache.playerFlags[plr]
			if not flags or flags.aimbot ~= false then
				local char = plr.Character
				if char and char:FindFirstChildOfClass("Humanoid") then
					if not (state.aimTeamCheck and fn.sameTeam(lp, plr)) then
						table.insert(out, { char = char, plr = plr })
					end
				end
			end
		end
	end

	fn.refreshNpcCache()
	for _, char in ipairs(cache.npcCache) do
		if char.Parent then
			table.insert(out, { char = char, plr = nil })
		end
	end

	return out
end

fn.aimPointFor = function(char)
	if state.aimPart == "Torso" then
		local upper = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
		if upper then return upper end
		local head = char:FindFirstChild("Head")
		if head then return head end
	else
		local head = char:FindFirstChild("Head")
		if head then return head end
	end

	local root = char:FindFirstChild("HumanoidRootPart")
	if root then return root end
	for _, obj in ipairs(char:GetChildren()) do
		if obj:IsA("BasePart") then return obj end
	end
	return nil
end

fn.bestAimTarget = function()
	if cache.aimLocked then
		local char = cache.aimLocked.char
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 and char.Parent then
			local part = fn.aimPointFor(char)
			if part then
				local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen then
					return {
						char = char,
						plr = cache.aimLocked.plr,
						part = part,
						pos = part.Position,
						screenX = screenPos.X,
						screenY = screenPos.Y,
					}
				end
			end
		end
		cache.aimLocked = nil
	end

	local best, bestScore = nil, math.huge
	local myChar = lp.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for _, entry in ipairs(fn.collectAimTargets()) do
		local char = entry.char
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			local part = fn.aimPointFor(char)
			if part then
				local dist = 0
				if myRoot then dist = (part.Position - myRoot.Position).Magnitude end
				if dist <= state.aimMaxDist then
					local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local mousePos = UserInputService:GetMouseLocation()
						local dx = screenPos.X - mousePos.X
						local dy = screenPos.Y - mousePos.Y
						local screenDist = math.sqrt(dx * dx + dy * dy)

						if screenDist <= state.aimFOV then
							local visible = true
							if state.aimVisibleOnly then
								local origin = camera.CFrame.Position
								local dir = (part.Position - origin).Unit
								local rp = RaycastParams.new()
								rp.FilterType = Enum.RaycastFilterType.Exclude
								rp.FilterDescendantsInstances = { lp.Character, char, ui.gui }
								rp.IgnoreWater = true
								local hit = workspace:Raycast(origin, dir * dist, rp)
								if hit then
									local hitPart = hit.Instance
									local hitPos = hit.Position
									local close = (hitPos - part.Position).Magnitude < 5
									if hitPart ~= part
										and not hitPart:IsDescendantOf(char)
										and not close then
										visible = false
									end
								end
							end

							if visible and screenDist < bestScore then
								bestScore = screenDist
								best = {
									char = char,
									plr = entry.plr,
									part = part,
									pos = part.Position,
									screenX = screenPos.X,
									screenY = screenPos.Y,
								}
							end
						end
					end
				end
			end
		end
	end

	if best then
		cache.aimLocked = { char = best.char, plr = best.plr }
	end

	return best
end

fn.humanize = function()
	cache.aimSeed = cache.aimSeed + 0.05
	local amp = state.aimHumanize
	return math.sin(cache.aimSeed * 1.7) * amp,
	       math.cos(cache.aimSeed * 2.3) * amp
end

local AIM_BIND = "94AimbotStep"

fn.aimStep = function()
	if state.unloaded then return end
	if not state.aimEnabled then cache.aimTarget = nil cache.aimLocked = nil return end
	local pg = lp:FindFirstChild("PlayerGui")
	if not (pg and pg:FindFirstChild("DuelsBoardGui")) then cache.aimTarget = nil cache.aimLocked = nil return end
	if not cache.aimHeld then
		cache.aimTarget = nil
		cache.aimLocked = nil
		return
	end

	local target = fn.bestAimTarget()
	cache.aimTarget = target
	if not target then return end

	local mousePos = UserInputService:GetMouseLocation()
	local dx = target.screenX - mousePos.X
	local dy = target.screenY - mousePos.Y
	local jx, jy = fn.humanize()
	dx = dx + jx
	dy = dy + jy

	local smoothFactor
	if state.aimSmoothCurve then
		local dist = math.sqrt(dx * dx + dy * dy)
		local normalized = math.clamp(dist / math.max(state.aimFOV, 1), 0, 1)
		smoothFactor = state.aimSmoothing * (0.4 + 0.6 * math.sin(normalized * math.pi))
	else
		smoothFactor = state.aimSmoothing
	end

	local mx = dx * smoothFactor * state.aimStrength
	local my = dy * smoothFactor * state.aimStrength
	if math.abs(mx) < 0.05 and math.abs(my) < 0.05 then return end
	pcall(function() mousemoverel(mx, my) end)
end

pcall(function() RunService:UnbindFromRenderStep(AIM_BIND) end)
RunService:BindToRenderStep(AIM_BIND, Enum.RenderPriority.Camera.Value + 1, fn.aimStep)

-- ============================================================
-- RAGEBOT
-- ============================================================
cache.rageTarget = nil
cache.orbitAngle = 0
cache.rageConn = nil

fn.findRageTarget = function()
	local myChar = lp.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local best, bestDist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then
			if not (state.teamCheck and fn.sameTeam(lp, plr)) then
				local char = plr.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					local head = char:FindFirstChild("Head")
					if hum and hum.Health > 0 and head then
						local d = (head.Position - myRoot.Position).Magnitude
						if d <= state.ragebotMaxDist and d < bestDist then
							bestDist = d
							best = char
						end
					end
				end
			end
		end
	end
	return best
end

fn.resetRageCamera = function()
	cache.rageTarget = nil
	cache.orbitAngle = 0
	pcall(function()
		camera.CameraType = Enum.CameraType.Custom
		local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if hum then camera.CameraSubject = hum end
	end)
end

fn.rageStep = function(dt)
	if state.unloaded then return end
	if not state.ragebotEnabled then cache.rageTarget = nil return end
	local pg = lp:FindFirstChild("PlayerGui")
	if not (pg and pg:FindFirstChild("DuelsBoardGui")) then cache.rageTarget = nil return end

	local target = fn.findRageTarget()
	cache.rageTarget = target
	if not target then return end

	local head = target:FindFirstChild("Head")
	if not head then return end

	local myChar = lp.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local headPos = head.Position
	local dist = math.clamp(state.orbitDistance, 1, 20)

	if state.ragebotMode == "Orbit" then
		cache.orbitAngle = (cache.orbitAngle + dt * state.orbitSpeed * 2) % (math.pi * 2)
		local offset = Vector3.new(math.cos(cache.orbitAngle) * dist, 0, math.sin(cache.orbitAngle) * dist)
		local desired = headPos + offset
		myRoot.CFrame = CFrame.lookAt(desired, Vector3.new(headPos.X, desired.Y, headPos.Z))
		myRoot.Velocity = Vector3.new(0, 0, 0)

		local camPos = desired + Vector3.new(0, 2, 0)
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.lookAt(camPos, headPos)

		local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
		if onScreen then
			local vp = camera.ViewportSize
			local deltaX = screenPos.X - vp.X / 2
			local deltaY = screenPos.Y - vp.Y / 2
			pcall(function() mousemoverel(deltaX, deltaY) end)
		end

	elseif state.ragebotMode == "Behind" then
		local targetCFrame = target:GetPivot()
		local behindDir = targetCFrame.LookVector
		local desired = headPos - behindDir * dist
		desired = Vector3.new(desired.X, headPos.Y, desired.Z)
		myRoot.CFrame = CFrame.lookAt(desired, Vector3.new(headPos.X, desired.Y, headPos.Z))
		myRoot.Velocity = Vector3.new(0, 0, 0)

		local camPos = desired + Vector3.new(0, 2, 0)
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.lookAt(camPos, headPos)

		local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
		if onScreen then
			local vp = camera.ViewportSize
			local deltaX = screenPos.X - vp.X / 2
			local deltaY = screenPos.Y - vp.Y / 2
			pcall(function() mousemoverel(deltaX, deltaY) end)
		end

	else -- "Above"
		local desired = Vector3.new(headPos.X, headPos.Y + dist, headPos.Z)
		myRoot.CFrame = CFrame.lookAt(desired, Vector3.new(headPos.X, desired.Y - dist, headPos.Z))
		myRoot.Velocity = Vector3.new(0, 0, 0)

		local camPos = desired + Vector3.new(0, 2, 0)
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.lookAt(camPos, headPos)

		local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
		if onScreen then
			local vp = camera.ViewportSize
			local deltaX = screenPos.X - vp.X / 2
			local deltaY = screenPos.Y - vp.Y / 2
			pcall(function() mousemoverel(deltaX, deltaY) end)
		end
	end
end

local RAGE_BIND = "94RageStep"
pcall(function() RunService:UnbindFromRenderStep(RAGE_BIND) end)
RunService:BindToRenderStep(RAGE_BIND, Enum.RenderPriority.Camera.Value + 2, fn.rageStep)

-- ============================================================
-- FLY / WALK / NOCLIP
-- ============================================================
cache.walkConn = nil
cache.walkHumanoid = nil
cache.walkGuard = nil

fn.applyWalkSpeed = function()
	local char = lp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if cache.walkHumanoid ~= hum then
		if cache.walkGuard then cache.walkGuard:Disconnect() cache.walkGuard = nil end
		cache.walkHumanoid = hum
		cache.walkGuard = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if state.unloaded then return end
			if state.walkEnabled and hum.WalkSpeed ~= state.walkSpeed then
				hum.WalkSpeed = state.walkSpeed
			elseif not state.walkEnabled and hum.WalkSpeed ~= 16 then
				hum.WalkSpeed = 16
			end
		end)
	end

	if state.walkEnabled then
		if hum.WalkSpeed ~= state.walkSpeed then
			hum.WalkSpeed = state.walkSpeed
		end
	else
		if hum.WalkSpeed ~= 16 then
			hum.WalkSpeed = 16
		end
	end
end

fn.keep(RunService.RenderStepped:Connect(function()
	if state.unloaded then return end
	fn.applyWalkSpeed()
end))

fn.flyStep = function(dt)
	if state.unloaded then return end
	fn.applyWalkSpeed()

	if not state.flyEnabled then return end

	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local move = Vector3.new(0, 0, 0)
	local cf = camera.CFrame

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end

	if move.Magnitude > 0 then
		hrp.Velocity = move.Unit * state.flySpeed
	else
		hrp.Velocity = Vector3.new(0, 0, 0)
	end
end

fn.keep(RunService.RenderStepped:Connect(fn.flyStep))

cache.noclipSnapshot = {}
cache.noclipRestoreUntil = 0

fn.applyNoclip = function()
	local char = lp.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false) end
end

fn.restoreCollision = function()
	local char = lp.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Name == "HumanoidRootPart" then
				part.CanCollide = false
			else
				part.CanCollide = true
			end
		end
	end
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true) end
end

fn.disableNoclip = function()
	fn.restoreCollision()
	cache.noclipRestoreUntil = tick() + 0.5
end

fn.keep(RunService.Stepped:Connect(function()
	if state.unloaded then return end
	if state.noclipEnabled then
		fn.applyNoclip()
	elseif tick() < cache.noclipRestoreUntil then
		fn.restoreCollision()
	end
end))

lp.CharacterAdded:Connect(function()
	cache.noclipSnapshot = {}
	cache.noclipRestoreUntil = 0
	task.wait(0.5)
	if state.noclipEnabled then fn.applyNoclip() end
	if state.walkEnabled then fn.applyWalkSpeed() end
end)

-- ============================================================
-- THIRD PERSON / FREE CAM
-- ============================================================
fn.updateThirdPersonCamera = function()
	if state.unloaded then return end
	if not state.thirdPerson then return end
	if state.freeCamEnabled then return end
	if state.ragebotEnabled then return end
	if cache.aimHeld and state.aimEnabled then return end

	local char = lp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local head = char and char:FindFirstChild("Head")
	if not (char and hum and head) then return end

	if camera.CameraType ~= Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Scriptable
	end

	local lookDir = camera.CFrame.LookVector
	local offset = Vector3.new(0, 1.5, 0) - lookDir * 6
	local focusPos = head.Position + offset
	camera.CFrame = CFrame.lookAt(focusPos, focusPos + lookDir)
	camera.Focus = CFrame.new(head.Position)
end

fn.keep(RunService.RenderStepped:Connect(fn.updateThirdPersonCamera))

cache.freeCamPos = nil
cache.freeCamYaw = 0
cache.freeCamPitch = 0

fn.updateFreeCam = function(dt)
	if state.unloaded then return end

	if not state.freeCamEnabled then
		cache.freeCamPos = nil
		return
	end

	if not cache.freeCamPos then
		cache.freeCamPos = camera.CFrame.Position
		local lv = camera.CFrame.LookVector
		cache.freeCamYaw = math.atan2(-lv.X, -lv.Z)
		cache.freeCamPitch = math.asin(lv.Y)
	end

	local md = UserInputService:GetMouseDelta()
	local sens = 0.003
	cache.freeCamYaw = cache.freeCamYaw - md.X * sens
	cache.freeCamPitch = math.clamp(cache.freeCamPitch - md.Y * sens, -math.rad(89), math.rad(89))

	local rot = CFrame.fromEulerAnglesYXZ(cache.freeCamPitch, cache.freeCamYaw, 0)
	local look = rot.LookVector
	local right = rot.RightVector

	local move = Vector3.new(0, 0, 0)
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + look end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - look end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end

	if move.Magnitude > 0 then
		cache.freeCamPos = cache.freeCamPos + move.Unit * 60 * dt
	end

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.new(cache.freeCamPos) * rot
end

fn.keep(RunService.RenderStepped:Connect(fn.updateFreeCam))

-- ============================================================
-- VISUAL TOGGLE
-- ============================================================
cache.visualsHidden = false
cache.visualSnapshot = nil

fn.setVisualsHidden = function(hide)
	if hide then
		cache.visualSnapshot = {
			espEnabled      = state.espEnabled,
			espTracers      = state.espTracers,
			espHealthBar    = state.espHealthBar,
			enemyHudEnabled = state.enemyHudEnabled,
			fovCircleState  = state.fovCircleState,
			watermarkEnabled = state.watermarkEnabled,
		}
		state.espEnabled      = false
		state.espTracers      = false
		state.espHealthBar    = false
		state.enemyHudEnabled = false
		state.fovCircleState  = false
		state.watermarkEnabled = false

		if fn.refreshESP then fn.refreshESP() end
		if fn.refreshTracers then fn.refreshTracers() end
		if fn.refreshHealthBars then fn.refreshHealthBars() end
		if fn.setDebugVisible then fn.setDebugVisible(false) end
		if ui.fovCircle then ui.fovCircle.Visible = false end
		if ui.watermark then ui.watermark.Visible = false end
		if ui.enemyHud then ui.enemyHud.Visible = false end
		if cache.enemyCards then
			for plr in pairs(cache.enemyCards) do
				if fn.dropCard then fn.dropCard(plr) end
			end
		end
		cache.visualsHidden = true
	else
		local snap = cache.visualSnapshot
		if snap then
			state.espEnabled      = snap.espEnabled
			state.espTracers      = snap.espTracers
			state.espHealthBar    = snap.espHealthBar
			state.enemyHudEnabled = snap.enemyHudEnabled
			state.fovCircleState  = snap.fovCircleState
			state.watermarkEnabled = snap.watermarkEnabled
		end

		if fn.refreshESP then fn.refreshESP() end
		if fn.refreshTracers then fn.refreshTracers() end
		if fn.refreshHealthBars then fn.refreshHealthBars() end
		if fn.setDebugVisible then fn.setDebugVisible(cache.debugOn) end
		if ui.fovCircle then ui.fovCircle.Visible = state.fovCircleState end
		if ui.watermark then ui.watermark.Visible = state.watermarkEnabled end
		cache.visualsHidden = false
		cache.visualSnapshot = nil
	end

	if fn.refreshAll then fn.refreshAll() end
	if fn.notify then
		fn.notify(hide and "visuals hidden" or "visuals restored",
			hide and Color3.fromRGB(255, 180, 0) or Color3.fromRGB(50, 210, 90))
	end
end

-- ============================================================
-- UNLOAD
-- ============================================================
fn.fullUnload = function()
	if state.unloaded then return end
	state.unloaded = true
	state.espEnabled = false
	state.triggerEnabled = false
	state.aimEnabled = false
	state.freeCamEnabled = false
	state.ragebotEnabled = false
	state.flyEnabled = false
	state.noclipEnabled = false
	fn.disableNoclip()
	pcall(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = true
	end)
	fn.save()
	for plr in pairs(cache.espCache) do fn.destroyESP(plr) end
	for plr in pairs(cache.enemyCards) do fn.dropCard(plr) end
	fn.clearTracers()
	fn.clearHealthBars()
	fn.dropAll()
	pcall(function() RunService:UnbindFromRenderStep(AIM_BIND) end)
	pcall(function() RunService:UnbindFromRenderStep(RAGE_BIND) end)
	pcall(function() ui.gui:Destroy() end)
	pcall(function() ui.gui.Parent = nil end)
end

-- ============================================================
-- INPUT
-- ============================================================
cache.panicStack = {}
cache.rmbDownAt = nil
cache.binding = false

UserInputService.InputBegan:Connect(function(input, processed)
	if state.unloaded then return end
	if cache.binding then return end
	if ui.nameBox and ui.nameBox:IsFocused() then return end
	if cache.searchOpen and ui.searchBox and ui.searchBox:IsFocused() then return end

	local isMouseAim = state.aimKeyIsMouse and (input.UserInputType == state.aimKey)
	if processed and not isMouseAim then return end

	if fn.isAimInput(input) then
		cache.aimHeld = true
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		cache.rmbDownAt = tick()
	end

	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Escape and cache.searchOpen then
			fn.closeSearch()
			return
		end

		if input.KeyCode == state.menuKey or input.KeyCode == Enum.KeyCode.RightShift then
			fn.setMenuOpen(not state.menuOpen)
		end

		if input.KeyCode == state.visualToggleKey then
			fn.setVisualsHidden(not cache.visualsHidden)
		end

		if input.KeyCode == state.panicKey then
			local now = tick()
			local fresh = {}
			for _, t in ipairs(cache.panicStack) do
				if now - t < 0.5 then table.insert(fresh, t) end
			end
			table.insert(fresh, now)
			cache.panicStack = fresh
			if #cache.panicStack >= 3 then
				cache.panicStack = {}
				fn.fullUnload()
				return
			end
		end

		if input.KeyCode == state.triggerKey then
			state.triggerEnabled = not state.triggerEnabled
			fn.refreshAll()
			fn.save()
			if fn.notify then fn.notify(state.triggerEnabled and "triggerbot enabled" or "triggerbot disabled", state.triggerEnabled and Color3.fromRGB(50, 210, 90) or Color3.fromRGB(255, 80, 80)) end
		end

		if input.KeyCode == state.espKey then
			state.espEnabled = not state.espEnabled
			fn.refreshAll()
			fn.refreshESP()
			fn.refreshTracers()
			fn.refreshHealthBars()
			fn.save()
			if fn.notify then fn.notify(state.espEnabled and "esp enabled" or "esp disabled", state.espEnabled and Color3.fromRGB(50, 210, 90) or Color3.fromRGB(255, 80, 80)) end
		end

		if input.KeyCode == state.aimToggleKey then
			state.aimEnabled = not state.aimEnabled
			fn.refreshAll()
			fn.save()
			if fn.notify then fn.notify(state.aimEnabled and "aimbot enabled" or "aimbot disabled", state.aimEnabled and Color3.fromRGB(50, 210, 90) or Color3.fromRGB(255, 80, 80)) end
		end

		if input.KeyCode == state.freeCamKey then
			state.freeCamEnabled = not state.freeCamEnabled
			if not state.freeCamEnabled then
				pcall(function()
					camera.CameraType = Enum.CameraType.Custom
					local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
					if hum then camera.CameraSubject = hum end
				end)
			end
		end

		if input.KeyCode == state.ragebotKey then
			state.ragebotEnabled = not state.ragebotEnabled
			fn.refreshAll()
			if not state.ragebotEnabled then fn.resetRageCamera() end
			fn.save()
			if fn.notify then fn.notify(state.ragebotEnabled and "ragebot enabled" or "ragebot disabled", state.ragebotEnabled and Color3.fromRGB(50, 210, 90) or Color3.fromRGB(255, 80, 80)) end
		end

		if input.KeyCode == state.flyKey then
			state.flyEnabled = not state.flyEnabled
			fn.refreshAll()
			fn.save()
			if fn.notify then fn.notify(state.flyEnabled and "fly enabled" or "fly disabled", state.flyEnabled and Color3.fromRGB(50, 210, 90) or Color3.fromRGB(255, 80, 80)) end
		end

		if input.KeyCode == state.noclipKey then
			state.noclipEnabled = not state.noclipEnabled
			if state.noclipEnabled then fn.applyNoclip() else fn.disableNoclip() end
			fn.refreshAll()
			fn.save()
			if fn.notify then fn.notify(state.noclipEnabled and "noclip enabled" or "noclip disabled", state.noclipEnabled and Color3.fromRGB(50, 210, 90) or Color3.fromRGB(255, 80, 80)) end
		end

		fn.refreshHotkeys()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if fn.isAimInput(input) then cache.aimHeld = false end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then cache.rmbDownAt = nil end
end)

cache.unloadArmed = false
cache.unloadDeadline = 0
cache.unloadConn = nil

ui.unloadBtn.MouseButton1Click:Connect(function()
	if not cache.unloadArmed then
		cache.unloadArmed = true
		cache.unloadDeadline = tick() + 1
		ui.unloadBtn.Text = "unload (1.0s)"
		cache.unloadConn = RunService.Heartbeat:Connect(function()
			if not cache.unloadArmed then
				cache.unloadConn:Disconnect()
				cache.unloadConn = nil
				return
			end
			local remaining = cache.unloadDeadline - tick()
			if remaining <= 0 then
				cache.unloadArmed = false
				ui.unloadBtn.Text = "unload"
				cache.unloadConn:Disconnect()
				cache.unloadConn = nil
			else
				ui.unloadBtn.Text = string.format("unload (%.1fs)", remaining)
			end
		end)
	else
		cache.unloadArmed = false
		fn.fullUnload()
	end
end)

-- ============================================================
-- TRIGGERBOT
-- ============================================================
cache.lastFire = 0
cache.nextFire = 0
cache.acquiredAt = nil

cache.torsoNames = {
	torso = true, uppertorso = true, lowertorso = true,
	body = true, chest = true, waist = true, hips = true,
}

fn.partMatches = function(hit, character, requested)
	if requested == "Any" then return true end
	if not character then return false end

	local function desc(hitPart, root)
		local cur = hitPart
		while cur and cur ~= character do
			if cur == root then return true end
			cur = cur.Parent
		end
		return false
	end

	if requested == "Head" then
		local head = character:FindFirstChild("Head")
		if head and desc(hit, head) then return true end
		if hit.Name:lower():find("head") then return true end
		return false
	end

	if requested == "Torso" then
		for _, name in ipairs({"Torso", "UpperTorso", "LowerTorso", "Body", "Chest", "Waist", "Hips"}) do
			local part = character:FindFirstChild(name)
			if part and desc(hit, part) then return true end
		end
		local n = hit.Name:lower()
		if cache.torsoNames[n] then return true end
		if n:find("torso") or n:find("body") or n:find("chest") then return true end
		return false
	end

	return true
end

fn.triggerTarget = function()
	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = { lp.Character, ui.gui }
	rp.IgnoreWater = true

	local hit = workspace:Raycast(ray.Origin, ray.Direction * state.triggerDistance, rp)
	if not hit then return nil end

	local hp = hit.Position
	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and (hp - hrp.Position).Magnitude < 5 then return nil end

	local model = hit.Instance
	while model and model ~= workspace do
		local hum = model:FindFirstChildOfClass("Humanoid")
		if hum then
			if hum.Health <= 0 then return nil end
			local plr = Players:GetPlayerFromCharacter(model)
			if plr and cache.playerFlags[plr] and cache.playerFlags[plr].triggerbot == false then
				return nil
			end
			if fn.partMatches(hit.Instance, model, state.targetPart) then
				return model, plr
			end
			return nil
		end
		model = model.Parent
	end
	return nil
end

task.spawn(function()
	while not state.unloaded do
		local pg = lp:FindFirstChild("PlayerGui")
		local inMatch = pg and pg:FindFirstChild("DuelsBoardGui") ~= nil

		if state.triggerEnabled and inMatch and not state.menuOpen then
			local ready = true
			if state.holdRightClick then
				ready = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
				if ready and state.rightClickDelay > 0 and cache.rmbDownAt then
					if tick() - cache.rmbDownAt < (state.rightClickDelay / 1000) then
						ready = false
					end
				end
			end

			if ready then
				local model, plr = fn.triggerTarget()
				local valid = model ~= nil and model ~= lp.Character
				if valid and state.teamCheck and plr and fn.sameTeam(lp, plr) then
					valid = false
				end

				local now = tick()
				if valid then
					if not cache.acquiredAt then cache.acquiredAt = now end
					local delay = state.triggerDelay / 1000
					if state.triggerJitter then
						delay = delay * (0.7 + math.random() * 0.6)
					end
					if now - cache.acquiredAt >= delay and now >= cache.nextFire then
						cache.nextFire = now + delay
						cache.lastFire = now
						pcall(function()
							mouse1press()
							task.wait(0.01)
							mouse1release()
						end)
					end
				else
					cache.acquiredAt = nil
					cache.nextFire = 0
				end
			else
				cache.acquiredAt = nil
				cache.nextFire = 0
			end
		else
			cache.acquiredAt = nil
			cache.nextFire = 0
		end
		task.wait(0.03)
	end
end)

-- ============================================================
-- STATUS + FPS + WATERMARK
-- ============================================================
cache.fps = 0
cache.fpsCount = 0
cache.fpsLast = tick()

fn.keep(RunService.RenderStepped:Connect(function()
	cache.fpsCount = cache.fpsCount + 1
	local now = tick()
	if now - cache.fpsLast >= 1 then
		cache.fps = cache.fpsCount
		cache.fpsCount = 0
		cache.fpsLast = now
	end

	if cache.fovCircleOn then
		local d = state.aimFOV * 2
		ui.fovCircle.Size = UDim2.new(0, d, 0, d)
	end
end))

task.spawn(function()
	while not state.unloaded do
		if state.watermarkEnabled then
			ui.watermark.Visible = true
			local ping = 0
			pcall(function()
				ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			ui.watermarkStats.Text = string.format("%d fps  |  %d ms", cache.fps, math.floor(ping))
		else
			if ui.watermark.Visible then
				ui.watermark.Visible = false
			end
		end
		task.wait(0.5)
	end
end)

task.spawn(function()
	while not state.unloaded do
		local pg = lp:FindFirstChild("PlayerGui")
		local inMatch = pg and pg:FindFirstChild("DuelsBoardGui") ~= nil

		cache.statusEsp.TextTransparency = state.espEnabled and 0 or 1
		cache.statusTrig.TextTransparency = (state.triggerEnabled and inMatch) and 0 or 1
		cache.statusAim.TextTransparency = state.aimEnabled and 0 or 1

		task.wait(0.1)
	end
end)

task.spawn(function()
	while not state.unloaded do
		if cache.debugOn and ui.info.Visible then
			local ping = 0
			pcall(function()
				ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			cache.dbg.fps.Text = string.format("fps: %d", cache.fps)
			cache.dbg.ping.Text = string.format("ping: %d ms", math.floor(ping))

			local pg = lp:FindFirstChild("PlayerGui")
			local inMatch = pg and pg:FindFirstChild("DuelsBoardGui") ~= nil
			cache.dbg.match.Text = inMatch and "in match: YES" or "in match: no"
			cache.dbg.match.TextColor3 = inMatch and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(180, 180, 180)

			local n = 0
			for _ in pairs(cache.enemyCards) do n = n + 1 end
			cache.dbg.enem.Text = string.format("enemies shown: %d", n)

			cache.dbg.aimbot.Text = state.aimEnabled and "aimbot: ON" or "aimbot: OFF"
			cache.dbg.aimbot.TextColor3 = state.aimEnabled and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(180, 180, 180)

			if cache.aimTarget then
				local nm = cache.aimTarget.plr and cache.aimTarget.plr.Name or "npc"
				cache.dbg.aimTgt.Text = "aim target: " .. nm
				cache.dbg.aimTgt.TextColor3 = Color3.fromRGB(0, 220, 0)
			else
				cache.dbg.aimTgt.Text = "aim target: none"
				cache.dbg.aimTgt.TextColor3 = Color3.fromRGB(180, 180, 180)
			end

			cache.dbg.rage.Text = state.ragebotEnabled and "ragebot: ON" or "ragebot: OFF"
			cache.dbg.rage.TextColor3 = state.ragebotEnabled and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(180, 180, 180)

			cache.dbg.fly.Text = state.flyEnabled and "fly: ON" or "fly: OFF"
			cache.dbg.fly.TextColor3 = state.flyEnabled and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(180, 180, 180)

			cache.dbg.noclip.Text = state.noclipEnabled and "noclip: ON" or "noclip: OFF"
			cache.dbg.noclip.TextColor3 = state.noclipEnabled and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(180, 180, 180)
		end
		task.wait(0.1)
	end
end)
