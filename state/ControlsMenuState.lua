require "utils.MenuItem"

local Global = require "Global"

ControlsMenuState = {}

function ControlsMenuState:new(config)
  local object = {
    menuItems = {},
    parentMenu = "menu",
    context = (config and config.context) or Global.context
  }
  setmetatable(object, { __index = ControlsMenuState })
  return object
end

function ControlsMenuState:init()
  table.insert(self.menuItems, MenuItem:new("Z - JUMP", 90))
  table.insert(self.menuItems, MenuItem:new("X - SHOT", 120))
  table.insert(self.menuItems, MenuItem:new("R - RELOAD", 150))
end

function ControlsMenuState:update(dt)
  return
end

function ControlsMenuState:draw()
  love.graphics.setColor(196 / 255, 207 / 255, 161 / 255)

  for _, v in ipairs(self.menuItems) do
    v:draw()
  end

  love.graphics.setColor(1, 1, 1)
end

function ControlsMenuState:keyreleased(key)
  return
end

function ControlsMenuState:keypressed(key)
  return
end
