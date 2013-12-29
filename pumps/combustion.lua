buildtest.pumps.types.combustion = {
	get_pump_active_formspec = function(heat, fuel)
		local formspec =
			"size[8,9]"..
			--"image[2,2;1,1;default_furnace_fire_bg.png^[lowpart:"..percent..":default_furnace_fire_fg.png]"..
			"list[context;fuel;2.5,2;1,1;]"..
			
			"image[6.5,0;1,5;default_lava.png^[lowpart:"..(heat)..":default_water.png]]"..
			--"image[6.5,0;1,5;default_water.png]"..
			--"image[6.5,"..(5 - heat * 5 / 4)..";1,1;buildtest_maker.png]"..
			
			"image[5.5,0;1,5;oil_oil.png^[lowpart:"..(fuel)..":oil_fuel.png]]"..
			--"image[5.5,0;1,5;oil_fuel.png]"..
			--"image[5.5,"..(5 - fuel * 5 / 100)..";1,1;buildtest_maker.png]"..
			
			"list[context;heat;2.5,3;1,1;]"..
			 "list[context;out;3.5,3;2,2;]"..
			"list[current_player;main;0,5;8,4;]"
		return formspec
	end,
	set_pump_active_formspec = function(pos)
		local meta = minetest.get_meta(pos)
		local fuel_level = meta:get_int("fuel")
		--local max_fuel = meta:get_int("maxfuel")
		local max_fuel = 1000
		local fuel = (fuel_level / max_fuel) * 100
		local def = minetest.registered_items[minetest.get_node(pos).name]
		--local water = def.buildtest.pump.typeId * 100 / 4
		local water = meta:get_int("water")
		local formspec = buildtest.pumps.types.combustion.get_pump_active_formspec(water, (fuel or 0))
		meta:set_string("formspec", formspec)
	end,
	handleCooling = function(pos, inv)
		local meta = minetest.get_meta(pos)
		local def = minetest.registered_items[minetest.get_node(pos).name]
		----------------------------------------------------
		if minetest.get_node(pos).name=="buildtest:engine_combustion_yellow" then
			--print(meta:get_int("water"))
			if meta:get_int("water") > 1 then
				meta:set_int("water", meta:get_int("water") - 2)
				buildtest.pumps.types.combustion.set_pump_active_formspec(pos)
				return false
			end
		end
		if minetest.get_node(pos).name=="buildtest:engine_combustion_red" then
			if meta:get_int("water") > 20 then
				meta:set_int("water", meta:get_int("water") - 20)
				buildtest.pumps.hacky_swap_node(pos, def.buildtest.pump.prev)
				buildtest.pumps.types.combustion.set_pump_active_formspec(pos)
				return true
			end
		end
		------------------------------------------------------
		if inv:get_stack("heat", 1):is_empty() then
			return false
		end
		local name = inv:get_stack("heat", 1):get_name()
		if name=="bucket:bucket_lava" then
			if def.buildtest.pump.next~=nil then
				buildtest.pumps.hacky_swap_node(pos, def.buildtest.pump.next)
				inv:set_stack("heat", 1, ItemStack(nil))
				inv:add_item("out", ItemStack("bucket:bucket_empty"))
				return true
			end
		end
		if name=="bucket:bucket_water" then
			--if def.buildtest.pump.prev~=nil then
			if meta:get_int("water") < 80 then
				--buildtest.pumps.hacky_swap_node(pos, def.buildtest.pump.prev)
				meta:set_int("water", meta:get_int("water") + 20)
				inv:set_stack("heat", 1, ItemStack(nil))
				inv:add_item("out", ItemStack("bucket:bucket_empty"))
				buildtest.pumps.types.combustion.set_pump_active_formspec(pos)
				return true
			end
		end
		return false
	end,
}

buildtest.pumps.register_pump("buildtest:engine_combustion", "default_steel_block.png", {
	description = "Buildtest Combustion Engine",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		---------------------------
		local formspec = buildtest.pumps.types.combustion.get_pump_active_formspec(0, 1)
		---------------------------
		meta:set_string("formspec", formspec)
		meta:set_int("water", 0)
		---------------------------
		local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("heat", 1)
		inv:set_size("out", 2*2)
		buildtest.pumps.on_construct(pos)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if not inv:is_empty("fuel") then
			return false
		end
		return true
	end,
},
{
	abm = function(pos)
		buildtest.pumps.send(pos)
	end,
	runConf = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local isBurning = function()
			local fuel_level = (meta:get_int("fuel") or 0)
			if fuel_level > 20 then
				fuel_level = fuel_level - 20
				meta:set_int("fuel", fuel_level)
				buildtest.pumps.types.combustion.set_pump_active_formspec(pos)
				return true
			end
			return false
		end
		
		if buildtest.pumps.types.combustion.handleCooling(pos, inv)==true then
			return false
		end
		
		if inv:get_stack("fuel", 1):is_empty() then
			return isBurning()
		end
		
		local items = inv:get_list("fuel")
		
		local itemName = items[1]:get_name()
		if itemName ~= "bucket:bucket_lava" and itemName ~= "oil:fuel_bucket" and itemName ~= "oil:bucket_oil" then
			return isBurning()
		end
--		print("item: "..inv:get_stack("fuel", 1):get_name())
		local fuel
		local sub
		fuel, sub = minetest.get_craft_result({
			method="fuel",
			width=1,
			items = items,
		})
		if fuel.time <= 0 then
			return isBurning()
		end
		--meta:set_int("maxfuel", fuel.time)
		local fuel_level = (meta:get_int("fuel") or 0)
		if fuel.time + fuel_level >= 1000 then
			return isBurning()
		end
		meta:set_int("fuel", fuel.time + fuel_level)
		inv:set_list("fuel", sub.items)
		buildtest.pumps.types.combustion.set_pump_active_formspec(pos)
--		print("pumping")
		return isBurning()
	end,
	
	canHeat = function(pos)
		local meta = minetest.get_meta(pos)
		if minetest.get_node(pos).name=="buildtest:engine_combustion_yellow" then
			if meta:get_int("water") > 20 then
				return false
			end
		end
		return true
	end,
	
	moveCount = 99,
	explodes = true,
}
)