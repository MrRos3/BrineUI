# BrineUI API compatibility

BrineUI retains the public control methods, options, and callback conventions of its pinned upstream API. `Version` reports the BrineUI version. `UpstreamVersion` reports the upstream version. See [Third-party notices](../../THIRD_PARTY_NOTICES.md) for the source revision.

| Surface | Behavior |
| --- | --- |
| Library | `CreateWindow`, `Notify`, `Popup`, theme and font controls, localization, and acrylic methods are available. Create one window per loaded library instance. |
| Window | Set `Theme`, `Size`, `ToggleKey`, `SideBarWidth`, `OpenButton`, `Topbar`, `Footer`, `Background`, `Resizable`, and search settings when creating a window. Defaults include the `Liquid` theme, acrylic blur, a 22px window radius, and a 20px element radius. |
| Tabs | Use `Tab:Select()` or `Window:SelectTab(Tab.Index)` to select a page. `SetTitle`, `SetDesc`, `Lock`, and `Unlock` are available on tabs. |
| Controls | Paragraph, Button, Toggle, Slider, ProgressBar, Keybind, Input, Dropdown, Code, Colorpicker, Section, Divider, Space, Image, Group, HStack, VStack, and Viewport are available. |
| Configs | New projects use `BrineUI/<Folder>/config/`. Existing folders are recognized when the BrineUI config directory is absent. An explicit `SetPath` takes precedence. |
| Icons | The standalone builds include six pinned icon mappings. Optional service integrations use their existing endpoints. |

## Calling conventions

- A slider uses `Value = { Min = 0, Max = 100, Default = 50 }`. `Set` calls the callback when the value changes.
- A dropdown uses `Values` and `Value`. `Multi` and `AllowNone` control how options can be selected.
- `HideSearchBar = false` shows search. The default notification duration is five seconds.
- Use `ConfigManager:CreateConfig(name, autoload)` to create a config and `BrineUI:SetTheme(name)` to set the library theme.

`npm run audit` checks signatures and options against the fixture in `tests/api-baseline.json`. The fixture records the pinned upstream method signatures and the options checked in BrineUI 0.1.1.
