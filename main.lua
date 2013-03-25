-- startrek roguelikelike experiment

require "navscreen"

function love.load()

	navscreen.load()

end


function love.update(dt)

	navscreen.update(dt)

end


function love.draw()

	navscreen.draw()

end


function love.keypressed(key)
	
	navscreen.keypressed(key)

end

