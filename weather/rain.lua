--adding weather.conf

local modpath = minetest.get_modpath(minetest.get_current_modname())
local worldpath = minetest.get_worldpath()
local input = io.open(modpath.."/weather.conf", "r")
if input then
	dofile(modpath.."/weather.conf")
	input:close()
	input = nil
end
input = io.open(worldpath.."/weather.conf", "r")
if input then
	dofile(worldpath.."/weather.conf")
	input:close()
	input = nil
end


-- Rain
weather_mod.register_downfall("weather:rain",{
	min_pos = {x=-9, y=7, z=-9},
	max_pos = {x= 9, y=7, z= 9},
	falling_speed=10,
	amount=25,
	exptime=0.8,
	size=25,
	texture="weather_rain.png",
	enable_lightning=true,
})
if minetest.is_yes(minetest.settings:get_bool('snow_covers_abm')) and minetest.get_modpath("waterplus") then
	minetest.register_abm({
		nodenames = {"group:crumbly", "group:snappy", "group:cracky", "group:choppy"},
		neighbors = {"default:air"},
		interval = 10.0, 
		chance = 80,
		action = function (pos, node, active_object_count, active_object_count_wider)
			if weather == "rain" then
				if minetest.registered_nodes[node.name].drawtype == "normal"
				or minetest.registered_nodes[node.name].drawtype == "allfaces_optional" then
					local np = vector.add(pos, {x=0, y=1, z=0})
					if minetest.get_node_light(np, 0.5) == 15
					and minetest.get_node(np).name == "air" then
						minetest.add_node(np, {name="waterplus:finite_1"})
						--minetest.env:add_node(np, {name="default:water_flowing"})
					end
				end
			end
		end
	})
end
