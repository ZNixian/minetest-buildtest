buildtest.autocraft = {
	allow_metadata_inventory_put = buildtest.libs.allow_metadata_inventory_put,
	allow_metadata_inventory_take = buildtest.libs.allow_metadata_inventory_take,
	allow_metadata_inventory_move = buildtest.libs.allow_metadata_inventory_move,
	--------------------------------------------------------------------------------
	do_craft = function(inventory)
		local recipe=inventory:get_list("craft")
		local result
		local new
		for i=1,9 do
			recipe[i]=ItemStack({name=recipe[i]:get_name(),count=1})
		end
		result,new=minetest.get_craft_result({method="normal",width=3,items=recipe})
		local input=inventory:get_list("in")
		if result.item:is_empty() then return end
		result=result.item
		if not inventory:room_for_item("in", result) then return end
		local to_use={}
		for _,item in ipairs(recipe) do
			if item~=nil and not item:is_empty() then
				if to_use[item:get_name()]==nil then
					to_use[item:get_name()]=1
				else
					to_use[item:get_name()]=to_use[item:get_name()]+1
				end
			end
		end
		local stack
		for itemname,number in pairs(to_use) do
			stack=ItemStack({name=itemname, count=number})
			if not inventory:contains_item("in",stack) then return end
		end
		for itemname,number in pairs(to_use) do
			stack=ItemStack({name=itemname, count=number})
			inventory:remove_item("in",stack)
		end
		inventory:add_item("in",result)
		for i=1,9 do
			inventory:add_item("in",new.items[i])
		end
	end,
}


minetest.register_node("buildtest:autocraft", {
	--tiles = {"buildtest_pump_mesecon.png"},
	description = "Buildtest Automatic Crafting Table",
	groups = {choppy=1, oddly_breakable_by_hand=3},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("craft", 9)
		inv:set_size("in", 8*3)
		
		meta:set_string("formspec", "size[8,11]"
				.."list[context;craft;2.5,0;3,3]"
				.."list[context;in;0,3.5;8,3]"
				.."list[current_player;main;0,7;8,4]")
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("in")
	end,
	--------------------------------------------------------------------------------
	allow_metadata_inventory_put = buildtest.autocraft.allow_metadata_inventory_put("in"),
	allow_metadata_inventory_take = buildtest.autocraft.allow_metadata_inventory_take("in"),
	allow_metadata_inventory_move = buildtest.autocraft.allow_metadata_inventory_move("in"),
	---------------------------------------------------------------------------------
	on_place = buildtest.pipes.onp_funct,
	on_dig = buildtest.pipes.ond_funct,
})

minetest.register_abm({
	nodenames={"buildtest:autocraft"},
	interval=5,
	chance=1,
	action=function(pos,node)
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		buildtest.autocraft.do_craft(inv)
	end,
})