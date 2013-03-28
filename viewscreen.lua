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
	
	-- and now some miniship ship-status graphics stuff
	-- miniship diagram component parts
	fed_nacelle_1 = love.graphics.newImage("img/viewscreen/miniships/fed_nacelle_1.png")
	fed_hull_1 = love.graphics.newImage("img/viewscreen/miniships/fed_hull_1.png")
	fed_saucer_1 = love.graphics.newImage("img/viewscreen/miniships/fed_saucer_1.png")
	alien_1_hull_1 = love.graphics.newImage("img/viewscreen/miniships/alien_1_hull_1.png")
	alien_1_thruster_1 = love.graphics.newImage("img/viewscreen/miniships/alien_1_thruster_1.png")
	alien_1_wing_1 = love.graphics.newImage("img/viewscreen/miniships/alien_1_wing_1.png")

	-- and miniship definitions
	fed_layout = { width = 42, height = 26, parts = {
			{part = "hull", image = fed_hull_1, x = 6, y = 5, xflip = false, yflip = false},
			{part = "saucer", image = fed_saucer_1, x = 20, y = 0, xflip = false, yflip = false},
			{part = "port nacelle", image = fed_nacelle_1, x = 0, y = 1, xflip = false, yflip = false},
			{part = "starboard nacelle", image = fed_nacelle_1, x = 0, y = 1, xflip = false, yflip = true}
		} }

	alien_1_layout = { width = 25, height = 22, parts = { 
			{part = "port thruster", image = alien_1_thruster_1, x = 0 , y = 1, xflip = false, yflip = false},
			{part = "starboard thruster", image = alien_1_thruster_1, x = 0, y = 1, xflip = false, yflip = true},
			{part = "port wing", image = alien_1_wing_1, x = 12, y = 0, xflip = false, yflip = false},
			{part = "starboard wing", image = alien_1_wing_1 , x = 12, y = 0, xflip = false, yflip = true},
			{part = "hull", image = alien_1_hull_1, x = 4, y = 0, xflip = false, yflip = false}
		} }

	-- and overarching ship data structures
	ourship = { name = "Demosthenes", layout = fed_layout, maxshields = 12, shields = 12, beam = 5 }
	alienship = { name = "Xzrrthp", layout = alien_1_layout, maxshields = 15, shields = 5, beam = 6 }

	-- pick an alien and a ship
	alien = alien_list[math.random(#alien_list)]
	alienvessel = alienvessel_list[math.random(#alienvessel_list)]

	-- construct our menu objects
	build_menus()

	alien_statement = generate_alien_statement()

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

	-- and draw some miniships
	draw_miniship(ourship, 160, 160, 0)
	draw_miniship(alienship, 240, 160, 180)

	draw_miniship_stats(ourship, 150, 190)
	draw_miniship_stats(alienship, 230, 190)

	-- render alien message
	love.graphics.printf(render_perceived_statement(alien_statement), 40, 108, 240, "center") 

	-- help text
  love.graphics.setColor(80, 80, 160)
  love.graphics.print( "arrow keys to navigate menu (options do fuckall for now)", 10, 218 )


end


function keypressed(key)
	if key == "down" then
		go_next_menu_item()
	elseif key == "up" then
		go_prev_menu_item()
	elseif key == "right" then
		do_menu_item()
	elseif key == "left" then
		go_parent_menu()
	end	
end


-- generate a statement from the alien
function generate_alien_statement()
	local phrases = {"Greetings, alien vessel.  We are a trading barge, from the planet Orbulon.",
			"Withdraw from this region or we will fire upon you until you explode.",
			"Death comes to us all with furious, merciless sureness, but for now let us talk.",
			"You will perish.",
			"You will flourish."
			}

	local newphrase = phrases[math.random(#phrases)]
	local tokens = hackysplit(newphrase) -- syntax for lua split?
	-- wait, lua has *no* built-in split function? Are you shitting me?

	-- statement data structure: the english word, the alien word, token by token, and the
	-- translated-or-not status {plain = token, alien = f(token), translated = false}
	local newstatement = {}
	for i,v in ipairs(tokens) do
		local plain = v
		local alien = alienize(v)
		local translated = false
		table.insert(newstatement, {plain = plain, alien = alien, translated = translated})
	end

	return newstatement
end
	

-- render a string of the so-far-translated alien statement
function render_perceived_statement(s) 
	local outstring = ""
	for i,v in ipairs(s) do
		if v.translated == true then
			outstring = outstring .. v.plain
		else
			outstring = outstring .. v.alien
		end
		if i < #s then
			outstring = outstring .. " "
		end
	end
	return outstring
end


-- cheapo split-on-space function since lua lacks a builtin one?
function hackysplit(string)
	local newlist = {}
	for token in string.gmatch(string, "[^%s]+") do
		-- newlist[#newlist + 1] = token -- has to be a less hacky way to push onto array
		table.insert(newlist, token)
	-- stock newlist with tokens of string
	end
	return newlist
end


-- translate plain english text to alien language
function alienize(string)
	local newword = string.reverse(string)
	-- translate word
	return newword
end


-- draw small ship schematic at x,y, possibly rotated
function draw_miniship(ship, ox, oy, orientation)

	-- a lot less to type
	local p = ship.layout.parts
	local w = ship.layout.width
	local h = ship.layout.height
	local orix = w / 2
	local oriy = w / 2

	for i,v in ipairs(p) do
		local x = v.x
		local y = v.y	
		local scalex = 1
		local scaley = 1
		local rotation = 0
		if orientation ~= 0 then
			rotation = math.rad(180)
		end
		if v.xflip == true then
			x = w - x
			scalex = -1
		end
		if v.yflip == true then
			y = h - y
			scaley = -1
		end

		-- rotation scheme currently shit, so just declining to actually use orientation
		love.graphics.setColor(0,255,0,255)
		love.graphics.draw(v.image, ox + x, oy + y, 0, scalex, scaley, 0, 0) 

	end
end


-- draw labels/stats for miniship
function draw_miniship_stats(ship, x, y)
	love.graphics.setColor(0,0,80,255)
	love.graphics.print(ship.name .. "\nShields: " .. ship.shields .. "\nWeapons: " .. ship.beam, x, y)
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
	active_menu.items[active_menu.selection][2]()
end


-- return to parent menu
function go_parent_menu()
	if active_menu.parent ~= nil then
		active_menu.parent()
	end
end


-- and now, a whole bunch of submenu functions! --

-- take us to dipomacy submenu
function do_root_menu()
	active_menu = menu_root
end

function do_diplomacy_menu()
	active_menu = menu_diplomacy
end

function do_tactical_menu()
	active_menu = menu_tactical
end

function do_engineering_menu()
	active_menu = menu_engineering
end

function do_navigation_menu()
	active_menu = menu_navigation
end

function do_communications_menu()
	active_menu = menu_communications
end

function do_sensors_menu()
	active_menu = menu_sensors
end


-- and now a fleet of action game logic functions based on order
function do_diplomacy_reason()

end


function do_diplomacy_bribe()

end


function do_tactical_target()

end


function do_tactical_evade()

end


function do_engineering_reroute()

end


function do_engineering_suggestions()

end


function do_navigation_approach()

end


function do_navigation_backoff()

end


function do_navigation_plot()

end


function do_communications_signal()

end


function do_communications_translation()

end


function do_communications_end()

end


function do_sensors_ship()

end


function do_sensors_area()

end


-- put together menus with references to previously defined functions
function build_menus()

	-- define some menu contents
	menu_root = { selection = 1, parent = nil, items = { 
			{"DIPLOMACY", do_diplomacy_menu},
			{"TACTICAL", do_tactical_menu},
			{"ENGINEERING", do_engineering_menu},
			{"NAVIGATION", do_navigation_menu},
			{"COMMUNICATIONS", do_communications_menu},
			{"SENSORS", do_sensors_menu}
		} }

	menu_diplomacy = { selection = 1, parent = do_root_menu, items = {
			{"REASON", do_diplomacy_reason},
			{"BRIBE", do_diplomacy_bribe}
		} }

	menu_tactical = { selection = 1, parent = do_root_menu, items = {
			{"TARGET", do_tactical_target},
			{"EVADE", do_tactical_evade}
		} }

	menu_engineering = { selection = 1, parent = do_root_menu, items = {
      {"REROUTE POWER", do_engineering_reroute },
			{"SUGGESTIONS", do_engineering_suggestions }
    } }

	menu_navigation = { selection = 1, parent = do_root_menu, items = {
      {"APPROACH", do_navigation_approach },
			{"BACK OFF", do_navigation_backoff },
			{"PLOT A COURSE", do_navigation_plot }
    } }

	menu_communications = { selection = 1, parent = do_root_menu, items = {
      {"REFINE SIGNAL", do_communications_signal },
			{"REFINE TRANSLATION", do_communications_translation},
			{"END TRANSMISSION", do_communications_end}
    } }

	menu_sensors = { selection = 1, parent = do_root_menu, items = {
      {"SCAN SHIP", do_sensors_ship },
			{"SCAN AREA", do_sensors_area }
    } }

end
