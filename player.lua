class "Player" {
		x = 512,
		y = 512,
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

--movement
function Player:jump()
	if self.standing then
		self.y_vel = self.jump_vel
		self.standing = false
	end
end
function Player:right()
	self.x_vel = self.speed
end

function Player:left()
	self.x_vel = -1 * (self.speed)
end

function Player:stop()
	self.x_vel = 0
end

function Player:collide(event)
	if event == "floor" then
		self.y_vel = 0
		self.standing = true
	end
	if event == "ceiling" then
		self.y_vel = 0
	end
end

function Player:update(dt)
		player:move(dt)
	self.state = self:getState()
end
function Player:isColliding(map, x, y)
	local collideLayer = map:getCollisionMap("Tile Layer 1")
	local tileX, tileY = math.floor(y / 32)+1, math.floor(x / 32)+1
	local tile = collideLayer.data[tileX][tileY]
	
	return not (tile == 0)
end

function Player:move(dt)
	local halfX = self.w / 2
	local halfY = self.h / 2
	self.y_vel = self.y_vel + (world.gravity * dt)
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
			self.x = nextX
		else
			self.x = nextX + map.tilewidth - ((nextX - halfX) % map.tilewidth)
		end
	end
end

function Player:getState()
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