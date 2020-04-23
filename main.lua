
--- GAME BY JIMANZIUM ---

love.graphics.setDefaultFilter("nearest","nearest")

require "world"
require "player"
require "critters"
require "cam"
require "phys"
require "parts"
require "menus"
require "sfx"

function reset()
	time = 0
	reset_player()
	reset_critters()
	reset_world()
	reset_parts()

	local landx, landy, landw, landh = get_land()
	cam_reset_pos()
	--cam_move(landx+landw/2 - 640/2,landy+landh/2 -480/2)
	math.randomseed(os.time())

	love.graphics.setBackgroundColor(32,32,32)
	for i=1,3 do
		--add_critter(landx+landw/2+math.random(-100,100),landy+landh/2+math.random(-100,100))
		add_egg(landx+landw/2+math.random(-100,100),landy+landh/2+math.random(-100,100))
	end

	for i=1,3 do
		add_pool(math.random(landx,landx+landw),math.random(landy,landy+landh),math.random(2,4))
	end

	for i=1,15 do
		add_food(math.random(landx,landx+landw),math.random(landy,landy+landh))
	end

	food_stop()

	for i=1,3 do
		add_bush(math.random(landx,landx+landw),math.random(landy,landy+landh))
	end

	set_paused(false)
end

function love.load()
	local f = love.graphics.newFont("Tomodachy.otf",20)
	f:setFilter("linear","linear")
	love.graphics.setFont(f)
	reset()
end

local time = 0

function get_time()
	return time
end
local paused = false

function get_paused()
	return paused
end

function set_paused(p)
	paused = p
end

function love.update(dt)

	if(paused == false) then
		local steps = 1
		if(love.keyboard.isDown("o")) then
			steps = 10
		end
		if(love.keyboard.isDown("k")) then
			--gain_xp(10)
		elseif(love.keyboard.isDown("l")) then
			--gain_mana(10)
		end
		for i=1,steps do
			time = time + dt

			parts_update(dt)
			critters_update(dt)
			
			world_update(dt)
			sfx_update(dt)
		end
	end
	player_update(dt)
	menus_update(dt)
end


function love.mousereleased(x,y,button)
	if(button == 1) then
		menu_pressed()
	end
end

function love.draw()
	cam_set()
	world_draw()
	critters_draw()
	player_draw()
	parts_draw()
	draw_rock_edge()

	cam_unset()

	cam_ui_set()
	player_HUD()
	menus_draw()
	cam_ui_unset()

	--love.graphics.print(math.floor(time),100,0)
end

function cprint(text,x,y)
	local f = love.graphics.getFont()
	local w = f:getWidth(text)
	local h = f:getHeight(text)
	love.graphics.print(text,math.floor(x-w/2),math.floor(y-h/2))
end

function get_dist(x1,y1,x2,y2)
	return math.sqrt((y2-y1)^2 + (x2-x1)^2)
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 <= x2+w2 and
         x2 <= x1+w1 and
         y1 <= y2+h2 and
         y2 <= y1+h1
end

local fs = true

function love.keypressed(key)
	if(key == "f1") then
		
		if(fs) then
			love.window.setFullscreen(false)
		else
			love.window.setFullscreen(true)
		end
		fs = not(fs)
	end
	if(key == "f2") then
		mute()
	end
	if(key == "f3") then
		music_mute()
	end
	if(key == "escape") then
		paused = not(paused)
	end
end