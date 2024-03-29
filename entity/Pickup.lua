local Quad = love.graphics.newQuad

Pickup = {}

function Pickup:new(objectName, pickupX, pickupY, pickupProperties)
  local object = {
    name = objectName,
    x = pickupX,
    y = pickupY,
    width = 8,
    height = 8,
    value = pickupProperties.value or 0,
    quads = Quad(136, 72, 8, 8, 160, 144) --Klatki animacji
  }
  setmetatable(object, { __index = Pickup })
  return object
end

function Pickup:update(dt, world)
  if self:touchesObject(world.player) then
    world.entities["pickup"][self.name] = nil
    --table.remove(Global.pickups, self.name)
    world.score = world.score + self.value
    if world.player.hitpoints < 3 then
      world.player.hitpoints = world.player.hitpoints + 1
    end
    soundEvents:play("select")
  end
end

function Pickup:draw()
  love.graphics.draw(sprite, self.quads, self.x - (self.width / 2),
      self.y - (self.width / 2))
end

function Pickup:touchesObject(object)
  local ax1, ax2 = self.x - self.width / 2, self.x + self.width / 2 - 1
  local ay1, ay2 = self.y - self.height / 2, self.y + self.height / 2 - 1
  local bx1, bx2 = object.x - object.width / 2, object.x + object.width / 2 - 1
  local by1, by2 = object.y - object.height / 2, object.y + object.height / 2 - 1

  return ((ax2 >= bx1) and (ax1 <= bx2) and (ay2 >= by1) and (ay1 <= by2))
end
