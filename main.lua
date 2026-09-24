require "Debug"
require "state.State"
require "utils.scores.Scores"
require "utils.properties.Properties"
require "event.SoundEvents"

local MathUtils = require "utils.MathUtils"
local SystemPropertyType = require "utils.properties.SystemPropertyType"
local GameContext = require "GameContext"
local GameConfig = require "config.GameConfig"
local Global = require "Global"

local handleAudioPropertyChange
local handleVsyncPropertyChange
local loadResources
local initProperties
local initScores

local state = {}

function love.load()
  Global.context = GameContext:new()
  loadResources(Global.context)

  Global.properties = Properties:new("settings")
  Global.properties:load()

  initProperties(Global.properties)

  handleAudioPropertyChange()
  handleVsyncPropertyChange()

  Global.propertiesEvents = Events:new(false)
  Global.propertiesEvents:hook("AUDIO", handleAudioPropertyChange)
  Global.propertiesEvents:hook("VSYNC", handleVsyncPropertyChange)

  Global.scores = Scores:new("scores", 10)
  Global.scores:load()

  initScores(Global.scores)

  state = State:new()
  state:set()
end

function handleAudioPropertyChange()
  local isAudio = Global.properties:get(SystemPropertyType.AUDIO)
  print(SystemPropertyType.AUDIO, isAudio)
  if tostring(isAudio) == "true" then
    love.audio.setVolume(1.0)
  else
    love.audio.setVolume(0.0)
  end
end

function handleVsyncPropertyChange()
  local isVsync = Global.properties:get(SystemPropertyType.VSYNC)
  print(SystemPropertyType.VSYNC, isVsync)
  if tostring(isVsync) == "true" then
    love.window.setMode(GameConfig.windowWidth, GameConfig.windowHeight, { vsync = true })
  else
    love.window.setMode(GameConfig.windowWidth, GameConfig.windowHeight, { vsync = false })
  end
end

function initScores(scores)
  if Global.scores:size() == 0 then
    for i = 1, 10 do
      Global.scores:add("AAA", 0)
    end
    Global.scores:save()
  end
  assert(Global.scores:size() == 10, "Invalid number of scores!")
end

function initProperties(properties)
  if properties:size() == 0 then
    for key, _ in pairs(SystemPropertyType) do
      properties:add(key, true)
    end
    
    properties:save()
  end
  assert(properties:size() == 2, "Invalid number of system properties!")
end

function love.update(dt)
  dt = MathUtils.clamp(dt, 0, 0.05) --math.min(dt, 0.016)
  state:update(dt)
end

function love.draw()
  state:draw()
end

function love.keyreleased(key)
  state:keyreleased(key)
end

function love.keypressed(key, isrepeat)
  state:keypressed(key)
end

function loadResources(context)
  context.soundEvents = SoundEvents:new(false)

  love.graphics.setBackgroundColor(31 / 255, 31 / 255, 31 / 255)
  love.graphics.setDefaultFilter("nearest", "nearest")
  context.assets.sprite = love.graphics.newImage("resources/images/spritesheet.png")
  context.assets.hud = love.graphics.newImage("resources/images/hud.png")
  context.assets.font = love.graphics.newFont("resources/fonts/visitor2.ttf", 38)
  love.graphics.setFont(context.assets.font)

  heart = love.graphics.newQuad(32, 40, 8, 8, 160, 144)
  clip = love.graphics.newQuad(16, 32, 8, 8, 160, 144)

  context.soundEvents:addSound("hit", love.audio.newSource("resources/sounds/hit.wav", "static"))
  context.soundEvents:addSound("select", love.audio.newSource("resources/sounds/select.wav", "static"))
  context.soundEvents:addSound("shot", love.audio.newSource("resources/sounds/shot.wav", "static"))
  context.soundEvents:addSound("click_on", love.audio.newSource("resources/sounds/clickon.wav", "static"))
  context.soundEvents:addSound("click_off", love.audio.newSource("resources/sounds/clickoff.wav", "static"))
  context.soundEvents:addSound("punch", love.audio.newSource("resources/sounds/punch.wav", "static"))
  context.soundEvents:addSound("jump", love.audio.newSource("resources/sounds/jump.wav", "static"))
  context.soundEvents:addSound("warp", love.audio.newSource("resources/sounds/warp.wav", "static"))

  context.mainTheme = love.audio.newSource("resources/music/Underclocked.mp3", "stream")
  context.mainTheme:setLooping(true)
  context.mainTheme:setVolume(0.5)

  soundEvents = context.soundEvents
  sprite = context.assets.sprite
  hud = context.assets.hud
  font = context.assets.font
  mainTheme = context.mainTheme
end
