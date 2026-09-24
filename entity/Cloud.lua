local Quad = love.graphics.newQuad
local init

Cloud = {}

function Cloud:new(cloudX, cloudY)
  local object = {
    x = cloudX,
    y = cloudY,
    context = Global and Global.context or nil,
    width = 8,
    height = 8,
    xSpeed = 10,
    Quads = {} --metoda init
  }

  init(object)
  setmetatable(object, {__index = Cloud})
  return object
end

function init(object)
  table.insert(object.Quads, Quad(64, 48, 8, 8, 160, 144))
  table.insert(object.Quads, Quad(72, 48, 8, 8, 160, 144))
end

function Cloud:draw()
  local spriteAsset = (self.context and self.context.assets and self.context.assets.sprite) or sprite
  for i, v in ipairs(self.Quads) do
    love.graphics.draw(spriteAsset, v, (self.x - (self.width / 2)) + 8 * (i - 1), self.y - (self.height / 2))
  end
end

function Cloud:update(dt, world)
  local halfX = math.floor(self.width / 2)
  self.x = self.x + (self.xSpeed * dt)

  if (self.x - halfX > world.map.tilewidth * world.map.width) then
    self.x = -16
  end
end
