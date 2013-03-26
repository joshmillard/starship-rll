-- startrek roguelikelike experiment

require "navscreen"
require "roster"
require "viewscreen"

gamemode_list = {"nav", "roster", "viewscreen"}
gamemode = nil 

function love.load()

	-- start in a specific gamemode
	gamemode = "nav"

	navscreen.load()
	roster.load()
	viewscreen.load()

end


function love.update(dt)

	if gamemode == "nav" then
		navscreen.update(dt)
	elseif gamemode == "roster" then
		roster.update(dt)
	elseif gamemode == "viewscreen" then
		viewscreen.update(dt)
	end

end


function love.draw()
	
	if gamemode == "nav" then
		navscreen.draw()
	elseif gamemode == "roster" then
		roster.draw()
	elseif gamemode == "viewscreen" then
		viewscreen.draw()
	end

	-- global mode-switching prompt
	love.graphics.setColor(50,50,50,130)
	love.graphics.rectangle("fill", 0,0,200,8)
	love.graphics.setColor(255,130,130,130)
	love.graphics.print("[1] nav  [2] roster  [3] bridge", 0, 0)

end

function love.keypressed(key)

	-- hacky little global modeswitching for demos
	if key == "1" then
		gamemode = "nav"
	elseif key == "2" then
		gamemode = "roster"
	elseif key == "3" then
		gamemode = "viewscreen"
	end
	
	-- pass key strokes through to currently active game mode's input routine
	if gamemode == "nav" then
		navscreen.keypressed(key)
	elseif gamemode == "roster" then
		roster.keypressed(key)
	elseif gamemode == "viewscreen" then
		viewscreen.keypressed(key)
	end
	
	-- global controls
  if key == "escape" then
    -- let's get out of here!
    love.event.quit()
	end


end

