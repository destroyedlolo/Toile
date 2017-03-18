-- Arc as Percentage Gauge

function ArcGaugePercent(
	psrf,	-- mother surface
	sx,sy,	-- surrounding box position in the mother surface
	sw,sh,	-- its size
	width,	-- arc width
	quarter,	-- quarter number (see Selene's DrawCircle())
	opts
)
--[[ known options :
--	bgcolor : color outside the gauge
--	emptycolor : color for empty area
--	tvcolor : color for TV
--	internetcolor : color for internet
--]]
	if not opts then
		opts = {}
	end
	if not opts.bgcolor then
		opts.bgcolor = COL_BLACK
	end
	if not opts.emptycolor then
		opts.emptycolor = opts.bgcolor
	end
	if not opts.tvcolor then
		opts.tvcolor = COL_ORANGE
	end
	if not opts.internetcolor then
		opts.internetcolor = COL_GREEN
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )

	------
	-- mask
	-----
		-- ARGB add an alpha layer to the created surface
	local mask = SelSurface:create { size = { sw,sh }, pixelformat=SelSurface.PixelFormatConst('ARGB') }

	-- arc stuffs
	local cx,cy
	if quarter == 1 then	-- bottom left
		cx,cy = 0,sh
	elseif quarter == 2 then	-- bottom right
		cx,cy = sw,sh
	elseif quarter == 3 then	-- top right
		cx,cy = sw,0
	else					-- top left
		cx,cy = 0,0
	end
	local radius = sw
	if sh < sw then
		radius = sh
	end

	-- draw arc
	mask:Clear( opts.bgcolor.get() )
	mask:SetColor( 255,255,255, 0 )
	mask:FillCircle( cx,cy, radius, SelSurface.CircleQuarterConst('Q'..quarter) )
	mask:SetColor( opts.bgcolor.get() )
	mask:FillCircle( cx,cy, radius-width, SelSurface.CircleQuarterConst('Q'..quarter) )

	-------
	-- Graphics
	-------
	function self.Clear()
		self.get():Clear( opts.emptycolor.get() )
	end

	function self.ApplyMask()
		self.get():SetBlittingFlags( SelSurface.BlittingFlagsConst('BLEND_ALPHACHANNEL') )
		self.get():Blit( mask, nil, 0,0 )
		self.get():SetBlittingFlags( SelSurface.BlittingFlagsConst('NONE') )
	end

	local function draw(min, max)
		if quarter == 1 then	-- bottom left
-- 0 = 0
-- 100% = pi/2
-- d = v*pi/200
			min = min * math.pi / 200
			max = max * math.pi / 200
			self.get():FillTriangle(
				cx,cy,
				cx + 3*radius*math.cos( min ), cy - 3*radius*math.sin( min ),
				cx + 3*radius*math.cos( max ), cy - 3*radius*math.sin( max )
			)
		elseif quarter == 2 then	-- bottom right
-- 0 = pi
-- 100% = pi/2
-- d = pi - v*pi/200 = pi * (1-v/200)
			min = math.pi * (1-min/200)
			max = math.pi * (1-max/200)
			self.get():FillTriangle(
				cx,cy,
				cx + 3*radius*math.cos( min ), cy - 3*radius*math.sin( min ),
				cx + 3*radius*math.cos( max ), cy - 3*radius*math.sin( max )
			)
		elseif quarter == 3 then	-- top right
			cx,cy = sw,0
		else					-- top left
			cx,cy = 0,0
		end
	end

	function self.update( c, t, i )
		self.Clear()

			-- calculate percentage
		t = t*800 / c
		i = i*800 / c + t
		if i > 100 then
			i = 100
		end

		if t ~=0 then
			self.setColor( opts.tvcolor )
			draw(0, t)
		end
		if i ~=0 then
			self.setColor( opts.internetcolor )
			draw(t, i)
		end

		self.ApplyMask()
		self.refresh()
	end

	return self
end
