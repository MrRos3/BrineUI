-- Search popup with results.
local Window = Brine:CreateWindow({ Title = "Brine", Author = "by Salty", Theme = THEME, Size = UDim2.fromOffset(620, 460), AutoScale = false, HideSearchBar = false })
run(0.1)
local T = Window:Tab({ Title = "Session", Icon = "layers", ShowTabTitle = true })
T:Toggle({ Title = "Notifications", Desc = "Show updates during this session", Value = true })
T:Slider({ Title = "Session volume", Value = { Min = 0, Max = 100, Default = 70 } })
T:Select()
run(1)
for _, c in Window.UIElements.SideBarContainer:GetChildren() do
	if c.ClassName == "TextButton" then click(c) end
end
for _, c in Window.UIElements.Main:GetChildren() do
	local box = c.ClassName == "Frame" and c.Name == "Frame" and find(c, "TextBox")
	if box then box.Text = "session" end
end
run(1)
emit()
