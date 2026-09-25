local Quad = love.graphics.newQuad

local PlayerAnimator = {}

function PlayerAnimator:new()
  local object = {
    animations = {
      move = {
        operator = Animation:new(0.12, {
          Quad(0, 16, 8, 8, 160, 144),
          Quad(0, 24, 8, 8, 160, 144),
          Quad(24, 16, 8, 8, 160, 144),
          Quad(32, 16, 8, 8, 160, 144),
          Quad(0, 24, 8, 8, 160, 144),
          Quad(40, 16, 8, 8, 160, 144)
        })
      },
      stand = {
        operator = Animation:new(0.35, {
          Quad(8, 16, 8, 8, 160, 144),
          Quad(16, 16, 8, 8, 160, 144),
          Quad(8, 16, 8, 8, 160, 144)
        })
      }
    },
    sprintQuad = Quad(56, 72, 8, 8, 160, 144)
  }
  setmetatable(object, { __index = PlayerAnimator })
  return object
end

function PlayerAnimator:getCurrentQuad(state)
  return self.animations[state].operator:getCurrentQuad()
end

function PlayerAnimator:update(state, dt)
  self.animations[state].operator:update(dt)
end

function PlayerAnimator:getSprintQuad()
  return self.sprintQuad
end

return PlayerAnimator
