buildtest.pipes.types.gold = {
	base = "default:gold_ingot",
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
		description = clas.."Buildtest Gold Pipe",
		tiles = {"buildtest_pipe_gold.png"},
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
				{ items = {'buildtest:pipe_gold_000000_'..id} }
			}
		},
		mesecons = {
			effector = {
				action_off = function (pos, node)
					local meta = minetest.get_meta(pos)
					meta:set_int("on", 1)
				end,
				action_on = function (pos, node)
					local meta = minetest.get_meta(pos)
					meta:set_int("on", 0)
				end,
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			buildtest.pipes.onp_funct(itemstack, placer, pointed_thing)
			local meta = minetest.get_meta(pointed_thing.above)
			meta:set_int("on", 1)
		end,
		on_dig = buildtest.pipes.ond_funct,
	}
	if count~=1 then
		def.groups.not_in_creative_inventory=1
	end
	minetest.register_node("buildtest:pipe_gold_"..name, def)
end)