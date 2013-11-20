buildtest.pipes.types.iron = {
	base = "default:steel_ingot",
}

buildtest.pipes.makepipe(function(set, nodes, count, name, id, clas)
	local top = "buildtest_pipe_iron_top.png"
	local side = "buildtest_pipe_iron.png"
	local def = {
		sunlight_propagates = true,
		paramtype = 'light',
		paramtype2= "facedir",
		walkable = true,
		climbable = false,
		diggable = true,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = nodes
		},
		--------------------------
		description = clas.."Buildtest Iron Pipe",
		tiles = {top,side,side,side,side,side},
		groups = {cracky=1},
		buildtest = {
			slowdown=0.1,
			pipe=1,
			connects={
				buildtest.pipes.defaultPipes
			},
		},
		mesecons = {
			effector = {
				action_off = function (pos, node)
				end,
				action_on = function (pos, node)
					--minetest.after(0.5, function() -- mesecons seems to call "action_on" BEFORE it sets all the wires to new nodes. -- WRONG!
					for i=0, 5 do
						local newPos = buildtest.posADD(pos, buildtest.pipes.types.iron.getRawDir(i*4))
						--if mesecon:is_power_on(newPos) then
--						local rule = {x=newPos.x, y=newPos.y, z=newPos.z, name = "in"..i}
--						local invRule = {x=rule.x, y=rule.y, z=rule.z, name = rule.name}
--						if mesecon:is_power_on(mesecon:addPosRule(pos, rule), invRule)
--										and mesecon:rules_link(mesecon:addPosRule(pos, rule), pos) then
--						local def = minetest.registered_items[minetest.get_node(newPos).name]
--						if	def~=nil and
--							def.mesecons~=nil and
--							def.mesecons.receptor~=nil and
--							def.mesecons.receptor.state=="on" then
						if strs:starts(minetest.get_node(newPos).name, "buildtest:pipe_meseconon_") then
							
							node.param2 = i * 4
							minetest.set_node(pos, node)
--								print("setting facedir to: "..node.param2)
						end
					end
					--end)
				end,
			},
		},
		drop = {
			max_items = 1,
			items = {
				{ items = {'buildtest:pipe_iron_000000_'..id} }
			}
		},
		on_place = function(itemstack, placer, pointed_thing)
			buildtest.pipes.onp_funct(itemstack, placer, pointed_thing)
			--local meta = minetest.get_meta(pointed_thing.above)
			--meta:set_int("facedir", 1)
		end,
		on_dig = buildtest.pipes.ond_funct,
		on_punch = function(pos, node, puncher)
			--node.param2 = node.param2 + 1
			--print("rotation: "..node.param2)
--			local meta = minetest.get_meta(pos)
			--local rot  = meta:get_int("rot")
			local rot = node.param2
			rot = rot + 4
			if rot >= 24 then rot = 0 end
			--meta:set_int("rot", rot)
			node.param2 = rot
			minetest.set_node(pos, node)
			--print("rotation: "..rot)
			--buildtest.pipes.processNode(pos)
		end,
	}
	if count~=1 then
		def.groups.not_in_creative_inventory=1
	end
	minetest.register_node("buildtest:pipe_iron_"..name, def)
end)

buildtest.pipes.types.iron.getRawDir = function(rot)
	if rot>=0 and rot<=3 then
		return {x= 0,y= 1,z= 0}
	end
	if rot>=4 and rot<=7 then
		return {x= 0,y= 0,z= 1}
	end
	if rot>=8 and rot<=11 then
		return {x= 0,y= 0,z=-1}
	end
	if rot>=12 and rot<=15 then
		return {x= 1,y= 0,z= 0}
	end
	if rot>=16 and rot<=19 then
		return {x=-1,y= 0,z= 0}
	end
	if rot>=20 and rot<=23 then
		return {x= 0,y=-1,z= 0}
	end
	return nil
end

buildtest.pipes.types.iron.getDir = function(pos)
	--print("ok")
	local node=minetest.get_node(pos)
	if node==nil then return nil end
	local rot = node.param2
	return buildtest.pipes.types.iron.getRawDir(rot)
end