minetest.register_node("buildtest:pump", {
	--tiles = {"buildtest_pump_mesecon.png"},
	description = "Buildtest Liquids Pump",
	groups = {choppy=1,oddly_breakable_by_hand=3},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	buildtest = {
		pipe_groups = {
			type = "liquid",
		},
		power = {
		},
	},
	on_construct = function(pos)
	end,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.5,-0.5,-0.5,0.5,0.5,0.5}}
	},
	selection_box = {{
		0.5,0.5,0.5,-0.5,-0.5,-0.5,
	}},
	on_place = function(itemstack, placer, pointed_thing)
		local itemstk=minetest.item_place(itemstack, placer, pointed_thing)
		for i=1,6 do
			buildtest.pipes.processNode(vector.add(pointed_thing.above,buildtest.toXY(i)))
		end
		return itemstk
	end
})

minetest.register_node("buildtest:pump_pipe_act", {
	groups = {oddly_breakable_by_hand=3},
})

minetest.register_node("buildtest:pump_pipe_off", {
	groups = {not_in_creative_inventory=1,oddly_breakable_by_hand=3},
})

minetest.register_abm({
	nodenames = {"default:lava_source"},
	neighbors = {"buildtest:pump_pipe_act"},
	interval = 10,
	chance = 1,
	action = function(pos, node)
		minetest.set_node(pos, {name="buildtest:pump_pipe_act"})
	end,
})
