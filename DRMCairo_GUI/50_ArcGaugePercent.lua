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
--	ownsurface : it's not a subsurface but a real one that will be blited to
--		the parent at refresh. Needed if it overlaps another one and draws
--		transparent colors
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

	-- Normalisation
	sx,sy = math.ceil(sx), math.ceil(sy)
	sw,sh = math.ceil(sw), math.ceil(sh)

	local self
	if opts.ownsurface == true then
		self = Surface(psrf, sx,sy, sw,sh, opts)
		self.Visibility(true) -- always put on its mother surface as it's not the primary
	else
		self = SubSurface(psrf, sx,sy, sw,sh, opts )
	end

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

		if not capacity or not tv or not internet or tonumber(capacity) == 0 then
			self.Refresh()
			return
		end

			-- calculate percentage
		tv = tv*8 / capacity
		internet = internet*8 / capacity

			-- For left quarter
			-- 		0 = PI
			-- 		100% -> 1 = 3*PI/2
			--
			-- For right quarter
			-- 		0 = 2*PI
			-- 		100% -> 1 = 3/2 * PI

		local r = sw
		if sw > sh then
			r = sh
		end
		r = r-5

		local left = true
		if opts.align and opts.align == ALIGN_RIGHT then
			left = nil
		end

		if tv ~=0 then
			self.setColor( opts.tvcolor )
			if left then
				self.get():DrawArc( sw, sh, r, 
					math.pi,
					(1 + tv/2)*math.pi,
					10, true
				)
			else
				self.get():DrawArc( 0, sh, r, 
					(2-tv/2)*math.pi,
					2*math.pi,
					10, true
				)
			end
		end
		if internet ~= 0 then
			self.setColor( opts.internetcolor )
			if left then
				self.get():DrawArc( sw, sh, r,
					(1 + tv/2)*math.pi, 
					(1+(tv + internet)/2)*math.pi,
					10
				)
			else
				self.get():DrawArc( 0, sh, r, 
					(2 - (tv + internet)/2)*math.pi,
					(2-tv/2)*math.pi,
					10 
				)
			end
		end
		if opts.emptycolor then
			self.setColor( opts.emptycolor )
			if left then
				self.get():DrawArc( sw, sh, r,
					(1 + (tv+internet)/2)*math.pi, 
					3/2*math.pi,
					10
				)
			else
				self.get():DrawArc( 0, sh, r,
					2*math.pi,
					(2 - (tv + internet)/2)*math.pi, 
					10
				)
			end
		end
		if opts.parts then
			self.setColor( opts.bgcolor )
			if left then
				for i = 0, 1/2, opts.parts do
					self.get():DrawLine( sw, sh, sw+r*2 * math.cos((1+i)*math.pi), sh+r*2 * math.sin((1+i)*math.pi),1)
				end
			else
				for i = 0, 1/2, opts.parts do
					self.get():DrawLine(  0, sh, r*2*math.cos((2-i)*math.pi), sh+r*2*math.sin((2-i)*math.pi),1)
				end
			end
		end


		self.Refresh()
	end

	return self
end
