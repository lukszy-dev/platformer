require "utils.Animation"

local Quad = love.graphics.newQuad

Behemoth = {}
setmetatable(Behemoth, { __index = Slime }) -- Extends Slime class

function Behemoth:new(objectName, behemothX, behemothY)
  local object = {
    name = objectName,
    x = behemothX, y = behemothY,
    context = Global and Global.context or nil,
    width = 8, height = 8,
    xSpeed = 0, ySpeed = 0,
    state = "move",
    hitpoints = 2,
    runSpeed = 40,
    onGround = false,
    jumpCount = 0,
    direction = 1,
    isHunter = false,
    xScale = 1,
    xOffset = 0,
    animations = {
      operator = Animation:new(0.14, {
        Quad( 0, 0, 8, 8, 160, 144),
        Quad( 8, 0, 8, 8, 160, 144),
        Quad(24, 0, 8, 8, 160, 144),
        Quad(32, 0, 8, 8, 160, 144),
        Quad( 8, 0, 8, 8, 160, 144),
        Quad(40, 0, 8, 8, 160, 144)
      })
    }
  }
  setmetatable(object, { __index = Behemoth })
  return object
end

function Behemoth:jump()
  if self.jumpCount < 1 then
    self.ySpeed = -130
    self.onGround = false
    self.jumpCount = self.jumpCount + 1;
  end
end

function Behemoth:collide(event)
  if event == "floor" then
    self.ySpeed = 0
    self.onGround = true
    self.jumpCount = 0
  end
  if event == "ceiling" then
    self.ySpeed = 0
  end
  if event == "wall" then
    if self.isHunter then
      self:jump()
    else
      self.direction = -1 * self.direction
    end
  end
end

function Behemoth:update(dt, world)
  Slime.update(self, dt, world) -- Call the superclass function

  local distanceX = world.player.x - self.x
  local distanceY = world.player.y - self.y
  local distance = math.sqrt(math.pow(distanceX, 2) + math.pow(distanceY, 2))

  if distance < 50 and math.abs(distanceY) < 20 then
    self.isHunter = true
    if world.player.x < self.x then
      self.direction = -1
    else
      self.direction = 1
    end
  else
    self.isHunter = false
  end
end

function Behemoth:fallDownDetection(map, halfX, halfY, nextX, nextY)
  if not self.isHunter then
    Slime.fallDownDetection(self, map, halfX, halfY, nextX, nextY, 2) -- Call the superclass function
  end
end
