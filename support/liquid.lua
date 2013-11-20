minetest.register_entity("buildtest:entity_liquid", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=0.5, y=0.5},
		collisionbox = {0, 0, 0, 0, 0, 0},
		physical = false,
	},
	on_step = function(self, dtime)
		self.object:remove()
--		self.totTime=self.totTime+dtime
--		if self.totTime > 2 then
--			self.totTime = 0
--			if self.pos~=nil and buildtest.pipeAt(self.pos) then
--				self.spread(self)
--			else
--				self.object:remove()
--			end
--		end
	end,
	on_punch = function(self, hitter)
	end,
	spread = function(self)
		local poses={
			{x= 0,y= 0,z=-1},
			{x= 0,y= 0,z= 1},
			{x= 0,y=-1,z= 0},
			{x= 0,y= 1,z= 0},
			{x=-1,y= 0,z= 0},
			{x= 1,y= 0,z= 0},
		}
		for _,object in ipairs(minetest.get_objects_inside_radius(self.pos, 5)) do
			if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == self.name then
				if object~=self.object then
					if object:get_luaentity().pos~=nil and object:get_luaentity().posOfs~=nil then
						if object:get_luaentity().pos~=self.pos then
							--return
							local remPos = object:get_luaentity().pos
							for i=1, #poses do
								if poses[i]~=nil then
									if poses[i].x==remPos.x and poses[i].y==remPos.y and poses[i].z==remPos.z then
										poses[i] = nil
									end
								end
							end
						end
					end
				end
			end
		end
		for i=1,#poses do
			if poses[i]~=nil then
				local newPos = self.addpos(poses[i], self.pos)
				if buildtest.pipeConn(newPos, self.pos) then
					--local posOfs = {x=poses[i].x/3,y=poses[i].y/3,z=poses[i].z/3}
					local ent = minetest.add_entity(newPos, "buildtest:entity_liquid")
					if ent then
						--print("ok")
						--ent:setpos(newPos)
						ent:get_luaentity().pos=newPos--self.pos
	--					ent:get_luaentity().posOfs=poses[i]
					end
				end
			end
		end
	end,
	addpos = function(posa, posb)
		return {x=posa.x+posb.x, y=posa.y+posb.y, z=posa.z+posb.z}
	end,
--	can_goto = function(pos, refpos)
--		local refnode = minetest.get_node(refpos)
--		if strs:starts(refnode.name, "buildtest:pipe_") then
--			local id = refnode.name:split("_")[3]
--			if id=="0" then
--				return false
--			end
--			return buildtest.pipeConn(pos, refpos)
--		end
--		return false
--	end,
	------------------------------------------------
	set_item = function(self, itemstring)
--		self.content = itemstring
----		print("ok")
--		local stack = ItemStack(itemstring)
--		local itemtable = stack:to_table()
--		local itemname = nil
--		if itemtable then
--			itemname = stack:to_table().name
--		end
--		local item_texture = nil
--		local item_type = ""
--		if minetest.registered_items[itemname] then
--			item_texture = minetest.registered_items[itemname].inventory_image
--			item_type = minetest.registered_items[itemname].type
--		end
--		prop = {
--			is_visible = true,
--			visual = "sprite",
--			textures = {"unknown_item.png"}
--		}
--		if item_texture and item_texture ~= "" then
--			prop.visual = "sprite"
--			prop.textures = {item_texture}
--			--prop.visual_size = {x=0.3, y=0.3}
--			prop.visual_size = {x=0.6, y=0.6}
--		else
--			prop.visual = "wielditem"
--			prop.textures = {itemname}
--			--prop.visual_size = {x=0.15, y=0.15}
--			prop.visual_size = {x=0.3, y=0.3}
--		end
--		self.object:set_properties(prop)
	end,
	--------------------------------------------------
	get_staticdata = function(self)
	end,

	on_activate = function(self, staticdata)
	end,
	
	totTime=0,
	lastTime=0,
	--pos={x=0,y=0,z=0},
	posOfs = {x=0,y=0,z=0},
	content={name="default:water_source"},
})