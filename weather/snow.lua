-- Snow
local spawnerdef = {
	amount = 8,
	time = 0.5,
	minexptime = 3,
	maxexptime = 15,
	minsize = 0.8,
	maxsize = 1.2,
	collisiondetection = true,
}
minetest.register_globalstep(function(dtime)
	if weather ~= "snow" then
		return
	end
	for _, player in ipairs(minetest.get_connected_players()) do
		local ppos = player:getpos()

		-- Make sure player is not in a cave/house...
		--if minetest.get_node_light(ppos, 0.5) ~= 15 then return end

		spawnerdef.minpos = addvectors(ppos, {x=-9, y=7, z=-9})
		spawnerdef.maxpos = addvectors(ppos, {x= 9, y=7, z= 9})

		spawnerdef.minvel = {x=0, y= -1, z=0}
		spawnerdef.maxvel = spawnerdef.minvel
		spawnerdef.minacc = {x=0, y= 0, z=0}
		spawnerdef.maxacc = spawnerdef.minacc

		spawnerdef.playername = player:get_player_name()

		for _,i in ipairs({"", "2"}) do
			spawnerdef.texture = "weather_snow"..i..".png"
			minetest.add_particlespawner(spawnerdef)
		end
	end
end)

--[[local snow_box =
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

--[ Enable this section if you have a very fast PC
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
					minetest.env:add_node(np, {name="weather:snow_cover"})
				end
			end
		end
	end
})
]]
