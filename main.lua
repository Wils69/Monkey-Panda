local sti = require "libraries/sti"
require("libraries/32lines")
require("libraries/AnAL")
require("libraries/camera")
require("Player")
require("World")

function love.load()
	local SmurfTileset  = love.graphics.newImage("Pictures/Tilesets/SmurfTileset.png")
	animPlayer_Right = newAnimation(SmurfTileset, 64, 64, 0.1, 0)
    map = sti.new("Maps/Test")
	camera:setBounds(0, 0, map.width * map.tilewidth - love.graphics.getWidth(), map.height * map.tileheight - love.graphics.getHeight())
	player = Player:new()
	world = World:new()
end

function love.update(dt)
	if dt > 0.05 then
		dt = 0.05
	end
	
	if love.keyboard.isDown("d") then
		player:right()
	end
	if love.keyboard.isDown("a") then
		player:left()
	end
	if love.keyboard.isDown(" ") and not(hasJumped) then
		player:jump()
	end
	player:update(dt)
	camera:setPosition(player.x - (love.graphics.getWidth()/2), player.y - (love.graphics.getHeight()/2))
    map:update(dt)
end



function love.draw()
	camera:set()

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
	

	map:draw()
    love.graphics.setColor( 255, 255, 255 )
	
	camera:unset()
end

function love.keyreleased(key)
	if (key == "a") or (key == "d") then
		player.x_vel = 0
	end
end