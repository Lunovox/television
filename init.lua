television = { }

television.translate = rawget(_G, "intllib") and intllib.Getter() or function(s) return s end

television.canInteract = function(meta, player)
	if player:get_player_name() == meta:get_string("owner") 
		or minetest.get_player_privs(player:get_player_name()).server
		or minetest.get_player_privs(player:get_player_name()).mayor
		or minetest.get_player_privs(player:get_player_name()).checkchest
		or (minetest.get_modpath("tradelands") and modTradeLands.canInteract(player:getpos(), player:get_player_name()))
	then
		return true
	end
	return false
end

television.getFaceDir = function(Direction)
	if Direction == "left" then
		return {{-1,0},{0,1},{1,0},{0,-1},}
	elseif Direction == "right" then
		return {{1,0},{0,-1},{-1,0},{0,1},}
	end
end

television.getBox = function()
	return {
		type = "fixed",
		fixed = {
			-1.5050,-0.3125, 0.3700, 
			 1.5050, 1.5050, 0.5050
		}
	}
end

television.checkwall = function(pos)
	local fdir = minetest.get_node(pos).param2

	local dxl = television.getFaceDir("left")[fdir + 1][1]	-- dxl = "[D]elta [X] [L]eft"
	local dzl = television.getFaceDir("left")[fdir + 1][2]	-- Z left

	local dxr = television.getFaceDir("right")[fdir + 1][1]	-- X right
	local dzr = television.getFaceDir("right")[fdir + 1][2]	-- Z right

	local node1 = minetest.get_node({x=pos.x+dxl, y=pos.y, z=pos.z+dzl})
	if not node1 or not minetest.registered_nodes[node1.name]
	  or not minetest.registered_nodes[node1.name].buildable_to then
		return false
	end

	local node2 = minetest.get_node({x=pos.x+dxr, y=pos.y, z=pos.z+dzr})
	if not node2 or not minetest.registered_nodes[node2.name]
	  or not minetest.registered_nodes[node2.name].buildable_to then
		return false
	end

	local node3 = minetest.get_node({x=pos.x+dxl, y=pos.y+1, z=pos.z+dzl})
	if not node3 or not minetest.registered_nodes[node3.name]
	  or not minetest.registered_nodes[node3.name].buildable_to then
		return false
	end

	local node4 = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
	if not node4 or not minetest.registered_nodes[node4.name]
	  or not minetest.registered_nodes[node4.name].buildable_to then
		return false
	end

	local node5 = minetest.get_node({x=pos.x+dxr, y=pos.y+1, z=pos.z+dzr})
	if not node5 or not minetest.registered_nodes[node5.name] 
	  or not minetest.registered_nodes[node5.name].buildable_to then
		return false
	end

	return true
end

television.putLabel = function(pos, message)
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", message)
end

minetest.register_node("television:widescreen", {
	description = television.translate("Television Widescreen "),
	drawtype = "mesh",
	mesh = "television_widescreen.obj",
	tiles = {
		"television_case.png",
		{ name=television.translate("television_screens_en.png"),
			animation={
				type="vertical_frames",
				aspect_w = 300, --150
				aspect_h = 170, --85
				length = 60 -- <= Tempo de duracao em segundos!!!
			}
		}

	},
	inventory_image = "television_item.png",
	--wield_image = "television_item.png",
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	light_source = default.LIGHT_MAX, --de 0 a 14
	selection_box = television.getBox(),
	collision_box = television.getBox(),
	--on_rotate = screwdriver.disallow,
	groups = {snappy=3, dig_immediate=2},
	after_place_node = function(pos, placer, itemstack)
		if not television.checkwall(pos) then
			minetest.set_node(pos, {name = "air"})
			return true	-- "API: If return true no item is taken from itemstack"
		else
			local meta = minetest.env:get_meta(pos)
			meta:set_string("owner",placer:get_player_name())
		end
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		local meta = minetest.env:get_meta(pos)
		if television.canInteract(meta, puncher) then
			minetest.set_node(pos, {name = "television:widescreen_off", param2 = node.param2})
			television.putLabel(pos, television.translate("Television Widescreen (off)"))
		end
	end,
	on_construct = function(pos)
		television.putLabel(pos, "Televisao de Tela Larga")
	end,
})

minetest.register_node("television:widescreen_off", {
	description = "Televisao de Tela Larga (Desligada)",
	drawtype = "mesh",
	mesh = "television_widescreen.obj",
	--tiles = {"television_case.png","television_screen_off.png",	},
	tiles = {
		"television_case_off.png",
		"television_screen_off.png"
	},
	--inventory_image = "outdoor_tv_inv.png",
	--wield_image = "outdoor_tv_inv.png",
	paramtype = "light",
	light_source = 1,
	paramtype2 = "facedir",
	selection_box = television.getBox(),
	collision_box = television.getBox(),
	--on_rotate = screwdriver.disallow,
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
	after_place_node = function(pos, placer, itemstack)
		if not television.checkwall(pos) then
			minetest.set_node(pos, {name = "air"})
			return true	-- "API: If return true no item is taken from itemstack"
		end
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		minetest.set_node(pos, {name = "television:widescreen", param2 = node.param2})
		television.putLabel(pos, television.translate("Television Widescreen"))
	end,
	drop = "television:widescreen",
	on_construct = function(pos)
		television.putLabel(pos, television.translate("Television Widescreen (off)"))
	end,

})

minetest.register_craft({
	output = 'television:widescreen',
	recipe = {
		{"default:obsidian_glass"	,"default:obsidian_glass"	,"default:obsidian_glass"},
		{"default:obsidian_glass"	,"default:obsidian_glass"	,"default:obsidian_glass"},
		{"default:obsidian"			,"default:mese"				,"default:obsidian"},
	}
})

minetest.register_alias(
	television.translate("television"),
	"television:widescreen"
)
minetest.register_alias("widescreen"	,"television:widescreen")
minetest.register_alias("televisao"		,"television:widescreen")
minetest.register_alias("tv"				,"television:widescreen")

minetest.log('action',"["..minetest.get_current_modname():upper().."] Loaded!")
