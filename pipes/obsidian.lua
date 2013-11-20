buildtest.pipes.types.obsidian = {
	base = "default:obsidian",
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
		description = clas.."Buildtest Obsidian Pipe",
		tiles = {"buildtest_pipe_obsidian.png"},
		groups = {choppy=1,oddly_breakable_by_hand=3},
		buildtest = {
			slowdown=0.1,
			pipe=1,
			connects={
				buildtest.pipes.defaultPipes
			},
		},
		drop = {
			max_items = 1,
			items = {
				{ items = {'buildtest:pipe_obsidian_000000_'..id} }
			}
		},
		on_place = buildtest.pipes.onp_funct,
		on_dig = buildtest.pipes.ond_funct,
	}
	if count~=1 then
		def.groups.not_in_creative_inventory=1
	end
	minetest.register_node("buildtest:pipe_obsidian_"..name, def)
end)