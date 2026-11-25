local Window = Brine:CreateWindow({ Title = "Brine", Author = "by Salty", Theme = THEME, Size = UDim2.fromOffset(620, 460), AutoScale = false })
run(0.1)
local T = Window:Tab({ Title = "Session", Icon = "layers", ShowTabTitle = true })
T:Toggle({ Title = "Notifications", Value = true })
T:Select()
run(1)
for _, b in Window.TopBarButtons do
	if b.Name == "Close" then click(b.Object:GetChildren()[1]) end
end
run(1)
emit()
