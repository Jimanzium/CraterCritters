
local critters = {}
local eggs = {}

local hungerOverTime = 1
local thirstOverTime = 1
local faithOverTime = 1

local walkSpeed = 100
local walkAcc = 200

function reset_critters()
	critters = {}
	eggs = {}
end

function critters_update(dt)
	if(love.keyboard.isDown("p")) then
		--critters = {}
		--eggs = {}
	end

	local landX, landY, landW, landH = get_land()

	for i,v in ipairs(eggs) do
		v.timer = v.timer - dt
		if(math.floor(v.timer)%2==0) then
			v.wobbleTimer = v.wobbleTimer + math.min(4,math.max(0.25, v.time/v.timer * 0.2)) * dt
			v.wobbleTimer = v.wobbleTimer % 1
		end
		if(v.timer < 0) then
			add_parts(v.x,v.y,1,-math.pi/2,3,100,150,50,100,20,2,{200,200,200})
			add_critter(v.x,v.y)
			table.remove(eggs,i)
		end
	end

	for i,v in ipairs(critters) do
		v.id = i
		v.hunger = math.max(0, v.hunger - hungerOverTime * dt)
		v.thirst = math.max(0,v.thirst - thirstOverTime * dt)
		v.faith = math.max(0, v.faith - faithOverTime * dt)
		v.age = v.age + dt

		if(v.hunger < 10 or v.thirst < 10) then
			v.health = v.health - dt
		end

		if(v.hunger > 35 and v.thirst > 35) then
			v.health = math.min(100,v.health + 3 * dt)
		end

		-- facing
		if(v.moveTarget and v.leaving == false) then

			
			if(v.x <= v.moveTarget.x) then
				v.facing = math.min(1,v.facing + dt * 5)
			else
				v.facing = math.max(-1,v.facing-5*dt)
			end
		end

		-- critter thought hmmmm...

		local highestPriority = 0
		local curBehaviour = 0
		for j,k in ipairs(v.behaviours) do
			k.priority = k.calcPriority(v)
			if(k.priority >= highestPriority) then
				highestPriority = k.priority
				curBehaviour = j
			end
		end

		v.curBehaviour = curBehaviour
		v.state = v.behaviours[curBehaviour].name
		v.behaviours[curBehaviour].action(v, dt)

		--[[
		v.x = v.x + v.xvel * dt
		v.y = v.y + v.yvel * dt
		]]

		-- repel other critters
		for j,k in ipairs(critters) do
			if not(i == j) then
				local d = get_dist(v.x,v.y,k.x,k.y)
				if(d < 40) then
					local a = math.atan2(v.y-k.y,v.x-k.x)
					local f = 50000/d * dt
					v.xvel = v.xvel + math.cos(a) * f
					v.yvel = v.yvel + math.sin(a) * f
				end
			end
		end

		v.x, v.y, v.z, v.xvel, v.yvel, v.zvel = update_phys(v.x,v.y,v.z,v.xvel,v.yvel,v.zvel,dt)

		if(v.health <= 0) then
			play_sfx(5)
			add_parts(v.x,v.y,1,-math.pi/2,2,50,100,50,100,5,1,{200,0,0})
			add_parts(v.x,v.y,1,-math.pi/2,2,50,100,50,100,5,1,v.color)
			table.remove(critters,i)
		end

		if(v.leaving) then
			local landx, landy, landw, landh = get_land()
			if(v.x < landx - 100 or v.x > landx + landw + 100 or v.y < landy - 100 or v.y > landy + landh + 100) then
				add_parts(v.x,v.y,v.z,-math.pi/2,2,50,100,50,100,30,1,v.color)
				table.remove(critters, i)
			end
		end

	end
end

function critter_goto(v, dt) -- goto current move target
	local landX, landY, landW, landH = get_land()
	if(v.moveTarget) then

		local tx, ty = v.moveTarget.x, v.moveTarget.y
		local a = math.atan2(v.y - ty, v.x - tx) + math.pi -- angle to move target
		local dx, dy = math.cos(a), math.sin(a)

		if(v.z == 0) then
			v.walkCycle = v.walkCycle + v.facing * dt
			v.walkCycle = v.walkCycle % 1

			v.xvel = dx * v.speed
			v.yvel = dy * v.speed
		end
	end
end

function critter_roam(v, dt)
	local landX, landY, landW, landH = get_land()
	if(v.moveTarget) then
		local tx, ty = v.moveTarget.x, v.moveTarget.y

		local d = get_dist(v.x,v.y,tx,ty) -- distance to target
		if(d < 20) then
			v.moveTarget = {x=math.random(landX, landX + landW), y=math.random(landY, landY + landH)}
			tx, ty = v.moveTarget.x, v.moveTarget.y
		end

		critter_goto(v,dt)
	else
		v.moveTarget = {x=math.random(landX, landX + landW), y=math.random(landY, landY + landH)}
	end
end

function critter_roam_priority(v)
	return 25
end

function critter_eat(v, dt)
	local food = get_nearby_food(v.x, v.y, v.sight)
	if (food) then
		local i = food
		food = get_food(food)
		v.moveTarget = {x = food.x, y = food.y}
		critter_goto(v, dt)

		local d = get_dist(v.x, v.y, food.x, food.y)
		if(d < 20) then
			add_parts(v.x,v.y,1,-math.pi/2,2,50,100,50,100,5,1,{200,0,0})
			v.hunger = v.hunger + 10
			food_remove(i)
			play_sfx(6)
		end

	else
		critter_roam(v, dt)
	end
end

function critter_eat_priority(v)
	return 100 - v.hunger
end

function critter_drink(v, dt)
	local drink = get_nearby_water(v.x,v.y,v.sight)
	if(drink) then
		drink = get_water(drink)
		v.moveTarget = {x = drink.x, y = drink.y}
		critter_goto(v, dt)

		local d = get_dist(v.x, v.y, drink.x, drink.y)
		if(d < drink.size * 10) then
			add_parts(v.x,v.y,1,-math.pi/2,2,50,100,50,100,3,1,{182,255,235})
			drink.size = drink.size - dt
			v.thirst = v.thirst + 100 * dt
			play_sfx(9)
		end
		
	else
		critter_roam(v, dt)
	end
end

function critter_drink_priority(v)
	local drink = get_nearby_water(v.x,v.y,v.sight)
	if (drink) then
		drink = get_water(drink)
		local d = get_dist(v.x,v.y,drink.x,drink.y)
		if(d < 100) then
			return 100 - v.thirst + 10
		end
	end

	return 100 - v.thirst
end

function critter_duplicate(v,dt)
	-- find partner
	if(v.partner == 0) then
		critter_roam(v,dt)
		for i,k in ipairs(critters) do
			if (k.id ~= v.id and k.partner == 0) then
				if(k.state == "duplicate") then
					v.partner = i
					k.partner = v.id
				end
			end
		end
	else -- bang partner
		target = critters[v.partner]
		if(target) then
			local d = get_dist(v.x,v.y,target.x, target.y)
			if(d < 40) then
				--add_critter(v.x,v.y)
				local mx, my = (v.x+target.x)/2,(v.y + target.y)/2
				add_parts(mx,my,1,-math.pi/2,2,50,100,250,300,20,2,{190,0,235})
				add_egg(mx, my)
				v.xvel = 0
				v.yvel = 0
				v.partner = 0
				target.partner = 0
				v.numKids = v.numKids + 1
				target.numKids = target.numKids + 1
			else
				v.moveTarget = {}
				v.moveTarget.x = target.x
				v.moveTarget.y = target.y
				critter_goto(v,dt)
			end
		end
	end
end

function critter_duplicate_priority(v)
	if(v.hunger < 50 or v.thirst < 50) then
		return 0
	end
	return v.age*2 - v.numKids * 200
end

function critter_worship(v,dt)
	local px, py = get_player_pos()
	local d = get_dist(v.x,v.y,px,py)
	if(d > 100) then
		v.moveTarget = {x=px,y=py}
		critter_goto(v,dt)
	else
		add_parts(v.x,v.y,14,-math.pi/2,2,50,100,50,100,3,1,{255,255,85})
		gain_xp(dt)
		v.xvel = 0
		v.yvel = 0
		v.faith = v.faith + 2 * dt
	end
end

function critter_worship_priority(v)
	local px, py = get_player_pos()
	local d = get_dist(v.x,v.y,px,py)


	if(v.hunger < 60 or v.thirst < 60) then
		return 0
	end
	
	if(d < 100) then
		return 100 - v.faith + 20
	end
	return 100 - v.faith
end

function critter_ending(v,dt)
	local px, py = get_player_pos()
	local d = get_dist(v.x,v.y,px,py)
	if(d > 100 and v.z <= 1) then
		v.moveTarget = {x=px,y=py}
		critter_goto(v,dt)
	else
		v.xvel = 0
		v.yvel = 0
		if(v.z < 300) then
			v.xvel = 100 * v.facing
			v.zvel = v.zvel + 600 * dt
		else
			v.leaving = true
			local d = 1
			if(v.facing < 0) then d = -1 end
			v.xvel = 500 * d
		end
	end
end

function critter_ending_priority(v)
	if(get_freed()) then
		return 100000
	else
		return 0
	end
end

local critter_behaviours = {
	{name = "roam", action = function(v, dt) critter_roam(v, dt) end, calcPriority = function(v) return critter_roam_priority(v) end, icon = love.graphics.newImage("roam.png")},
	{name = "eat", action = function(v, dt) critter_eat(v, dt) end, calcPriority = function(v) return critter_eat_priority(v) end, icon = love.graphics.newImage("eat.png")},
	{name = "drink", action = function(v, dt) critter_drink(v, dt) end, calcPriority = function(v) return critter_drink_priority(v) end, icon = love.graphics.newImage("drink.png")},
	{name = "duplicate", action = function(v, dt) critter_duplicate(v, dt) end, calcPriority = function(v) return critter_duplicate_priority(v) end, icon = love.graphics.newImage("heart.png")},
	{name = "worship", action = function(v, dt) critter_worship(v, dt) end, calcPriority = function(v) return critter_worship_priority(v) end, icon = love.graphics.newImage("worship.png")},
	{name = "ending", action = function(v, dt) critter_ending(v, dt) end, calcPriority = function(v) return critter_ending_priority(v) end, icon = love.graphics.newImage("worship.png")}
}

function add_behaviours(v, c)
	if not(v.behaviours) then
		v.behaviours = {}
	end
	
	for i,k in ipairs(critter_behaviours) do
		local b = {}
		b.name = k.name
		b.action = function(v,dt) k.action(v,dt) end
		b.calcPriority = function(v) return k.calcPriority(v) end
		b.priority = 0

		table.insert(v.behaviours, b)
	end
end

function add_egg(x,y)
	play_sfx(7)
	local t = math.random(10,20)
	local egg = {x=x,y=y,timer = t, time=t,wobbleTimer=0}
	table.insert(eggs,egg)
end

function get_population()
	return #critters + #eggs
end

function add_critter(x,y)
	play_sfx(8)
	local cr = {}
	cr.leaving = false
	cr.partner = 0
	cr.id = #critters + 1
	cr.x = x
	cr.y = y
	cr.z = 1
	cr.xvel = 0
	cr.yvel = 0
	cr.zvel = -100
	cr.facing = 1
	cr.numKids = 0
	cr.walkCycle = 0

	cr.speed = 100
	cr.sight = 400

	cr.age = 0
	cr.health = 100
	cr.hunger = 100
	cr.thirst = 100
	cr.faith = 100
	cr.state = "roam"

	cr.color = {math.random(1,255),math.random(1,255),math.random(1,255)}
	cr.curBehaviour = 0
	add_behaviours(cr, 1)

	add_parts(x,y,1,-math.pi/2,3,100,150,50,100,10,2,cr.color)

	table.insert(critters,cr)
end

function critters_heal_all()
	for i,v in ipairs(critters) do
		add_parts(v.x,v.y,1,-math.pi/2,3,100,150,50,100,30,2,v.color)

		v.health = 100
		v.hunger = 100
		v.thirst = 100
		v.faith = 100
	end
end

local critR = 15 -- critter radius
local legImg = love.graphics.newImage("leg.png")
local tailImg = love.graphics.newImage("tail.png")

local faceImg1 = love.graphics.newImage("face.png")
local faceImg2 = love.graphics.newImage("face2.png")
local faceImg3 = love.graphics.newImage("face3.png")

local eggImg = love.graphics.newImage("egg.png")

local shadowImg = love.graphics.newImage("shadow.png")
function critters_draw()

	-- eggs ---------------------------------------------------
	for i,v in ipairs(eggs) do
		local wobble = 0
		--if(v.timer < 5 and math.floor(v.timer)%2==1) then
			wobble = v.wobbleTimer % 1
			wobble = math.cos(wobble*2*math.pi - math.pi) * 0.15
		--end
		love.graphics.draw(eggImg,v.x,v.y,wobble,1,1,eggImg:getWidth()/2,eggImg:getHeight()*0.75)
	end

	-- crits ---------------------------------------------------
	for i,v in ipairs(critters) do


		love.graphics.setColor(255,255,255,50)

		love.graphics.draw(shadowImg,v.x-critR,v.y+critR)

		local legA = math.cos(v.walkCycle * 2*math.pi) * 0.5
		local legB = math.cos((v.walkCycle+0.5) * 2*math.pi) * 0.5
		local bob = math.cos(v.walkCycle * 2 * math.pi) * -1.5
		love.graphics.setColor(v.color)

		love.graphics.draw(tailImg, v.x - v.facing * critR/2,v.y -v.z + critR * 0.4 + bob, -v.facing + legA*0.2,1,1,15,30)
		
		if(v.facing >= 0) then
			love.graphics.draw(legImg, v.x + critR * 0.3, v.y + critR * 0.75 - v.z,legA,1,1,legImg:getWidth()/2,0)
		else
			love.graphics.draw(legImg, v.x - critR * 0.3, v.y + critR * 0.75 - v.z,legB,1,1,legImg:getWidth()/2,0)
		end

		love.graphics.circle("fill",v.x,v.y - v.z + bob,critR) -- body

		if(v.facing >= 0) then
			love.graphics.draw(legImg, v.x - critR * 0.3, v.y + critR * 0.75 - v.z,legB,1,1,legImg:getWidth()/2,0)
		else
			love.graphics.draw(legImg, v.x + critR * 0.3, v.y + critR * 0.75 - v.z,legA,1,1,legImg:getWidth()/2,0)
		end

		
		local f = 1
		if(v.facing < 0) then f = -1 end
		local face = faceImg1
		if(v.health < 30) then
			face = faceImg3
		elseif(v.health < 60) then
			face = faceImg2
		end
		love.graphics.draw(face,v.x + critR * 0.25 * v.facing, v.y - critR * 0.3  - v.z + bob,0,f,1,face:getWidth()/2,face:getWidth()/2)

		love.graphics.setColor(255,255,255)
		
		if(critter_behaviours[v.curBehaviour].icon) then
			local icon = critter_behaviours[v.curBehaviour].icon
			love.graphics.draw(icon,v.x + critR * 0.25 * v.facing - 5, v.y - critR * 0.3  - v.z + bob - 18 - 5)
		end

		--love.graphics.circle("fill",v.x + critR * 0.25 * v.facing, v.y - critR * 0.3  - v.z,critR/2)
		
		--love.graphics.circle("fill",v.x,v.y,4)
		
		--[[
		local tx, ty = v.moveTarget.x, v.moveTarget.y
		local d = get_dist(v.x,v.y,tx,ty)
		--love.graphics.print(d, v.x - 10,v.y-20)
		love.graphics.print(v.state, v.x - 10,v.y-20)
		love.graphics.circle("fill",v.moveTarget.x,v.moveTarget.y,4)
		]]

		--[[
		love.graphics.print(v.health, v.x,v.y-80)
		love.graphics.print(v.thirst, v.x,v.y - 60)
		love.graphics.print(v.hunger, v.x,v.y-40)
		love.graphics.print(v.state, v.x, v.y-20)
		love.graphics.print(v.age * 2 - v.numKids * 200, v.x, v.y - 120)
		]]
		
	end
end