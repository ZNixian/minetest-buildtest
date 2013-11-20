minetest.register_node("buildtest:pump", {
	--tiles = {"buildtest_pump_mesecon.png"},
	description = "Buildtest Liquids Pump",
	groups = {choppy=1,oddly_breakable_by_hand=3},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	buildtest = {
		pipe=1,
		connects={
			--{"buildtest:pipe_wood"},
			buildtest.pipes.defaultPipes,
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
})