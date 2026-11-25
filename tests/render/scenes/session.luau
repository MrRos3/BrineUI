-- The README example, first tab.
local Window = Brine:CreateWindow({
	Title = "Brine", Author = "by Salty", Theme = THEME, Size = UDim2.fromOffset(760, 540), SideBarWidth = 200,
	HideSearchBar = false, ScrollBarEnabled = true,
})
run(0.1)
local Workspace = Window:Section({ Title = "Workspace", Opened = true })
local Session = Workspace:Tab({ Title = "Session", Icon = "layers", ShowTabTitle = true })
Workspace:Tab({ Title = "Controls", Icon = "sliders-horizontal", ShowTabTitle = true })
Window:Tab({ Title = "Appearance", Icon = "palette", ShowTabTitle = true })
Window:Tab({ Title = "Private", Icon = "lock", Locked = true })
Session:Paragraph({ Title = "Your session, composed.", Desc = "A quieter place for the controls you use every day." })
Session:Toggle({ Title = "Notifications", Desc = "Show updates during this session", Value = true })
Session:Toggle({ Title = "Auto-save", Value = false })
Session:Slider({ Title = "Volume", Step = 1, Value = { Min = 0, Max = 100, Default = 70 } })
Session:Dropdown({ Title = "Profile", Values = { "Balanced", "Quiet", "Focused" }, Value = "Balanced", Callback = function() end })
Session:Button({ Title = "Send a test notification", Icon = "arrow-up-right" })
Session:Select()
run(2)
emit()
