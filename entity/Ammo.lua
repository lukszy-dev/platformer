local Quad = love.graphics.newQuad

Ammo = {}

function Ammo:new(ammoX, ammoY, ammoClass, ammoRange)
  local object = {
    x = ammoX, y = ammoY,
    context = Global and Global.context or nil,
    width = 8, height = 8,
    xSpeed = 170,
    xScale = 1,
    xOffset = 0,
    range = ammoRange,
    distance = 0,
    class = ammoClass,
    damage = 1,
    iterator = 1,
    timer = 0,
    toRemove = false,
    animationQuads = {
      bullet = {
        Quad(16, 32, 8, 8, 160, 144)
      },
      shotgun = {
        Quad(24, 32, 8, 8, 160, 144)
      }
    },
    splashAnimationQuads = {
      splashAnimation = {
        Quad(64, 32, 8, 8, 160, 144),
        Quad(72, 32, 8, 8, 160, 144),
        Quad(80, 32, 8, 8, 160, 144)
      }
    }
  }
  setmetatable(object, { __index = Ammo })
  return object
end

function Ammo:update(dt)
  if self.toRemove == false then
    self.distance = self.distance + (self.xScale * self.xSpeed * dt)
    self.x = self.x + (self.xScale * self.xSpeed * dt)
  end
end

function Ammo:draw()
  local spriteAsset = (self.context and self.context.assets and self.context.assets.sprite) or sprite
  if self.toRemove == false then
    love.graphics.draw(spriteAsset, self.animationQuads[self.class][1], self.x - (self.width / 2),
      self.y - (self.height / 2), 0, self.xScale, 1, self.xOffset)
  else
    love.graphics.draw(spriteAsset, self.splashAnimationQuads["splashAnimation"][self.iterator], self.x - (self.width / 2),
      self.y - (self.height / 2), 0, self.xScale, 1, self.xOffset)
  end
end

function Ammo:splashAnimation(dt, delay, frames)
  self.timer = self.timer + dt
  if self.timer > delay then
    self.timer = 0
    self.iterator = self.iterator + 1
    if self.iterator > frames then
      self.iterator = 1
    end
  end
end

function Ammo:mapColliding(map, x, y)
  local layer = map.layers["ground"]
  local tileX = math.floor(x / map.tilewidth) + 1
  local tileY = math.floor(y / map.tileheight) + 1
  local tile = layer.data[tileY][tileX]

  return tile and (tile.properties or {}).solid
end

function Ammo:touchesObject(object)
  local ax1, ax2 = self.x - self.width / 2, self.x + self.width / 2 - 1
  local ay1, ay2 = self.y - self.height / 2, self.y + self.height / 2 - 1
  local bx1, bx2 = object.x - object.width / 2, object.x + object.width / 2 - 1
  local by1, by2 = object.y - object.height / 2, object.y + object.height / 2 - 1

  return ((ax2 >= bx1) and (ax1 <= bx2) and (ay2 >= by1) and (ay1 <= by2))
end
