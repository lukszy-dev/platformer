-- Zmienne globalne

local GameConfig = require "config.GameConfig"

local Global = {
  title = GameConfig.title,
  copyright = GameConfig.copyright,

  debug = GameConfig.debug,

  windowHeight = GameConfig.windowHeight,
  windowWidth = GameConfig.windowWidth,

  context = nil,
  properties = {},
  scores = {},

  scale = GameConfig.scale
}

return Global
