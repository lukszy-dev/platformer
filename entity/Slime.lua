require "utils.Animation"

local Quad = love.graphics.newQuad

Slime = {}

function Slime:new(objectName, slimeX, slimeY)
  local object = {
    name = objectName,
    x = slimeX, y = slimeY,
    context = Global and Global.context or nil,
    width = 8, height = 8,
    xSpeed = 0, ySpeed = 0,
    state = "move",
    hitpoints = 1,
    runSpeed = 20,
    onGround = false,
    direction = 1,
    xScale = 1,
    xOffset = 0,
    animations = {
      operator = Animation:new(0.50, {
        Quad( 8, 8, 8, 8, 160, 144),
        Quad(16, 8, 8, 8, 160, 144)
      })
    }
  }
  setmetatable(object, { __index = Slime })
  return object
end

function Slime:move()
  self.xSpeed = self.direction * self.runSpeed
  self.xScale = self.direction
  -- Texture orientation
  if self.direction == 1 then
    self.xOffset = 0
  else
    self.xOffset = self.width
  end
end

function Slime:getAnimationQuad()
  return self.animations.operator:getCurrentQuad()
end

function Slime:updateAnimations(dt)
  self.animations.operator:update(dt)
end

function Slime:draw()
  local spriteAsset = (self.context and self.context.assets and self.context.assets.sprite) or sprite
  love.graphics.draw(spriteAsset, self:getAnimationQuad(), self.x - (self.width / 2),
      self.y - (self.height / 2), 0, self.xScale, 1, self.xOffset)
end

function Slime:collide(event)
  if event == "floor" then
    self.ySpeed = 0
    self.onGround = true
  end
  if event == "ceiling" then
    self.ySpeed = 0
  end
  if event == "wall" then
    self.direction = -1 * self.direction
  end
end

function Slime:mapColliding(map, x, y)
  local layer = map.layers["ground"]
  local tileX = math.floor(x / map.tilewidth) + 1
  local tileY = math.floor(y / map.tileheight) + 1
  local tile = layer.data[tileY][tileX]

  return tile and (tile.properties or {}).solid
end

function Slime:update(dt, world)
  local halfX = math.floor(self.width / 2)
  local halfY = math.floor(self.height / 2)

  self.ySpeed = self.ySpeed + (world.gravity * dt)

  --Kolizje z mapą w pionie
  local nextY = math.floor(self.y + (self.ySpeed * dt))
  if self.ySpeed < 0 then
    if not (self:mapColliding(world.map, self.x - halfX, nextY - halfY))
    and not (self:mapColliding(world.map, self.x + halfX - 1, nextY - halfY)) then
      self.y = nextY
      self.onGround = false
    else
      self.y = nextY + world.map.tileheight - ((nextY - halfY) % world.map.tileheight)
      self:collide("ceiling")
    end
  elseif self.ySpeed > 0 then
    if not (self:mapColliding(world.map, self.x - halfX, nextY + halfY))
    and not (self:mapColliding(world.map, self.x + halfX - 1, nextY + halfY)) then
      self.y = nextY
      self.onGround = false
    else
      self.y = nextY - ((nextY + halfY) % world.map.tileheight)
      self:collide("floor")
    end
  end

  --Kolizje z mapą w poziomie
  local nextX = self.x + (self.xSpeed * dt)
  if self.xSpeed > 0 then --prawy bok
    if not (self:mapColliding(world.map, nextX + halfX, self.y - halfY))
    and not (self:mapColliding(world.map, nextX + halfX, self.y + halfY - 1)) then
      self.x = nextX
    else
      self.x = nextX - ((nextX + halfX) % world.map.tilewidth)
      self:collide("wall")
    end
  elseif self.xSpeed < 0 then --lewy bok
    if not (self:mapColliding(world.map, nextX - halfX, self.y - halfY))
    and not (self:mapColliding(world.map, nextX - halfX, self.y + halfY - 1)) then
      self.x = nextX
    else
      self.x = nextX + world.map.tilewidth - ((nextX - halfX) % world.map.tilewidth)
      self:collide("wall")
    end
  end

  self:fallDownDetection(world.map, halfX, halfY, nextX, nextY)

  --Animacja
  self:updateAnimations(dt)

  --Ruch
  self:move()
end

--Sprawdzaj czy natrafi na przepaść
function Slime:fallDownDetection(map, halfX, halfY, nextX, nextY, floors)
  local floors = floors or 1
  local rightCornerCondition = false
  local leftCornerCondition = false

  if self.xSpeed > 0 then
    rightCornerCondition = self:mapColliding(map, self.x - halfX, nextY + halfY)
  elseif self.xSpeed < 0 then
    leftCornerCondition = self:mapColliding(map, self.x + halfX, nextY + halfY)
  end	

  for i = 0, floors - 1 do
    if self.xSpeed > 0 then
      rightCornerCondition = rightCornerCondition 
        and not self:mapColliding(map, self.x + halfX, nextY + halfY + (self.height * i))
    elseif self.xSpeed < 0 then
      leftCornerCondition = leftCornerCondition 
        and not self:mapColliding(map, self.x - halfX, nextY + halfY + (self.height * i))
    end
  end
  
  if rightCornerCondition or leftCornerCondition then
    self.direction = -1 * self.direction
  end
end

--Kolizje z obiektami
function Slime:touchesObject(object)
  local ax1, ax2 = self.x - self.width / 2, self.x + self.width / 2 - 1
  local ay1, ay2 = self.y - self.height / 2, self.y + self.height / 2 - 1
  local bx1, bx2 = object.x - object.width / 2, object.x + object.width / 2 - 1
  local by1, by2 = object.y - object.height / 2, object.y + object.height / 2 - 1

  return ((ax2 >= bx1) and (ax1 <= bx2) and (ay2 >= by1) and (ay1 <= by2))
end
