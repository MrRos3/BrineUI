-- Liquid glass over the shared palette. Fills stay translucent; the tint is strong enough
-- that text holds over any scene, with or without the background blur.
local function hex(value)
	return Color3.fromHex(value)
end

local Dark = {
	Name = "Liquid",

	Accent = hex("16181D"),
	Background = hex("14161B"),
	Dialog = hex("1B1E24"),
	DialogBackgroundTransparency = 0.02,
	Popup = hex("1B1E24"),
	PopupBackgroundTransparency = 0.02,
	WindowBackground = hex("0B0D11"),
	WindowBackgroundTransparency = 0.22,
	WindowShadow = hex("000000"),
	Outline = hex("FFFFFF"),
	Text = hex("FFFFFF"),
	Placeholder = hex("C3C8D2"),
	Icon = hex("DCE0E8"),
	Primary = hex("3AA0FF"),
	Button = hex("0B6BD3"),
	Toggle = hex("2FB657"),
	Checkbox = hex("0B6BD3"),
	Slider = hex("62B8FF"),
	SliderThumb = hex("FFFFFF"),
	ProgressBar = hex("62B8FF"),

	PanelBackground = hex("FFFFFF"),
	PanelBackgroundTransparency = 0.965,
	ElementBackground = hex("FFFFFF"),
	ElementBackgroundTransparency = 0.91,
	TabBackgroundActive = hex("FFFFFF"),
	TabBackgroundActiveTransparency = 0.85,
	TabBackgroundHover = hex("FFFFFF"),
	TabBackgroundHoverTransparency = 0.93,
	TabTextTransparency = 0.12,
	TabIconTransparency = 0.12,
	TabIconTransparencyActive = 0,

	LockedBackground = hex("0B0D11"),
	LockedText = hex("FFFFFF"),
	Field = hex("000000"),
	FieldTransparency = 0.72,
	LabelBackgroundTransparency = 1,

	GlassRim = hex("FFFFFF"),
	GlassRimTransparency = 0.35,
	GlassSheen = hex("FFFFFF"),
	GlassSheenTransparency = 0.1,
	TopbarGlass = hex("FFFFFF"),
	TopbarGlassTransparency = 0.9,

	DropdownBackground = hex("1E2128"),
	DropdownBackgroundTransparency = 0.02,
	DropdownTabBackground = hex("FFFFFF"),
	WindowSearchBarBackground = hex("1B1E24"),
	Notification = hex("14161B"),
	NotificationTransparency = 0.14,
	Notification2Transparency = 1,
	NotificationContentTransparency = 0.12,
	NotificationDuration = hex("FFFFFF"),
	NotificationDurationTransparency = 0.94,
	Tooltip = hex("2A2E37"),
}

local Light = table.clone(Dark)
for key, value in
	{
		Name = "Liquid Light",

		Accent = hex("FFFFFF"),
		Background = hex("F4F6FA"),
		Dialog = hex("FAFBFD"),
		Popup = hex("FAFBFD"),
		WindowBackground = hex("EEF1F7"),
		WindowBackgroundTransparency = 0.2,
		Outline = hex("0B0D12"),
		Text = hex("0B0D12"),
		Placeholder = hex("333944"),
		Icon = hex("2C313B"),
		Primary = hex("0A62C9"),
		Button = hex("0A62C9"),
		Toggle = hex("1D8A41"),
		Checkbox = hex("0A62C9"),
		Slider = hex("0A62C9"),
		ProgressBar = hex("0A62C9"),

		PanelBackgroundTransparency = 0.75,
		ElementBackgroundTransparency = 0.45,
		TabBackgroundActiveTransparency = 0.3,
		TabBackgroundHoverTransparency = 0.6,
		LockedBackground = hex("EEF1F7"),
		LockedText = hex("0B0D12"),
		Field = hex("0B0D12"),
		FieldTransparency = 0.92,
		GlassRim = hex("FFFFFF"),
		GlassRimTransparency = 0,
		GlassSheenTransparency = 0,
		TopbarGlassTransparency = 0.45,

		DropdownBackground = hex("FAFBFD"),
		DropdownTabBackground = hex("4A5A75"),
		WindowSearchBarBackground = hex("FAFBFD"),
		Notification = hex("FAFBFD"),
		NotificationTransparency = 0.06,
		NotificationDuration = hex("0B0D12"),
		Tooltip = hex("2A2E37"),
	}
do
	Light[key] = value
end

return { Dark = Dark, Light = Light }
