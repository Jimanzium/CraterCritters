

local mouseX, mouseY = 0, 0

local abilities = {
	{name = "sprout water", cost = 5, cd = 0, timer = 0, lvlReq = 1, icon = love.graphics.newImage("ability1.png")}, -- 1
	{name = "spawn food", cost = 5, cd = 0.1, timer = 0, lvlReq = 1, icon = love.graphics.newImage("ability2.png")}, -- 2
	{name = "spawn bush", cost = 25, cd = 25, timer = 0, lvlReq = 2, icon = love.graphics.newImage("ability3.png")}, -- 3
	{name = "spawn spring", cost = 25, cd = 25, timer = 0, lvlReq = 2, icon = love.graphics.newImage("ability4.png")}, -- 4
	{name = "make rain", cost = 30, cd = 30, timer = 0, lvlReq = 3 , icon = love.graphics.newImage("ability5.png")}, -- 5
	{name = "rain food", cost = 30, cd = 30, timer = 0, lvlReq = 3, icon = love.graphics.newImage("ability6.png")}, -- 6
	{name = "refill mana", cost = 0, cd = 30, timer = 0, lvlReq = 4, icon = love.graphics.newImage("ability7.png")}, -- 7
	{name = "refresh", cost = 50, cd = 40, timer = 0, lvlReq = 4, icon = love.graphics.newImage("ability8.png")}, -- 8
	{name = "spawn eggs", cost = 40, cd = 30, timer = 0, lvlReq = 5, icon = love.graphics.newImage("ability9.png")}, -- 9
	{name = "heal all", cost = 50, cd = 40, timer = 0, lvlReq = 5, icon = love.graphics.newImage("ability10.png")}, -- 10
	{name = "Free Critters", cost = 0, cd = 0, timer = 0, lvlReq = 6, icon = love.graphics.newImage("ability11.png")}, -- 11


}
local ability = 1

local freed = false

function get_freed()
	return freed
end

local totalXp = 0
local xp = 0
local xpReq = 100

local lvl = 1

local mana = 100
local manaGain = 1

local player = {}
player.x = 0
player.y = 0
player.size = 0

function get_lvl()
	return lvl
end

function reset_player()
	manaGain = 1
	freed = false
	ability = 1

	totalXp = 0
	xp = 0
	xpReq = 100

	lvl = 1

	mana = 100

	player.x = 0
	player.y = 0
	player.size = 0	
end



function player_update(dt)

	if(love.keyboard.isDown("1")) then
		ability = 1
	elseif(love.keyboard.isDown("2")) then
		ability = 2
	end

	mana = math.min(100, mana + dt)
	player.size = 20 + totalXp/5
	if(xp > xpReq) then
		manaGain = manaGain + 0.25
		mana = 100
		lvl = lvl + 1
		local size = (lvl + xp/xpReq) * 20
		add_parts(player.x, player.y ,size*0.75,-math.pi/2,2,50*lvl,100*lvl,50,100,25 * lvl,1,{0,200,0})
		play_sfx(11)
		
		xp = xp - xpReq
		xpReq = xpReq * 1.5
	end
	local x,y,w,h = get_land()
	player.x = x + w/2
	player.y = y + h/2

	-- move camera
	local newX, newY = love.mouse.getX(), love.mouse.getY()
	if(love.mouse.isDown(2)) then -- move cam
		local dx, dy = mouseX - newX, mouseY - newY
		cam_move(dx, dy)
	end

	mouseX, mouseY = newX, newY

	for i=1,#abilities do
		abilities[i].timer = math.max(0,abilities[i].timer - dt)
	end
	
	if(love.mouse.isDown(1)) then
		local sw, sh = get_ui_w()
		local camScale = get_cam_scale()
		if(mouseY / camScale > sh - 40) then -- change ability
			for i=1,#abilities do 
				local x = sw/2 - #abilities * 40/2 + (i-1) * 40 + 5
				local y = sh - 40
				if(CheckCollision(x,y,30,30,mouseX/camScale, mouseY/camScale, 2,2)) then
					ability = i
				end
			end	
		else

			-- use abilities ----------------------------------------------------------------------------------------------------------------
			-- sprout water
			local camX, camY = get_cam()
			if(get_paused() == false and abilities[ability].timer <= 0 and mana > abilities[ability].cost and lvl >= abilities[ability].lvlReq) then
				abilities[ability].timer = abilities[ability].cd
				local ax, ay = mouse_cam()
				if(ability == 1) then
					local ax, ay = mouse_cam()
					add_parts(ax, ay,1,-math.pi/2,1,50,100,150,200,4,1,{182,255,235})

					mana = mana - abilities[ability].cost * dt
					local water = get_nearby_water(ax, ay, 20)
					if(water) then
						local water = get_water(water)
						water.size = water.size + dt
					else
						add_pool(ax, ay, 1)
					end
					mana = mana - abilities[ability].cost * dt
				elseif(ability == 2) then -- spawn food
					--play_sfx(10)
					
					add_parts(ax, ay,1,-math.pi/2,2,50,100,50,100,5,1,{0,113,28})
					add_parts(ax, ay,1,-math.pi/2,2,50,100,50,100,5,1,{56,28,0})

					mana = mana - abilities[ability].cost
					add_food(ax, ay)
				elseif(ability == 3) then
					play_sfx(10)
					mana = mana - abilities[ability].cost
					add_bush(ax, ay)
				elseif(ability == 4) then
					play_sfx(10)
					mana = mana - abilities[ability].cost
					add_spring(ax, ay)					
				elseif(ability == 5) then -- rain water
					play_sfx(10)
					mana = mana - abilities[ability].cost
					set_rain_timer(10)
				elseif(ability == 6) then -- rain food
					play_sfx(10)
					mana = mana - abilities[ability].cost
					local landx, landy, landw, landh = get_land()
					for i=1,80 do
						add_food(math.random(landx, landx + landw), math.random(landy, landy + landh))
					end
				elseif(ability == 7) then -- refill mana
					play_sfx(10)
					mana = 100
				elseif(ability == 8) then -- refresh
					play_sfx(10)
					for i=1,#abilities do
						abilities[i].timer = 0
					end
					abilities[8].timer = abilities[8].cd
				elseif(ability == 9) then -- spawn egg
					play_sfx(10)
					mana = mana - abilities[ability].cost
					add_egg(ax, ay)
				elseif(ability == 10) then -- heal all
					play_sfx(10)
					mana = mana - abilities[ability].cost
					critters_heal_all()
				elseif(ability == 11) then -- release the critters
					play_sfx(10)
					freed = true
				end
			end

			-----------------------------------------------------------------------------------------------------------------------------------
		end
	end	
end

function gain_xp(a)
	xp = xp + a
	totalXp = totalXp + a
end

function gain_mana(a)
	for i=1,#abilities do
		abilities[i].timer = 0
	end
	mana = mana + a
end

function get_player_pos()
	return player.x, player.y
end

function draw_split(x,y,splits,size,ang,w)
	if not(ang) then ang = 0 end

	for i = 1,splits do
		local range = math.pi
		love.graphics.setLineWidth(2)
		local a = -math.pi + ((i/splits) * range) - (1/splits * range) /2  -- -ang/2

		local dx = math.cos(a) * size
		local dy = math.sin(a) * size

		local dwx = math.cos(a+math.pi/2) * w
		local dwy = math.sin(a+math.pi/2) * w

		love.graphics.polygon("fill",x+dwx,y+dwy,x-dwx,y-dwy, x+dx+dwx/2, y+dy+dwy/2, x+dx-dwx/2, y+dy-dwy/2)
		love.graphics.polygon("line",x+dwx,y+dwy,x-dwx,y-dwy, x+dx+dwx/2, y+dy+dwy/2, x+dx-dwx/2, y+dy-dwy/2)

		--love.graphics.line(x,y,x+dx,y+dy)

		if(splits/2 > 1) then
			draw_split(x+dx, y+dy,math.ceil(splits/2),size*0.5,(1/splits * math.pi)/2,w/2)

		else
			love.graphics.setColor(48,65,0)
			love.graphics.circle("fill",x+dx,y+dy,10*(lvl+xp/xpReq))
			love.graphics.setColor(65,32,0)
		end
	end
end

function player_draw()
	--love.graphics.circle("line", player.x, player.y, 20)

	love.graphics.setColor(65,32,0)
	local splits = lvl
	local size = (lvl + xp/xpReq) * 20
	local w = size / 10
	
	love.graphics.setLineWidth(w)
	love.graphics.polygon("fill",player.x + 10, player.y,player.x - 10, player.y, player.x - 5, player.y - size/2, player.x + 5, player.y - size/2)
	--love.graphics.line(player.x, player.y, player.x, player.y - size/2)
	draw_split(player.x, player.y - size/2, splits, size, 0, w)
	love.graphics.setLineWidth(1)
	--[[
	local size = 100
	local x = player.x
	local y = player.y
	for i = 1,splits do
		local a = -math.pi + (((i)/splits) * math.pi) - (1/splits * math.pi) / 2
		local dx = math.cos(a) * size
		local dy = math.sin(a) * size

		local x2, y2 = x + dx, y + dy
		love.graphics.line(x,y,x+dx,y+dy)

		--[[
		for j = -1,1 do
			local a2 = a + ((j/2) * math.pi/2)
			local dx = math.cos(a2) * size * 0.75
			local dy = math.sin(a2) * size * 0.75

			love.graphics.line(x2,y2,x2+dx,y2+dy)
		end
		]]
	--end

	
	--love.graphics.line(player.x, player.y, player.x, player.y-player.size)
	love.graphics.setColor(255,255,255)
	--[[
	local w = math.max(1,player.size/20)
	love.graphics.setLineWidth(w)
	love.graphics.setColor(83,43,0)
	love.graphics.line(player.x, player.y, player.x, player.y-player.size)
	love.graphics.setLineWidth(1)
	love.graphics.setColor(255,255,255)
	]]
end

local abilIconBack = love.graphics.newImage("abilityIconBack.png")
local abilLocked = love.graphics.newImage("abilityLocked.png")
local pointer = love.graphics.newImage("pointer.png")

function player_HUD()
	local sw, sh = get_ui_w()

	--[[
	love.graphics.print("Lvl: "..lvl, 10,10)
	love.graphics.print("Xp: "..math.floor(xp).." / "..xpReq, 10,30)
	love.graphics.print(get_population(), 200,10)
	]]--

	
	--love.graphics.rectangle("fill",4,sh-14,sw-8,10)


	-- background
	love.graphics.setLineWidth(4)

	love.graphics.setColor(31,15,0)
	love.graphics.rectangle("line",0,0,30,sh)
	love.graphics.rectangle("line",sw-30,0,30,sh)
	love.graphics.rectangle("line",0,sh-10,sw,10)
	love.graphics.rectangle("line",sw/2 -#abilities*40/2 - 2,sh-50,#abilities*40 + 4,50)
	love.graphics.circle("line",0,sh,80)
	love.graphics.circle("line",0,sh,80)
	love.graphics.circle("line",sw,sh,80)
	love.graphics.circle("line",sw,sh,80)	

	love.graphics.setLineWidth(1)

	love.graphics.setColor(77,37,0)
	love.graphics.rectangle("fill",0,0,30,sh)
	love.graphics.rectangle("fill",sw-30,0,30,sh)
	love.graphics.rectangle("fill",0,sh-10,sw,10)
	love.graphics.rectangle("fill",sw/2 -#abilities*40/2 - 2,sh-50,#abilities*40 + 4,50)
	love.graphics.circle("fill",0,sh,80)
	love.graphics.circle("line",0,sh,80)
	love.graphics.circle("fill",sw,sh,80)
	love.graphics.circle("line",sw,sh,80)	

	-- ability bar
	local hovering = false

	love.graphics.setColor(255,255,255)
	local camScale = get_cam_scale()
	for i=1,#abilities do 
		local x = sw/2 - #abilities * 40/2 + (i-1) * 40 + 5
		local y = sh - 40

		--love.graphics.rectangle("line",x,y,30,30)
		love.graphics.draw(abilIconBack, x, y)
		if(abilities[i].icon) then
			love.graphics.draw(abilities[i].icon,x,y)
		end

		love.graphics.setColor(0,0,0,125)
		love.graphics.rectangle("fill",x,y+30,30,-30 * abilities[i].timer/abilities[i].cd)
		love.graphics.setColor(255,255,255)

		if(lvl < abilities[i].lvlReq) then
			love.graphics.draw(abilLocked,x,y)
		end

		if(CheckCollision(x,y,30,30,mouseX/camScale, mouseY/camScale, 2,2)) then
			cprint(abilities[i].name, sw/2, sh-50)
			hovering = true
			--love.graphics.print(abilities[i].name, love.mouse.getX(), love.mouse.getY() - 10)
		end

		if(i==ability) then
			love.graphics.draw(pointer,x+15-3,y-3)
		end

	end

	if (hovering == false) then
		cprint(abilities[ability].name, sw/2, sh-50)
	end

	-- mana bar
	love.graphics.setColor(56,28,0)
	love.graphics.rectangle("fill", sw - 24, 4, 20, sh - 8) 
	love.graphics.setColor(72,255,235)
	love.graphics.rectangle("fill", sw - 24, 4 + sh - 8, 20, -mana/100 * (sh - 8))

	local cost = abilities[ability].cost/100 * (sh-8)
	love.graphics.setColor(255,255,255)
	if(mana >= abilities[ability].cost) then
		love.graphics.rectangle("fill",sw - 24,4 + sh - 8 -mana/100 * (sh - 8) ,20,cost)
	else
		love.graphics.rectangle("fill",sw - 24,4 + sh - 8 - 0/100 * (sh - 8) -cost,20,2)
	end

 	-- xp bar
 	love.graphics.setColor(56,28,0)
	love.graphics.rectangle("fill", 4, 4, 20, sh - 8)
	love.graphics.setColor(255,125,0)
	love.graphics.rectangle("fill", 4, 4 + sh - 8, 20, -xp/xpReq * (sh - 8))

	love.graphics.setColor(0,100,200)
	--love.graphics.rectangle("fill",0,sh-4,sw*xp/xpReq,4)
	love.graphics.setColor(255,255,255)

	if(get_paused()) then
		love.graphics.setColor(0,0,0,100)
		love.graphics.rectangle("fill",0,0,sw,sh)
		love.graphics.setColor(255,255,255)
	end
end