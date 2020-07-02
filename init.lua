TOILE_VERSION=6.0604

-- Ensure we're not using obsolete version
if SELPLUG_DRMCairo then
	assert( SELENE_VERSION >= 6.0009, "HDB requires at least Selene v6.00.09" )
else
	assert( SELENE_VERSION >= 5.0100, "HDB requires at least Selene v5.01.00" )
end

-- compatibility with newer Lua
-- local unpack = unpack or table.unpack


-- modules helpers
lfs = require "lfs" -- LuaFileSystem


function loaddir(path, dir )
	local t={}

	for f in lfs.dir(path..dir) do
		local attr = lfs.attributes( path..dir ..'/'.. f )
		local found, len, res = f:find("^(.*)%.[^%.]*$")
		if found and attr.mode == 'file' and res:sub(1,1) ~= '.' and f:match("^.+(%..+)$") ~= '.md' then
			table.insert( t, res )
		end
	end

	table.sort(t)

	for _,res in ipairs( t ) do
		require('Toile/' .. dir ..'/'.. res)
		SelLog.log('L', dir ..'/'.. res .. ' loaded')
	end
end

-- load modules
local info = debug.getinfo(1,'S');
local whereiam = string.match(info.source, "@(.-)([^\\/]-%.?([^%.\\/]*))$")

SelLog.log('Loading Toile v'.. TOILE_VERSION ..' ...' )
loaddir(whereiam, 'Supports')
wdTimer = bipTimer(1)	-- Wathdog timer

loaddir(whereiam, 'Inputs')

if SELPLUG_DRMCairo then	-- DRMCairo used
	animTimer = bipTimer(.25)	-- Animation timer
	loaddir(whereiam, 'DRMCairo_GUI')
elseif SELPLUG_OLED then -- OLED used
	loaddir(whereiam, 'OLed')
elseif SELPLUG_DFB then	-- DirectFB used
	animTimer = bipTimer(.25)	-- Animation timer
	loaddir(whereiam, 'DirectFB_GUI')
else
	error("No graphical layer found")
end

