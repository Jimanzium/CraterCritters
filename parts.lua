
local parts = {}

function reset_parts()
	parts = {}
end

function parts_update(dt)
	for i,v in ipairs(parts) do
		v.x, v.y, v.z, v.xvel, v.yvel, v.zvel = update_phys(v.x,v.y,v.z,v.xvel,v.yvel,v.zvel,dt)

		v.lifetime = v.lifetime - dt
		if(v.lifetime < 0) then
			table.remove(parts,i)
		end
	end
end

function add_parts(x,y,z,angle,range,forceMin, forceMax,zvelMin,zvelMax,am,lifetime,color)
	for i=1,am do
		local lifetime = math.random((lifetime-lifetime/2)*10,(lifetime+lifetime/2)*10)/10
		local a = math.random((angle-range)*100,(angle+range)*100)/100
		local f = math.random(forceMin, forceMax)
		local dx = math.cos(a) * f
		local dy = math.sin(a) * f
		local cR = 20

		local c = {math.random(color[1]-cR,color[1]+cR),math.random(color[2]-cR,color[2]+cR),math.random(color[3]-cR,color[3]+cR)}
		c[1] = math.max(c[1], 1); c[1] = math.min(c[1], 255)
		c[2] = math.max(c[2], 1); c[2] = math.min(c[2], 255)
		c[3] = math.max(c[3], 1); c[3] = math.min(c[3], 255)
		local pa = {x=x,y=y,z=z,xvel=dx,yvel=dy,zvel=math.random(zvelMin,zvelMax),w=5,h=5,life=lifetime,lifetime=lifetime,color=c}
		table.insert(parts,pa)
	end
end

function parts_draw()
	for i,v in ipairs(parts) do
		love.graphics.setColor(v.color[1],v.color[2],v.color[3],v.lifetime/v.life*255)
		love.graphics.rectangle("fill",v.x -v.w/2,v.y-v.z-v.h/2,v.w,v.h)
	end
	love.graphics.setColor(255,255,255)
end