--adding weather.conf
print("Lol print works")
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
minetest.register_globalstep(function(dtime)
	if weather ~= "rain" then return end
	for _, player in ipairs(minetest.get_connected_players()) do
		local ppos = player:getpos()

		-- Make sure player is not in a cave/house...
		if minetest.env:get_node_light(ppos, 0.5) ~= 15 then return end

		local minp = addvectors(ppos, {x=-9, y=7, z=-9})
		local maxp = addvectors(ppos, {x= 9, y=7, z= 9})

		local vel = {x=0, y=   -4, z=0}
		local acc = {x=0, y=-9.81, z=0}

		minetest.add_particlespawner({amount=25, time=0.5,
			minpos=minp, maxpos=maxp,
			minvel=vel, maxvel=vel,
			minacc=acc, maxacc=acc,
			minexptime=0.8, maxexptime=0.8,
			minsize=25, maxsize=25,
			collisiondetection=false, vertical=true, texture="weather_rain.png", player=player:get_player_name()})
	end
end)

-- Might want to comment this section out if you don't have a fast computer
--if RAIN_DROPS then
if RAIN_DROPS and minetest.get_modpath("waterplus") then
minetest.register_abm({
	nodenames = {"group:crumbly", "group:snappy", "group:cracky", "group:choppy"},
	neighbors = {"default:air"},
	interval = 10.0, 
	chance = 80,
	action = function (pos, node, active_object_count, active_object_count_wider)
		if weather == "rain" then
			if minetest.registered_nodes[node.name].drawtype == "normal"
			or minetest.registered_nodes[node.name].drawtype == "allfaces_optional" then
				local np = addvectors(pos, {x=0, y=1, z=0})
				if minetest.env:get_node_light(np, 0.5) == 15
				and minetest.env:get_node(np).name == "air" then
					--if minetest.get_modpath("waterplus") then
						--minetest.env:add_node(np, {name="waterplus:finite_1"})
					--else
						minetest.env:add_node(np, {name="default:water_flowing"})
					--end
				end
			end
		end
	end
})
end
