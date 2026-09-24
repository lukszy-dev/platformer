require "utils.Animation"

local Quad = love.graphics.newQuad

MegaBehemoth = {}
--Dziedziczenie po klasie Behemoth
setmetatable(MegaBehemoth, { __index = Behemoth })

function MegaBehemoth:new(objectName, behemothX, behemothY)
  local object = {
    name = objectName,
    x = behemothX, y = behemothY,
    context = Global and Global.context or nil,
    width = 16, height = 16,
    xSpeed = 0, ySpeed = 0,
    state = "move",
    hitpoints = 20,
    runSpeed = 40,
    onGround = false,
    xScale = 1,
    xOffset = 0,
    animations = {
      move = {
        Quad(120, 40, 16, 16, 160, 144),
      }
    }
  }

  setmetatable(object, { __index = MegaBehemoth })
  return object
end

function MegaBehemoth:draw()
  local spriteAsset = (self.context and self.context.assets and self.context.assets.sprite) or sprite
  love.graphics.draw(spriteAsset, self.animations.move[1], self.x - (self.width / 2),
      self.y - (self.height / 2), 0, self.xScale, 1, self.xOffset)

  -- love.graphics.rectangle('line', self.x - (self.width / 2), self.y - (self.height / 2), 
  -- 		self.width, self.height)
end

function MegaBehemoth:updateAnimations(dt)
  return
end
