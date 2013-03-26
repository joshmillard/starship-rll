-- startrek roguelikelike experiment

require "navscreen"
require "roster"

gamemode_list = {"nav", "roster"}
gamemode = nil 

function love.load()

	-- start in a specific gamemode
	gamemode = "nav"

	navscreen.load()
	roster.load()

end


function love.update(dt)

	if gamemode == "nav" then
		navscreen.update(dt)
	elseif gamemode == "roster" then
		roster.update(dt)
	end

end


function love.draw()
	
	if gamemode == "nav" then
		navscreen.draw()
	elseif gamemode == "roster" then
		roster.draw()
	end

	-- global mode-switching prompt
	love.graphics.setColor(50,50,50,130)
	love.graphics.rectangle("fill", 0,0,200,8)
	love.graphics.setColor(255,130,130,130)
	love.graphics.print("[1] nav  [2] roster", 0, 0)

end

function love.keypressed(key)

	-- hacky little global modeswitching for demos
	if key == "1" then
		gamemode = "nav"
	elseif key == "2" then
		gamemode = "roster"
	end
	
	-- pass key strokes through to currently active game mode's input routine
	if gamemode == "nav" then
		navscreen.keypressed(key)
	elseif gamemode == "roster" then
		roster.keypressed(key)
	end
	
	-- global controls
  if key == "escape" then
    -- let's get out of here!
    love.event.quit()
	end


end

