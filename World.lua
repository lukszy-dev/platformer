require "entity.Player"
require "entity.Pickup"
require "entity.Slime"
require "entity.Behemoth"
require "entity.MegaBehemoth"
require "entity.Button"
require "entity.Spring"
require "entity.Spike"
require "entity.Warp"
require "entity.Acid"
require "entity.platform.Platform"
require "entity.Cloud"
require "utils.Camera"

local Global = require "Global"
local CollectionUtils = require "utils.CollectionUtils"
local STI = require "lib.SimpleTiledImpl.sti"
local ENTITY_NAMES = require "constants.EntityNames"
local ENTITY_TYPES = require "constants.EntityTypes"

World = {}

function World:new(config)
  local object = {
    camera = {},
    map = {},
    firstMap = 5,
    currentMap = 5,
    player = {},
    entities = {},
    gravity = 760, --800
    score = 0,
    context = (config and config.context) or Global.context
  }

  object.camera = Camera:new()
  object.camera.scaleX = Global.scale
  object.camera.scaleY = Global.scale

  setmetatable(object, { __index = World })
  return object
end

function World:init(level)
  self:clean()

  if level == nil then
    level = "map" .. self.currentMap
  end

  --[[ Load map ]]
  self.map = STI("resources/maps/" .. level .. ".lua")

  --[[ Hide object layer]]
  local objectLayer = self.map.layers["objects"]
  objectLayer.visible = false

  --[[ Iterate over objects in object layer and create entities ]]
  for _, object in pairs(objectLayer.objects) do
    if object.properties then
      local objectName = object.properties.name
      local objectType = object.properties.type
      local objectPosX = object.x + object.width / 2
      local objectPosY = object.y - object.height / 2

      local Entity = ENTITY_TYPES[objectType]

      if Entity then
        local entityObject = Entity:new(objectName, objectPosX, objectPosY, object.properties)
        entityObject.context = self.context

        if objectType == ENTITY_NAMES.PLAYER then
          self.player = entityObject
        else
          CollectionUtils.addToTable(self.entities, objectType, objectName, entityObject)
        end
      end
    end
  end

  self.camera:setBounds(0, 0, (self.map.width * self.map.tilewidth) - (Global.windowWidth * self.camera.scaleX),
    (self.map.height * self.map.tileheight) - (Global.windowHeight * self.camera.scaleX))
end

function World:update(dt)
  self.player:update(dt, self)
  self.map:update(dt)

  for _, v in pairs(self.entities) do
    for _, w in pairs(v) do
      w:update(dt, self)
    end
  end

  if self.camera.activated then
    self.camera:flowX(dt, self.player.x - Global.windowWidth / self.map.tilewidth,
      self.player.y - Global.windowHeight / self.map.tileheight, 80)
  else
    self.camera:setPosition(self.player.x - Global.windowWidth / self.map.tilewidth,
      self.player.y - Global.windowHeight / self.map.tileheight)
  end
end

function World:draw()
  local spriteAsset = (self.context and self.context.assets and self.context.assets.sprite) or sprite
  local hudAsset = (self.context and self.context.assets and self.context.assets.hud) or hud

  self.camera:set()

  self.map:draw()

  for _, v in pairs(self.entities) do
    for _, entity in pairs(v) do
      entity:draw()
    end
  end

  self.player:draw()

  self.camera:unset()

  --[[ Shake screen when player hit --]]
  if self.player.immune then
    love.graphics.translate(8 * (math.random() - 0.5), 8 * (math.random() - 0.5))
  end

  --[[ Draw HUD --]]
  love.graphics.draw(hudAsset, love.graphics.getWidth() - 168, 10, 0, 4, 4)
  love.graphics.print({ { 196 / 255, 207 / 255, 161 / 255 }, self.score }, 10, 5)

  for i = 1, self.player.hitpoints do
    love.graphics.draw(spriteAsset, heart, love.graphics.getWidth() - 20 - (i * 28), 22, 0, 4, 4)
  end

  for i = 1, (5 - self.player.firedShots) do
    love.graphics.draw(spriteAsset, clip, love.graphics.getWidth() - 20 - (i * 28), 46, 0, 4, 4)
  end

  --[[ Debug info --]]
  if Global.debug then
    Debug:info(math.floor(self.player.x + 0.5), math.floor(self.player.y + 0.5))
  end
end

-- World Cleanup
function World:clean()
  for k, v in pairs(self.entities) do
    for l, w in pairs(v) do
      self.entities[k][l] = nil
    end
    self.entities[k] = nil
  end
end

function World:change(level)
  self:init(level)
  self.camera:setBounds(0, 0, (self.map.width * self.map.tilewidth) - (Global.windowWidth * self.camera.scaleX),
    (self.map.height * self.map.tileheight) - (Global.windowHeight * self.camera.scaleX))
end

function World:keyreleased(key)
  self.player:keyreleased(key)
end

function World:keypressed(key)
  self.player:keypressed(key)

  if key == "l" then
    if self.camera.stop == false then
      self.camera.stop = true
    else
      self.camera.stop = false
      self.camera.activated = true
    end
  end
end
