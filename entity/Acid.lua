require "utils.Animation"

local Quad = love.graphics.newQuad

Acid = {}

function Acid:new(objectName, acidX, acidY)
  local object = {
    name = objectName,
    x = acidX,
    y = acidY + 1,
    context = Global and Global.context or nil,
    initY = acidY + 1,
    width = 8,
    height = 8,
    xScale = 1,
    xOffset = 0,
    state = "init",
    fallSpeed = 40,
    isFallen = false,
    isInit = true,
    animations = {
      drop = {
        operator = Animation:new(1, {
          Quad(48, 0, 8, 8, 160, 144)
        })
      },
      splash = {
        operator = Animation:new(0.30, {
          Quad(48, 8, 8, 8, 160, 144),
          Quad(48, 16, 8, 8, 160, 144),
          Quad(48, 24, 8, 8, 160, 144)
        }, 4)
      },
      init = {
        operator = Animation:new(0.30, {
          Quad(56, 8, 8, 8, 160, 144),
          Quad(56, 16, 8, 8, 160, 144),
          Quad(56, 24, 8, 8, 160, 144)
        }, 4)
      }
    }
  }
  setmetatable(object, { __index = Acid })
  return object
end

function Acid:getCurrentAnimationOperator()
  return self.animations[self.state].operator
end

function Acid:draw()
  local animationOperator = self:getCurrentAnimationOperator()
  local spriteAsset = (self.context and self.context.assets and self.context.assets.sprite) or sprite
  love.graphics.draw(spriteAsset, animationOperator:getCurrentQuad(), self.x - (self.width / 2),
    self.y - (self.height / 2), 0, self.xScale, 1, self.xOffset)
end

function Acid:getState()
  local myState = ""
  if self.isFallen then
    myState = "splash"
  elseif self.isInit then
    myState = "init"
  else
    myState = "drop"
  end
  return myState
end

function Acid:update(dt, world)
  if self:mapColliding(world.map, self.x, self.y + (self.height / 2)) and not self.isFallen then
    local tileY = math.floor(self.y / world.map.tileheight)
    self.y = tileY * world.map.tileheight + 4
    self.isFallen = true
  end

  if not self.isFallen and not self.isInit then
    self.y = self.y + self.fallSpeed * dt
  end

  local animationOperator = self:getCurrentAnimationOperator()
  animationOperator:update(dt)

  if self.state == "splash" and animationOperator:getCurrentIteration() == 4 then
    self.isFallen = false
    self.isInit = true
    self.y = self.initY
    animationOperator:setIteration(1)
  end

  if self.state == "init" and animationOperator:getCurrentIteration() == 4 then
    self.isInit = false
    animationOperator:setIteration(1)
  end

  if self:touchesObject(world.player) then
    if world.player.immune == false and self.state ~= "init" then
      local sound = (self.context and self.context.soundEvents) or soundEvents
      if sound then
        sound:play("punch")
      end
      world.player.immune = true
      world.player.immuneTime = 2
      world.player.hitpoints = world.player.hitpoints - 1
    end
  end

  self.state = self:getState()
end

function Acid:mapColliding(map, x, y)
  local layer = map.layers["ground"]
  local tileX = math.floor(x / map.tilewidth) + 1
  local tileY = math.floor(y / map.tileheight) + 1
  local tile = layer.data[tileY][tileX]

  return tile and (tile.properties or {}).solid
end

function Acid:touchesObject(object)
  local ax1, ax2 = self.x - self.width / 2, self.x + self.width / 2 - 1
  local ay1, ay2 = self.y - self.height / 2, self.y + self.height / 2 - 1
  local bx1, bx2 = object.x - object.width / 2, object.x + object.width / 2 - 1
  local by1, by2 = object.y - object.height / 2, object.y + object.height / 2 - 1

  return ((ax2 >= bx1) and (ax1 <= bx2) and (ay2 >= by1) and (ay1 <= by2))
end
