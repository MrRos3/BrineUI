# Validation

## Roblox desktop in BrineUI 0.3.13

- Tested startup, row heights, controls, sections, code block, menu, notification, dialog, close and reopen, and the Liquid, Liquid Light, and Dark themes.
- Tested traffic lights, a custom top bar button, tooltips, menu selection, slider drag, toggle, color picker, search, window drag and resize, and fullscreen.
- Verified that background blur follows the window at scales 1 and 0.7, including in a host below the top bar. Its panes hide, return, and clean up with the window.

## Automated checks

`npm run check` builds the standalone library and demo, checks API signatures and options against a committed fixture, verifies the MIT license files, compiles Luau, runs the navigation and standalone tests, measures theme contrast, and renders the fixture scenes.

The CI build pins darklua 0.19.0 and Luau 0.748. Touch, gamepad, and in-client saved config behavior require testing in the intended client.
