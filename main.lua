function love.load()

        -- set us up for blocky 3x3 pixel scaling of graphics
        love.graphics.setMode(960, 720, false, true, 0)
        love.graphics.setDefaultImageFilter("nearest", "nearest")

        -- load in some art assets!
        shipimage = love.graphics.newImage("/img/uss-ship.png")

        f_ocr_12 = love.graphics.newFont("font/OCRAStd.otf", 12)

        -- create a simple ship table data structure
        ship = { image = shipimage, x = 100, y = 100, theta = 0, velocity = 0, maxv = 100, minv = -30,
                xoffset = shipimage:getWidth() / 2, yoffset = shipimage:getHeight() / 2 }

        -- and let's generate a hacky starfield
	-- create a large field of random x,y coordinates
	starfield = {} 	
	for i=1, 1000 do
		newstarx = math.random(0, 1000)
		newstary = math.random(0, 1000)
		newstarcolorr = math.random(255)
		newstarcolorg = math.random(255)
		newstarcolorb = math.random(255)
		table.insert(starfield, {newstarx, newstary, newstarcolorr, newstarcolorg, newstarcolorb} )
	end

end

function love.update(dt)
        -- handle turning
        if love.keyboard.isDown("left") then
                ship.theta = ship.theta - (60 * dt)
                if ship.theta < 0 then
                        ship.theta = ship.theta + 360
                end
        elseif love.keyboard.isDown("right") then
                ship.theta = ship.theta + (60 * dt)
                if ship.theta > 360 then
                        ship.theta = ship.theta - 360
                end
        end

        -- handle velocity changes
        if love.keyboard.isDown("up") then
                ship.velocity = ship.velocity + (1 * dt)
                if ship.velocity > ship.maxv then
                        ship.velocity = ship.maxv
                end
        elseif love.keyboard.isDown("down") then
                ship.velocity = ship.velocity - (1 * dt)
                if ship.velocity < ship.minv then
                        ship.velocity = ship.minv
                end
        end

        -- move ship based on heading and velocity
        ship.x = ship.x + (ship.velocity * math.cos(math.rad(ship.theta)))
        ship.y = ship.y + (ship.velocity * math.sin(math.rad(ship.theta)))
end

function love.draw()
	-- draw everything scaled up 3x for blocky pixel look
        love.graphics.scale(3, 3)

	-- draw the stars
	for i,v in ipairs(starfield) do
		love.graphics.setColor(v[3], v[4], v[5], 255)
		love.graphics.point(v[1], v[2])
	end

	-- draw the ship
        love.graphics.setColor(255,255,255,255)
        love.graphics.draw(ship.image, ship.x, ship.y, math.rad(ship.theta), 1, 1, ship.xoffset, ship.yoffset)
	
	-- print a jolly message on the screen
        love.graphics.setFont(f_ocr_12)
        love.graphics.setColor(40, 40, 0)
        love.graphics.print( "space!", 200, 200 )
end

function love.keypressed(key)
        if key == "down" then
        elseif key == "up" then
        elseif key == "right" then
        elseif key == "left" then
        end
end