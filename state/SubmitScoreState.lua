local Global = require "Global"

SubmitScoreState = {}

local alphabet = {
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
  'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
  'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0',
  '1', '2', '3', '4', '5', '6', '7', '8', '9'
}

function SubmitScoreState:new(config)
  local object = {
    charSelected = 1,
    itemSelected = 1,
    submitName = {},
    parentMenu = "scores",
    score = (config and config.score) or nil,
    context = (config and config.context) or Global.context
  }
  setmetatable(object, { __index = SubmitScoreState })
  return object
end

function SubmitScoreState:init()
  for i = 1, 3 do
    self.submitName[i] = alphabet[1]
  end
end

function SubmitScoreState:update(dt)
  self.submitName[self.itemSelected] = alphabet[self.charSelected]
end

function SubmitScoreState:draw()
  love.graphics.setColor(196 / 255, 207 / 255, 161 / 255)

  love.graphics.print("ENTER INITIALS", 350, 100)

  for i, char in ipairs(self.submitName) do
    love.graphics.print(char, 400 + 30 * i, 160)
  end

  --[[ Character underline]]
  for i = 1, 3 do
    if i == self.itemSelected then
      love.graphics.rectangle("fill", 400 + 30 * i, 190, 16, 3)
    end
  end

  love.graphics.setColor(1, 1, 1)
end

function SubmitScoreState:keyreleased(key)
  return
end

local function findIndexOfChar(char)
  for i, v in ipairs(alphabet) do
    if v == char then
      return i
    end
  end
  return 1
end

function SubmitScoreState:keypressed(key)
  if key == "up" then
    if self.charSelected == #alphabet then
      self.charSelected = 1
    else
      self.charSelected = self.charSelected + 1
    end
  end

  if key == "down" then
    if self.charSelected == 1 then
      self.charSelected = #alphabet
    else
      self.charSelected = self.charSelected - 1
    end
  end

  if key == "right" then
    if self.itemSelected < 3 then
      self.charSelected = findIndexOfChar(self.submitName[self.itemSelected + 1])
      self.itemSelected = self.itemSelected + 1
    end
  end

  if key == "left" then
    if self.itemSelected > 1 then
      self.charSelected = findIndexOfChar(self.submitName[self.itemSelected - 1])
      self.itemSelected = self.itemSelected - 1
    end
  end

  if key == "return" or key == "enter" then
    local name = ""
    local scores = (self.context and self.context.scores) or Global.scores

    for i = 1, 3 do
      name = name .. self.submitName[i]
    end

		scores:add(name, self.score)
	end
end
