SubmitScoreState = {}

local alphabet = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
            'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
            'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0',
            '1', '2', '3', '4', '5', '6', '7', '8', '9'}

function SubmitScoreState:new()
	object = {
		charSelected = 1,
		itemSelected = 1,
		submitName = {},
    parentMenu = "scores"
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
  love.graphics.print("NOTHING TO FEAR", 10, 5)
  	love.graphics.print("(C) 2016 WILSON", 10, 285)

	love.graphics.print("ENTER INITIALS", 350, 100)

	for i, char in ipairs(self.submitName) do
		love.graphics.print(char, 400 + 30 * i, 160)
	end
  for i = 1, 3 do
    if i == self.itemSelected then
      love.graphics.rectangle("fill", 400 + 30 * i, 190, 16, 3)
    end
  end
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
    for i = 1, 3 do
      name = name .. self.submitName[i]
    end
    Global.scores:add(name, Global.score)
  end
end
