local sti = require "sti"
require("AnAL")

function love.load()
	local SmurfTileset  = love.graphics.newImage("Pictures/Tilesets/SmurfTileset.png")
	animPlayer_Right = newAnimation(SmurfTileset, 64, 64, 0.1, 0)
	
    map = sti.new("Maps/test")
	player = 	{
			lastState = "right",
			x = 64,
			y = 64,
			x_vel = 0,
			y_vel = 0,
			jump_vel = -1024,
			speed = 512,
			flySpeed = 700,
			state = "",
			h = 64,
			w = 64,
			standing = false,
			bananas = 0,
			}
	world = 	{
			gravity = 1536,
			ground = 512,
			}
	function player:jump()
		if self.standing then
			self.y_vel = self.jump_vel
			self.standing = false
		end
	end

	function player:right()
		self.x_vel = self.speed
	end

	function player:left()
		self.x_vel = -1 * (self.speed)
	end

	function player:stop()
		self.x_vel = 0
	end

	function player:collide(event)
		if event == "floor" then
			self.y_vel = 0
			self.standing = true
		end
		if event == "cieling" then
			self.y_vel = 0
		end
	end

	function player:update(dt)

		player:move(dt)
		self.state = self:getState()
	end

	function player:isColliding(layer, x, y)
		local collideLayer = map:getCollisionMap("Tile Layer 1")
		local tileX, tileY = math.floor(x / 32), math.floor(y / 32)
		local tile = collideLayer.data[tileX][tileY]
		
		return not(tile == 0)
	end


	function player:move(dt)
		local halfX = self.w / 2
		local halfY = self.h / 2

		self.y_vel = self.y_vel + (world.gravity * dt)
		
		self.x_vel = math.clamp(self.x_vel, -self.speed, self.speed)
		self.y_vel = math.clamp(self.y_vel, -self.flySpeed, self.flySpeed)
		
		local nextY = self.y + (self.y_vel*dt)
		if self.y_vel < 0 then -- Jumping
			if not (self:isColliding(map.layers.name["Player"], self.x - halfX, nextY - halfY))
				and not (self:isColliding(map.layers.name["Player"], self.x + halfX - 1, nextY - halfY)) then
				self.y = nextY
				self.standing = false
			else
				self.y = nextY + map.tileheight - ((nextY - halfY) % map.tileheight)
				self:collide("cieling")
			end
		end
		if self.y_vel > 0 then -- Falling
			if not (self:isColliding(map.layers["Player"], self.x-halfX, nextY + halfY))
				and not(self:isColliding(map.layers["Player"], self.x + halfX - 1, nextY + halfY)) then
					self.y = nextY
					self.standing = false
			else
				self.y = nextY - ((nextY + halfY) % map.tileheight)
				self:collide("floor")
			end
		end
		
		local nextX = self.x + (self.x_vel * dt)
		if self.x_vel > 0 then
			if not(self:isColliding(map.layers["Player"], nextX + halfX, self.y - halfY))
				and not(self:isColliding(map.layers["Player"], nextX + halfX, self.y + halfY - 1)) then
				self.x = nextX
			else
				self.x = nextX - ((nextX + halfX) % map.tilewidth)
			end
		elseif self.x_vel < 0 then
			if not(self:isColliding(map.layers["Player"], nextX - halfX, self.y - halfY))
				and not(self:isColliding(map.layers["Player"], nextX - halfX, self.y + halfY - 1)) then
				self.x = nextXS
			else
				self.x = nextX + map.tilewidth - ((nextX - halfX) % map.tilewidth)
			end
		end
	end

	function player:getState()
		local tempState = ""
		if self.standing then
			if self.x_vel > 0 then
				tempState = "right"
			elseif self.x_vel < 0 then
				tempState = "left"
			else
				tampState = "stand"
			end
		end
		if self.y_vel > 0 then
			tempState = "fall"
		elseif self.y_vel < 0 then
			tempState = "jump"
		end
		return tempState
	end
    -- Set using name
end

function love.update(dt)
	player:update(dt)
    map:update(dt)
end

function math.clamp(low, n, high) return math.min(math.max(low, n), high) end

function love.draw()
	if player.state == "right" then
		animPlayer_Right:draw(player.x - player.w/2, player.y - player.h/2)
		player.lastState = player.state
	elseif player.state == "left" then
		animPlayer_Right:draw(player.x - player.w/2, player.y - player.h/2)
		player.lastState = player.state
	else
		if player.lastState == "right" then
			animPlayer_Right:draw(player.x - player.w/2, player.y - player.h/2)
		else
			animPlayer_Right:draw(player.x - player.w/2, player.y - player.h/2)
		end
	end
	
	local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
	map:setDrawRange(player.x, player.y, windowWidth, windowHeight)
	map:draw()
    love.graphics.setColor( 255, 255, 255 )
end