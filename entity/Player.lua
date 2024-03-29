require "entity.Ammo"
require "utils.Animation"

local Quad = love.graphics.newQuad

Player = {}

function Player:new(objectName, playerX, playerY)
  local object = {
    name = objectName,
    x = playerX, y = playerY,
    width = 8, height = 8,
    xSpeed = 0, ySpeed = 0,
    jumpSpeed = -130, runSpeed = 70,
    state = "stand",
    hitpoints = 3,
    isSprint = false,
    direction = 1,
    xScale = 1,
    xOffset = 0,
    onGround = false,
    jumpCount = 0, hasJumped = false,
    shots = {}, firedShots = 0, selectedWeapon = "bullet",
    immune = false, immuneTime = 2, isPoked = false,
    isMoving = false,
    animations = {
      move = {
        operator = Animation:new(0.12, {
          Quad( 0, 16, 8, 8, 160, 144),
          Quad( 0, 24, 8, 8, 160, 144),
          Quad(24, 16, 8, 8, 160, 144),
          Quad(32, 16, 8, 8, 160, 144),
          Quad( 0, 24, 8, 8, 160, 144),
          Quad(40, 16, 8, 8, 160, 144)
        })
      },
      stand = {
        operator = Animation:new(0.35, {
          Quad( 8, 16, 8, 8, 160, 144),
          Quad(16, 16, 8, 8, 160, 144),
          Quad( 8, 16, 8, 8, 160, 144)
        })
      }
    },
    sprintQuads = {
      -- Quad(24, 72, 8, 8, 160, 144),
      -- Quad(32, 72, 8, 8, 160, 144),
      -- Quad(40, 72, 8, 8, 160, 144),
      Quad(56, 72, 8, 8, 160, 144)
    }
  }
  setmetatable(object, { __index = Player })
  return object
end

function Player:jump()
  if self.isPoked or self.jumpCount < 2 then
    self.ySpeed = self.jumpSpeed
    self.onGround = false
    self.jumpCount = self.jumpCount + 1;
  end
end

function Player:specialJump(strenght)
  self.ySpeed = self.jumpSpeed - strenght
  self.jumpCount = 0
end

function Player:moveRight()
  self.isMoving = true
  self.direction = 1
  self.xSpeed = self.direction * self.runSpeed
  self.xScale = self.direction
  self.xOffset = 0
end

function Player:moveLeft()
  self.isMoving = true
  self.direction = -1
  self.xSpeed = self.direction * self.runSpeed
  self.xScale = self.direction
  self.xOffset = self.width
end

function Player:sprint()
  self.xSpeed = self.xSpeed + self.direction * 30
end

function Player:stop()
  self.isMoving = false
  self.xSpeed = 0
end

function Player:shot()
  self.firedShots = self.firedShots + 1

  local bullet = Ammo:new(self.x, self.y, self.selectedWeapon, 120)
  bullet.xScale = self.xScale
  bullet.xOffset = self.xOffset

  if self.xScale == 1 then
    bullet.x = bullet.x + bullet.width / 2
  else
    bullet.x = bullet.x - bullet.width / 2
  end

  table.insert(self.shots, bullet)

  soundEvents:play("shot")
end

function Player:getAnimationQuad()
  return self.animations[self.state].operator:getCurrentQuad()
end

function Player:updateAnimations(dt)
  self.animations[self.state].operator:update(dt)
end

function Player:draw()
  --Bohater
  love.graphics.draw(sprite, self:getAnimationQuad(), self.x - (self.width / 2),
    self.y - (self.height / 2), 0, self.xScale, 1, self.xOffset)
  --Strzały
  for i, v in ipairs(self.shots) do
    v:draw()
  end

  if self.isSprint and self.xSpeed ~= 0 then
    love.graphics.draw(sprite, self.sprintQuads[1],
      self.x - self.direction * (self.width * math.abs(0.5 + self.direction)),
      self.y - (self.height / 2),
      0, self.xScale, 1, self.xOffset)
  end

  -- love.graphics.rectangle("line", self.x - (self.width / 2), self.y - (self.height / 2), self.width, self.height)
end

function Player:collide(event)
  if event == "floor" then
    self.ySpeed = 0
    self.onGround = true
    self.jumpCount = 0
  end
  if event == "ceiling" then
    self.ySpeed = 0
  end
  if event == "platform" then
    self.onGround = true
    self.jumpCount = 0
  end
end

function Player:mapColliding(map, x, y)
  local layer = map.layers["ground"]
  local tileX = math.floor(x / map.tilewidth) + 1
  local tileY = math.floor(y / map.tileheight) + 1
  if (map.width < tileX or map.height < tileY or tileX <= 0 or tileY <= 0) then
    return false
  end
  local tile = layer.data[tileY][tileX]

  return tile and (tile.properties or {}).solid
end

function Player:enemyColliding(entities)
  --Kolizja z przeciwnikiem
  for _, v in pairs({"behemoth", "slime", "mega_behemoth"}) do
    local enemies = entities[v] or {}
    for _, w in pairs(enemies) do
      if w:touchesObject(self) and not self.immune then
        self.isPoked = true
        soundEvents:play("punch")

        if self.immune == false then
          self.immune = true
          self.immuneTime = 2
          self.hitpoints = self.hitpoints - 1
        end

        self.runSpeed = self.runSpeed + 30
        self:jump()

        if love.keyboard.isDown("right")
          or (w.xScale == -1 and not love.keyboard.isDown("left")) then
          self:moveLeft()
        elseif love.keyboard.isDown("left") or w.xScale == 1 then
          self:moveRight()
        end
      end
    end

    if self.onGround and self.isPoked then
      self.isPoked = false
      self.runSpeed = self.runSpeed - 30
      self:stop()
    end
  end
end

function Player:ammoUpdate(dt, world)
  for i, v in ipairs(self.shots) do
    v:update(dt, world)

    if (v.distance > v.range or v.distance < - v.range)
      or v:mapColliding(world.map, v.x + v.xScale * 2, v.y) then
      v.toRemove = true
    end

    for _, w in pairs({"behemoth", "slime", "mega_behemoth"}) do
      local enemies = world.entities[w] or {}
      for _, u in pairs(enemies) do 
        if v:touchesObject(u) and not v.toRemove then
          u.hitpoints = u.hitpoints - v.damage
          if u.hitpoints <= 0 then
            world.entities[w][u.name] = nil
          end

          v.toRemove = true
          world.score = world.score + 50
          soundEvents:play("hit")
        end
      end
    end

    if v.toRemove then
      v:splashAnimation(dt, 0.10, 4) -- 4 klatki żeby animacja się skończyła
      if v.iterator == 4 then
        table.remove(self.shots, i)
      end
    end
  end
end

function Player:update(dt, world)
  local halfX = math.floor(self.width / 2)
  local halfY = math.floor(self.height / 2)

  self.ySpeed = self.ySpeed + (world.gravity * dt)

  --Kolizje w pionie
  local nextY = self.y + (self.ySpeed * dt)
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

  --Kolizje w poziomie
  local nextX = self.x + (self.xSpeed * dt)
  if self.xSpeed > 0 then
    if not (self:mapColliding(world.map, nextX + halfX, self.y - halfY))
    and not (self:mapColliding(world.map, nextX + halfX, self.y + halfY - 1)) then
      self.x = nextX
    else
      self.x = nextX - ((nextX + halfX) % world.map.tilewidth)
    end
  elseif self.xSpeed < 0 then
    if not (self:mapColliding(world.map, nextX - halfX, self.y - halfY))
    and not (self:mapColliding(world.map, nextX - halfX, self.y + halfY - 1)) then
      self.x = nextX
    else
      self.x = nextX + world.map.tilewidth - ((nextX - halfX) % world.map.tilewidth)
    end
  end

  --Ograniczenie ruchu do wielkości mapy
  if self.x + halfX > world.map.tilewidth * world.map.width then
    self.x = world.map.tilewidth * world.map.width - halfX
  elseif self.x - halfX < 0 then
    self.x = halfX
  end

  --Aktualizacja pocisków
  self:ammoUpdate(dt, world)

  --Kolizja z przeciwnikami
  self:enemyColliding(world.entities)

  --Ograniczenie prędkości spadania
  if self.ySpeed > 224 then
    self.ySpeed = 224
  end

  --Nietykalność
  if self.immuneTime > 0 then
    self.immuneTime = self.immuneTime - dt
    if self.immuneTime <= 0 then
      self.immune = false
    end
  end

  self:updateAnimations(dt)

  if self.direction == 1 then
    self:moveRight()
  elseif self.direction == -1 then
    self:moveLeft()
  end

  if self.isSprint then
    self:sprint()
  end

  if not love.keyboard.isDown("left") and not love.keyboard.isDown("right") and not self.isPoked then
    self:stop()
  end

  self.isSprint = love.keyboard.isDown("lshift")

  self.state = self:getState()
end

function Player:isAlive(map)
  return not (self.hitpoints <= 0
    or (self.y + math.floor(self.height / 2)) > map.height * map.tileheight)
end

function Player:getState()
  local myState = ""
  if self.xSpeed ~= 0 and self.isMoving then
    myState = "move"
  else
    myState = "stand"
  end
  return myState
end

function Player:keypressed(key)
  if not self.isPoked then
    if key == "right" and not love.keyboard.isDown("left") then --prawo
      self.direction = 1
    elseif key == "left" and not love.keyboard.isDown("right") then --lewo
      self.direction = -1
    end

    if key == "z" and not self.hasJumped then --skok
      self:jump()
      self.hasJumped = true
    end
    if key == "r" then
      self.firedShots = 0
    end
    if (key == "x") and (self.firedShots < 5) then
      self:shot()
    end
  end
end

function Player:keyreleased(key)
  if key == "z" then
    self.hasJumped = false
  end
  if key == "right" then --prawo
    if love.keyboard.isDown("left") then
      self.direction = -1
    end
  elseif key == "left" then --lewo
    if love.keyboard.isDown("right") then
      self.direction = 1
    end
  end
end
