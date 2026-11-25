-- Touch: the reopen button after closing the window.
UIS.TouchEnabled, UIS.KeyboardEnabled = true, false
local Window = Brine:CreateWindow({ Title = "Brine", Theme = THEME, Size = UDim2.fromOffset(620, 460), AutoScale = false, Icon = "layers" })
run(1)
Window:Close()
run(2)
emit()
