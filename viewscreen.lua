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
	viewscreen_noise_1 = love.graphics.newImage("img/viewscreen/viewscreen-noise-1.png")
	viewscreen_noise_2 = love.graphics.newImage("img/viewscreen/viewscreen-noise-2.png")
	viewscreen_starfield = love.graphics.newImage("img/viewscreen/viewscreen-stars.png")

	-- group things up
	alienvessel_list = {alienvessel_1, alienvessel_2}
	alien_list = {alien_1, alien_2, alien_3}
	viewscreen_noise_anim_frames = {viewscreen_noise_1, viewscreen_noise_2}
	viewscreen_noise_anim_index = 1
	viewscreen_noise_anim_delay = 0.2
	viewscreen_noise_anim_t = 0
	
	-- and now some miniship ship-status graphics stuff
	-- miniship diagram component parts
	fed_nacelle_1 = love.graphics.newImage("img/viewscreen/miniships/fed_nacelle_1.png")
	fed_hull_1 = love.graphics.newImage("img/viewscreen/miniships/fed_hull_1.png")
	fed_saucer_1 = love.graphics.newImage("img/viewscreen/miniships/fed_saucer_1.png")
	alien_1_hull_1 = love.graphics.newImage("img/viewscreen/miniships/alien_1_hull_1.png")
	alien_1_thruster_1 = love.graphics.newImage("img/viewscreen/miniships/alien_1_thruster_1.png")
	alien_1_wing_1 = love.graphics.newImage("img/viewscreen/miniships/alien_1_wing_1.png")
	shield_oval = love.graphics.newImage("img/viewscreen/miniships/shield_oval.png")

	-- and miniship definitions
	fed_layout = { width = 42, height = 26, parts = {
			{part = "hull", image = fed_hull_1, x = 6, y = 5, xflip = false, yflip = false, 
				maxhp = 10, hp = 10},
			{part = "saucer", image = fed_saucer_1, x = 20, y = 0, xflip = false, yflip = false, 
				maxhp = 8, hp = 8},
			{part = "port nacelle", image = fed_nacelle_1, x = 0, y = 1, xflip = false, yflip = false, 
				maxhp = 5, hp = 5},
			{part = "starboard nacelle", image = fed_nacelle_1, x = 0, y = 1, xflip = false, yflip = true,
				maxhp = 5, hp = 5}
		} }

	alien_1_layout = { width = 25, height = 22, parts = { 
			{part = "port thruster", image = alien_1_thruster_1, x = 0 , y = 1, xflip = false, yflip = false,
				maxhp = 3, hp = 3},
			{part = "starboard thruster", image = alien_1_thruster_1, x = 0, y = 1, xflip = false, yflip = true,
				maxhp = 3, hp = 3},
			{part = "port wing", image = alien_1_wing_1, x = 12, y = 0, xflip = false, yflip = false,
				maxhp = 4, hp = 4},
			{part = "starboard wing", image = alien_1_wing_1 , x = 12, y = 0, xflip = false, yflip = true,
				maxhp = 4, hp = 4},
			{part = "hull", image = alien_1_hull_1, x = 4, y = 0, xflip = false, yflip = false,
				maxhp = 12, hp = 12}
		} }

	-- and overarching ship data structures
	ourship = { name = "Demosthenes", layout = fed_layout, maxshields = 12, shields = 12, beam = 5 }
	alienship = { name = "Xzrrthp", layout = alien_1_layout, maxshields = 15, shields = 5, beam = 6 }

	-- and some red alert graphics
	red_alert_all_clear_img = love.graphics.newImage("img/viewscreen/red_alert_off.png")
	red_alert_img = love.graphics.newImage("img/viewscreen/red_alert_on.png")
	red_alert_active = true
	red_alert_blink_on = false
	red_alert_blink_timer = 0
	red_alert_blink_delay = 1

	-- pick an alien and a ship
	alien = alien_list[math.random(#alien_list)]
	alienvessel = alienvessel_list[math.random(#alienvessel_list)]

	-- construct our menu objects
	build_menus()

	-- are they currently hostile? are we attacking?
	aliens_hostile = true
	attacking = true

	-- comm related globals
	alien_statement = generate_alien_statement()
	comm_signal_noise = 0.8
	channel_open = true

	-- engineering related globals
	babble_verb = {}
	babble_adjective = {}
	babble_noun = {}
	build_babble_tables()

	-- which menu are we viewing?
	active_menu = menu_root

end


function update(dt)

	-- do viewscreen noise anim cycle (need to figure out generalized anim cycle/event plan)
	viewscreen_noise_anim_t = viewscreen_noise_anim_t + dt
	if viewscreen_noise_anim_t > viewscreen_noise_anim_delay then
		if math.random(3) > 2 then
			viewscreen_noise_anim_index = viewscreen_noise_anim_index + 1
			if viewscreen_noise_anim_index > #viewscreen_noise_anim_frames then
				viewscreen_noise_anim_index = 1
			end
			viewscreen_noise_anim_t = viewscreen_noise_anim_t - viewscreen_noise_anim_delay
		end
	end

	-- do red alert anim
	if red_alert_active == true then
		red_alert_blink_timer = red_alert_blink_timer + dt
		if red_alert_blink_timer > red_alert_blink_delay then
			-- toggle
			red_alert_blink_timer = red_alert_blink_timer - red_alert_blink_delay
			if red_alert_blink_on == true then
				red_alert_blink_on = false
			else
				red_alert_blink_on = true
			end
		end
	end

	-- check for end of turn processing
	if turn_ended == true then
		if aliens_hostile then
			do_incoming_fire()
		end
		if attacking == true then
			do_outgoing_fire()
		end
		turn_ended = false
	end

end


function draw()
  -- 3x3 blocky pixels
  love.graphics.scale(3, 3)

	-- if we've got an open comm channel, render the interlocutor's bridge
	if channel_open == true then
		-- let's lay down an alien and a vessel
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(alienvessel, 0, 0)
		love.graphics.draw(alien, 124, 38)
	
		-- and possibly some viewscreen visual noise
		love.graphics.setColor(math.random(100) + 155, math.random(100) + 155, math.random(100) + 155, 155 * comm_signal_noise)
		love.graphics.draw(viewscreen_noise_anim_frames[viewscreen_noise_anim_index], 0, 0)
	
	else
		-- a nice starfield!
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(viewscreen_starfield, 0, 0)
	end

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

	-- red alert beacon!
	draw_red_alert_status()

	-- render alien message if comm open
	if channel_open == true then
		love.graphics.setColor(0,0,0,255)
		love.graphics.printf(render_perceived_statement(alien_statement), 40, 108, 240, "center") 
	end

	-- render current response text, if any
	love.graphics.setColor(0,100,0,255)
	love.graphics.printf(response, 40, 135, 240, "center")

	-- help text
  love.graphics.setColor(80, 80, 160)
  love.graphics.print( "arrow keys to navigate/activate menu", 10, 218 )


end


function keypressed(key)
	-- cheap hack in lieu of actual messaging control: wait for keypress to clear feedback message
	response = ""

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


-- given two ships (a)ttacker and (d) defender, calc and assign damage
function do_attack(a, d)
	local shield_damage = a.beam
	local hull_damage = 0
	if shield_damage > d.shields then
		hull_damage = shield_damage - d.shields
		shield_damage = d.shields
	end
	d.shields = d.shields - shield_damage
	
	if hull_damage > 0 then
		-- penetrated shields, do some real damage
		-- pick a random ship part and damage it
		local target = d.layout.parts[math.random(#(d.layout.parts))]
		if hull_damage > target.hp then
			hull_damage = target.hp
		end
		target.hp = target.hp - hull_damage
	end
end

-- calculate and assign damage to enemy ship
function do_outgoing_fire()
	do_attack(ourship, alienship)
end

-- calculate and assign incomin damage from enemy ship
function do_incoming_fire()
	do_attack(alienship, ourship)
end


-- draw red alert beacon
function draw_red_alert_status()
	local x = 10
	local y = 20
	if red_alert_active == true then
		-- red alert!
		love.graphics.setColor(255,255,255,255)
		if red_alert_blink_on == true then
			love.graphics.draw(red_alert_img, x, y)
		else
			love.graphics.draw(red_alert_all_clear_img, x, y)
		end
		love.graphics.setColor(180,0,0,255)
		love.graphics.print(" RED\nALERT", x - 1, y + 15)
	else
		-- all clear
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(red_alert_all_clear_img, x, y)
	end
end


-- generate a statement from the alien
function generate_alien_statement()
	local phrases = {"Greetings, alien vessel.  We are a trading barge, from the planet Orbulon.",
			"Withdraw from this region or we will fire upon you until you explode.",
			"Death comes to us all with furious, merciless sureness, but for now let us talk.",
			"You will perish, glory to the all-fathers.",
			"You will flourish, glory to the all-fathers",
			"Perhaps you would consider selling us some fuel.",
			"You can't stop here, this is Andorian warp-bat country.",
			"Holy cow!  You're the ugliest creatures we've ever encountered!  May we take some photographs for our archives?"
			}

	local newphrase = phrases[math.random(#phrases)]
	local tokens = hackysplit(newphrase) -- syntax for lua split?
	-- wait, lua has *no* built-in split function? Are you shitting me?

	-- statement data structure: plain is plantext, alien is munged text, translated is per-token 
	-- translation status
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
	local noisechars = {"#", "@", "%", "*", "&"}

	for i,v in ipairs(s) do
		local outword
		if v.translated == true then
			outword = v.plain
		else
			outword = string.upper(v.alien)
		end
-- Because we aren't used a fixed-width font, this is too successful at 
-- muddying up the text beyond readability under the current re-render-every-frame
-- regime.
--
--		for i=1,string.len(outword) do
--			if((math.random() * 5) < comm_signal_noise) then
--				outword = replace_char(i, outword, noisechars[math.random(#noisechars)])
--			end
--		end
		outstring = outstring .. outword
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


-- and a hacky character-replacement function as well, via stack overflow
function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
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
	local oriy = h / 2

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
		-- replace this quicky green-channel hack with a proper color range function for damage
		love.graphics.setColor(130,(255 * (v.hp / v.maxhp)),0,255)
		love.graphics.draw(v.image, ox + x, oy + y, 0, scalex, scaley, 0, 0) 

	end

	-- add shield overlay
	if ship.shields > 0 then
		local sp = ship.shields / ship.maxshields -- shield percentage
		love.graphics.setColor(200, (sp * 100) + 100, sp * 255, (sp * 200) + 55)
		love.graphics.draw(shield_oval, ox - 10, oy - 10)
	end

end


-- draw labels/stats for miniship
function draw_miniship_stats(ship, x, y)
	love.graphics.setColor(0,0,80,255)
	love.graphics.print(ship.name .. "\nShields: " .. ship.shields .. "\nWeapons: " .. ship.beam, x, y)
end


function draw_active_menu()
	local menux = 20
	local menuy = 160

	-- oh hey neat, you can use # around an evaluated expression? 
	for i=1,#(active_menu.items) do
		if active_menu.selection == i then
			love.graphics.setColor(90,30,30,255)
		else
			love.graphics.setColor(0,0,0,255)
		end
		love.graphics.print(active_menu.items[i][1], menux, menuy + (i*8))
	end
	love.graphics.setColor(90,30,30,255)
	love.graphics.print("--", menux - 10, menuy + (active_menu.selection*8))
end


-- stock babble constituent tables with words
function build_babble_tables()
	babble_verb = {"modulate",
"re-modulate",
"invert",
"boost",
"redirect",
"rewire",
"energize",
"polarize",
"depolarize",
"flush",
"reboot",
"realign",
"deactivate",
"ionize",
"deionize",
"oscilate",
"isolate",
"calibrate",
"filter",
"deflect",
"rotate",
"magnify",
"detach",
"repurpose",
"overclock",
"supercharge",
"re-integrate",
"underclock",
"overdrive"
		}

	babble_adjective = {"spectral",
"dimensional",
"energy",
"rotational",
"deflector",
"positronic",
"duotronic",
"quantum",
"molecular",
"modular",
"antimatter",
"dilithium",
"trilithium",
"subspace",
"fuel",
"jeffries",
"particle",
"atomic",
"subatomic",
"matter",
"tachyon",
"photon",
"eidetic",
"stochastic"
		}

	babble_noun = {"matrix",
"converter",
"coil",
"generator",
"deflector",
"sensor",
"antenna",
"array",
"battery",
"continuum",
"spectrum",
"replicator",
"recycler",
"conduit",
"tube",
"collider",
"field",
"processor",
"simulator",
"repressor",
"suppressor",
"regressor",
"transponder",
"transistor"
		}

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
	response = "Eng: \'" .. eng_suggestion() .. "\'"
	end_turn()
end


function do_navigation_approach()

end


function do_navigation_backoff()

end


function do_navigation_plot()

end

function do_communications_start()
	response = "Comm: \'"  .. start_comm() .. "\'"
	end_turn()
end

function do_communications_signal()
	response = "Comm: \'" .. refine_signal() .. "\'"
	end_turn()
end


function do_communications_translation()
	response = "Comm: \'" .. refine_translation() .. "\'"
	end_turn()
end


function do_communications_end()
	response = "Comm: \'" .. end_comm() .. "\'"
	end_turn()
end


function do_sensors_ship()

end


function do_sensors_area()

end


-- do end-of-turn stuff
function end_turn()
	-- for now, just set a bool that update can check
	turn_ended = true
end

-- suggest some technobabble solution
function eng_suggestion()
	local prefix = {"I dunno, sir, I guess I could ",
			"Oh! I bet we could ",
			"Let's see, if we ",
			"I've got it! We'll ",
			"It's crazy, but how about I ",
			"Gimme a minute, I'll ",
			"Best bet is we just ",
			"It's a long shot, but we can ",
			"I dunno, maybe we can "
		}

	local bs = ""
	bs = bs .. prefix[math.random(#prefix)]
	bs = bs .. babble_verb[math.random(#babble_verb)] .. " the "
	bs = bs .. babble_adjective[math.random(#babble_adjective)] .. " "
	bs = bs .. babble_noun[math.random(#babble_noun)] .. "..."

	return bs
end


-- open a channel to alien if present and not already open
function start_comm() 
	if channel_open == false then
		channel_open = true
		return "Hailing...they're responding, sir."
	else
		return "We've already got them on the view screen, Captain."
	end
end


-- end communications if in progress
function end_comm()
  if channel_open == true then
    channel_open = false
    return "Aye, Captain.  Channel terminated."
  else
    return "Sir?"
  end
end


-- incrementally improve current translation of alien communication
function refine_translation()
	local numimproved = 0
	local numunimproved = 0

	if channel_open == false then
		return "Sir, we have no communications to translate"
	end	

	-- translate 0 or more untranslated words
	for i,v in ipairs(alien_statement) do
		if v.translated == false then
			if math.random() > 0.5 then
				v.translated = true
				numimproved = numimproved + 1
			else
				numunimproved = numunimproved + 1 
			end
		end
	end

	-- send back a status reply	
	
	if (numimproved == 0) and (numunimproved == 0) then
		return "Translation is complete, sir."
	elseif numimproved == 0 then
		return "Still trying to figure this one out, sir."
	elseif numimproved == 1 then
		return "Ah, so their adverbial structure is fractal!"
	elseif numimproved == 2 then
		return "Wait, this is a bimodal syntax...oh!  Right!"
	else
		return "We're making excellent progress, sir."
	end
end


-- clean up the visual/linguistic clarity of the signal if possible
function refine_signal()
	local degreeimproved = 0
	local delta = 0

  if channel_open == false then
    return "Sir, there's no signal to refine currently."
  end

	delta = math.random() * 0.8
	if delta > comm_signal_noise then
		delta = comm_signal_noise
	end

	comm_signal_noise = comm_signal_noise - delta
	if comm_signal_noise == 0 then
		return "Signal is free of comm artifacts, sir."
	elseif delta > 0.5 then
		return "Recalibrating transponder...wow, that did the trick!"
	elseif delta > 0.2 then
		return "Should be a bit clearer now, sir"
	elseif delta > 0 then
		return "It's not much, sir, but I managed to squelch some noise..."
	else
		return "Sorry, sir, this signals got some stubborn gunk in it."
	end
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
			{"OPEN CHANNEL", do_communications_start },
      {"REFINE SIGNAL", do_communications_signal },
			{"REFINE TRANSLATION", do_communications_translation},
			{"END TRANSMISSION", do_communications_end}
    } }

	menu_sensors = { selection = 1, parent = do_root_menu, items = {
      {"SCAN SHIP", do_sensors_ship },
			{"SCAN AREA", do_sensors_area }
    } }

end


