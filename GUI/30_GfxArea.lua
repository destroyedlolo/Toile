-- Area to graph some trends

function GfxArea(
	psrf,	-- mother surface
	sx,sy,	-- position in the mother surface
	sw,sh,	-- its size
	color,	-- initial foreground color
	bgcolor, -- background color
	opts
)
--[[ known options  :
--	align : how to align the graphic (LEFT by default, RIGHT known also)
--	stretch : if not null, enlarge the graphic to fit surface width (force left alignment)
--	hlines = { { val, col }, ... } : draw a line for specified value
--	heverylines = { { val, col [,limit] }, ... } : draw a line every val'th value
--		if limit provided, lines are drawn only if max-min < limit
--	vlinesH = col : draw a line every hour.
--	vlinesD = col : draw a line every day.
--	min_delta : minimum delta b/w min and max value
--
--	noclear : don't call Clear() after FrozeUnder() - for gfx debuging purposes -
--]]
	if not opts then
		opts = {}
	end
	if opts.align ~= ALIGN_RIGHT or opts.stretch then
		opts.align = ALIGN_LEFT
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )
	self.get():SetDrawingFlags( SelSurface.DrawingFlagsConst('BLEND') )
	self.get():SetRenderOptions( SelSurface.RenderOptionsFlagsConst('ANTIALIAS') )

	local mask = 0	-- invalid
	local back

	function self.FrozeUnder()	
		-- The current content of the surface will be "under" our graphic
		self.refresh() -- Ensure the background is fresh
		back = self.get():clone()
		mask = SelSurface:create { size = { sw,sh }, pixelformat=SelSurface.PixelFormatConst('ARGB') }
		mask:SetColor( color.get() )

		if not opts.noclear then
			self.ownsrf():Clear( bgcolor.get() )
--			self.refresh()
		end
	end

	self.ownsrf = self.get
	function self.get()
		if mask == 0 then
			return self.ownsrf()
		else
			return mask
		end
	end

	function self.Clear()
		if mask ~= 0 then
			self.ownsrf():restore(back)
			mask:Clear( bgcolor.get() )
		else
			self.get():Clear( bgcolor.get() )
		end
	end

	function self.DrawGfx( data, amin )	-- Minimal graphics
		self.Clear()

			--
			-- Calculate scales
			--

		local min,max = data:MinMax()
		if not min then	-- Nothing to display
			return
		end
		if amin then
			if amin < min then
				min = amin
			end
		end
		if opts.min_delta then
			if max - min < opts.min_delta then
				local m = (max + min)/2
				min = m - opts.min_delta/2
				max = m + opts.min_delta/2
			end
		end
	
		if max == min then	-- No dynamic data to draw
			self.ownsrf():Clear( bgcolor.get() ) -- Ensure empty surface if nothing as to be displayed
			return
		end
		local h = self.get():GetHight()-1
		local sy = h/(max-min) -- vertical scale
		local sx = self.get():GetWidth()/data:GetSize()
		if opts.stretch then
			if data:HowMany() == 0 then -- No data to display
				return
			end
			sx = self.get():GetWidth()/(data:HowMany() - 1) -- -1 as the 1st one doesn't have offset
		end

			--
			-- Draw additional gfx
			--
		if opts.heverylines then
			for _,v in ipairs( opts.heverylines ) do
				local draw = true
				if v[3] then
					if max - min >= v[3] then
						draw = false
					end
				end

				if draw == true then
					self.setColor( v[2] )
					for y = math.ceil(min/v[1])*v[1], math.floor(max/v[1])*v[1], v[1] do
						self.get():DrawLine(0,  h - (y-min)*sy, self.get():GetWidth(), h - (y-min)*sy)
					end
				end
			end
		end

		if opts.hlines then
			for _,v in ipairs( opts.hlines ) do
				self.setColor( v[2] )
				self.get():DrawLine(0,  h - (v[1]-min)*sy, self.get():GetWidth(), h - (v[1]-min)*sy)
			end
		end

			--
			-- Drawing
			--

		local y		-- previous value
		local x=0	-- x position
		if opts.align == ALIGN_RIGHT then
			x = self.get():GetWidth() - data:HowMany()*sx
		end

		self.setColor( color )

		local ansH,ansD
		for v,t in data:iData() do
			if y then
				x = x+1

				if opts.vlinesH then
					local hr = os.date('%H',t)
					if ansH and ansH ~= hr then
						self.setColor( opts.vlinesH )
						self.get():DrawLine(x*sx, 0, x*sx, self.get():GetHight())
						self.setColor( color )
					end
					ansH = hr
				end

				if opts.vlinesD then
					local d = os.date('%d',t)
					if ansD and ansD ~= d then
						self.setColor( opts.vlinesD )
						self.get():DrawLine(x*sx, 0, x*sx, self.get():GetHight())
						self.setColor( color )
					end
					ansD = d
				end

				self.get():DrawLine((x-1)*sx, h - (y-min)*sy, x*sx, h - (v-min)*sy)
			end
			y = v 
		end

		if mask ~= 0 then	-- Apply the mask
			self.ownsrf():SetBlittingFlags( SelSurface.BlittingFlagsConst('BLEND_ALPHACHANNEL') )
			self.ownsrf():Blit( mask, nil, 0,0 )
			self.ownsrf():SetBlittingFlags( SelSurface.BlittingFlagsConst('NONE') )
		end
	end

	return self
end
