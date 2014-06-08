buildtest.pipes.makepipe(function(set, nodes, count, name, id, clas, type)
	if type=="liquid" then return end
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
		description = clas.."Buildtest Emerald Pipe",
		tiles = {"buildtest_pipe_emr.png"},
		groups = {choppy=1,oddly_breakable_by_hand=3},
		buildtest = {
			slowdown=0.1,
			pipe=1,
			autoconnect=false,
			connects={
				buildtest.pipes.defaultPipes,
				{"default:chest"}
			},
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
				{ items = {'buildtest:pipe_emr_000000_'..id} }
			}
		},
		--on_place = buildtest.pipes.onp_funct,
		on_place = function(itemstack, placer, pointed_thing)
			buildtest.pipes.onp_funct(itemstack, placer, pointed_thing)
			local meta = minetest.get_meta(pointed_thing.above)
			
			meta:set_string("infotext", "Emeriald Pipe")
			local inv = meta:get_inventory()
			inv:set_size("main", 8*2)
		end,
		on_dig = buildtest.pipes.ond_funct,
		on_rightclick = function(pos, node, clicker, itemstack)
			local posname = "nodemeta:"..pos.x..","..pos.y..","..pos.z
			local formspec = "invsize[8,7;]"
						.."list["..posname..";main;0,0;8,2;]"
						.."list[current_player;main;0,2;8,4;]"
			minetest.show_formspec(clicker:get_player_name(), "buildtest:pipe_emr_"..name, formspec)
		end,
		--------------------------------------------------------------------------------
		allow_metadata_inventory_put = buildtest.libs.allow_metadata_inventory_put(nil),
		allow_metadata_inventory_take = buildtest.libs.allow_metadata_inventory_take(nil),
		allow_metadata_inventory_move = buildtest.libs.allow_metadata_inventory_move(nil),
	}
	if count~=1 then
		def.groups.not_in_creative_inventory=1
	end
	minetest.register_node("buildtest:pipe_emr_"..name, def)
end)