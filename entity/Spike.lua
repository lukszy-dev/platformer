local Quad = love.graphics.newQuad

Spike = {}

function Spike:new(objectName, spikeX, spikeY)
  local object = {
    name = objectName,
    x = spikeX,
    y = spikeY,
    context = Global and Global.context or nil,
    width = 8,
    height = 8,
    iterator = 1,
    quads = {
      Quad(88, 104, 8, 8, 160, 144)}
  }
  setmetatable(object, { __index = Spike })
  return object
end

function Spike:update(dt, world)
  local sound = (self.context and self.context.soundEvents) or soundEvents

  if self:touchesObject(world.player) then
    if world.player.immune == false then
      world.player.immune = true
      world.player.immuneTime = 2
      world.player.hitpoints = world.player.hitpoints - 1
      if sound then
        sound:play("punch")
      end
    end
    --player:jump()
  end
end

function Spike:draw()
  local spriteAsset = (self.context and self.context.assets and self.context.assets.sprite) or sprite
  love.graphics.draw(spriteAsset, self.quads[self.iterator], self.x - (self.width / 2),
      self.y - (self.height / 2))
end

function Spike:touchesObject(object)
  local ax1, ax2 = self.x - self.width / 2, self.x + self.width / 2 - 1
  local ay1, ay2 = self.y - self.height / 2, self.y + self.height / 2 - 1
  local bx1, bx2 = object.x - object.width / 2, object.x + object.width / 2 - 1
  local by1, by2 = object.y - object.height / 2, object.y + object.height / 2 - 1

  return ((ax2 >= bx1) and (ax1 <= bx2) and (ay2 >= by1) and (ay1 <= by2))
end
