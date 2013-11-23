buildtest.canPumpInto = {
	["default:chest_locked"] = {"main"},
	["default:chest"] = {"main"},
	["morechests:dropbox"] = {"main"},
	["default:furnace_active"] = {"src", negy = "fuel"},
	["default:furnace"] = {"src", negy = "fuel"},
	--["buildtest:pump_stirling"] = {"heat", negy = "fuel"},
	["buildtest:autocraft"] = {"in", on_send = function(pos)
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		buildtest.autocraft.do_craft(inv)
	end},
	["itest:macerator"] = {"src"},
	["itest:macerator_active"] = {"src"},
	
	["itest:iron_furnace_active"] = {"src", negy = "fuel"},
	["itest:iron_furnace"] = {"src", negy = "fuel"},
	["itest:electric_furnace_active"] = {"src"},
	["itest:electric_furnace"] = {"src"},
	["itest:extractor_active"] = {"src"},
	["itest:extractor"] = {"src"},
	["itest:generator_active"] = {"src"},
	["itest:generator"] = {"src"},
}

buildtest.get_listname_for_dir_in = function(dir, posname)
	local listName = buildtest.canPumpInto[posname][1]
	local dirName = ""
	if dir.x+dir.y+dir.z > 0 then
		dirName = dirName .. "neg"
	end
	if dir.x~=0 then
		dirName = dirName .. "x"
	end
	if dir.y~=0 then
		dirName = dirName .. "y"
	end
	if dir.z~=0 then
		dirName = dirName .. "z"
	end
	if buildtest.canPumpInto[posname][dirName]~=nil then
		listName = buildtest.canPumpInto[posname][dirName]
	end
	return listName
end

minetest.register_entity("buildtest:entity_flat", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=0.5, y=0.5},
		--visual_size = {x=1, y=1},
--		textures = {"worldedit_pos1.png", "worldedit_pos1.png",
--			"worldedit_pos1.png", "worldedit_pos1.png",
--			"worldedit_pos1.png", "worldedit_pos1.png"},
--		collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
		collisionbox = {0, 0, 0, 0, 0, 0},
		physical = false,
	},
	on_step = function(self, dtime)
		self.totTime=self.totTime+dtime
		local pos=self.object:getpos()
--		pos.x=pos.x+dtime
--		self.object:setpos(pos)
		if self.totTime > 1 / self.speed then
			self.totTime = 0 --self.totTime - 1 / self.speed
			--self.lastTime=math.toint(self.totTime)
			--print(self.totTime)
			--local acc=self.object:getacceleration()
			--acc.x=0-acc.x
			--acc.y=0-acc.y
			--acc.z=0-acc.z
			--self.object:setacceleration(acc)
			if self.nextpos~=nil then
				local newDir=nil
				local posname = minetest.get_node(self.nextpos).name
				--if posname=="default:chest" or posname=="default:chest_locked" then
				if buildtest.canPumpInto[posname]~=nil then
					local listName = buildtest.get_listname_for_dir_in(self.olddir, posname)
					
					local inv = minetest.get_meta(self.nextpos):get_inventory()
					if inv:room_for_item(listName, self.content)==true then
						inv:add_item(listName, self.content)
					else
						self.turn_into_item(self, self.content)
					end
--					local leftover = inv:add_item("main", self.content)
--					if leftover~=nil and leftover:get_count()>0 then
--						self.turn_into_item(self, leftover)
--						return
--					end
					self.object:remove()
					
					if buildtest.canPumpInto[posname].on_send~=nil then
						buildtest.canPumpInto[posname].on_send(self.nextpos)
					end
					
					return
				end
				--if self.nextpos==nil then
				--	return
				--end
				--self.object:setpos({x=self.nextpos.x, y=self.nextpos.y+2, z=self.nextpos.z})  --  snap to grid
				
				if strs:starts(posname, "buildtest:pipe_iron_") then
					newDir = buildtest.pipes.types.iron.getDir(self.nextpos)
				end
				
				if strs:starts(posname, "buildtest:pipe_diamond_") then
					newDir = buildtest.pipes.types.diamond.getDir(self.nextpos, self.content)
					if newDir==nil then
						for i=1,6 do
							local tmpPos=buildtest.posADD(pos,buildtest.toXY(i))
							if strs:starts(minetest.get_node(tmpPos).name, "buildtest:pipe_gold")==true then
								newDir = buildtest.toXY(i)
							end
						end
					end
				end
				
				if strs:starts(posname, "buildtest:pipe_stripe_") then
					local targetPos = self.addpos(self.object:getpos(), self.olddir)
					if minetest.get_node(targetPos).name == "air"
								and self.content.count==1 and minetest.registered_nodes[self.content.name]~=nil then
						minetest.set_node(targetPos, self.content)
						self.object:remove()
						nodeupdate(targetPos)
						return
					end
				end
				
				if strs:starts(posname, "buildtest:pipe_gate") then
					local getRunAction = buildtest.pipes.types.gate.types[posname].getRunAction(self.nextpos).entProcess(self.content)
				end
				
				self.object:setpos(self.nextpos)  --  snap to grid
				if newDir==nil then
					newDir = self.get_dir(self)
				end
				if newDir==nil then
					self.turn_into_item(self, self.content)
					--self.nextpos = nil
					return
				end
				
				---------------
				local posUnder = {x=self.nextpos.x, y=self.nextpos.y - 1, z=self.nextpos.z}
				if strs:starts(minetest.get_node(posUnder).name, "buildtest:pump_") then
					local speedup = minetest.get_meta(posUnder):get_int("speedup")
					if speedup==nil then speedup=0 end
					self.speed = self.speed + speedup
				end
				
				if strs:starts(posname, "buildtest:pipe_gold_") then
					local speedup = minetest.get_meta(self.nextpos):get_int("on")
					--print("ok: "..speedup)
					self.speed = self.speed + (speedup * 1)
				end
				
				local pipedef = minetest.registered_items[posname]
				if pipedef~=nil then
					if pipedef.buildtest~=nil then
						if pipedef.buildtest.slowdown~=nil then
							self.speed = self.speed - pipedef.buildtest.slowdown
						end
					end
				end
				
				
				if self.speed > 20 then self.speed = 20 end
				if self.speed < 1 then self.speed = 1 end
				---------------
				
				self.olddir=newDir
				self.nextpos=self.addpos(self.nextpos,newDir)
				self.object:setvelocity(buildtest.posMult(newDir, self.speed))
				self.direction = newDir
				--print("old: "..minetest.pos_to_string(self.currpos))
				--print("new: "..minetest.pos_to_string(self.currpos))
			else
				self.object:remove()
			end
		end
	end,
	on_punch = function(self, hitter)
	end,
	get_dir = function(self)
		local poses={
			{x= 0,y= 0,z=-1},
			{x= 0,y= 0,z= 1},
			{x=-1,y= 0,z= 0},
			{x= 1,y= 0,z= 0},
			{x= 0,y=-1,z= 0},
			{x= 0,y= 1,z= 0},
		}
		local prohib={self.invertpos(self.direction)}
		for i=1,#prohib do
			for j=1,#poses do
				if minetest.pos_to_string(poses[j])==minetest.pos_to_string(prohib[i]) then
					poses[j]=0
				elseif buildtest.pipeConn(self.addpos(self.nextpos,poses[j]),self.nextpos)==false then  --  minetest.get_node(self.addpos(self.nextpos,poses[j]))
					poses[j]=0
				end
			end
		end
		for i=1,#poses do
			if poses[i]~=0 then
				return poses[i]
			end
		end
		return nil
	end,
	invertpos = function(pos)
		return {x=0-pos.x, y=0-pos.y, z=0-pos.z}
	end,
	addpos = function(posa, posb)
		return {x=posa.x+posb.x, y=posa.y+posb.y, z=posa.z+posb.z}
	end,
	ispipe = function(node)
		if node.name=="air" then
			return false
		end
		local def=minetest.registered_items[node.name]
		if def.buildtest==nil then
			return false
		end
		return true
	end,
	------------------------------------------------
	set_item = function(self, itemstring)
		self.content = itemstring
--		print("ok")
		local stack = ItemStack(itemstring)
		local itemtable = stack:to_table()
		local itemname = nil
		if itemtable then
			itemname = stack:to_table().name
		end
		local item_texture = nil
		local item_type = ""
		if minetest.registered_items[itemname] then
			item_texture = minetest.registered_items[itemname].inventory_image
			item_type = minetest.registered_items[itemname].type
		end
		prop = {
			is_visible = true,
			visual = "sprite",
			textures = {"unknown_item.png"}
		}
		if item_texture and item_texture ~= "" then
			prop.visual = "sprite"
			prop.textures = {item_texture}
			--prop.visual_size = {x=0.3, y=0.3}
			prop.visual_size = {x=0.6, y=0.6}
		else
			prop.visual = "wielditem"
			prop.textures = {itemname}
			--prop.visual_size = {x=0.15, y=0.15}
			prop.visual_size = {x=0.3, y=0.3}
		end
		self.object:set_properties(prop)
	end,
	------------------------------------------------
	turn_into_item = function(self, stack)
		minetest.add_item(self.addpos(self.object:getpos(),self.olddir), stack)
		self.object:remove()
	end,
	--------------------------------------------------
	get_staticdata = function(self)
		--local nextpoz = minetest.pos_to_string(self.nextpos)
		return	minetest.serialize({
			self.nextpos,
			self.olddir,
			self.content,
			self.speed,
			self.direction,
		})
	end,

	on_activate = function(self, staticdata)
--		if  staticdata=="" or staticdata==nil then return end
--		local item = minetest.deserialize(staticdata)
		
		
--		self.olddir = item.olddir
--		self.speed = item.speed
		--self.direction = item.direction
		--self.nextpos = minetest.pos_to_string(item.nextpos)
		
		--self.object:setpos(self.nextpos)
		
		--self:set_item(self.content)
	end,
	
	totTime=0,
	lastTime=0,
	olddir={x=0,y=0,z=0},
	content={name="default:dirt",count=0},
	speed = 1,
	direction = {x=0,y=0,z=0},
})