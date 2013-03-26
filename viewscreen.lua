module(..., package.seeall);

-- viewscreen/bridge ship interactions

function load()

  -- set us up for blocky 3x3 pixel scaling of graphics
  -- this stuff is probably more global to game initialization than it is something
  -- that needs initializing on a per-game-mode level in the long run
  love.graphics.setMode(960, 720, false, true, 0)
  love.graphics.setDefaultImageFilter("nearest", "nearest")

	-- load up viewscreen graphics
	viewscreenwindow = love.graphics.newImage("img/viewscreen/viewscreen-window.png")
	alienvessel_1 = love.graphics.newImage("img/viewscreen/alien-vessel-one.png")
	alienvessel_2 = love.graphics.newImage("img/viewscreen/alien-vessel-two.png")
	alien_1 = love.graphics.newImage("img/viewscreen/alien-1.png")
  alien_2 = love.graphics.newImage("img/viewscreen/alien-2.png")
  alien_3 = love.graphics.newImage("img/viewscreen/alien-3.png")

	-- group things up
	alienvessel_list = {alienvessel_1, alienvessel_2}
	alien_list = {alien_1, alien_2, alien_3}

	-- pick an alien and a ship
	alien = alien_list[math.random(#alien_list)]
	alienvessel = alienvessel_list[math.random(#alienvessel_list)]

end


function update(dt)

end


function draw()
  -- 3x3 blocky pixels
  love.graphics.scale(3, 3)

	-- let's lay down an alien and a vessel
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(alienvessel, 0, 0)
	love.graphics.draw(alien, 124, 38)
	
	-- and mask it all with the viewscreen
	love.graphics.setColor(180,180,180,255)
	love.graphics.draw(viewscreenwindow, 0, 0)

end


function keypressed(key)

end
