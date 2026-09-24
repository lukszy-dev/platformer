-- Zmienne globalne

local Global = {
  title = "2D PLATFORMER",
  copyright = "(C) 2021 LUKASZ SZYPLINSKI",

  debug = false,

  windowHeight = love.graphics.getHeight(),
  windowWidth = love.graphics.getWidth(),

  context = nil,
  properties = {},
  scores = {},

  scale = 0.25
}

return Global
