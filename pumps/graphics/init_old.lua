local def = {
	collisionbox = {0,0,0,0,0,0},
	visual = "mesh",
	mesh = "buildtest_pump.x",
	--textures = {"mobs_dirt_monster.png"},
	visual_size = {x=5, y=5},
--	drawtype = "front",
	--paramtype = "light",
	on_step = function(self, dtime)
--		print("ok")
		if self==nil or self.homepos==nil or self.homename==nil then
			--self.object:remove()
			return
		end
		if self.reset==true then
			self.resetSelf(self)
			return
		end
		--if self.inInit==true then return end
		
		self.totTime=self.totTime+dtime
		if self.totTime > 1 then
			self.object:setpos(self.homepos)
			self.totTime = 0 --self.totTime - 1 / self.speed
			if minetest.get_node(self.homepos).name ~= self.homename then
				self.object:remove()
				return
			end
			local def = minetest.registered_items[minetest.get_node(self.homepos).name]
			local meta = minetest.get_meta(self.homepos)
			local level = meta:get_int("level") or 1
			self.speed = level
			local texture = def.buildtest.pump.textures[1]
			if def.buildtest.pump.textures[level]~=nil then
				texture = texture.."^"..def.buildtest.pump.textures[level]
			end
			
			self.setTexture(self.object, texture)
			self.setAnim(self, level)
		end
	end,
	speed = 1,
	totTime = 0,
	lastLevel = -1,
	reset = false,
	inInit = true,
	inited = false,
	setTexture = function(self, texture)
		prop = {
			visual_size = {x=5, y=5},
			drawtype = "front",
			visual = "mesh",
			mesh = "buildtest_pump.x",
			textures = {texture},
		}
		self:set_properties(prop)
	end,
	resetTexture = function(self)
		local def = minetest.registered_items[minetest.get_node(self.homepos).name]
		local texture = def.buildtest.pump.textures[1]
		self.setTexture(self.object, texture)
	end,
	resetSelf = function(self)
		--print("a: ok")
		self.reset = false
		self.object:setpos(self.homepos)
		self.resetAnim(self)
		self.resetTexture(self)
--		self.inInit = false
	end,
	setAnim = function(self, level)
		if  self.lastLevel ~= level then
			self.lastLevel  = level
			--print("ok")
			self.object:set_animation(
				{
					x=1  --  start
					,y=30   --  end
				},
				level*15  --frame rate
				--15
				, 0
			)
		end
	end,
	resetAnim = function(self)
		local meta = minetest.get_meta(self.homepos)
		local level = meta:get_int("level") or 1
		self.setAnim(self, level)
	end,
	get_staticdata = function(self)
		if self.homepos==nil then return "?" end
		--return minetest.pos_to_string(self.homepos)
		--local homepos = minetest.pos_to_string(self.homepos)
--		self.homeposAsText = minetest.pos_to_string(self.homepos)
--		--local texture = self.textures[1]
--		return	minetest.serialize({
----				self.homeposAsText,
--				self.homename,
--			})
		return minetest.pos_to_string(self.homepos) or "?"
	end,
	on_activate = function(self, staticdata)
--		local item = minetest.deserialize(staticdata)
--		self.homepos = minetest.string_to_pos(item.homeposAsText)
--		self.homename = item.homename
--		--self.setTexture(self, "buildtest_pump_mesecon.png")
--		self.reset = true
--		print("ok")
--		if self.handmade==true then return end
		if staticdata==nil or staticdata=="" then return end
		self.object:remove()
		--------------------
		--------------------
--		local pos = minetest.string_to_pos(staticdata)
--		if pos~=nil then
--			buildtest.pumps.on_construct(pos)
--		end
	end,
}

minetest.register_entity("buildtest:pump_ent", def)