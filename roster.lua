module(..., package.seeall);

-- crew roster / dossier experiments

function load()
	
	-- set us up for blocky 3x3 pixel scaling of graphics
	-- this stuff is probably more global to game initialization than it is something
	-- that needs initializing on a per-game-mode level in the long run
	love.graphics.setMode(960, 720, false, true, 0)
	love.graphics.setDefaultImageFilter("nearest", "nearest")

	-- load up some face parts!
	eyebrows_arched = love.graphics.newImage("/img/portraits/eyebrows_arched.png")
	eyebrows_flat = love.graphics.newImage("/img/portraits/eyebrows_flat.png")
	eyes_big = love.graphics.newImage("/img/portraits/eyes_big.png")
	eyes_narrow = love.graphics.newImage("/img/portraits/eyes_narrow.png")
  face_oval = love.graphics.newImage("/img/portraits/face_oval.png")
  face_square = love.graphics.newImage("/img/portraits/face_square.png")
  hair_full = love.graphics.newImage("/img/portraits/hair_full.png")
  hair_wisp = love.graphics.newImage("/img/portraits/hair_wisp.png")
  mouth_frown = love.graphics.newImage("/img/portraits/mouth_frown.png")
  mouth_smile = love.graphics.newImage("/img/portraits/mouth_smile.png")
  mouth_thin = love.graphics.newImage("/img/portraits/mouth_thin.png")
  nose_thin = love.graphics.newImage("/img/portraits/nose_thin.png")
  nose_wide = love.graphics.newImage("/img/portraits/nose_wide.png")
  shoulders_thin = love.graphics.newImage("/img/portraits/shoulders_thin.png")
  shoulders_wide = love.graphics.newImage("/img/portraits/shoulders_wide.png")

	-- and organize those into lists of alternate parts
	eyebrows_list = { {"arched", eyebrows_arched}, {"flat", eyebrows_flat } }
	eyes_list = { {"big", eyes_big}, {"narrow", eyes_narrow } }
	face_list = { {"oval", face_oval}, {"square", face_square } }
	hair_list = { {"full", hair_full}, {"wispy", hair_wisp } }
	mouth_list = { {"frowning", mouth_frown}, {"smiling", mouth_smile}, {"serious", mouth_thin } }
	nose_list = { {"thin", nose_thin}, {"wide", nose_wide } }
	shoulders_list = { {"thin", shoulders_thin}, {"wide", shoulders_wide } }	

	-- create a palette of base colors for various face parts
	shoulders_colors = { {160,20,20}, {200,200,50}, {80, 160, 200} }
	eyes_colors = { {255, 255, 255}, {220, 220, 220}, {255, 255, 200}, {220, 220, 180} }
	face_colors = { {240, 210, 210}, {220, 220, 200}, {220, 200, 190}, {200, 180, 150}, {170, 150, 110},
			{160, 150, 90}, {130, 100, 60}, {90, 80, 50}, {70, 50, 30}, {90, 180, 80}, {100, 200, 230} }
	hair_colors = { {220, 220, 100}, {180, 160, 20}, {150, 120, 10}, {110, 90, 10}, {80, 60, 10}, 
			{50, 30, 0}, {170, 50, 0}, {120, 40, 0}, {60, 0, 0}, {0, 0, 0}, {255, 240, 200}, {210, 210, 210},
			{160, 160, 160}, {80, 80, 80}, {255, 255, 255} }

	-- reference template for face object
	portrait = { eyebrows = nil, eyebrows_c = {255,255,255,255}, 
			eyes = nil, eyes_c = {255,255,255,255},
      face = nil, face_c = {255,255,255,255},
      hair = nil, hair_c = {255,255,255,255},
      mouth = nil, mouth_c = {255,255,255,255},
      nose = nil, nose_c = {255,255,255,255},
      shoulders = nil, shoulders_c = {255,255,255,255}
		}

	-- some name-making material
	firstnames_list = {"James", "John", "Robert", "Michael", "William", "David", "Richard", "Charles",
			"Joseph", "Thomas", "Christopher", "Daniel", "Paul", "Mark", "Donald", "George",
			"Geordi", "Bill", "Will", "Jean Luc", "Miles", "Wesley", "Wes", "Jim", "Spock", "Montgomery",
			"Anton", "Leonard", "Hikaru"
		}
	lastnames_list = {"Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson",
			"Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin",
			"Thompson", "Garcia", "Martinez", "Robinson", "Clark", "Rodgriguez", "Lewis", "Lee",
			"LaForge", "Riker", "Picard", "O'Brien", "Crusher", "Kirk", "Spock", "Scott", 
			"Chekov", "McCoy", "Sulu", "Troi", "Ishikawa", "Sisko", "Nerys", "Bashir", "Garak"
		}
	initials_list = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
			"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}

	-- some misc. biographical fodder
	departments_list = {"Command", "Engineering", "Tactical", "Medical", "Linguistics",
			"Maintenance", "Cargo", "Security", "Morale", "Informatics"}
	roles_list = {"chief officer", "senior officer", "crewman"}
	morale_list = {"depressed", "poor", "fair", "middling", "good", "cheerful", "thrilled"}
	ambitions_list = {"engineering", "combat", "command", "medicine", "linguistics",
			"machinery", "sports", "visual art", "music", "romance", "companionship",
			"parenthood", "reading", "writing", "cooking", "exploration", "safety",
			"promotion", "drinking"}

	-- character template
	-- don't need this, really, but for reference
	curchar = {firstname = "",
			lastname = "",
			initial = "",
			age = 0,
			department = "",
			role = "",
			morale = "",
			ambitions = {}
		}

	crewroster = {}
	generatecrewroster()

	-- modal switch hack
	viewmode = "list"

	-- pointer for roster
	rosterindex = 1

end


function update(dt)

end


function draw()
	-- 3x3 blocky pixels
	love.graphics.scale(3, 3)

	love.graphics.setBackgroundColor(230, 200, 140)

	if viewmode == "dossier" then
		-- let's look at an individual crewman!

		-- portrait frame
		love.graphics.setColor(40, 40, 40, 255)
		love.graphics.rectangle("fill", 8, 8, 68, 68)
		love.graphics.setColor(120, 100, 80, 255)
		love.graphics.rectangle("fill", 10, 10, 64, 64)

		-- render that fella!
		drawface(10,10)
		drawbio()
	
	elseif viewmode == "list" then
		-- lets look at the full list
		drawroster()
	end

  -- print some help text
  love.graphics.setColor(80, 80, 160)
  love.graphics.print( "up/down to select, right to view, left to return", 10, 218 )


end


function keypressed(key) 

	if viewmode == "list" then
		if key == "right" then
			viewmode = "dossier"
			curchar = crewroster[rosterindex]
		elseif key == "down" then
			-- in the long run, abstract roster index navigation stuff
			rosterindex = rosterindex + 1
			if rosterindex > #crewroster then
				rosterindex = 1
			end
		elseif key == "up" then
			rosterindex = rosterindex - 1
			if rosterindex < 1 then
				rosterindex = #crewroster
			end
		end

	elseif viewmode == "dossier" then
		if key == "left" then
			viewmode = "list"
		end
	end

	-- force toggle between view modes
	if key == "m" then
		if viewmode == "dossier" then
			viewmode = "list"
		else
			viewmode = "dossier"
		end
	end
	
end


-- draw the face graphics in order
function drawface(x,y)
	local portrait = curchar.face

	love.graphics.setColor(portrait.shoulders_c)
	love.graphics.draw(portrait.shoulders, 0 + x, 0 + y)
  love.graphics.setColor(portrait.face_c)
  love.graphics.draw(portrait.face, 0 + x, 0 + y)
  love.graphics.setColor(portrait.eyebrows_c)
  love.graphics.draw(portrait.eyebrows, 0 + x, 0 + y)
  love.graphics.setColor(portrait.eyes_c)
  love.graphics.draw(portrait.eyes, 0 + x, 0 + y)
  love.graphics.setColor(portrait.nose_c)
  love.graphics.draw(portrait.nose, 0 + x, 0 + y)
  love.graphics.setColor(portrait.mouth_c)
  love.graphics.draw(portrait.mouth, 0 + x, 0 + y)
  love.graphics.setColor(portrait.hair_c)
  love.graphics.draw(portrait.hair, 0 + x, 0 + y)

end


-- print out some biographic info
function drawbio()
	local char = curchar

	love.graphics.setColor(0,0,0,255)
	local namestring = char.firstname
	if(char.initial ~= "") then
		namestring = namestring .. " " .. char.initial
	end
	namestring = namestring .. " " .. char.lastname
	love.graphics.print(namestring, 10, 80)
	love.graphics.print("Age: " .. char.age, 10, 88)

	love.graphics.print("Assignment:\n" .. char.department .. ",\n " .. char.role, 10, 100)

	love.graphics.print("Morale:\n " .. char.morale, 10, 130)

	local ambitionstring = ""
	for i,v in ipairs(char.ambitions) do
		ambitionstring = ambitionstring .. " " .. v[1] .. " "
		for i=1,v[2] do
			ambitionstring = ambitionstring .. "+"
		end
		ambitionstring = ambitionstring .. "\n" 
	end
	love.graphics.print("Ambitions:\n" .. ambitionstring, 10, 150) 
end


-- draw up the list of the crew
function drawroster() 
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("USS Demo crew roster", 10, 12)
	love.graphics.print("NAME", 18, 26)
	love.graphics.print("DEPARTMENT", 98, 26)
	love.graphics.print("ROLE", 178, 26)
	love.graphics.print("AGE", 258, 26)

	for i=1,#crewroster do
		local c = crewroster[i]
		if rosterindex == i then	
			love.graphics.setColor(90,30,30,255)
		else
			love.graphics.setColor(0,0,0,255)
		end

		local namestring = c.lastname .. ", " .. string.sub(c.firstname, 1, 1)
		love.graphics.print(namestring, 20, 30 + (i*8))

		love.graphics.print(c.department, 100, 30 + (i*8))
		love.graphics.print(c.role, 180, 30 + (i*8))
		love.graphics.print(c.age, 260, 30 + (i*8))
	end
		
	-- draw pointer
	love.graphics.setColor(90,0,0,255)
	love.graphics.print("--", 10, 30 + (rosterindex*8))

end


-- generate a list of crewmen and put them in the global list
function generatecrewroster()
	for i=1,20 do
		table.insert(crewroster, generatecharacter())
	end
end


-- put together face and bio
function generatecharacter()
	local char = {}
	char.firstname = firstnames_list[math.random(#firstnames_list)]
	char.lastname = lastnames_list[math.random(#lastnames_list)]
	char.initial = ""
	if(math.random(2) > 1) then
		char.initial = initials_list[math.random(#initials_list)] .. "."
		if(math.random(5) == 1) then
			char.initial = char.initial .. " " .. initials_list[math.random(#initials_list)] .. "."
		end
	end

	char.age = math.random(25) + 18
	char.department = departments_list[math.random(#departments_list)]
	
	if math.random(5) > 1 then
		char.role = "crewman"
	elseif math.random(3) > 1 then
		char.role = "senior officer"
	else
		char.role = "chief officer"
	end
	
	char.morale = morale_list[math.random(#morale_list)]

	-- pick an ambition at random and give it a random intensity
	char.ambitions = { {ambitions_list[math.random(#ambitions_list)], math.random(5) } }
	-- then add a couple more if chance has it
	-- note: this lazy demo hack can lead to duplicate ambitions
	if(math.random(2) > 1) then
		table.insert(char.ambitions, {ambitions_list[math.random(#ambitions_list)], math.random(5) })
		if(math.random(2) > 1) then
	    table.insert(char.ambitions, {ambitions_list[math.random(#ambitions_list)], math.random(5) })
		end
	end

	char.face = generaterandomface() 

	return char

end


-- pick random facial features and colors
function generaterandomface()

	local portrait = {}

	-- various color palettes; mouth is always pearly white for now, nose has no color but hey
	local hairc = hair_colors[math.random(#hair_colors)]
	local eyesc = eyes_colors[math.random(#eyes_colors)]
	local shoulderc = shoulders_colors[math.random(#shoulders_colors)]
	local facec = face_colors[math.random(#face_colors)]
	local mouthc = {255,255,255,255}
	local nosec = {255,255,255,255}

  portrait.eyebrows = eyebrows_list[math.random(#eyebrows_list)][2]
  portrait.eyebrows_c = hairc
  portrait.eyes = eyes_list[math.random(#eyes_list)][2]
  portrait.eyes_c = eyesc
  portrait.face = face_list[math.random(#face_list)][2]
  portrait.face_c = facec
  portrait.hair = hair_list[math.random(#hair_list)][2]
  portrait.hair_c = hairc
  portrait.mouth = mouth_list[math.random(#mouth_list)][2]
  portrait.mouth_c = mouthc
  portrait.nose = nose_list[math.random(#nose_list)][2]
  portrait.nose_c = nosec
  portrait.shoulders = shoulders_list[math.random(#shoulders_list)][2]
  portrait.shoulders_c = shoulderc

	return portrait

end


--- return a quartet of 0-255 color values
function getrandomcolor()
	local red = math.random(0, 255)
	local green = math.random(0,255)
	local blue = math.random(0,255)
	return {red, green, blue, 255}
end
