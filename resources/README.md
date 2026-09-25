# Resource layout

## Runtime assets

- `images/spritesheet.png` is the runtime texture atlas.
- `images/hud.png` is the runtime HUD image.
- `maps/map5.tmx` through `maps/map8.tmx` are the active Tiled sources.
- `maps/map5.lua` through `maps/map8.lua` are generated map files loaded by the game.
- `maps/tileset.tsx` is the canonical runtime tileset definition.

## Archived assets

- `archive/maps/` contains prototype maps that are not part of the current campaign.
- `source-art/` contains editor files, source exports, and spacing variants that are not loaded by the game.

When changing an active map, update the TMX source and regenerate its Lua representation before testing the game.
