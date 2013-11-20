buildtest.pipes.types.wood = {
	base = "default:wood",
}

buildtest.pipes.makepipe(function(set, nodes, count, name, id, clas)
	local def = {
		sunlight_propagates = true,
		paramtype = 'light',
		walkable = true,
		climbable = false,
		diggable = true,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = nodes
		},
		--------------------------
		description = clas.."Buildtest Wood Pipe",
		tiles = {"buildtest_pipe_wood.png"},
		groups = {choppy=1,oddly_breakable_by_hand=3},
		buildtest = {
			pipe=1,
			slowdown=0.1,
			connects={
				--"default:chest",
				buildtest.pipes.defaultPipes
			},
			disconnects = {{	
				"default:chest",
			}},
		},
		drop = {
			max_items = 1,
			items = {
				{ items = {'buildtest:pipe_wood_000000_'..id} }
			}
		},
		on_place = buildtest.pipes.onp_funct,
		on_dig = buildtest.pipes.ond_funct,
	}
	if count~=1 then
		def.groups.not_in_creative_inventory=1
	end
	minetest.register_node("buildtest:pipe_wood_"..name, def)
end)