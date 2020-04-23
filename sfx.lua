

local sfxs = {
	love.audio.newSource("sfx/click1.ogg"), -- 1 click
	love.audio.newSource("sfx/click2.ogg"), -- 2 click
	love.audio.newSource("sfx/critterSound1.ogg"), -- 3 critter
	love.audio.newSource("sfx/critterSound2.ogg"), -- 4 critter
	love.audio.newSource("sfx/death.ogg"), -- 5 death
	love.audio.newSource("sfx/eat.ogg"), -- 6 eat
	love.audio.newSource("sfx/eggSpawn.ogg"), -- 7 spawn egg
	love.audio.newSource("sfx/hatch.ogg"), -- 8 hatch egg
	love.audio.newSource("sfx/drink.ogg"), -- 9 drink
	love.audio.newSource("sfx/ting.ogg"), -- 10 ting
	love.audio.newSource("sfx/chime.ogg") -- 11 chime
}

local music = love.audio.newSource("sfx/music.ogg")
music:setLooping(true)
music:play()

function music_mute()
	if(music:isPlaying()) then
		music:stop()
	else
		music:play()
	end
end

local cheapTimer = 0
local cheapTime = 40

function sfx_update(dt)
	cheapTimer = cheapTimer - dt
	if(cheapTimer < 0) then
		play_sfx(math.random(3,4))
		cheapTimer = cheapTimer + math.max(5,cheapTime/get_population())
	end
end

local sfxMute = false

function mute()
	if(sfxMute) then
		sfxMute = false
	else
		sfxMute = true
	end
end

function play_sfx(i)
	if(sfxMute == false) then
		love.audio.stop(sfxs[i])
		love.audio.play(sfxs[i])
	end
end