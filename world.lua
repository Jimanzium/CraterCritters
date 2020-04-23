

local land = {}
land.x = 0
land.y = 0
land.w = 1400
land.h = 1000

local pools = {}

function add_pool(x,y,size)
	local po = {x=x,y=y,size = size}
	table.insert(pools,po)
end

local foods = {}

function add_food(x,y)
	local fo = {x=x,y=y,z=1,xvel=math.random(-50,50),yvel=math.random(-50,50),zvel=-300}
	table.insert(foods,fo)
end

local bushes = {}

function add_bush(x,y)
	local bu = {x=x,y=y,spawnMin=10,spawnMax=20,timer=15}
	table.insert(bushes,bu)
end

local rainTimer = 0
local rainSpawnTimer = 0
local rainRate = 0.025
local rainPool = 0.2

function set_rain_timer(t)
	rainTimer = t
end

local springs = {}
local springWait = 5
local springOnFor = 1
local springRate = 0.1
local springFillRate = 0.2

function add_spring(x,y)
	local sp = {x=x,y=y,timer=springOnFor,spawnTimer=0}
	table.insert(springs, sp)
end

function reset_world()
	land.x = 0
	land.y = 0
	land.w = 1400
	land.h = 1000
	bushes = {}
	pools = {}
	springs = {}
	foods = {}
	rainTimer = 0
end

function world_update(dt)
	for i,v in ipairs(springs) do
		v.timer = v.timer - dt
		if(v.timer < springOnFor) then
			
			local pool = get_nearby_water(v.x,v.y,10)
			if(pool) then
				pool = pools[pool]
				if(pool.size < 6) then
					pool.size = pool.size + springFillRate * dt
				end
			else
				add_pool(v.x,v.y,0.5)
			end


			v.spawnTimer = v.spawnTimer - dt
			if(v.spawnTimer < 0) then


				add_parts(v.x,v.y,1,0,6,50,100,150,200,4,1,{182,255,235})
				v.spawnTimer = v.spawnTimer + springRate
			end
		end

		if(v.timer < 0) then
			v.timer = v.timer + springOnFor + springWait
		end
	end

	if(rainTimer > 0) then
		rainSpawnTimer = rainSpawnTimer - dt
		if(rainSpawnTimer < 0) then
			--add_parts(x,y,z,angle,range,forceMin, forceMax,zvelMin,zvelMax,am,lifetime,color)
			local x, y = math.random(land.x,land.x+land.w), math.random(land.y,land.y+land.h)
			local z = 400
			add_parts(x,y,z,0,1,40, 60,10,20,2,5,{0,0,100})
			rainSpawnTimer = rainSpawnTimer + rainRate
		end

		if(#pools < 4) then
			x, y = math.random(land.x,land.x+land.w), math.random(land.y,land.y+land.h)
			add_pool(x,y,1)
		end
		for i,v in ipairs(pools) do
			v.size = v.size + rainPool * dt
		end

		rainTimer = rainTimer - dt
	end
	for i,v in ipairs(foods) do
		v.x, v.y, v.z, v.xvel, v.yvel, v.zvel = update_phys(v.x,v.y,v.z,v.xvel,v.yvel,v.zvel,dt)
	end

	for i,v in ipairs(pools) do 
		if(v.size < 0.5) then
			table.remove(pools, i)
		end
	end

	for i,v in ipairs(bushes) do
		v.timer = v.timer - dt
		if(v.timer <= 0) then
			v.timer = math.random(v.spawnMin, v.spawnMax)
			add_food(v.x,v.y)
		end
	end
end

local waterImg = love.graphics.newImage("water.png")
local appleImg = love.graphics.newImage("apple.png")
local bushImg = love.graphics.newImage("bush.png")
local grassImg = love.graphics.newImage("grass.png")

local rockEdgeImg = love.graphics.newImage("rockEdge.png")
local rockFaceImg = love.graphics.newImage("rockFace.png")

function draw_rock_edge()
	local tw, th = grassImg:getDimensions()
	for x=0, land.w/tw - 1 do
		love.graphics.draw(rockEdgeImg,x*tw,-100)

		love.graphics.draw(rockEdgeImg,x*tw,land.h,0,1,-1)
	end

	for y=0, land.h/th -1 do
		love.graphics.draw(rockEdgeImg,0,(y)*th,math.pi/2,1,-1)
		love.graphics.draw(rockEdgeImg,land.w,(y)*th,math.pi/2,1,1)
	end

	love.graphics.draw(rockEdgeImg,land.w,-100,math.pi/2,1,1)
	love.graphics.draw(rockEdgeImg,0,-100,math.pi/2,1,-1)
end

function food_stop()
	for i,v in ipairs(foods) do
		v.xvel = 0
		v.zvel = 0
		v.yvel = 0
		v.z = 0
	end
end

function world_draw()
	--love.graphics.setColor(0,155,0)
	

	love.graphics.setColor(75,75,75)
	--love.graphics.rectangle("fill",land.x,land.y - 100, land.w, 100)
	love.graphics.setColor(255,255,255)

	local tw, th = grassImg:getDimensions()
	for x=0, land.w/tw -1 do
		for y=0, land.h/th -1 do
			if(y == 0) then
				love.graphics.draw(rockFaceImg,x*tw,(y-1)*th)


			end
			love.graphics.draw(grassImg,x*tw,y*th)

			if(y==math.floor(land.h/th)-1) then
				
			end
			if(x == 0) then
				
			end
			if(x == math.floor(land.w/tw) -1) then
				
			end
		end
	end





	--love.graphics.setColor(0,0,200)
	love.graphics.setColor(255,255,255)
	for i,v in ipairs(pools) do
		--love.graphics.circle("fill",v.x,v.y,v.size*10)
		local tw = v.size * 10
		local scale = tw/waterImg:getWidth() * 2
		love.graphics.draw(waterImg,v.x,v.y,0,scale,scale,waterImg:getWidth()/2, waterImg:getHeight()/2)
	end

	
	for i,v in ipairs(foods) do 
		love.graphics.draw(appleImg,v.x-3,v.y-3 - v.z)
	end

	for i,v in ipairs(bushes) do
		love.graphics.draw(bushImg,v.x,v.y,0,1,1,bushImg:getWidth()/2,bushImg:getHeight())
	end

	love.graphics.setColor(255,255,255)

end

function get_nearby_water(x,y,maxD)
	local minD = maxD
	local closest = 0
	for i,v in ipairs(pools) do
		local d = get_dist(x,y,v.x,v.y) - v.size * 10
		if(d < maxD and d < minD) then
			minD = d
			closest = i
		end
	end
	if not(closest == 0) then
		return closest
	end
	return false
end

function get_water(i)
	return pools[i]
end

function get_nearby_food(x,y,maxD)
	local minD = maxD
	local closest = 0
	for i,v in ipairs(foods) do
		local d = get_dist(v.x,v.y,x,y)
		if(d < maxD and d < minD) then
			minD = d
			closest = i
		end
	end
	if not(closest == 0) then
		return closest
	end
	return false
end

function get_food(i)
	return foods[i]
end

function food_remove(i)
	table.remove(foods,i)
end

function get_land()
	return land.x, land.y, land.w, land.h
end