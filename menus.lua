
local dismiss = false

function menu_pressed()
		local sw, sh = get_ui_w()
		local pop = get_population()
		if(get_lvl() >= 6 and get_freed() == false and dismiss == false) then
			set_paused(true)
			if(gui_button_check(sw/2, sh/2 + 100, 100,20)) then
				dismiss = true
				set_paused(false)
			end
		elseif(pop <= 1 and get_lvl() < 6) then
			set_paused(true)
			if(gui_button_check(sw/2 + 60, sh * 0.75, 100, 20)) then
				reset()
			elseif(gui_button_check(sw/2 - 60, sh * 0.75, 100, 20)) then
				love.event.quit()
			end
		elseif(get_freed() and pop <= 0) then
			set_paused(true)
			if(gui_button_check(sw/2 + 60, sh * 0.75, 100, 20)) then
				reset()
			elseif(gui_button_check(sw/2 - 60, sh * 0.75, 100, 20)) then
				love.event.quit()
			end
		elseif(get_paused()) then
			if(gui_button_check(sw/2 + 60, sh * 0.75, 100, 20)) then
				set_paused(false)
			elseif(gui_button_check(sw/2 - 60, sh * 0.75, 100, 20)) then
				love.event.quit()
			end
		end
end

function menus_update(dt)

end

function menus_draw()
	local sw, sh = get_ui_w()
	local pop = get_population()
	if(get_lvl() >= 6 and get_freed() == false and dismiss == false) then
		cprint("MAX LVL REACHED", sw/2, sh/2)
		cprint("Use your final ability to free the critters!", sw/2, sh/2 + 20)
		gui_button("Okay", sw/2, sh/2 + 100, 100,20)
		--gui_button("Keep playing", sw/2 + 60, sh * 0.75, 110, 20)
		--gui_button("Free the critters", sw/2 - 60, sh * 0.75, 110, 20)
	elseif(pop <= 1 and get_lvl() < 6) then
		cprint("GAME OVER", sw/2, sh/2)
		gui_button("Retry", sw/2 + 60, sh * 0.75, 100, 20)
		gui_button("Quit", sw/2 - 60, sh * 0.75, 100, 20)
	elseif(get_freed() and pop <= 0) then
		cprint("WINNER", sw/2, sh/2)
		gui_button("Play Again", sw/2 + 60, sh * 0.75, 100, 20)
		gui_button("Quit", sw/2 - 60, sh * 0.75, 100, 20)
	elseif(get_paused()) then
		cprint("PAUSED", sw/2, sh/2)
		gui_button("Resume", sw/2 + 60, sh * 0.75, 100, 20)
		gui_button("Quit", sw/2 - 60, sh * 0.75, 100, 20)
	elseif(get_time() < 15) then

		f = math.min(255,255 - math.cos((get_time()/15*2*math.pi)) * 255)

		love.graphics.setColor(255,255,255,f)
		cprint("Crater Critters", sw/2, sh*0.25)
		love.graphics.setColor(255,255,255)
	end
end

function gui_button_check(x,y,w,h)
	local s = get_cam_scale()
	local mx, my = love.mouse.getX()/s, love.mouse.getY()/s
	--if(love.mouse.isDown(1)) then
		if(CheckCollision(x-w/2,y-h/2,w,h,mx,my,2,2)) then
			play_sfx(2)
			return true
		end
	--end
end

function gui_button(text,x,y,w,h)
	love.graphics.setColor(31,15,0)
	love.graphics.rectangle("fill",x-w/2 - 2,y-h/2 - 2,w + 4,h + 4)

	love.graphics.setColor(77,37,0)
	love.graphics.rectangle("fill",x-w/2,y-h/2,w,h)
	love.graphics.setColor(255,255,255)
	cprint(text, x, y)
end