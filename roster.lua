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


	-- character template
	char = {firstname = "",
			lastname = "",
			initial = "",
			age = 0
		}

	generatecharacter()

end


function update(dt)

end


function draw()
	-- 3x3 blocky pixels
	love.graphics.scale(3, 3)

	-- simple backdrop
	love.graphics.setBackgroundColor(230, 200, 140)

	love.graphics.setColor(40, 40, 40, 255)
	love.graphics.rectangle("fill", 8, 8, 68, 68)
	love.graphics.setColor(120, 100, 80, 255)
	love.graphics.rectangle("fill", 10, 10, 64, 64)

	-- render that fella!
	drawface(10,10)
	drawbio()

  -- print some help text
  love.graphics.setColor(80, 80, 160)
  love.graphics.print( "r for new character", 10, 218 )


end


function keypressed(key) 
	if key == "r" then
		generatecharacter()
	end
	
end


-- draw the face graphics in order
function drawface(x,y)
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
	love.graphics.setColor(0,0,0,255)
	local namestring = char.firstname
	if(char.initial ~= "") then
		namestring = namestring .. " " .. char.initial
	end
	namestring = namestring .. " " .. char.lastname
	love.graphics.print(namestring, 10, 80)
	love.graphics.print("Age: " .. char.age, 10, 88)
end


-- put together face and bio
function generatecharacter()
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

	generaterandomface() 

end


-- pick random facial features and colors
function generaterandomface()

  portrait.eyebrows = eyebrows_list[math.random(#eyebrows_list)][2]
  portrait.eyebrows_c = getrandomcolor()
  portrait.eyes = eyes_list[math.random(#eyes_list)][2]
  portrait.eyes_c = getrandomcolor()
  portrait.face = face_list[math.random(#face_list)][2]
  portrait.face_c = getrandomcolor()
  portrait.hair = hair_list[math.random(#hair_list)][2]
  portrait.hair_c = getrandomcolor()
  portrait.mouth = mouth_list[math.random(#mouth_list)][2]
  portrait.mouth_c = getrandomcolor()
  portrait.nose = nose_list[math.random(#nose_list)][2]
  portrait.nose_c = getrandomcolor()
  portrait.shoulders = shoulders_list[math.random(#shoulders_list)][2]
  portrait.shoulders_c = getrandomcolor()

end


--- return a quartet of 0-255 color values
function getrandomcolor()
	local red = math.random(0, 255)
	local green = math.random(0,255)
	local blue = math.random(0,255)
	return {red, green, blue, 255}
end
