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

	-- define some menu contents
	menu_root = { selection = 1, items = { 
			{"DIPLOMACY", "do_diplomacy_menu()"},
			{"TACTICAL", "do_tactical_menu()"},
			{"ENGINEERING", "do_engineering_menu()"},
			{"NAVIGATION", "do_navigation_menu()"},
			{"COMMUNICATIONS", "do_communications_menu()"},
			{"SENSORS", "do_sensors_menu()"}
		} }

	-- which menu are we viewing?
	active_menu = menu_root

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

	-- then draw a menu
	draw_active_menu()

end


function keypressed(key)
	if key == "down" then
		go_next_menu_item()
	elseif key == "up" then
		go_prev_menu_item()
	elseif key == "right" then
		do_menu_item()
	end	
end


function draw_active_menu()
	-- oh hey neat, you can use # around an evaluated expression? 
	for i=1,#(active_menu.items) do
		if active_menu.selection == i then
			love.graphics.setColor(90,30,30,255)
		else
			love.graphics.setColor(0,0,0,255)
		end
		love.graphics.print(active_menu.items[i][1], 20, 160 + (i*8))
	end
	love.graphics.setColor(90,30,30,255)
	love.graphics.print("--", 10, 160 + (active_menu.selection*8))
end


-- cycle to the next item in the current active menu
function go_next_menu_item()
	active_menu.selection = active_menu.selection + 1
	if active_menu.selection > #(active_menu.items) then
		active_menu.selection = 1
	end
end


-- and prev
function go_prev_menu_item()
	active_menu.selection = active_menu.selection - 1
	if active_menu.selection < 1 then
		active_menu.selection = #(active_menu.items)
	end	
end


-- execute function tied to menu item
function do_menu_item()
	-- ha ha sucker
end
