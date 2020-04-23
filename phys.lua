

local gravity = 400
local friction = 100

function update_phys(x,y,z,dx,dy,dz,dt)
	local landx, landy, landw, landh = get_land()

	if(love.keyboard.isDown("space")) then
		z = 0
		dz = 0
	end

	if(z > 0) then
		dz = dz - gravity * dt
		if(z + dz * dt < 0) then
			dz = -dz * 0.75
			if(dz < 100) then
				dz = 0
				z = 0
			end
		end
	end

	if(z == 0) then
		if(dx > 0) then
			dx = math.max(0,dx - friction * dt)
		else
			dx = math.min(0,dx + friction * dt)
		end

		if(dy > 0) then
			dy = math.max(0,dy - friction * dt)
		else
			dy = math.min(0,dy + friction * dt)
		end
	end

	if(z < 100 and CheckCollision(x,y,2,2,landx, landy, landw, landh)) then
		if(x + dx * dt < landx or x + dx * dt > landx + landw) then
			dx = -dx
		end

		if(y + dy * dt < landy or y + dy * dt > landy + landh) then
			dy = -dy
		end
	end

	x = x + dx * dt
	y = y + dy * dt
	z = z + dz * dt
	return x,y,z,dx,dy,dz
end