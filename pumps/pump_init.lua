buildtest.pumps = {
	types = {},
	crafts = {},
	colours = {
		[1] = "blue",
		[2] = "green",
		[3] = "yellow",
		[4] = "red",
	},
	pulls = {
		["default:chest"] = {"main"},
		["default:furnace_active"] = {"dst"},
		["default:furnace"] = {"dst"},
		["buildtest:autocraft"] = {"in"},
		["itest:macerator"] = {"dst"},
		["itest:macerator_active"] = {"dst"},
		["itest:iron_furnace_active"] = {"dst"},
		["itest:iron_furnace"] = {"dst"},
		["itest:electric_furnace_active"] = {"dst"},
		["itest:electric_furnace"] = {"dst"},
		["itest:extractor_active"] = {"dst"},
		["itest:extractor"] = {"dst"},
	},
	pumpible = {
	},
	hacky_swap_node = function(pos, name)
		local node = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		--local meta0 = meta:to_table()
		if node.name == name then
			return
		end
		node.name = name
		local meta0 = meta:to_table()
		minetest.set_node(pos,node)
		meta = minetest.get_meta(pos)
		meta:from_table(meta0)
	end,
	temp = function(pos, amnt)
		local prev = minetest.registered_items[minetest.get_node(pos).name].buildtest.pump[amnt]
		if prev~=nil then
			buildtest.pumps.hacky_swap_node(pos, prev)
		end
	end,
	findpipe = function(pos)
		for i=1,6 do
			local tmpPos=buildtest.posADD(pos,buildtest.toXY(i))
			if buildtest.pipeAt(tmpPos)==true or buildtest.pumps.isPumpable(tmpPos)==true then
				return tmpPos
			end
		end
		return {x=pos.x,y=pos.y+1,z=pos.z}
	end,
	findchest = function(pos)
		for i=1,6 do
			local tmpPos=buildtest.posADD(pos,buildtest.toXY(i))
			if buildtest.pumps.pulls[minetest.get_node(tmpPos).name]~=nil then
				return tmpPos
			end
		end
		return {x=pos.x,y=pos.y+1,z=pos.z}
	end,
	isPumpable = function(pos)
		local def=minetest.registered_items[minetest.get_node(pos).name]
		if def==nil then return false end
		if def.buildtest==nil then return false end
		if def.buildtest.power==nil then return false end
		return true
	end,
}

buildtest.pumps.send_power = function(pipepos, speed, movecount)
	local chestpos = buildtest.pumps.findchest(pipepos) --{x=pipepos.x,y=pipepos.y+1,z=pipepos.z}
	if buildtest.pumps.pulls[minetest.get_node(chestpos).name]~=nil and (strs:starts(minetest.get_node(pipepos).name, "buildtest:pipe_wood_")
					or strs:starts(minetest.get_node(pipepos).name, "buildtest:pipe_emr_")) then  --  was minetest.get_node(chestpos).name=="default:chest"
		local inv = minetest.get_meta(chestpos):get_inventory()
		local tosend = nil
		local pipeinv = minetest.get_meta(pipepos):get_inventory()
		local listname = buildtest.pumps.pulls[minetest.get_node(chestpos).name][1]
		local numitems = 1
		---------------------------------
		for i=1, inv:get_size(listname) do
			local cell = inv:get_stack(listname, i):to_table()
			if tosend==nil and cell~=nil and inv:get_stack(listname, i):is_empty()==false then
				if strs:starts(minetest.get_node(pipepos).name, "buildtest:pipe_wood_") or pipeinv:contains_item("main", {name = cell.name}) then
					local move = math.min(cell.count,
							movecount)
					
					tosend=ItemStack(cell):to_table()
					tosend.count = 1
					numitems = move
					cell.count = cell.count - move
					inv:set_stack(listname, i, cell)
				end
			end
		end
		if tosend==nil then return end
		local tbetween = 0.5 * (#buildtest.pumps.colours + 1 - speed) / numitems
		for i=1, numitems do
			minetest.after(tbetween * i, function()
				local entity = buildtest.makeEnt(pipepos, tosend, speed, chestpos)
			end)
		end
--		if entity then
--			entity:setpos(chestpos)
--			entity:setvelocity({x=0, y=0-speed, z=0})
--		end
	elseif strs:starts(minetest.get_node(pipepos).name, "buildtest:pipe_obsidian_") then
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, speed*movecount)) do
			if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
				if object:get_luaentity().itemstring ~= "" then
----				local titem=tube_item(pos,object:get_luaentity().itemstring)
----				titem:get_luaentity().start_pos = {x=pos.x,y=pos.y-1,z=pos.z}
----				titem:setvelocity({x=0.01,y=1,z=-0.01})
----				titem:setacceleration({x=0, y=0, z=0})
					buildtest.makeEnt(pipepos, ItemStack(object:get_luaentity().itemstring):to_table(), speed, pipepos)
				end
				--object:setvelocity
				object:get_luaentity().itemstring = ""
				object:remove()
			end
		end
	elseif buildtest.pumps.pumpible[minetest.get_node(pipepos).name]~=nil then
		buildtest.pumps.pumpible[minetest.get_node(pipepos).name].power(pipepos, speed)
	elseif strs:starts(minetest.get_node(pipepos).name, "buildtest:pipe_stripe_") then
		local itemName = minetest.get_node(chestpos).name
		if itemName~="air" and itemName~="ignore" then
--			print("currently cutting: "..itemName)
			local drops = minetest.get_node_drops(itemName, "default:pick_mese")--minetest.registered_nodes[itemName].drop
			
			for _,item in ipairs(drops) do
				local count, name
				if type(item) == "string" then
					count = 1
					name = item
				else
					count = item:get_count()
					name = item:get_name()
				end
				
				local entity = buildtest.makeEnt(pipepos, {name = name, count = count}, speed, pipepos)
				if entity then
					entity:setpos(chestpos)
					entity:setvelocity({x=0, y=0-speed, z=0})
				end
			end
			
			minetest.set_node(chestpos, {name = "air"})
			nodeupdate(chestpos)
		end
	else
		--speedup = speed
	end
end

buildtest.pumps.send_power_from = function(pos, power)
end

buildtest.pumps.register_pump = function(name, textureBase, flags, def)
	local abm = def.abm
	for typeId, typeName in pairs(buildtest.pumps.colours) do
		local sideTexture = textureBase.."^buildtest_pump_mask_"..typeName.."_side.png"
		local def = {
			tiles = {sideTexture, sideTexture.."^[transformR180", sideTexture.."^[transformR270", sideTexture.."^[transformR90",
								textureBase, textureBase},
			groups = {choppy=1,oddly_breakable_by_hand=3},
			paramtype = "light",
			paramtype2 = "facedir",
			sunlight_propagates = true,
			buildtest = {
				slowdown=0.1,
				connects={
				},
				disconnects = {},
				pump = {
--					maxSpeed = 0.5,
--					moveCount = 1,
--					maxLevel = 5,
					upTime = 60,
					next = name.."_"..(buildtest.pumps.colours[typeId + 1] or typeName),
					prev = name.."_"..(buildtest.pumps.colours[typeId - 1] or typeName),
					colour = typeName,
					stepSpeed = typeId,--#buildtest.pumps.colours + 1 - typeId,
					typeId = typeId,
					moveCount = def.moveCount or 1,
					runConf = def.runConf,
					explodes = def.explodes or false,
					canHeat = def.canHeat,
					
--					textures = {
--						"buildtest_pump_mesecon.png",
--						"buildtest_pump_blue.png",
--						"buildtest_pump_green.png",
--						"buildtest_pump_orange.png",
--						"buildtest_pump_red.png",
--					}
				}
			},
--			on_construct = function(pos)
--				buildtest.pumps.on_construct(pos)
--			end,
			on_place = function(itemstack, placer, pointed_thing)
				local stack = minetest.item_place(itemstack, placer, pointed_thing)
				buildtest.pumps.on_construct(pointed_thing.above)
				return stack
			end,
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = {
					--{0,0,0,0,0,0},
					{-5/16, -5/16, -5/16, 5/16, 5/16, 8/16},
					{-8/16, -8/16, -8/16, 8/16, 8/16, -5/16},
				}
			},
			drop = {
				max_items = 1,
				items = {
					{ items = {name.."_"..buildtest.pumps.colours[1]} }
				}
			},
			mesecons = {
				effector = {
					action_off = function (pos, node)
						local meta = minetest.get_meta(pos)
						meta:set_int("on", 0)
					end,
					action_on = function (pos, node)
						local meta = minetest.get_meta(pos)
						meta:set_int("on", 1)
					end,
				},
			},
	--		selection_box = {{
	--			0.5,0.5,0.5,-0.5,-0.5,-0.5,
	--		}},
		}
		for name, val in pairs(flags) do
			if name~="groups" then
				def[name] = val
			end
		end
		if flags.groups~=nil then
			for name, val in pairs(flags.groups) do
				def.groups[name]=val
			end
		end
		if typeId~=1 then
			def.groups.not_in_creative_inventory=1
		end
		if buildtest.pumps.colours[typeId + 1]==nil then
			def.buildtest.pump.next=nil
		end
		if buildtest.pumps.colours[typeId - 1]==nil then
			def.buildtest.pump.prev=nil
		end
		minetest.register_node(name.."_"..typeName, def)
		
		minetest.register_abm({
			nodenames = {name.."_"..typeName},
			interval = 0.5,
			chance = 1,
			action = abm
		})
	end
end

buildtest.pumps.send = function(pos)
	local node = minetest.get_node(pos)
--	print("ok")
--	local facedir = minetest.get_node(pos).param2
--	facedir = buildtest.facedir_to_dir(facedir)
--	facedir = buildtest.posADD(pos,facedir)
--	local chestpos=buildtest.pipes.getConns(facedir)
--	if #chestpos == 0 then
--		return
--	end
--	chestpos = chestpos[0]
	local pipepos = vector.add(pos, minetest.facedir_to_dir(node.param2))--buildtest.pumps.findpipe(pos)  --{x=pos.x,y=pos.y+1,z=pos.z}
	local speedup = 0
	local thisMeta = minetest.get_meta(pos)
	
	if thisMeta:get_int("on")~=1 then
		buildtest.pumps.temp(pos, "prev")
		return
	end
	
	local def = minetest.registered_items[node.name]
	if def.buildtest.pump~=nil then
		
		if def.buildtest.pump.runConf~=nil then
			if def.buildtest.pump.runConf(pos)==false then
				buildtest.pumps.temp(pos, "prev")
				return
			end
		end
		
		local timerCount = thisMeta:get_int("timer") or 0
		--if timerCount==nil then timerCount=0 end
		timerCount = timerCount + 1
--		if timerCount % def.buildtest.pump.upTime == 0 then
--			local id
--			for name,value in pairs(minetest.luaentities) do
--				--print(name)
--				if strs:starts(value.name, "buildtest:") and value.homepos==pos then
--					id=name
--				end
--			end
--			if not id then
--				buildtest.pumps.on_construct(pos)
--			end
--			--timerCount = 0
--			local level = thisMeta:get_int("level") or 1
--			--if level==nil then level=0 end
--			level = level + 1
--			if level <= def.buildtest.pump.maxLevel then
--				thisMeta:set_int("level", level)
--			end
--		end
		local canHeat = false
		if timerCount >= def.buildtest.pump.upTime then
			canHeat = true
			
			for name,value in pairs(minetest.luaentities) do
				if strs:starts(value.name, "buildtest:") and value.homepos==pos then -- :get_luaentity()
					value:remove()
				end
			end
			buildtest.pumps.on_construct(pos, "default_wood.png", def.buildtest.pump.typeId)
		end
		if def.buildtest.pump.canHeat~=nil then
			if def.buildtest.pump.canHeat(pos)==false then
				canHeat=false
			end
		end
		if canHeat==true then
			--print("ok: "..def.buildtest.pump.next)
--			local node = minetest.get_node(pos)
--			node.name = def.buildtest.pump.next
--			minetest.set_node(pos, node)
			if def.buildtest.pump.next~=nil then
				buildtest.pumps.hacky_swap_node(pos, def.buildtest.pump.next)
			elseif def.buildtest.pump.explodes == true then
				minetest.remove_node(pos)
				tnt:blowup(pos, 0.5, nil)
			end

			thisMeta:set_int("timer", 0)
			return
		end
		thisMeta:set_int("timer", timerCount)
	end
	
	--if not buildtest.pipeAt(pipepos) then return end
	
	--local speed = thisMeta:get_int("level") or 1
	local speed = def.buildtest.pump.stepSpeed
	--minetest.set_node(chestpos, {name="default:cobble"})
	--if thisMeta:get_int("timer") % (def.buildtest.pump.maxLevel + 1 - speed) ~= 0 then
	if thisMeta:get_int("timer") % (#buildtest.pumps.colours + 1 - speed) ~= 0 then
		return
	end
	
	buildtest.pumps.send_power(pipepos, speed, def.buildtest.pump.moveCount)
	
	--thisMeta:set_int("speedup", speedup)
end

buildtest.facedir_to_dir = function(param)
	local list={
				{x= 0,y=0,z= 1},
				{x= 1,y=0,z= 0},
				{x= 0,y=0,z=-1},
				{x=-1,y=0,z= 0},
	}
	return list[param+1]
end

buildtest.makeEnt = function(pos, tosend, speed, from)
	if from==nil then from=pos end
	if speed < 1 then speed = 1 end
	local entity=minetest.add_entity(pos, "buildtest:entity_flat")
	if entity then
		entity:get_luaentity().nextpos = pos
		entity:get_luaentity().speed = speed
		entity:setpos(from)
		entity:setvelocity(vector.subtract(pos, from))
		entity:get_luaentity():set_item(tosend)
		--entity:get_luaentity().inInit = false
	end
	return entity
end

buildtest.pumps.on_construct = function(pos, texture, speed)
	--print("ok")
--	local ent = minetest.add_entity(pos, "buildtest:pump_ent")
--	if ent then
--		local luaent = ent:get_luaentity()
--		ent:setpos(pos)
--		--ent:get_luaentity():setTexture(texture)
--		--ent:get_luaentity():setAnim(speed)
--		ent:get_luaentity().config = {
--			texture = texture,
--			speed = speed,
--		}
--		ent:get_luaentity().homepos = pos
----		ent:get_luaentity().handmade = true
--		--ent:get_luaentity().setTexture(ent, "buildtest_pump_mesecon.png")
----		ent:get_luaentity().homename = minetest.get_node(pos).name
----		ent:get_luaentity().reset = true
--	end
	
	local ppos = vector.subtract(buildtest.pumps.findpipe(pos), pos)
	local facedir = minetest.dir_to_facedir(ppos, true)
	local node = minetest.get_node(pos)
	
	if facedir~=node.param2 then
		node.param2 = facedir
		minetest.set_node(pos, node)
	end
end

dofile(minetest.get_modpath("buildtest").."/pumps/graphics/init.lua")
dofile(minetest.get_modpath("buildtest").."/pumps/mesecon.lua")
dofile(minetest.get_modpath("buildtest").."/pumps/sterling.lua")
dofile(minetest.get_modpath("buildtest").."/pumps/pump.lua")
dofile(minetest.get_modpath("buildtest").."/pumps/combustion.lua")