minetest.register_node("buildtest:quarry", {
	tiles = {
		"buildtest_quarry_top.png",
		"buildtest_quarry.png",
		"buildtest_quarry.png",
		"buildtest_quarry.png",
		"buildtest_quarry.png",
		"buildtest_quarry_front.png",
	},
	description = "Buildtest Quarry",
	groups = {cracky=1},
	paramtype2 = "facedir",
	buildtest = {
		pipe_groups = {
			type = "transp",
		},
		power = {
		},
	},
	on_construct = function(pos)
		local nextTo = buildtest.landmarks.getNextTo(pos)
		local bounds = buildtest.landmarks.getBounds(nextTo)
		buildtest.landmarks.removeMarks(nextTo)
		local meta = minetest.get_meta(pos)
		meta:set_string("pmin", minetest.pos_to_string(bounds.pmin))
		meta:set_string("pmax", minetest.pos_to_string(bounds.pmax))
		meta:set_int("size", (bounds.pmax.x-bounds.pmin.x)*(bounds.pmax.z-bounds.pmin.z))
		meta:set_int("power", 0)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local itemstk=minetest.item_place(itemstack, placer, pointed_thing)
		for i=1,6 do
			buildtest.pipes.processNode(vector.add(pointed_thing.above,buildtest.toXY(i)))
		end
		return itemstk
	end
})

buildtest.pumps.pumpible["buildtest:quarry"] = {
	power = function(pos, speed)
		local meta = minetest.get_meta(pos)
		local power = meta:get_int("power")
		power = power + speed
		local size = meta:get_int("size")
		if power < size then
			meta:set_int("power", power)
		end
		power = power - size
		meta:set_int("power", power)
		
		local pmin = minetest.string_to_pos(meta:get_string("pmin"))
		local pmax = minetest.string_to_pos(meta:get_string("pmax"))
		print(meta:get_string("pmin"))
		
		local topos  = buildtest.pumps.findpipe(pos)
		local l = pmin.y-1
		while minetest.get_node({x=pmin.x, y=l, z=pmin.z}).name=="air" do
			l=l-1
		end
		pmin.y = l
		
		for x=pmin.x,pmax.x do
			for z=pmin.z,pmax.z do
				local bpos = {x=x, y=pmin.y, z=z}
				local n = minetest.get_node(bpos)
				if n.name~="ignore" then
					minetest.remove_node(bpos)
					local itemstacks = minetest.get_node_drops(n.name)
					for _, itemname in ipairs(itemstacks) do
						buildtest.makeEnt(topos, {name=itemname}, 1, bpos)
					end
				end
			end
		end
	end,
}