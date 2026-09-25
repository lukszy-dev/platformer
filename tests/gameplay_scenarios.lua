package.path = "./?.lua;./?/init.lua;" .. package.path
unpack = table.unpack

love = {
  keyboard = {},
  graphics = {
    getWidth = function()
      return 640
    end,
    getHeight = function()
      return 360
    end,
    setColor = function() end,
    print = function() end,
    push = function() end,
    pop = function() end,
    translate = function() end,
    newQuad = function()
      return {}
    end
  },
  audio = {},
  event = {
    quit = function()
      love.event.quitCalled = true
    end
  }
}

local function assertEqual(actual, expected, message)
  assert(actual == expected, string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)))
end

local function newProperties()
  local values = {
    { "AUDIO", true },
    { "VSYNC", true }
  }
  local properties = { properties = values }

  setmetatable(properties, {
    __call = function(self)
      local index = 0
      return function()
        index = index + 1
        if self.properties[index] then
          return index, unpack(self.properties[index])
        end
      end
    end
  })

  function properties:add(name, value)
    for index, item in ipairs(self.properties) do
      if item[1] == name then
        self.properties[index] = { name, value }
        return
      end
    end
  end

  function properties:get(name)
    for _, item in ipairs(self.properties) do
      if item[1] == name then
        return item[2]
      end
    end
  end

  function properties:save()
    self.saved = true
  end

  return properties
end

local function newScores()
  local scores = { entries = {} }

  function scores:add(name, score)
    table.insert(self.entries, { name, score })
  end

  function scores:save()
    self.saved = true
  end

  return scores
end

World = {}
package.preload["World"] = function()
  return World
end

require "event.Events"
require "state.State"

local GameState = _G.GameState
local originalGameStateNew = GameState.new
local fakeGameEntered = false

function GameState:new(config)
  local object = {
    context = config.context,
    isEnd = false
  }
  setmetatable(object, { __index = GameState })
  return object
end

function GameState:init()
  fakeGameEntered = true
end

function GameState:update()
end

function GameState:draw()
end

function GameState:keypressed()
end

function GameState:keyreleased()
end

function GameState:getScore()
  return 0
end

local context = {
  title = "Platformer",
  copyright = "Test",
  properties = newProperties(),
  propertiesEvents = Events:new(false),
  scores = newScores(),
  soundEvents = {
    play = function(self, sound)
      self.lastSound = sound
    end
  },
  mainTheme = {
    stop = function(self)
      self.stopped = true
    end
  }
}

local state = State:new(context)
state:set()
assertEqual(state.name, nil, "initial menu keeps unnamed state")
assertEqual(state.currentState.subState, "game", "menu starts on new game")

state:update(0)
state:keypressed("down")
state:keypressed("down")
state:keypressed("return")
assertEqual(state.name, "settings", "menu navigation enters settings")
assertEqual(state.currentState.parentMenu, "menu", "settings has menu parent")

local previousAudio = context.properties:get("AUDIO")
state:keypressed("right")
assertEqual(context.properties.properties[1][2], false, "settings toggles audio property")
assertEqual(context.soundEvents.lastSound, "select", "settings navigation plays select sound")
assert(previousAudio ~= false, "scenario starts with audio enabled")

state:keypressed("escape")
assertEqual(state.name, "menu", "escape returns to parent menu")
assertEqual(context.mainTheme.stopped, true, "escape stops the theme")

state:set("game")
assertEqual(fakeGameEntered, true, "menu can enter gameplay state")
assertEqual(state.name, "game", "game state is active")

state:set("submit", { score = 125 })
state.currentState:keypressed("return")
assertEqual(#context.scores.entries, 1, "score submission creates an entry")
assertEqual(context.scores.entries[1][1], "AAA", "score submission uses current initials")
assertEqual(context.scores.entries[1][2], 125, "score submission preserves score")

state:set("exit")
assertEqual(context.scores.saved, true, "exit saves scores")
assertEqual(context.properties.saved, true, "exit saves properties")
assertEqual(love.event.quitCalled, true, "exit requests application quit")

GameState.new = originalGameStateNew
print("gameplay scenarios ok")
