-- Real bundled library startup with a small Roblox API boundary.
local function reject(operation)
	return function()
		error(operation .. " was called during standalone startup")
	end
end

local request = reject("External request")
local writefile = reject("File write")
local isfolder = reject("Folder check")
local gethwid = reject("Device identifier")
local connect = { Connect = function() end }
local gui = {}
local services = {
	RunService = { IsStudio = function() return false end },
	UserInputService = { InputBegan = connect, InputEnded = connect },
	LocalizationService = { SystemLocaleId = "en-us" },
	HttpService = {
		GenerateGUID = function() return "brine-test" end,
		JSONDecode = function(_, data) return { version = data:match('"version":"([^"]+)"') } end,
		GetAsync = reject("HTTP request"),
	},
	Players = { LocalPlayer = { WaitForChild = function(_, name) assert(name == "PlayerGui"); return gui end } },
	Workspace = { CurrentCamera = {} },
}
local game = {
	GetService = function(_, name) return services[name] or {} end,
	HttpGet = reject("HTTP request"),
}
local workspace = services.Workspace
local function vector(x, y) return { X = x, Y = y } end
local Vector2 = { new = vector, zero = vector(0, 0) }
local Color3 = {
	new = function() return {} end,
	fromHex = function() return {} end,
	fromRGB = function() return {} end,
}
local UDim = { new = vector }
local UDim2 = { new = vector, fromOffset = vector }
local Rect = { new = vector }
local ColorSequence = { new = vector }
local function keypoint(time, value) return { Time = time, Value = value } end
local ColorSequenceKeypoint = { new = keypoint }
local NumberSequence = { new = vector }
local NumberSequenceKeypoint = { new = keypoint }
local Enum = { KeyCode = { RightShift = "RightShift" } }
local Instance = { new = function(class, parent) return { ClassName = class, Parent = parent } end }

local Brine = (function()
-- INSERT BUNDLE
end)()

assert(type(Brine.CreateWindow) == "function" and type(Brine.Notify) == "function")
assert(Brine.Version ~= "0.0.0" and Brine:GetCurrentTheme() == "Liquid")
assert(Brine.ScreenGui.Parent == gui)
for _, pack in ipairs({ "lucide", "solar", "craft", "geist", "sfsymbols", "gravity" }) do
	local data = Brine.Creator.Icons.Icons[pack]
	local name = next(data.Icons or data)
	local result = Brine.Creator.Icons.Icon2(name, pack)
	assert(result and result[1]:match("^rbxassetid://"), "Missing bundled icon from " .. pack)
end
assert(Brine.Creator.Icon("layers")[1] ~= "")

-- Check the actual demo's UI wiring at the public API boundary.
local tabs, notice, theme = {}, nil, nil
local window = { Tab = function(_, config)
	local tab = { Config = config }
	function tab:Select() self.Selected = true end
	function tab:Slider(options) self.SliderOptions = options end
	function tab:Button(options) self.ButtonOptions = options end
	function tab:Dropdown(options) self.DropdownOptions = options end
	table.insert(tabs, tab)
	return tab
end }
local demoLibrary = {
	CreateWindow = function(_, options)
		assert(options.Title == "Brine" and options.ToggleKey == Enum.KeyCode.RightShift)
		assert(not options.Folder and not options.KeySystem, "Demo requires optional host functions")
		return window
	end,
	Notify = function(_, options) notice = options.Title end,
	SetTheme = function(_, selected) theme = selected end,
}
local result = (function(...)
-- INSERT EXAMPLE
end)(demoLibrary)
assert(result == window and #tabs == 2 and tabs[1].Selected)
assert(tabs[1].SliderOptions.Value.Default == 70)
tabs[1].ButtonOptions.Callback()
tabs[2].DropdownOptions.Callback("Light")
assert(notice == "BrineUI is ready" and theme == "Light")
print("PASS: standalone startup loads all six pinned packs without external requests; demo creates tabs and wires UI callbacks.")
