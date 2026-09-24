require "utils.MenuItem"

local Global = require "Global"

HighScoreState = {}

function HighScoreState:new(config)
  local object = {
    parentMenu = "menu",
    context = (config and config.context) or Global.context
  }
  setmetatable(object, { __index = HighScoreState })
  return object
end

function HighScoreState:init()
  return
end

function HighScoreState:update(dt)
  return
end

function HighScoreState:draw()
  local scores = (self.context and self.context.scores) or Global.scores
  local prefix = ""

  for i, score, name in scores() do
    if i == 1 then
      prefix = "1ST"
    elseif i == 2 then
      prefix = "2ND"
    elseif i == 3 then
      prefix = "3RD"
    else
      prefix = i .. "TH"
    end

    love.graphics.setColor(196 / 255, 207 / 255, 161 / 255)
    love.graphics.print(prefix, 355, 10 + 30 * (i - 1))
    love.graphics.print(name, 455, 10 + 30 * (i - 1))
    love.graphics.print(score, 555, 10 + 30 * (i - 1))
    love.graphics.setColor(1, 1, 1)
  end
end

function HighScoreState:keyreleased(key)
  return
end

function HighScoreState:keypressed(key)
  return
end
