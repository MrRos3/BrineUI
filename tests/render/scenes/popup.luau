Brine:SetTheme(THEME)
Brine:Popup({ Title = "Load the hub?", Content = "It adds a window you can reopen with Right Shift.", Icon = "info", Buttons = {
	{ Title = "Cancel", Variant = "Tertiary", Callback = function() end },
	{ Title = "Load", Icon = "arrow-right", Variant = "Primary", Callback = function() end },
} })
run(1)
emit()
