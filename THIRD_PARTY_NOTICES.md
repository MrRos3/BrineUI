# Third-party notices

BrineUI's original work is copyright 2026 Salty (MrRos3). Portions are derived from WindUI 1.6.66 by Footagesus (Footages) at revision d2c9bac5f96f997418d680d19cb759892542e492. The original MIT license appears in licenses/Upstream-LICENSE and in both standalone bundles. https://github.com/Footagesus/WindUI

The pinned Icons submodule is by Footages, https://github.com/Footagesus/Icons, MIT, copyright 2025 Footages. Its MIT text is included in the bundle. It exposes icon packs whose original licensing and asset permissions still apply: Lucide (ISC), Craft Icons, Geist Icons, Solar Icons and SF Symbols. Consult each pack's terms before distributing its assets; this project does not relicense them under MIT. Upstream credits: https://github.com/lucide-icons/lucide, https://www.figma.com/community/file/1415718327120418204, https://vercel.com/geist/icons, https://icones.js.org/collection/solar, https://sf-symbols-one.vercel.app/.

The upstream color picker credits Dawid-Scripts / Fluent. Roblox-hosted shapes, fonts and images retain their existing asset IDs and permissions. Source highlighter credit: https://devforum.roblox.com/t/realtime-richtext-lua-syntax-highlighting/2500399

Gravity UI Icons is also included by the pinned Icons loader: https://github.com/gravity-ui/icons, MIT. Full Lucide and Gravity license texts are retained in licenses/ and included in the standalone distribution. Solar icons are by 480 Design, https://github.com/480-Design/Solar-Icon-Set, licensed CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/); they are accessed through the upstream Roblox asset mapping, which converts the original icon artwork to Roblox image references. Original icon copyright stays with its authors. Pack attribution applies whether a mapping is bundled locally or loaded from the upstream URL.

`src/modules/BundledIcons.lua` adapts the pinned Footagesus `Main-v2.lua` icon loader to use only local pack mappings. The icon lookup functions and Roblox asset references come from the upstream dependency.
