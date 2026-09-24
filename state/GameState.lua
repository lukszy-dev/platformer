require "World"

GameState = {}

function GameState:new(config)
  local object = {
    world = {},
    isEnd = false,
    context = (config and config.context) or Global.context
  }
  setmetatable(object, { __index = GameState })
  return object
end

function GameState:init()
  self.world.currentMap = self.world.firstMap
  self.world = World:new({ context = self.context })
  self.world:init()

  if self.context and self.context.mainTheme then
    self.context.mainTheme:play()
  end

  self.isEnd = false
end

function GameState:update(dt)
  self.world:update(dt)

  if not self.world.player:isAlive(self.world.map) then
    if self.context and self.context.mainTheme then
      self.context.mainTheme:stop()
    end
    self.isEnd = true
  end
end

function GameState:draw()
  self.world:draw()
end

function GameState:keyreleased(key)
  self.world:keyreleased(key)
end

function GameState:keypressed(key)
  self.world:keypressed(key)
end

function GameState:getScore()
  return self.world.score
end
