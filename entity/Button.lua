local Quad = love.graphics.newQuad

Button = {}

function Button:new(objectName, buttonX, buttonY, buttonProperties)
  local object = {
    name = objectName,
    x = buttonX,
    y = buttonY,
    context = Global and Global.context or nil,
    width = 8,
    height = 8,
    iterator = 1,
    isPressed = false,
    interact = buttonProperties.interact or nil,
    animationQuads = { --Klatki animacji
      Quad(104, 104, 8, 8, 160, 144),
      Quad(104, 112, 8, 8, 160, 144)}
  }
  setmetatable(object, { __index = Button })
  return object
end

local clicked = false

function Button:update(dt, world)
  local sound = (self.context and self.context.soundEvents) or soundEvents

  if self:touchesObject(world.player) then
    --[[if player.ySpeed > 0 then
      player.y = self.y - self.height + 1
      player:collide("floor")
    end]]
    if self.isPressed == false then
      if self.interact ~= nil then
        world.entities["platform"][self.interact].isMoving = true
      end
      --table.insert(Global.enemies, Behemoth:new('behemoth_0', 0, 28))
      self.isPressed = true
      if sound then
        sound:play("click_on")
      end
    end
    self.iterator = 2
    clicked = true
  else
    if clicked then
      if sound then
        sound:play("click_off")
      end
      clicked = false
    end
    self.isPressed = false
    self.iterator = 1
  end
end

function Button:draw()
  local spriteAsset = (self.context and self.context.assets and self.context.assets.sprite) or sprite
  love.graphics.draw(spriteAsset, self.animationQuads[self.iterator], self.x - (self.width / 2),
    self.y - (self.height / 2))
end

function Button:touchesObject(object)
  local ax1, ax2 = self.x - self.width / 2, self.x + self.width / 2 - 1
  local ay1, ay2 = self.y - self.height / 2, self.y + self.height / 2 - 1
  local bx1, bx2 = object.x - object.width / 2, object.x + object.width / 2 - 1
  local by1, by2 = object.y - object.height / 2, object.y + object.height / 2 - 1

  return ((ax2 >= bx1) and (ax1 <= bx2) and (ay2 >= by1) and (ay1 <= by2))
end
