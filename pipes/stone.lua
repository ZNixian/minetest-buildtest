buildtest.pipes.types.stone = {
	base = "default:stone",
}

buildtest.pipes.makepipe(function(set, nodes, count, name, id, clas, type, toverlay)
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
		description = clas.."Buildtest Stone Pipe",
		tiles = {"buildtest_pipe_stone.png"..toverlay},
		groups = {choppy=1,oddly_breakable_by_hand=3},
		buildtest = {
			slowdown=0.025,
			pipe=1,
			connects={
				buildtest.pipes.defaultPipes
			},
			disconnects = {{	
					"buildtest:pipe_cobble",
			}},
			pipe_groups = {
				type = type,
			},
			vconnects={
				buildtest.pipes.defaultVPipes
			},
		},
		drop = {
			max_items = 1,
			items = {
				{ items = {'buildtest:pipe_stone_000000_'..id} }
			}
		},
		on_place = buildtest.pipes.onp_funct,
		on_dig = buildtest.pipes.ond_funct,
	}
	if count~=1 then
		def.groups.not_in_creative_inventory=1
	end
	minetest.register_node("buildtest:pipe_stone_"..name, def)
end)