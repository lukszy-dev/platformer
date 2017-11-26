require "entity.Ammo"
require "utils.Animation"

local Global = require "Global"
local Quad = love.graphics.newQuad

Player = {}

function Player:new(objectName, playerX, playerY)
	local object = {
		name = objectName,
		x = playerX, y = playerY,
		width = 8, height = 8,
		xSpeed = 0, ySpeed = 0,
		jumpSpeed = -130, runSpeed = 70,
		state = "stand",
		hitpoints = 3,
		isSprint = false,
		direction = 1,
		xScale = 1,
		xOffset = 0,
		onGround = false,
		jumpCount = 0, hasJumped = false,
		shots = {}, firedShots = 0,
		immunity = false, immunityTime = 2, isPoked = false,
		isMoving = false,
		animations = {
			move = {
				operator = Animation:new(0.14, 4,
				{
					Quad( 0, 16, 8, 8, 160, 144),
					Quad(24, 16, 8, 8, 160, 144),
					Quad(32, 16, 8, 8, 160, 144),
					Quad(40, 16, 8, 8, 160, 144)
				})
			},
			stand = {
				operator = Animation:new(0.35, 3,
				{
					Quad( 8, 16, 8, 8, 160, 144),
					Quad(16, 16, 8, 8, 160, 144),
					Quad( 8, 16, 8, 8, 160, 144)
				})
			}
		},
		sprintQuads = {
			-- Quad(24, 72, 8, 8, 160, 144),
			-- Quad(32, 72, 8, 8, 160, 144),
			-- Quad(40, 72, 8, 8, 160, 144),
			Quad(56, 72, 8, 8, 160, 144)
		}
	}
	setmetatable(object, { __index = Player })
	return object
end

function Player:jump()
	if self.isPoked or self.jumpCount < 2 then
		self.ySpeed = self.jumpSpeed
		self.onGround = false
		self.jumpCount = self.jumpCount + 1;
	end
end

function Player:specialJump(strenght)
	self.ySpeed = self.jumpSpeed - strenght
  	-- self.jumpCount = 1
end

function Player:moveRight()
	self.isMoving = true
	self.direction = 1
	self.xSpeed = self.direction * self.runSpeed
	self.xScale = self.direction
	self.xOffset = 0
end

function Player:moveLeft()
	self.isMoving = true
	self.direction = -1
	self.xSpeed = self.direction * self.runSpeed
	self.xScale = self.direction
	self.xOffset = 8
end

function Player:sprint()
	self.xSpeed = self.xSpeed + self.direction * 30
end

function Player:stop()
	self.isMoving = false
	self.xSpeed = 0
end

function Player:shot()
	self.firedShots = self.firedShots + 1

	bullet = Ammo:new(self.x, self.y, "bullet", 120)
	bullet.xScale = self.xScale
	bullet.xOffset = self.xOffset

	if self.xScale == 1 then
		bullet.x = bullet.x + bullet.width / 2
	else
		bullet.x = bullet.x - bullet.width / 2
	end

	table.insert(self.shots, bullet)

	soundEvents:play("shot")
end

function Player:getAnimationQuad()
	return self.animations[self.state].operator:getCurrentQuad()
end

function Player:updateAnimations(dt)
	self.animations[self.state].operator:update(dt)
end

function Player:draw()
	--Bohater
	love.graphics.draw(sprite, self:getAnimationQuad(), self.x - (self.width / 2),
		self.y - (self.height / 2), 0, self.xScale, 1, self.xOffset)
	--Strzały
	for i, v in ipairs(self.shots) do
		v:draw()
	end

	if self.isSprint and self.xSpeed ~= 0 then
		love.graphics.draw(sprite, self.sprintQuads[1], self.x - self.direction * (self.width * math.abs(0.5 + self.direction)), 
			self.y - (self.height / 2), 0, self.xScale, 1, self.xOffset)
	end

	-- love.graphics.rectangle("line", self.x - (self.width / 2), self.y - (self.height / 2), self.width, self.height)
end

function Player:collide(event)
	if event == "floor" then
		self.ySpeed = 0
		self.onGround = true
		self.jumpCount = 0
	end
	if event == "ceiling" then
		self.ySpeed = 0
	end
	if event == "platform" then
		self.onGround = true
		self.jumpCount = 0
	end
end

function Player:mapColliding(map, x, y)
	local layer = Global.map.layers["ground"]
	local tileX = math.floor(x / Global.map.tilewidth) + 1
	local tileY = math.floor(y / Global.map.tileheight) + 1
	--print(tileX .. " " .. tileY)
	if (Global.map.width < tileX or Global.map.height < tileY or tileX <= 0 or tileY <= 0) then
		return false
	end
	local tile = layer.data[tileY][tileX]

	return tile and (tile.properties or {}).solid
end

function Player:enemyColliding()
	--Kolizja z przeciwnikiem
	for _, v in pairs({Global.objects["behemoth"], Global.objects["slime"]}) do
		for _, w in pairs(v) do	
			if w:touchesObject(self) and not self.immunity then
				self.isPoked = true
				soundEvents:play("punch")

				if self.immunity == false then
					self.immunity = true
					self.immunityTime = 2
					self.hitpoints = self.hitpoints - 1
				end

				self.runSpeed = self.runSpeed + 30
				self:jump()

				if love.keyboard.isDown("right")
					or (w.xScale == -1 and not love.keyboard.isDown("left")) then
					self:moveLeft()
				elseif love.keyboard.isDown("left") or w.xScale == 1 then
					self:moveRight()
				end
			end
		end

		if self.onGround and self.isPoked then
			self.isPoked = false
			self.runSpeed = self.runSpeed - 30
			self:stop()
		end
	end
end

function Player:ammoUpdate(dt)
	for i, v in ipairs(self.shots) do
		v:update(dt)

		if (v.distance > v.range or v.distance < - v.range)
			or v:mapColliding(map, v.x + v.xScale * 2, v.y) then
			v.toRemove = true
		end

		for _, w in pairs({Global.objects["behemoth"], Global.objects["slime"]}) do
			for _, u in pairs(w) do 
				if v:touchesObject(u) and not v.toRemove then
					u.hitpoints = u.hitpoints - v.damage
					if u.hitpoints <= 0 then
						Global.objects["behemoth"][u.name] = nil
						Global.objects["slime"][u.name] = nil
					end

					v.toRemove = true
					Global.score = Global.score + 50
					soundEvents:play("hit")
				end
			end
		end

		if v.toRemove then
			v:splashAnimation(dt, 0.10, 4) -- 4 klatki żeby animacja się skończyła
			if v.iterator == 4 then
				table.remove(self.shots, i)
			end
		end
	end
end

function Player:update(dt)
	local halfX = math.floor(self.width / 2)
	local halfY = math.floor(self.height / 2)

	self.ySpeed = self.ySpeed + (Global.gravity * dt)

	--Kolizje w pionie
	local nextY = self.y + (self.ySpeed * dt)
	if self.ySpeed < 0 then
		if not (self:mapColliding(Global.map, self.x - halfX, nextY - halfY))
		and not (self:mapColliding(Global.map, self.x + halfX - 1, nextY - halfY)) then
			self.y = nextY
			self.onGround = false
		else
			self.y = nextY + Global.map.tileheight - ((nextY - halfY) % Global.map.tileheight)
			self:collide("ceiling")
		end
	elseif self.ySpeed > 0 then
		if not (self:mapColliding(Global.map, self.x - halfX, nextY + halfY))
		and not (self:mapColliding(Global.map, self.x + halfX - 1, nextY + halfY)) then
			self.y = nextY
			self.onGround = false
		else
			self.y = nextY - ((nextY + halfY) % Global.map.tileheight)
			self:collide("floor")
		end
	end

	--Kolizje w poziomie
	local nextX = self.x + (self.xSpeed * dt)
	if self.xSpeed > 0 then
		if not (self:mapColliding(Global.map, nextX + halfX, self.y - halfY))
		and not (self:mapColliding(Global.map, nextX + halfX, self.y + halfY - 1)) then
			self.x = nextX
		else
			self.x = nextX - ((nextX + halfX) % Global.map.tilewidth)
		end
	elseif self.xSpeed < 0 then
		if not (self:mapColliding(Global.map, nextX - halfX, self.y - halfY))
		and not (self:mapColliding(Global.map, nextX - halfX, self.y + halfY - 1)) then
			self.x = nextX
		else
			self.x = nextX + Global.map.tilewidth - ((nextX - halfX) % Global.map.tilewidth)
		end
	end

	--Ograniczenie ruchu do wielkości mapy
	if self.x + self.width / 2 > Global.map.tilewidth * Global.map.width then
		self.x = Global.map.tilewidth * Global.map.width - self.width / 2
	end

	--Aktualizacja pocisków
	self:ammoUpdate(dt)

	--Kolizja z przeciwnikami
	self:enemyColliding()

	--Ograniczenie prędkości spadania
	if self.ySpeed > 224 then
		self.ySpeed = 224
	end

	--Nietykalność
	if self.immunityTime > 0 then
		self.immunityTime = self.immunityTime - dt
		if self.immunityTime <= 0 then
			self.immunity = false
		end
	end

	self:updateAnimations(dt)

	if self.direction == 1 then
		self:moveRight()
	elseif self.direction == -1 then
		self:moveLeft()
	end

	if self.isSprint then
		self:sprint()
	end

	if not love.keyboard.isDown("left")
	and not love.keyboard.isDown("right")
	and not self.isPoked then
		self:stop()
	end

	self.isSprint = love.keyboard.isDown("lshift")

	self.state = self:getState()
end

function Player:isAlive()
	return not (self.hitpoints <= 0
		or (self.y + math.floor(self.height / 2)) > Global.map.height * Global.map.tileheight)
end

function Player:getState()
	local myState = ""
	if self.xSpeed ~= 0 and self.isMoving then
		myState = "move"
	else
		myState = "stand"
	end
	return myState
end

function Player:keypressed(key)
	if not self.isPoked then
		if key == "right" and not love.keyboard.isDown("left") then --prawo
			self.direction = 1
		elseif key == "left" and not love.keyboard.isDown("right") then --lewo
			self.direction = -1
		end

		if key == "z" and not self.hasJumped then --skok
			self:jump()
			self.hasJumped = true
		end
		if key == "r" then
			self.firedShots = 0
		end
		if (key == "x") and (self.firedShots < 5) then
			self:shot()
		end
	end
end

function Player:keyreleased(key)
	if key == "z" then
		self.hasJumped = false
	end
	if key == "right" then --prawo
		if love.keyboard.isDown("left") then
			self.direction = -1
		end
	elseif key == "left" then --lewo
		if love.keyboard.isDown("right") then
			self.direction = 1
		end
	end
end