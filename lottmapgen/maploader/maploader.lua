
maploader = { }

local types = { }

local bmp_meta = {
	__index = bmp_methods,
}

--[[
typedef = {
	description = "FOO File",
	check = func(file), --> bool
	load = func(file), --> table or (nil, errormsg)
}
]]

function maploader.register_type(def)

	types[#types + 1] = def

end

local function find_loader(file)

	for _,def in ipairs(types) do

		file:seek("set", 0)
		local r = def.check(file)
		file:seek("set", 0)

		if r then
			return def
		end

	end

	return nil, "maploader: unknown file type"

end

function maploader.load(filename)

	local f, e = io.open(filename, "rb")
	if not f then return nil, "maploader: "..e end

	local def, e = find_loader(f)
	if not def then return nil, e end

	local r, e = def.load(f)

	f:close()

	if r then
		r = setmetatable(r, bmp_meta)
	end

	return r, e

end

function maploader.type(filename)

	local f, e = io.open(filename, "rb")
	if not f then return nil, "maploader: "..e end

	local def, e = find_loader(f)
	if not def then return nil, e end

	return def.description

end

--should take an argument of size !> 80x80 dimensions

--should be two dimensional...
function maploader.to_map(bmp, pal, minp, maxp)
	local data = {} --stores table of biome indices
	local dataix = 1
	--local dataiy = 1
	hcen = math.floor(bmp.h / 2)
	wcen = math.floor(bmp.w / 2)
	--for z = hcen + minp.z, hcen + maxp.z do
	--	for x = wcen + minp.x, wcen + maxp.x do
	for z = 1, bmp.h do
		for x = 1, bmp.w do
			local c = bmp.pixels[z][bmp.w + 1 - x]
			local i = palette.bestfit_color(pal, c)
			if (i == 1) and ((c.r ~= 255) or (c.g ~= 0) or (c.r ~= 255)) then
				print("WARNING: wrong color taken as transparency:"
					..(("at (%d,%d): [R=%d,G=%d,B=%d]"):format(x, z, c.r, c.g, c.b))
				)
			end
			local biome = pal[i].biome
			data[dataix]=biome--[dataiy] = biome
			--print(data[dataix])
			--dataiy = dataiy + 1
			dataix = dataix + 1
		end
	
	end
	--print(data.size)
	return data
end

function maploader.get_biome(minp, maxp, ind) --don't know how many of these I need yet...
	local bmp, e = maploader.load(minetest.get_modpath("lottmapgen").."/images/fullmap.bmp")
	if not bmp then
		print("[maploader] Failed to load image: "..(e or "unknown error"))
		return
	end
	
	local map = {}
	--this needs to print to a map, not a shematic! 2D, not-3D.
	map = maploader.to_map(bmp, palette.biome_palette, minp, maxp)
	
	--print(bmp.w)
	--print(bmp.h)
	--grab whatcha need
	return map, bmp.w, bmp.h
	
	
end
