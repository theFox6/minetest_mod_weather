-- Weather:
-- * rain
-- * snow
-- * wind (not implemented)
print("Lol print works")
assert(minetest.add_particlespawner, "I told you to run the latest GitHub!")

addvectors = function (v1, v2)
	return {x=v1.x+v2.x, y=v1.y+v2.y, z=v1.z+v2.z}
end

save_weather = function ()
	local file = io.open(minetest.get_worldpath().."/weather", "w+")
	file:write(weather)
	file:close()
end

read_weather = function ()
	local file = io.open(minetest.get_worldpath().."/weather", "r")
	if not file then return end
	local readweather = file:read()
	file:close()
	return readweather
end

weather = read_weather()

minetest.register_globalstep(function(dtime)
	if weather == "rain" or weather == "snow" then
		if math.random(1, 10000) == 1 then
			weather = "none"
			save_weather()
		end
	else
		if math.random(1, 50000) == 1 then
			weather = "rain"
			save_weather()
		end
		if math.random(1, 50000) == 2 then
			weather = "snow"
			save_weather()
		end
	end
end)

dofile(minetest.get_modpath("weather").."/rain.lua")
dofile(minetest.get_modpath("weather").."/snow.lua")
dofile(minetest.get_modpath("weather").."/command.lua")


