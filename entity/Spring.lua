local Quad = love.graphics.newQuad

Spring = {}

function Spring:new(objectName, springX, springY, springProperties)
  local object = {
    name = objectName,
    x = springX,
    y = springY,
    context = Global and Global.context or nil,
    width = 8,
    height = 8,
    iterator = 1,
    power = springProperties.power or 120,
    isPressed = false,
    animationQuads = { -- Animation frames
      Quad(96, 104, 8, 8, 160, 144),
      Quad(96, 112, 8, 8, 160, 144)}
  }
  setmetatable(object, { __index = Spring })
  return object
end

function Spring:update(dt, world)
  local sound = (self.context and self.context.soundEvents) or soundEvents

  if self:touchesObject(world.player) then
    self.iterator = 2
    world.player:specialJump(self.power)
    if sound then
      sound:play("jump")
    end
  elseif world.player.ySpeed > 0 then
    self.iterator = 1
  end
end

function Spring:draw()
  local spriteAsset = (self.context and self.context.assets and self.context.assets.sprite) or sprite
  love.graphics.draw(spriteAsset, self.animationQuads[self.iterator], self.x - (self.width / 2),
      self.y - (self.height / 2))
end

function Spring:touchesObject(object)
  local ax1, ax2 = self.x - self.width / 2, self.x + self.width / 2 - 1
  local ay1, ay2 = self.y - self.height / 2, self.y + self.height / 2 - 1
  local bx1, bx2 = object.x - object.width / 2, object.x + object.width / 2 - 1
  local by1, by2 = object.y - object.height / 2, object.y + object.height / 2 - 1

  return ((ax2 >= bx1) and (ax1 <= bx2) and (ay2 >= by1) and (ay1 <= by2))
end
