local cam = {}
cam.x = 0
cam.y = 0
cam.scale = 1

local res = {w=640, h=480}
local screen = {w=0,h=0}

function cam_set()
	screen.w = love.graphics.getWidth()
	screen.h = love.graphics.getHeight()

	cam.scale = math.min(screen.w/res.w, screen.h/res.h)

	love.graphics.push()
	love.graphics.scale(cam.scale)
	love.graphics.translate(-cam.x, -cam.y)
end

function get_ui_w()
	return screen.w / cam.scale, screen.h / cam.scale
end

function get_cam_scale()
	return cam.scale
end


function cam_reset_pos()	
	screen.w = love.graphics.getWidth()
	screen.h = love.graphics.getHeight()
	cam.scale = math.min(screen.w/res.w, screen.h/res.h)

	local landx, landy, landw, landh = get_land()
	cam.x = landw/2 - screen.w / cam.scale / 2
	cam.y = landh/2 - screen.h / cam.scale / 2
end

function cam_ui_set()
	love.graphics.push()
	love.graphics.scale(cam.scale)
end

function cam_ui_unset()
	love.graphics.pop()
end

function mouse_cam()
	return love.mouse.getX() / cam.scale + cam.x , love.mouse.getY()  / cam.scale + cam.y
end

function cam_unset()
	love.graphics.pop()
end

function cam_move(x,y)
	cam.x = cam.x + x
	cam.y = cam.y + y
end

function get_cam()
	return cam.x, cam.y
end