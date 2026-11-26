local BrineUI = {
	Window = nil,
	Theme = nil,
	Creator = require("./modules/Creator"),
	LocalizationModule = require("./modules/Localization"),
	NotificationModule = require("./components/Notification"),
	Themes = nil,
	Transparent = false,

	TransparencyValue = 0.15,

	UIScale = 1,

	ConfigManager = nil,
	Version = "0.0.0",
	UpstreamVersion = "1.6.66",

	Services = require("./utils/services/Init"),

	OnThemeChangeFunction = nil,

	cloneref = nil,
	UIScaleObj = nil,

	CreateWindow = nil,

	CurrentInput = nil,
}

-- Older integrations can still read the original version field.
BrineUI.WindUIVersion = BrineUI.UpstreamVersion

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

BrineUI.cloneref = cloneref

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

function BrineUI.GenerateGUID()
	return HttpService:GenerateGUID(false)
end

local CurInput = BrineUI.GenerateGUID()

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
	--[[if GameProcessed then
		return
	end]]

	task.defer(function()
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			if BrineUI.CurrentInput and BrineUI.CurrentInput ~= CurInput then
				return
			end

			BrineUI.CurrentInput = CurInput
			--print(CurInput)
			--BrineUI.InputStartedOnUI = false
		end
	end)
end)
UserInputService.InputEnded:Connect(function(Input, GameProcessed)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		if BrineUI.CurrentInput and BrineUI.CurrentInput ~= CurInput then
			return
		end

		BrineUI.CurrentInput = nil
	end
end)

local LocalPlayer = assert(Players.LocalPlayer, "BrineUI requires a Roblox client with a LocalPlayer")

local Package = HttpService:JSONDecode(require("../build/package"))
if Package then
	BrineUI.Version = Package.version
end

local KeySystem = require("./components/KeySystem")

local Creator = BrineUI.Creator

local New = Creator.New

--local Tween = Creator.Tween
--local ServicesModule = BrineUI.Services

local Acrylic = require("./utils/Acrylic/Init")

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

-- Ordinary LocalScripts cannot parent into CoreGui. gethui stays preferred
-- where supplied; the normal Roblox client uses its own PlayerGui.
local GUIParent = gethui and gethui() or LocalPlayer:WaitForChild("PlayerGui")

-- Draw above every other ScreenGui, including the Roblox menu when the
-- executor parents us into CoreGui (gethui). Layers inside Brine keep their
-- order: window, notifications, dropdowns, tooltips.
local TOP_ORDER = 2147483647
BrineUI.DisplayOrders = {
	Window = TOP_ORDER - 3,
	Notifications = TOP_ORDER - 2,
	Dropdowns = TOP_ORDER - 1,
	Tooltips = TOP_ORDER,
}

local UIScaleObj = New("UIScale", {
	Scale = BrineUI.UIScale,
})

BrineUI.UIScaleObj = UIScaleObj

BrineUI.ScreenGui = New("ScreenGui", {
	Name = "BrineUI",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	ScreenInsets = "None",
	DisplayOrder = BrineUI.DisplayOrders.Window,
}, {

	New("Folder", {
		Name = "Window",
	}),
	-- New("Folder", {
	--     Name = "Notifications"
	-- }),
	-- New("Folder", {
	--     Name = "Dropdowns"
	-- }),
	New("Folder", {
		Name = "KeySystem",
	}),
	New("Folder", {
		Name = "Popups",
	}),
	New("Folder", {
		Name = "ToolTips",
	}),
})

BrineUI.NotificationGui = New("ScreenGui", {
	Name = "BrineUI/Notifications",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	DisplayOrder = BrineUI.DisplayOrders.Notifications,
})
BrineUI.DropdownGui = New("ScreenGui", {
	Name = "BrineUI/Dropdowns",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	ScreenInsets = "None",
	DisplayOrder = BrineUI.DisplayOrders.Dropdowns,
})
BrineUI.TooltipGui = New("ScreenGui", {
	Name = "BrineUI/Tooltips",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	ScreenInsets = "None",
	DisplayOrder = BrineUI.DisplayOrders.Tooltips,
})
ProtectGui(BrineUI.ScreenGui)
ProtectGui(BrineUI.NotificationGui)
ProtectGui(BrineUI.DropdownGui)
ProtectGui(BrineUI.TooltipGui)

Creator.Init(BrineUI)

function BrineUI:SetParent(parent)
	if BrineUI.ScreenGui then
		BrineUI.ScreenGui.Parent = parent
	end
	if BrineUI.NotificationGui then
		BrineUI.NotificationGui.Parent = parent
	end
	if BrineUI.DropdownGui then
		BrineUI.DropdownGui.Parent = parent
	end
	if BrineUI.TooltipGui then
		BrineUI.TooltipGui.Parent = parent
	end
end
math.clamp(BrineUI.TransparencyValue, 0, 1)

local Holder = BrineUI.NotificationModule.Init(BrineUI.NotificationGui)

function BrineUI:Notify(Config)
	Config.Holder = Holder.Frame
	Config.Window = BrineUI.Window
	--Config.BrineUI = BrineUI
	return BrineUI.NotificationModule.New(Config)
end

function BrineUI:SetNotificationLower(Val)
	Holder.SetLower(Val)
end

function BrineUI:SetFont(FontId)
	Creator.UpdateFont(FontId)
end

function BrineUI:OnThemeChange(func)
	BrineUI.OnThemeChangeFunction = func
end

function BrineUI:AddTheme(LTheme)
	BrineUI.Themes[LTheme.Name] = LTheme
	return LTheme
end

function BrineUI:SetTheme(Value)
	if BrineUI.Themes[Value] then
		BrineUI.Theme = BrineUI.Themes[Value]
		Creator.SetTheme(BrineUI.Themes[Value])

		if BrineUI.OnThemeChangeFunction then
			BrineUI.OnThemeChangeFunction(Value)
		end

		return BrineUI.Themes[Value]
	end
	return nil
end

function BrineUI:GetThemes()
	return BrineUI.Themes
end
function BrineUI:GetCurrentTheme()
	return BrineUI.Theme.Name
end
function BrineUI:GetTransparency()
	return BrineUI.Transparent or false
end
function BrineUI:GetWindowSize()
	return BrineUI.Window.UIElements.Main.Size
end
function BrineUI:Localization(LocalizationConfig)
	return BrineUI.LocalizationModule:New(LocalizationConfig, Creator)
end

function BrineUI:SetLanguage(Value)
	if Creator.Localization then
		return Creator.SetLanguage(Value)
	end
	return false
end

function BrineUI:ToggleAcrylic(Value)
	if BrineUI.Window and BrineUI.Window.AcrylicPaint and BrineUI.Window.AcrylicPaint.Model then
		BrineUI.Window.Acrylic = Value
		BrineUI.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
		if Value then
			Acrylic.Enable()
		else
			Acrylic.Disable()
		end
	end
end

function BrineUI:Gradient(stops, props)
	local colorSequence = {}
	local transparencySequence = {}

	for posStr, stop in next, stops do
		local position = tonumber(posStr)
		if position then
			position = math.clamp(position / 100, 0, 1)

			local color = stop.Color
			if typeof(color) == "string" and string.sub(color, 1, 1) == "#" then
				color = Color3.fromHex(color)
			end

			local transparency = stop.Transparency or 0

			table.insert(colorSequence, ColorSequenceKeypoint.new(position, color))
			table.insert(transparencySequence, NumberSequenceKeypoint.new(position, transparency))
		end
	end

	table.sort(colorSequence, function(a, b)
		return a.Time < b.Time
	end)
	table.sort(transparencySequence, function(a, b)
		return a.Time < b.Time
	end)

	if #colorSequence < 2 then
		table.insert(colorSequence, ColorSequenceKeypoint.new(1, colorSequence[1].Value))
		table.insert(transparencySequence, NumberSequenceKeypoint.new(1, transparencySequence[1].Value))
	end

	local gradientData = {
		Color = ColorSequence.new(colorSequence),
		Transparency = NumberSequence.new(transparencySequence),
	}

	if props then
		for k, v in pairs(props) do
			gradientData[k] = v
		end
	end

	return gradientData
end

function BrineUI:Popup(PopupConfig)
	PopupConfig.BrineUI = BrineUI
	return require("./components/popup/Init").new(PopupConfig, BrineUI.ScreenGui.Popups)
end

BrineUI.Themes = require("./themes/Init")(BrineUI, Creator)

local DEFAULT_THEME = "Liquid"

Creator.Themes = BrineUI.Themes

BrineUI:SetTheme(DEFAULT_THEME)
BrineUI:SetLanguage(Creator.Language)

function BrineUI:CreateWindow(Config)
	local CreateWindow = require("./components/window/Init")

	if Config.Folder and not RunService:IsStudio() and writefile then
		if not isfolder("BrineUI") then
			makefolder("BrineUI")
		end
		if not isfolder(Config.Folder) then
			makefolder(Config.Folder)
		end
	end

	Config.BrineUI = BrineUI
	Config.Window = BrineUI.Window
	Config.Parent = BrineUI.ScreenGui.Window

	if BrineUI.Window then
		warn("You cannot create more than one window")
		return
	end

	local CanLoadWindow = true

	local Theme = BrineUI.Themes[Config.Theme] or BrineUI.Themes[DEFAULT_THEME]

	--BrineUI.Theme = Theme
	Creator.SetTheme(Theme)

	if Config.KeySystem then
		local hwid = gethwid or function()
			return LocalPlayer.UserId
		end
		local Filename = hwid()
		CanLoadWindow = false

		local function loadKeysystem()
			KeySystem.new(Config, Filename, function(c)
				CanLoadWindow = c
			end)
		end

		local keyPath = (Config.Folder or "Temp") .. "/" .. Filename .. ".key"

		if Config.KeySystem.KeyValidator then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isValid = Config.KeySystem.KeyValidator(savedKey)

				if isValid then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		elseif not Config.KeySystem.API then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isKey = (type(Config.KeySystem.Key) == "table") and table.find(Config.KeySystem.Key, savedKey)
					or tostring(Config.KeySystem.Key) == tostring(savedKey)

				if isKey then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		else
			if isfile(keyPath) then
				local fileKey = readfile(keyPath)
				local isSuccess = false

				for _, i in next, Config.KeySystem.API do
					local serviceData = BrineUI.Services[i.Type]
					if serviceData then
						local args = {}
						for _, argName in next, serviceData.Args do
							table.insert(args, i[argName])
						end

						local service = serviceData.New(table.unpack(args))
						local success = service.Verify(fileKey)
						if success then
							isSuccess = true
							break
						end
					end
				end

				CanLoadWindow = isSuccess
				if not isSuccess then
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		end

		repeat
			task.wait()
		until CanLoadWindow
	end

	local Window = CreateWindow(Config)

	BrineUI.Transparent = Config.Transparent
	BrineUI.Window = Window

	if Config.Acrylic ~= false then
		Acrylic.init()
	end

	-- function Window:ToggleTransparency(Value)
	--     BrineUI.Transparent = Value
	--     BrineUI.Window.Transparent = Value

	--     Window.UIElements.Main.Background.BackgroundTransparency = Value and BrineUI.TransparencyValue or 0
	--     Window.UIElements.Main.Background.ImageLabel.ImageTransparency = Value and BrineUI.TransparencyValue or 0
	--     Window.UIElements.Main.Gradient.UIGradient.Transparency = NumberSequence.new{
	--         NumberSequenceKeypoint.new(0, 1),
	--         NumberSequenceKeypoint.new(1, Value and 0.85 or 0.7),
	--     }
	-- end

	return Window
end

return BrineUI
