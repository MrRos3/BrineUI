# BrineUI

## Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/MrRos3/BrineUI/main/dist/main.lua"))()
```

This loads the library. Use the full example below to create your own window.

## Quick demo

Run this one line to open the full example: every element, grouped into tabs.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/MrRos3/BrineUI/main/dist/demo.lua"))()
```

## Full example

Copy this whole script to open a two-tab window. Press **Right Shift** to show or hide it.

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/MrRos3/BrineUI/main/dist/main.lua"))()

local Window = Library:CreateWindow({
    Title = "BrineUI",
    Author = "by Salty",
    Theme = "Liquid",
    ToggleKey = Enum.KeyCode.RightShift,
})

local Home = Window:Tab({ Title = "Home", Icon = "layers", ShowTabTitle = true })
local Settings = Window:Tab({ Title = "Settings", Icon = "palette", ShowTabTitle = true })

local message = "BrineUI is ready"
local notificationsEnabled = true
local duration = 4

Home:Paragraph({
    Title = "Notification preview",
    Desc = "Enter a message, then send it. Duration and theme are in Settings.",
})

Home:Input({
    Title = "Message",
    Value = message,
    Callback = function(text)
        message = text ~= "" and text or "BrineUI is ready"
    end,
})

Home:Button({
    Title = "Send notification",
    Icon = "arrow-up-right",
    Callback = function()
        if notificationsEnabled then
            Library:Notify({
                Title = "BrineUI",
                Content = message,
                Duration = duration,
                Icon = "check",
            })
        end
    end,
})

Settings:Toggle({
    Title = "Notifications",
    Value = notificationsEnabled,
    Callback = function(enabled)
        notificationsEnabled = enabled
    end,
})

Settings:Slider({
    Title = "Notification duration (seconds)",
    Value = { Min = 1, Max = 10, Default = duration },
    Callback = function(seconds)
        duration = seconds
    end,
})

Settings:Dropdown({
    Title = "Theme",
    Values = { "Liquid", "Liquid Light", "Brine", "Dark", "Light" },
    Value = "Liquid",
    Callback = function(theme)
        Library:SetTheme(theme)
    end,
})

Home:Select()
```
