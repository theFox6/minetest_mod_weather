-- Rain
local spawnerdef = {
	amount = 25,
	time = 0.5,
	minexptime = 0.8,
	maxexptime = 0.8,
	minsize = 0.8,
	maxsize = 1.2,
	collisiondetection = true,
	vertical = true,
	texture = "weather_rain.png",
}
minetest.register_globalstep(function(dtime)
	if weather ~= "rain" then
		return
	end
	for _, player in ipairs(minetest.get_connected_players()) do
		local ppos = player:getpos()

		-- Make sure player is not in a cave/house...
		--if minetest.get_node_light(ppos, 0.5) ~= 15 then return end

		spawnerdef.minpos = addvectors(ppos, {x=-9, y=7, z=-9})
		spawnerdef.maxpos = addvectors(ppos, {x= 9, y=7, z= 9})

		spawnerdef.minvel = {x=0, y= -40, z=0}
		spawnerdef.maxvel = spawnerdef.minvel
		spawnerdef.minacc = {x=0, y= 0, z=0}
		spawnerdef.maxacc = spawnerdef.minacc

		spawnerdef.playername = player:get_player_name()

		minetest.add_particlespawner(spawnerdef)
	end
end)
