# Liquid glass

BrineUI's Liquid themes draw the window, panels, and controls as glass.

## How the glass is made

| Layer | Where it comes from |
| --- | --- |
| Blur | `Acrylic` blurs the game behind the window and is on by default. Set `Acrylic = false` to turn it off. |
| Tint | Translucent fills: window, then panel, then card. Theme keys such as `WindowBackgroundTransparency` and `ElementBackgroundTransparency` set how clear each one is. |
| Sheen | A soft fall of light from the top of each pane. |
| Rim | One 1px line, bright at the top left and bottom right, dim along the sides. The window's rim light turns to follow the pointer. |
| Thumbs | The capsule slider thumb and glass toggle sprites turn clear while held. |

`src/modules/Glass.lua` draws the sheen and the rim for everything. Roblox interfaces cannot bend what is behind them, so there is no true refraction. The interface itself is not blurred either, so menus and dialogs, which sit over text, stay nearly opaque.

## Rules

- Window radius 22, cards 20 (23 with `NewElements`), fields 14, menus 20, dialogs 28, buttons round.
- Window buttons are traffic lights. The selected tab is a pill that swells in.
- Text must hold with no blur. `npm run contrast` measures every pair with the window over pure black and over pure white.
- Reduce Motion in Roblox settings is honored, and it stops the rim light from moving.

## Themes

`Liquid` is the default and `Liquid Light` is its pair. Earlier themes keep their colors, stay as opaque as they were, and get a fainter rim and sheen.

## Checking it

`npm run render` runs the real bundle against a small Roblox GUI boundary and writes one HTML page per scene and theme. The blur in those pictures is the browser's. They do not reproduce Roblox text shaping, sliced corner images or the toggle sprites.
