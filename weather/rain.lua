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

		minetest.add_particlespawner(25, 0.5,
			minp, maxp,
			vel, vel,
			acc, acc,
			0.8, 0.8,
			25, 25,
			false, "weather_rain.png", player:get_player_name())
	end
end)
