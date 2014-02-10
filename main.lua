local sti = require "sti"
require("AnAL")
require("camera")

function love.load()
	local SmurfTileset  = love.graphics.newImage("Pictures/Tilesets/SmurfTileset.png")
	animPlayer_Right = newAnimation(SmurfTileset, 64, 64, 0.1, 0)


	
    map = sti.new("Maps/Test")
	camera:setBounds(0, 0, map.width * map.tilewidth - love.graphics.getWidth(), map.height * map.tileheight - love.graphics.getHeight())
	
	player = 	{
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
		if event == "ceiling" then
			self.y_vel = 0
		end
	end

	function player:update(dt)

		player:move(dt)
		self.state = self:getState()
	end

	function player:isColliding(map, x, y)
		local collideLayer = map:getCollisionMap("Tile Layer 1")
		local tileX, tileY = math.floor(y / 32)+1, math.floor(x / 32)+1
		local tile = collideLayer.data[tileX][tileY]
		
		return not (tile == 0)
	end


	function player:move(dt)
		local halfX = self.w / 2
		local halfY = self.h / 2

		self.y_vel = self.y_vel + (world.gravity * dt)
		
		self.x_vel = math.clamp(self.x_vel, -self.speed, self.speed)
		self.y_vel = math.clamp(self.y_vel, -self.flySpeed, self.flySpeed)
		
		local nextY = self.y + (self.y_vel*dt)
		if self.y_vel < 0 then -- Jumping
			if not (self:isColliding(map, self.x - halfX, nextY - halfY))
				and not (self:isColliding(map, self.x + halfX - 1, nextY - halfY)) then
				self.y = nextY
				self.standing = false
			else
				self.y = nextY + map.tileheight - ((nextY - halfY) % map.tileheight)
				self:collide("ceiling")
			end
		end
		if self.y_vel > 0 then -- Falling
			if not (self:isColliding(map, self.x-halfX, nextY + halfY))
				and not(self:isColliding(map, self.x + halfX - 1, nextY + halfY)) then
					self.y = nextY
					self.standing = false
			else
				self.y = nextY - ((nextY + halfY) % map.tileheight)
				self:collide("floor")
			end
		end
		
		local nextX = self.x + (self.x_vel * dt)
		if self.x_vel > 0 then
			if not(self:isColliding(map, nextX + halfX, self.y - halfY))
				and not(self:isColliding(map, nextX + halfX, self.y + halfY - 1)) then
				self.x = nextX
			else
				self.x = nextX - ((nextX + halfX) % map.tilewidth)
			end
		elseif self.x_vel < 0 then
			if not(self:isColliding(map, nextX - halfX, self.y - halfY))
				and not(self:isColliding(map, nextX - halfX, self.y + halfY - 1)) then
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
	camera:setPosition( player.x - (love.graphics.getWidth()/2), player.y - (love.graphics.getHeight()/2))
    map:update(dt)
end

function math.clamp(low, n, high) return math.min(math.max(low, n), high) end

function love.draw()
	camera:set()

	local collideLayer = map:getCollisionMap("Tile Layer 1")
	local tileX, tileY = math.floor(player.x / 32), math.floor(player.y / 32)
	local tile = collideLayer.data[19][19]


 


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

	map:draw()
    love.graphics.setColor( 255, 255, 255 )
	
	camera:unset()
end

function love.keyreleased(key)
	if (key == "a") or (key == "d") then
		player.x_vel = 0
	end
end
