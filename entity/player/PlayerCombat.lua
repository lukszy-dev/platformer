local PlayerCombat = {}

function PlayerCombat:new(player)
  local object = {
    player = player
  }
  setmetatable(object, { __index = PlayerCombat })
  return object
end

function PlayerCombat:handleAmmoUpdate(dt, world)
  for i, v in ipairs(self.player.shots) do
    v:update(dt, world)

    if (v.distance > v.range or v.distance < -v.range)
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
          local sound = (self.player.context and self.player.context.soundEvents) or soundEvents
          if sound then
            sound:play("hit")
          end
        end
      end
    end

    if v.toRemove then
      v:splashAnimation(dt, 0.10, 4)
      if v.iterator == 4 then
        table.remove(self.player.shots, i)
      end
    end
  end
end

function PlayerCombat:handleEnemyCollisions(entities)
  for _, v in pairs({"behemoth", "slime", "mega_behemoth"}) do
    local enemies = entities[v] or {}
    for _, w in pairs(enemies) do
      if w:touchesObject(self.player) and not self.player.immune then
        self.player.isPoked = true
        local sound = (self.player.context and self.player.context.soundEvents) or soundEvents
        if sound then
          sound:play("punch")
        end

        if self.player.immune == false then
          self.player.immune = true
          self.player.immuneTime = 2
          self.player.hitpoints = self.player.hitpoints - 1
        end

        self.player.runSpeed = self.player.runSpeed + 30
        self.player:jump()

        if love.keyboard.isDown("right")
          or (w.xScale == -1 and not love.keyboard.isDown("left")) then
          self.player:moveLeft()
        elseif love.keyboard.isDown("left") or w.xScale == 1 then
          self.player:moveRight()
        end
      end
    end

    if self.player.onGround and self.player.isPoked then
      self.player.isPoked = false
      self.player.runSpeed = self.player.runSpeed - 30
      self.player:stop()
    end
  end
end

return PlayerCombat
