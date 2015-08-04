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

-- Snow
minetest.register_globalstep(function(dtime)
	if weather ~= "snow" then return end
	for _, player in ipairs(minetest.get_connected_players()) do
		local ppos = player:getpos()

		-- Make sure player is not in a cave/house...
		if minetest.env:get_node_light(ppos, 0.5) ~= 15 then return end

		local minp = addvectors(ppos, {x=-9, y=7, z=-9})
		local maxp = addvectors(ppos, {x= 9, y=7, z= 9})

		local minp_deep = addvectors(ppos, {x=-10, y=3.2, z=-10})
		local maxp_deep = addvectors(ppos, {x= 10, y=2.6, z= 10})

		local vel = {x=0, y=   -0.5, z=0}
		local acc = {x=0, y=   -0.5, z=0}

		minetest.add_particlespawner(5, 0.5,
			minp, maxp,
			vel, vel,
			acc, acc,
			5, 5,
			25, 25,
			false, "weather_snow.png", player:get_player_name())

		minetest.add_particlespawner(4, 0.5,
			minp_deep, maxp_deep,
			vel, vel,
			acc, acc,
			4, 4,
			25, 25,
			false, "weather_snow.png", player:get_player_name())
	end
end)

local snow_box =
{
	type  = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
}

-- Snow cover
minetest.register_node("weather:snow_cover", {
	tiles = {"weather_snow_cover.png"},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = snow_box,
	selection_box = snow_box,
	groups = {not_in_creative_inventory = 1, crumbly = 3, attached_node = 1},
	drop = {}
})



-- Enable this section if you have a very fast PC
if SNOW_COVER then
minetest.register_abm({
	nodenames = {"group:crumbly", "group:snappy", "group:cracky", "group:choppy"},
	neighbors = {"default:air"},
	interval = 10.0, 
	chance = 80,
	action = function (pos, node, active_object_count, active_object_count_wider)
		if weather == "snow" then
			if minetest.registered_nodes[node.name].drawtype == "normal"
			or minetest.registered_nodes[node.name].drawtype == "allfaces_optional" then
				local np = addvectors(pos, {x=0, y=1, z=0})
				if minetest.env:get_node_light(np, 0.5) == 15
				and minetest.env:get_node(np).name == "air" then
					minetest.env:add_node(np, {name="default:snow"})
					--minetest.env:add_node(np, {name="weather:snow_cover"})
				end
			end
		end
	end
})
end
