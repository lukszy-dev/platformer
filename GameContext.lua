local GameContext = {}

function GameContext:new()
  local object = {
    title = nil,
    copyright = nil,
    assets = {},
    state = nil,
    properties = nil,
    scores = nil,
    propertiesEvents = nil,
    soundEvents = nil,
    mainTheme = nil,
    windowWidth = love.graphics.getWidth(),
    windowHeight = love.graphics.getHeight(),
    scale = 0.25
  }

  setmetatable(object, { __index = GameContext })
  return object
end

return GameContext
