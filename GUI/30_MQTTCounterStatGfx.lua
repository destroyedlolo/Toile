-- Receive montly counter statistics
-- Note : this class is hybride as containing both transport layer
-- and Gfx part.
-- It's because this class is hardly tight with counters implementation

--[[ Format (as per /companions/PubCompteurs)
	Counter,year,month,value
consomation_HC,2017,05,207158
consomation_HP,2017,05,209223
production_BASE,2017,05,86780
consomation_HC,2017,04,420013
]]

function MQTTCounterStatGfx(
	psrf,	-- mother surface
	name, topic,
	sx,sy,	-- position in the mother surface
	sw,sh,	-- its size
	opts
)
--[[ known options  :
--	bgcolor : background color (default = COL_GFXBG)
--	bordercolor : borders's color
--	production_border : production column border color
--	productioncolor : production column fill color (default : COL_GREEN)
--	consumption_border : consumption column border color
--	consumptionHCcolor : consumption column fill color for "Heure Creuse"
--					(default = COL_ORANGE)
--	consumptionHPcolor : consumption column fill color for "Heure Plaine"
--					(default = COL_RED)
--
--	maxyears : how many years to display at a maximum
--]]
	if not opts then
		opts = {}
	end
	opts.bgcolor = opts.bgcolor or COL_GFXBG
	opts.productioncolor = opts.productioncolor or COL_GREEN
	opts.consumptionHCborder = opts.consumptionHCborder or COL_ORANGE
	opts.consumptionHPborder = opts.consumptionHPborder or COL_RED

	local self = SubSurface(psrf, sx,sy, sw,sh )
	local mqtttp = MQTTinput(name, topic)
	local dt = {}
	local nyears -- Number of years stored

	function self.Clear()
		self.get():Clear( opts.bgcolor.get() )
		if opts.bordercolor then
			self.get():SetColor( opts.bordercolor.get() )
			self.get():DrawRectangle(0,0, sw,sh)
		end
	end

	function self.load( sdt )	-- load from a string
		dt = {}
		nyears = 0

		for l in (sdt.."\n"):gmatch"(.-)\n" do
			local name, year, month, val = string.match( l, '([%w%_]+),(%d+),(%d+),(%d+)')
			if val then
				if not dt[year] then
					dt[year] = {}
					nyears = nyears + 1
				end
				if not dt[year][month] then
					dt[year][month]={}
				end
				dt[year][month][name] = val
			end
		end
	end

	function self.update( )	-- Updates graphics
		self.Clear()
		local w,h = sw, sh

		if opts.bordercolor then
			w = w - 4
			h = h - 4
		end

	end

	local function rcvdt()	-- MQTT data received
		self.load( SelShared.get(name) )
		self.update()
	end
	mqtttp.TaskOnceAdd( rcvdt )

	return self
end
