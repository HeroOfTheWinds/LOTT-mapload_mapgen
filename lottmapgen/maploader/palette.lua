
palette = { }

local PAL_SIZE = 256

local floor = math.floor

local col_diff

--[[ bestfit_init:
  |  Color matching is done with weighted squares, which are much faster
  |  if we pregenerate a little lookup table...
  ]]
local function bestfit_init()

	col_diff = { }

	for i = 0, 63 do
		local k = i * i;
		local t

		t = k * (59 * 59)
		col_diff[0  +i] = t
		col_diff[0  +128-i] = t

		t = k * (30 * 30)
		col_diff[128+i] = t
		col_diff[128+128-i] = t

		t = k * (11 * 11)
		col_diff[256+i] = t
		col_diff[256+128-i] = t
	end

end

--[[ bestfit_color:
  |  Searches a palette for the color closest to the requested R, G, B value.
  ]]
function palette.bestfit_color(pal, c)

	local r, g, b = floor(c.r / 4), floor(c.g / 4), floor(c.b / 4)

	local i, coldiff, lowest, bestfit

	assert((r >= 0) and (r <= 63))
	assert((g >= 0) and (g <= 63))
	assert((b >= 0) and (b <= 63))

	bestfit = 1
	lowest = math.huge

	-- only the transparent (pink) color can be mapped to index 0
	if (r == 63) and (g == 0) and (b == 63) then
		i = 1
	else
		i = 2
	end

	while i < PAL_SIZE do
		local cc = pal[i]
		if not cc then break end
		local rgb = { r=floor(cc.r / 4), g = floor(cc.g / 4), b = floor(cc.b / 4) }
		coldiff = col_diff[0 + ((rgb.g - g) % 0x80)]
		if coldiff < lowest then
			coldiff = coldiff + col_diff[128 + ((rgb.r - r) % 0x80)]
			if coldiff < lowest then
				coldiff = coldiff + col_diff[256 + ((rgb.b - b) % 0x80)]
				if coldiff < lowest then
					bestfit = i
					if coldiff == 0 then return bestfit end
					lowest = coldiff
				end
			end
		end
		i = i + 1
	end

	return bestfit

end

--TODO: grab the right color values
palette.biome_palette = {
	{ biome=0, r=130, g=130, b=130 },--ignore biome 0
	{ biome=1, r=201, g=218, b=224 }, --Angmar
	{ biome=2, r=143, g=169, b=188 }, --snowplains...actually not in middle earth??
	{ biome=3, r=158, g=141, b=105 }, --Trollshaws
	{ biome=4, r=50, g=114, b=56 }, --Dunlands
	{ biome=5, r=197, g=204, b=83 }, --Gondor
	{ biome=6, r=169, g=181, b=66 }, --Ithilien
	{ biome=7, r=242, g=211, b=55 }, --Lorien/Lothlorien
	{ biome=8, r=0, g=0, b=0 }, --MORDOR
	{ biome=9, r=44, g=137, b=45 }, --Fangorn
	{ biome=10, r=20, g=33, b=18 }, --Mirkwood
	{ biome=11, r=196, g=140, b=98 }, --Iron Hills
	{ biome=12, r=157, g=161, b=82 }, --Rohan
	{ biome=13, r=116, g=183, b=71 }, --Shire
	{ biome=14, r=0, g=85, b=160 },--water 1
	{ biome=15, r=0, g=135, b=255 },--water 2
}

bestfit_init()
