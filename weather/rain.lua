-- Rain
minetest.register_globalstep(function(dtime)
	if weather.type ~= "rain" then return end
	for _, player in ipairs(minetest.get_connected_players()) do
		local ppos = player:getpos()

		-- Make sure player is not in a cave/house...
		if minetest.env:get_node_light(ppos, 0.5) ~= 15 then return end

		local minp = addvectors(ppos, {x=-9, y=7, z=-9})
		local maxp = addvectors(ppos, {x= 9, y=7, z= 9})

		local vel = {x=math.random()*weather.wind, y=   -4, z=math.random()*weather.wind}
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
