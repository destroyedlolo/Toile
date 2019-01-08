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
--	yearXoffset : offset for ancient years (default = 5) 
--	yearYoffset : offset for ancient years (default = 5)
--	fadeyears ; percentage of color fading
--	barrespace : space b/w barres (default = 5)
--	production_offset : put some space for backgroup consomation (default = 3)
--]]
	if not opts then
		opts = {}
	end
	opts.bgcolor = opts.bgcolor or COL_GFXBG
	opts.productioncolor = opts.productioncolor or COL_GREEN
	opts.consumptionHCcolor = opts.consumptionHCcolor or COL_ORANGE
	opts.consumptionHPcolor = opts.consumptionHPcolor or COL_RED
	opts.yearXoffset = opts.yearXoffset or 5
	opts.yearYoffset = opts.yearYoffset or 5
	opts.barrespace = opts.barrespace or 5
	opts.production_offset = opts.production_offset or 3
	opts.fadeyears = opts.fadeyears or 0

	local self = SubSurface(psrf, sx,sy, sw,sh )
	local mqtttp = MQTTinput(name, topic)
	local dt = {}
	local years = {} -- Years stored
	local maxv -- maximum value to display

	function self.Clear()
		self.get():Clear( opts.bgcolor.get() )
		if opts.bordercolor then
			self.get():SetColor( opts.bordercolor.get() )
			self.get():DrawRectangle(0,0, sw,sh)
		end
	end

	function self.load( sdt )	-- load from a string
		dt = {}
		years = {}
		maxv = 0

		for l in (sdt.."\n"):gmatch"(.-)\n" do
			local name, year, month, val = string.match( l, '([%w%_]+),(%d+),(%d+),(%d+)')
			month = tonumber(month)

			if val then
				if not dt[year] then
					dt[year] = {}
					table.insert( years, year )
				end
				if not dt[year][month] then
					dt[year][month]={}
				end
				dt[year][month][name] = val
			end
		end
		table.sort(years, function(a,b) return a>b end)
		if opts.maxyears then	-- removing surplus years 
			while( #years > opts.maxyears ) do
				table.remove(years)
			end
		end
	end

	function self.update( )	-- Updates graphics
		self.Clear()
		local w,h = sw, sh
		local ox,oy = 0,h	-- origin of graphics

		if opts.bordercolor then
			w = w - 4
			h = h - 4
			ox,oy = 2, h - opts.yearYoffset*#years
		end

		if maxv == 0 then -- Find the highest value
			for _,year in ipairs(years) do	-- Loop in years
				for _, v in pairs( dt[year] ) do -- Loop in months
					maxv = math.max( maxv, v['production_BASE'], 
						(v['consomation_HC'] or 0) + (v['consomation_HP'] or 0)
					)
				end
			end
		end

			-- Offsets
		local sx = w / 12
		local bw = sx - opts.barrespace - #years*opts.yearXoffset	-- Barres' width
		local sy = (h - #years*opts.yearYoffset) / maxv
		local bwp = bw - 2*opts.production_offset	--Production barre width
		if bwp < bw - opts.yearXoffset then
			bwp = bw - opts.yearXoffset
		end

			-- Drawing
		for i = #years, 1, -1 do
			local x = ox + i*opts.yearXoffset
			for m = 1, 12 do
				local y
				if dt[years[i]][m] then
					y = 0
					if dt[years[i]][m]['consomation_HC'] then
						y = math.ceil(dt[years[i]][m]['consomation_HC'] * sy)
						self.setColorRGB( opts.consumptionHCcolor.fade( 100 - opts.fadeyears*(i-1) ) )
						self.get():FillRectangle( x, oy-y, bw, y )
					end
					if dt[years[i]][m]['consomation_HP'] then
						self.setColorRGB( opts.consumptionHPcolor.fade( 100 - opts.fadeyears*(i-1) ) )
						local y2 = math.ceil(dt[years[i]][m]['consomation_HP'] * sy)
						self.get():FillRectangle( x, oy - y - y2, bw, y2 )
						y = y + y2
					end

					if opts.consumption_border then
						self.setColor(opts.consumption_border)
						self.get():DrawRectangle( x, oy-y, bw, y )
					end

					if dt[years[i]][m]['production_BASE'] then
						y = math.ceil(dt[years[i]][m]['production_BASE'] * sy)
						self.setColorRGB( opts.productioncolor.fade( 100 - opts.fadeyears*(i-1) ) )
						self.get():FillRectangle( x + opts.production_offset, oy-y, bwp, y )
						if opts.production_border then
							self.setColor(opts.production_border)
							self.get():DrawRectangle( x + opts.production_offset, oy-y, bwp, y )
						end
					end
				end
				x = x + sx
			end
			oy = oy + opts.yearYoffset
		end
	end

	local function rcvdt()	-- MQTT data received
		self.load( SelShared.Get(name) )
		self.update()
	end
	mqtttp.TaskOnceAdd( rcvdt )

	return self
end
