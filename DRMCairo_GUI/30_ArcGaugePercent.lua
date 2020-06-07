-- Arc as Percentage Gauge
-- Mostly made to display internet usage

function ArcGaugePercent(
	psrf,	-- parent surface
	sx,sy,	-- surrounding box position in the mother surface
	sw,sh,	-- its size
	opts
)
--[[ known options :
--	align : tell if the graphics is on the left (default) or on the right
--	bgcolor : color outside the gauge
--	emptycolor : color for empty area (optional)
--	tvcolor : color for TV
--	internetcolor : color for internet
--	parts : split into parts in ??xPI randian 
--		(e.i : a quarter is PI/2 so part = 1/8 will split a quarter in 4 parts)
--]]
	if not opts then
		opts = {}
	end
	if not opts.align then
		opts.align = ALIGN_LEFT
	end
	if not opts.bgcolor then
		opts.bgcolor = COL_BLACK
	end
	if not opts.tvcolor then
		opts.tvcolor = COL_ORANGE
	end
	if not opts.internetcolor then
		opts.internetcolor = COL_GREEN
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )

	----
	-- Methods
	----

	function self.Clear()
		self.get():Clear( opts.bgcolor.get() )
	end

	function self.update( 
		capacity,	-- Total resource available (maximum sum of all other values)
		tv, 		-- 1st value to display
		internet	-- 2nd value to display
	)
		self.Clear()

			-- calculate percentage
		tv = tv*8 / capacity
		internet = internet*8 / capacity

			-- For left quarter
			-- 		0 = PI
			-- 		100% -> 1 = PI/2

		local r = sw
		if sw > sh then
			r = sh
		end
		r = r-5

		if tv ~=0 then
			self.setColor( opts.tvcolor )
			self.get():DrawArc( sw, sh, r, 
				math.pi,
				(1 + tv/2)*math.pi,
				10 
			)
		end
		if internet ~= 0 then
			self.setColor( opts.internetcolor )
			self.get():DrawArc( sw, sh, r,
				(1 + tv/2)*math.pi, 
				(1+(tv + internet)/2)*math.pi,
				10
			)
		end
		if opts.emptycolor then
			self.setColor( opts.emptycolor )
			self.get():DrawArc( sw, sh, r,
				(1 + (tv+internet)/2)*math.pi, 
				3/2*math.pi,
				10
			)
		end
		if opts.parts then
			self.setColor( opts.bgcolor )
			for i = 0, 1/2, opts.parts do
				self.get():DrawLine( sw, sh, sw+r*2*math.cos((1+i)*math.pi), sh+r*2*math.sin((1+i)*math.pi),1)
			end
		end


		self.Refresh()
	end

	return self
end
