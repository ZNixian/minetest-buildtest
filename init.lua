buildtest={
	libs = {
		allow_metadata_inventory_put = function(exc, isnumber)
			return function(pos, listname, index, stack, player)
					if listname==exc then
						return stack:get_count()
					end
					local meta=minetest.get_meta(pos)
					local inv=meta:get_inventory()
					if inv:get_stack(listname, index):is_empty() then
						local newStack = {name = stack:get_name()}
						if isnumber==true then
							newStack.count = stack:get_count()
						end
						inv:set_stack(listname, index, newStack)
					end
					return 0
				end
		end,
		allow_metadata_inventory_take = function(exc)
			return function(pos, listname, index, stack, player)
					if listname==exc then
						return stack:get_count()
					end
					local meta=minetest.get_meta(pos)
					local inv=meta:get_inventory()
					inv:set_stack(listname, index, nil)
					return 0
					end
		end,
		allow_metadata_inventory_move = function(exc, ok)
			return function(pos, from_list, from_index, to_list, to_index, count, player)
					if from_list==to_list or ok==true then
						return count
					end
					return 0
					end
		end,
	}
}

dofile(minetest.get_modpath("buildtest").."/pipes/pipes_defs.lua")
dofile(minetest.get_modpath("buildtest").."/pipes/pipes_init.lua")
dofile(minetest.get_modpath("buildtest").."/pumps/pump_init.lua")
dofile(minetest.get_modpath("buildtest").."/support/entity.lua")
dofile(minetest.get_modpath("buildtest").."/support/liquid.lua")
dofile(minetest.get_modpath("buildtest").."/misc/init.lua")

dofile(minetest.get_modpath("buildtest").."/crafts.lua")

print("[buildtest] Mod loaded!")