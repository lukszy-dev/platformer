local PlayerPhysics = {}

function PlayerPhysics:new(player)
  local object = {
    player = player
  }
  setmetatable(object, { __index = PlayerPhysics })
  return object
end

function PlayerPhysics:applyMovement(world, dt)
  local halfX = math.floor(self.player.width / 2)
  local halfY = math.floor(self.player.height / 2)

  self.player.ySpeed = self.player.ySpeed + (world.gravity * dt)

  local nextY = self.player.y + (self.player.ySpeed * dt)
  if self.player.ySpeed < 0 then
    if not (self.player:mapColliding(world.map, self.player.x - halfX, nextY - halfY))
      and not (self.player:mapColliding(world.map, self.player.x + halfX - 1, nextY - halfY)) then
      self.player.y = nextY
      self.player.onGround = false
    else
      self.player.y = nextY + world.map.tileheight - ((nextY - halfY) % world.map.tileheight)
      self.player:collide("ceiling")
    end
  elseif self.player.ySpeed > 0 then
    if not (self.player:mapColliding(world.map, self.player.x - halfX, nextY + halfY))
      and not (self.player:mapColliding(world.map, self.player.x + halfX - 1, nextY + halfY)) then
      self.player.y = nextY
      self.player.onGround = false
    else
      self.player.y = nextY - ((nextY + halfY) % world.map.tileheight)
      self.player:collide("floor")
    end
  end

  local nextX = self.player.x + (self.player.xSpeed * dt)
  if self.player.xSpeed > 0 then
    if not (self.player:mapColliding(world.map, nextX + halfX, self.player.y - halfY))
      and not (self.player:mapColliding(world.map, nextX + halfX, self.player.y + halfY - 1)) then
      self.player.x = nextX
    else
      self.player.x = nextX - ((nextX + halfX) % world.map.tilewidth)
    end
  elseif self.player.xSpeed < 0 then
    if not (self.player:mapColliding(world.map, nextX - halfX, self.player.y - halfY))
      and not (self.player:mapColliding(world.map, nextX - halfX, self.player.y + halfY - 1)) then
      self.player.x = nextX
    else
      self.player.x = nextX + world.map.tilewidth - ((nextX - halfX) % world.map.tilewidth)
    end
  end

  if self.player.x + halfX > world.map.tilewidth * world.map.width then
    self.player.x = world.map.tilewidth * world.map.width - halfX
  elseif self.player.x - halfX < 0 then
    self.player.x = halfX
  end

  if self.player.ySpeed > 224 then
    self.player.ySpeed = 224
  end
end

function PlayerPhysics:applyDirectionalVelocity()
  if self.player.direction == 1 then
    self.player:moveRight()
  elseif self.player.direction == -1 then
    self.player:moveLeft()
  end

  if self.player.isSprint then
    self.player:sprint()
  end

  if not love.keyboard.isDown("left") and not love.keyboard.isDown("right") and not self.player.isPoked then
    self.player:stop()
  end
end

return PlayerPhysics
