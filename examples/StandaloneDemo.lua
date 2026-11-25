-- The build embeds this example in dist/demo.lua with the BrineUI library.
local Brine = assert(..., "Run the generated dist/demo.lua to open the BrineUI demo")

local Window = Brine:CreateWindow({
	Title = "Brine",
	Author = "by Salty",
	Theme = "Liquid",
	ToggleKey = Enum.KeyCode.RightShift,
})

local Session = Window:Tab({ Title = "Session", Icon = "layers", ShowTabTitle = true })
local Settings = Window:Tab({ Title = "Appearance", Icon = "palette", ShowTabTitle = true })

Session:Slider({
	Title = "Demo level",
	Value = { Min = 0, Max = 100, Default = 70 },
	Callback = function(value)
		print("BrineUI demo level", value)
	end,
})

Session:Button({
	Title = "Send a test notification",
	Icon = "arrow-up-right",
	Callback = function()
		Brine:Notify({ Title = "BrineUI is ready", Duration = 4, Icon = "check" })
	end,
})

Settings:Dropdown({
	Title = "Theme",
	Values = { "Liquid", "Liquid Light", "Brine", "Dark", "Light" },
	Value = "Liquid",
	Callback = function(theme)
		Brine:SetTheme(theme)
	end,
})

Session:Select()
return Window
