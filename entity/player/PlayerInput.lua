local PlayerInput = {}

function PlayerInput:new(player)
  local object = {
    player = player
  }
  setmetatable(object, { __index = PlayerInput })
  return object
end

function PlayerInput:handleKeyPressed(key)
  if not self.player.isPoked then
    if key == "right" and not love.keyboard.isDown("left") then
      self.player.direction = 1
    elseif key == "left" and not love.keyboard.isDown("right") then
      self.player.direction = -1
    end

    if key == "z" and not self.player.hasJumped then
      self.player:jump()
      self.player.hasJumped = true
    end

    if key == "r" then
      self.player.firedShots = 0
    end

    if key == "x" and self.player.firedShots < 5 then
      self.player:shot()
    end
  end
end

function PlayerInput:handleKeyReleased(key)
  if key == "z" then
    self.player.hasJumped = false
  end

  if key == "right" then
    if love.keyboard.isDown("left") then
      self.player.direction = -1
    end
  elseif key == "left" then
    if love.keyboard.isDown("right") then
      self.player.direction = 1
    end
  end
end

return PlayerInput
