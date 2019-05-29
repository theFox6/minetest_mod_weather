-- Snow
weather_mod.register_downfall("weather:snow",{
	min_pos = {x=-9, y=7, z=-9},
	max_pos = {x= 9, y=7, z= 9},
	falling_speed=5,
	amount=10,
	exptime=5,
	size=25,
	texture="weather_snow.png"
})

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

-- Snow cover ABM when snow_covers_abm setting is set to `true`
if minetest.is_yes(minetest.settings:get_bool('snow_covers_abm')) then
	minetest.log('action', '[weather] Loaded fast computer ABM (snow covers when weather:snow is set)')
	minetest.register_abm({
		nodenames = {"group:crumbly", "group:snappy", "group:cracky", "group:choppy"},
		neighbors = {"default:air"},
		interval = 10.0,
		chance = 80,
		action = function (pos, node)
			if weather.type == "weather:snow" then
				if minetest.registered_nodes[node.name].drawtype == "normal"
				or minetest.registered_nodes[node.name].drawtype == "allfaces_optional" then
					local np = vector.add(pos, {x=0, y=1, z=0})
					if minetest.env:get_node_light(np, 0.5) == 15
					and minetest.env:get_node(np).name == "air" then
						minetest.env:add_node(np, {name="weather:snow_cover"})
					end
				end
			end
		end
	})
end
