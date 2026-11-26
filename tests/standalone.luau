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

-- Run the full example against a recorder: every call is logged and returns another recorder.
local calls, windows = {}, 0
local function recorder(): any
	return setmetatable({}, {
		__index = function(_, key)
			return function(_, ...)
				calls[key] = (calls[key] or 0) + 1
				return recorder()
			end
		end,
		__concat = function() return "" end,
	})
end
local demoLibrary = setmetatable({
	Version = Brine.Version,
	CreateWindow = function(_, options)
		windows += 1
		assert(type(options.Title) == "string" and options.Title:find("Brine"), "the example names the window")
		assert(options.OpenButton and options.OpenButton.Enabled ~= false, "the example keeps the minimize badge")
		return recorder()
	end,
}, { __index = function(_, key) return recorder()[key] end })
-- The example reaches for more of the Roblox API than startup does.
local Enum = setmetatable({}, { __index = function(_, kind)
	return setmetatable({}, { __index = function(_, item) return kind .. "." .. item end })
end })
local Font = { new = function() return {} end }
local task = { spawn = function() end, wait = function() end, delay = function() end }
;(function(...)
-- INSERT EXAMPLE
end)(demoLibrary)
assert(windows == 1, "one window")
assert((calls.Tab or 0) >= 8, "the example has every tab")
for _, element in { "Section", "Paragraph", "Button", "Toggle", "Slider", "Input", "Dropdown", "Colorpicker", "Keybind", "Code", "Group", "Divider", "ProgressBar", "HStack" } do
	assert((calls[element] or 0) > 0, "the example shows " .. element)
end
print("PASS: standalone startup loads all six pinned packs without external requests; the full example builds every element.")
