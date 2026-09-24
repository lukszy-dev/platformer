require "utils.MenuItem"

local Global = require "Global"
local STATE_NAMES = require "state.constants.StateNames"

MenuState = {}

local subStates = {
  [1] = {
    label = "NEW",
    state = STATE_NAMES.GAME
  },
  [2] = {
    label = "SCORES",
    state = STATE_NAMES.SCORES
  },
  [3] = {
    label = "SETTINGS",
    state = STATE_NAMES.SETTINGS
  },
  [4] = {
    label = "CONTROLS",
    state = STATE_NAMES.CONTROLS
  },
  [5] = {
    label = "EXIT",
    state = STATE_NAMES.EXIT
  }
}

function MenuState:new(config)
  local object = {
    menuItems = {},
    itemSelected = (config and config.lastSelectedItem) or 1,
    subState = subStates[(config and config.lastSelectedItem) or 1].state,
    pause = false,
    context = (config and config.context) or Global.context
  }
  setmetatable(object, { __index = MenuState })
  return object
end

function MenuState:init()
  for i, v in ipairs(subStates) do
    table.insert(self.menuItems, MenuItem:new(v.label, 90 + 30 * (i - 1)))
  end

  self.menuItems[self.itemSelected]:select(true)
end

function MenuState:update(dt)
  self.menuItems[self.itemSelected]:select(true)

  for _, v in ipairs(self.menuItems) do
    v:update(dt)
  end
end

function MenuState:draw()
  love.graphics.setColor(196 / 255, 207 / 255, 161 / 255)

  love.graphics.print(Global.title, 10, 5)
  love.graphics.print(Global.copyright, 10, 285)

  for _, v in ipairs(self.menuItems) do
    v:draw()
  end

  love.graphics.setColor(1, 1, 1)
end

function MenuState:keyreleased(_)
  return
end

function MenuState:keypressed(key)
  if key == "up" then
    self.menuItems[self.itemSelected]:select(false)
    if self.itemSelected > 1 then
      self.itemSelected = self.itemSelected - 1
    else
      self.itemSelected = #self.menuItems
    end

    self.subState = subStates[self.itemSelected].state
    if self.context and self.context.soundEvents then
      self.context.soundEvents:play("select")
    elseif soundEvents then
      soundEvents:play("select")
    end
  end
  if key == "down" then
    self.menuItems[self.itemSelected]:select(false)
    if self.itemSelected < #self.menuItems then
      self.itemSelected = self.itemSelected + 1
    else
      self.itemSelected = 1
    end

    self.subState = subStates[self.itemSelected].state
    if self.context and self.context.soundEvents then
      self.context.soundEvents:play("select")
    elseif soundEvents then
      soundEvents:play("select")
    end
  end
end
