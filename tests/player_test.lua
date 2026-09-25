package.path = "./?.lua;./?/init.lua;" .. package.path

love = {
  keyboard = {
    pressed = {}
  },
  graphics = {
    newQuad = function(x, y, width, height, sheetWidth, sheetHeight)
      return { x = x, y = y, width = width, height = height,
        sheetWidth = sheetWidth, sheetHeight = sheetHeight }
    end
  }
}

function love.keyboard.isDown(key)
  return love.keyboard.pressed[key] == true
end

local function assertEqual(actual, expected, message)
  assert(actual == expected, string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)))
end

local function assertNear(actual, expected, message)
  assert(math.abs(actual - expected) < 0.0001,
    string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)))
end

local function resetKeyboard()
  love.keyboard.pressed = {}
end

local function testInput()
  local PlayerInput = require "entity.player.PlayerInput"
  local jumpCount = 0
  local shotCount = 0
  local player = {
    direction = 1,
    hasJumped = false,
    isPoked = false,
    firedShots = 0,
    jump = function(self)
      jumpCount = jumpCount + 1
    end,
    shot = function(self)
      shotCount = shotCount + 1
      self.firedShots = self.firedShots + 1
    end
  }
  local input = PlayerInput:new(player)

  input:handleKeyPressed("right")
  assertEqual(player.direction, 1, "right input sets direction")

  input:handleKeyPressed("z")
  assertEqual(jumpCount, 1, "jump input invokes jump")
  assertEqual(player.hasJumped, true, "jump input latches key state")
  input:handleKeyPressed("z")
  assertEqual(jumpCount, 1, "held jump does not repeat")
  input:handleKeyReleased("z")
  assertEqual(player.hasJumped, false, "jump release clears key state")

  input:handleKeyPressed("x")
  assertEqual(shotCount, 1, "shoot input invokes shot")
  input:handleKeyPressed("r")
  assertEqual(player.firedShots, 0, "reload input resets fired shots")

  player.isPoked = true
  input:handleKeyPressed("left")
  assertEqual(player.direction, 1, "poked player ignores directional input")
end

local function testPhysics()
  local PlayerPhysics = require "entity.player.PlayerPhysics"
  local player = {
    x = 16,
    y = 0,
    width = 8,
    height = 8,
    xSpeed = 0,
    ySpeed = 0,
    direction = 1,
    runSpeed = 70,
    isSprint = false,
    isPoked = false,
    isMoving = false,
    mapColliding = function()
      return false
    end,
    moveRight = function(self)
      self.isMoving = true
      self.xSpeed = self.runSpeed
    end,
    moveLeft = function(self)
      self.isMoving = true
      self.xSpeed = -self.runSpeed
    end,
    sprint = function(self)
      self.xSpeed = self.xSpeed + self.direction * 30
    end,
    stop = function(self)
      self.isMoving = false
      self.xSpeed = 0
    end
  }
  local physics = PlayerPhysics:new(player)
  local world = {
    gravity = 760,
    map = { tilewidth = 8, tileheight = 8, width = 20, height = 20 }
  }

  physics:applyMovement(world, 1)
  assertNear(player.ySpeed, 224, "fall speed is capped")
  assertNear(player.x, 16, "stationary player does not move horizontally")

  love.keyboard.pressed.right = true
  physics:applyDirectionalVelocity()
  assertEqual(player.xSpeed, 70, "directional velocity uses run speed")
  assertEqual(player.isMoving, true, "directional velocity marks player moving")

  player.isSprint = true
  physics:applyDirectionalVelocity()
  assertEqual(player.xSpeed, 100, "sprint adds directional speed")

  resetKeyboard()
  player.isSprint = false
  physics:applyDirectionalVelocity()
  assertEqual(player.xSpeed, 0, "released movement stops player")
end

local function testCombat()
  local PlayerCombat = require "entity.player.PlayerCombat"
  local playedSound = nil
  local player = {
    context = {
      soundEvents = {
        play = function(_, name)
          playedSound = name
        end
      }
    },
    shots = {},
    hitpoints = 3,
    immune = false,
    immuneTime = 0,
    isPoked = false,
    onGround = false,
    runSpeed = 70,
    jump = function(self)
      self.jumped = true
    end,
    moveLeft = function(self)
      self.direction = -1
    end,
    moveRight = function(self)
      self.direction = 1
    end,
    stop = function(self)
      self.stopped = true
    end
  }
  local combat = PlayerCombat:new(player)
  local enemy = {
    xScale = 1,
    touchesObject = function()
      return true
    end,
    hitpoints = 1,
    name = "enemy-1"
  }
  local entities = { slime = { [enemy.name] = enemy } }

  combat:handleEnemyCollisions(entities)
  assertEqual(player.hitpoints, 2, "enemy collision damages player")
  assertEqual(player.immune, true, "enemy collision grants immunity")
  assertEqual(player.isPoked, true, "enemy collision marks player as poked")
  assertEqual(playedSound, "punch", "enemy collision plays punch sound")

  local bullet = {
    distance = 0,
    range = 100,
    x = 0,
    y = 0,
    xScale = 1,
    damage = 1,
    toRemove = false,
    iterator = 4,
    update = function() end,
    mapColliding = function()
      return false
    end,
    touchesObject = function()
      return true
    end,
    splashAnimation = function() end
  }
  player.shots = { bullet }
  player.context.soundEvents.play = function(_, name)
    playedSound = name
  end
  local combatWorld = {
    map = {},
    entities = { slime = { [enemy.name] = enemy } },
    score = 0
  }

  combat:handleAmmoUpdate(0.1, combatWorld)
  assertEqual(enemy.hitpoints, 0, "ammo damages enemy")
  assertEqual(combatWorld.score, 50, "ammo awards score")
  assertEqual(playedSound, "hit", "ammo collision plays hit sound")
  assertEqual(#player.shots, 0, "spent ammo is removed")
end

local function testPlayerConstruction()
  Global = { context = nil }
  require "entity.Player"
  local player = Player:new("player", 10, 20)

  assert(player.input ~= nil, "player creates input component")
  assert(player.physics ~= nil, "player creates physics component")
  assert(player.combat ~= nil, "player creates combat component")
  assertEqual(player.x, 10, "player preserves initial x position")
  assertEqual(player.y, 20, "player preserves initial y position")
end

local tests = {
  { name = "PlayerInput", run = testInput },
  { name = "PlayerPhysics", run = testPhysics },
  { name = "PlayerCombat", run = testCombat },
  { name = "Player construction", run = testPlayerConstruction }
}

for _, test in ipairs(tests) do
  resetKeyboard()
  local ok, err = pcall(test.run)
  if not ok then
    io.stderr:write("FAIL " .. test.name .. ": " .. tostring(err) .. "\n")
    os.exit(1)
  end
  print("PASS " .. test.name)
end

print("player tests ok")
