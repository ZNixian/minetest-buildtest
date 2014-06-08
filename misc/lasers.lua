minetest.register_node("buildtest:laser", {
	description = "Buildtest Assembly Laser",
	tiles = {
		"buildtest_laser_top.png",
		"buildtest_laser.png",
		"buildtest_laser.png",
	},
	groups = {cracky=3},
	buildtest = {
		power = {
		},
	},
	paramtype2 = "wallmounted",
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local mode = meta:get_int("mode")
		mode = (mode + 1) % 2
		meta:set_int("mode", mode)
		meta:set_string("infotext", "Laser. Mode: "..mode .. " (rightclick to change)")
	end,
})


buildtest.pumps.pumpible["buildtest:laser"] = {
	power = function(laser_pos, speed)
		local meta = minetest.get_meta(pos)
		local mode = meta:get_int("mode")
		if mode==0 then
			local pos = minetest.find_node_near(laser_pos, 5, {"group:buildtest_laser"})
			if pos~=nil then
				buildtest.assembly.add_energy(pos, speed)
			end
		elseif mode==1 then
			local dirs = {
				[0] = {y = 1},
				[1] = {y = -1},
				[2] = {x = 1},
				[3] = {x = -1},
				[4] = {z = 1},
				[5] = {z = -1},
			}
			local pos = laser_pos
			local dir = dirs[minetest.get_node(laser_pos).param2]
			dir.x = dir.x or 0
			dir.y = dir.y or 0
			dir.z = dir.z or 0
			for i=1, 30 do
				pos = vector.add(pos, dir)
				local node = minetest.get_node(pos)
				if minetest.get_item_group(node.name, "buildtest_laser")~=0 then
					local def = minetest.registered_nodes[node.name]
					if def~=nil and def.buildtest~=nil and def.buildtest.on_laser~=nil then
						def.buildtest.on_laser(pos, speed)
					end
				elseif node.name~="air" then
					return
				end
			end
		end
	end,
}