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
--	mode : drawing mode
--		- 'delta' : draw min-max
--		- default or 'range' : min/max range
--	gradient : use a dynamic gradient behind
--	gradientA : gradient for average values
--	transparency : the surfaces below must be refreshed as this one has 
--		transparency. With this opt set, surfaces bellow are cleared first.
--		Mostly useful when it has background image.
--
--  CAUTION : Gradian is calculated ONLY for min/max value.
--  	Consequently, INTERMEDIATES VALUES ARE IGNORED.
--]]
	if not opts then
		opts = {}
	end
	if opts.align ~= ALIGN_RIGHT or opts.stretch then
		opts.align = ALIGN_LEFT
	end
	if not opts.mode then
		opts.mode = 'range'
	end

	local self
	if opts.ownsurface == true then
		self = Surface(psrf, sx,sy, sw,sh, opts)
		self.Visibility(true)
	else
		self = SubSurface(psrf, sx,sy, sw,sh, opts )
	end

	function self.getMode()
		return opts.mode
	end

	function self.Clear(
		clipped -- clipping area from child (optional)
	)
		if psrf.Clear and opts.transparency then
			if clipped then	-- Offset this surface
				clipped[1] = clipped[1]+sx
				clipped[2] = clipped[2]+sy
			else
				clipped = { sx,sy, sw,sh }
			end
			psrf.Clear(clipped)
		end

		self.get():Clear( bgcolor.get() )	-- Then clear ourself
	end

	function self.setGradient( g )
		opts.gradient = g
	end

	local pmin, pmax = 0,0	-- Previous collection value
	local gradient_srf, gradient_srfA
	function self.DrawGfx( data, amin )	-- Minimal graphics
		self.Clear()

if opts.debug then
	print(opts.debug, "drawGfx")
end
			--
			-- Calculate scales
			--

		local min,max
		if opts.mode == 'delta' then
			min,max = data:DiffMinMax()
		else
			min,max = data:MinMax()
		end
if opts.debug then
	print(opts.debug, "collection", data:HowMany(), min, max)
end
	
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

		if min == max then
			return
		end

		local w,h = self.get():GetWidth(), self.get():GetHight()-1
		local sy = h/(max-min) -- vertical scale
		local sx = self.get():GetWidth()/data:GetSize()
		if opts.stretch then
			if data:HowMany() == 0 then -- No data to display
				return
			end
			sx = self.get():GetWidth()/(data:HowMany() - 1) -- -1 as the 1st one doesn't have offset
		end


			--
			-- Create/update background gradients
			--

		if opts.gradient and (pmin ~= min or pmax ~= max) then	-- Rethink gradient only if min/max changed
			pmin = min
			pmax = max
			if gradient_srf then
				gradient_srf:Release()
			end

			gradient_srf = SelDCSurface.create( w,h )

				-- Gradient
			local pat = SelDCPattern.createLinear(0,h, 0,0)
			pat:addFixPoint( 0, opts.gradient.findgradientcolor(min) )
			pat:addFixPoint( 1, opts.gradient.findgradientcolor(max) )

			gradient_srf:SetSourcePattern(pat)
			gradient_srf:FillRectangle(0,0, w,h)

			pat:Release()

				-- Shadow
			pat = SelDCPattern.createLinear(0,0, w,0)
			pat:addFixPoint( 0, .2, .2, .2, .9 )
			pat:addFixPoint( 1, .2, .2, .2, 0 )

			local tspat = SelDCSurface.create( w,h )
			tspat:SetSourcePattern(pat)
			tspat:FillRectangle(0,0, w,h)

			pat:Release()

				-- Mix both
			gradient_srf:SetSourceSurface(tspat)
			gradient_srf:Paint()

			tspat:Release()

			if opts.gradientA and data.MinMaxA then	-- It's SelAverageCollection
				if gradient_srfA then
					gradient_srfA:Release()
				end

				gradient_srfA = SelDCSurface.create( w,h )

					-- Gradient
				pat = SelDCPattern.createLinear(0,h, 0,0)
				pat:addFixPoint( 0, opts.gradientA.findgradientcolor(min) )
				pat:addFixPoint( 1, opts.gradientA.findgradientcolor(max) )

				gradient_srfA:SetSourcePattern(pat)
				gradient_srfA:FillRectangle(0,0, w,h)

				pat:Release()

					-- Shadow
				pat = SelDCPattern.createLinear(0,0, w,0)
				pat:addFixPoint( 0, .2, .2, .2, .9 )
				pat:addFixPoint( 1, .2, .2, .2, 0 )

				local tspat = SelDCSurface.create( w,h )
				tspat:SetSourcePattern(pat)
				tspat:FillRectangle(0,0, w,h)

				pat:Release()

					-- Mix both
				gradient_srfA:SetSourceSurface(tspat)
				gradient_srfA:Paint()

				tspat:Release()
			end
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
			-- Drawing Average
			--

		local y		-- previous value
		local x=0	-- x position

		if data.MinMaxA then	-- It's SelAverageCollection
			local hmimmediate,hmaverage = data:HowMany()

			if hmaverage > 0 then
				if opts.align == ALIGN_RIGHT then
					x = self.get():GetWidth() - hmaverage*sx
				end

				if gradient_srfA then
					self.get():SetSourceSurface(gradient_srfA)
				else
					self.setColor( color )
				end

				-- Dodo : even if not useful for the moment, multi values
				-- are already coded
				for v,t,_ in data:aData() do
if opts.debug then
	print(opts.debug .. "avg",  v,t,_, min,max, t == max)
end

					local vmax
					if _ then	-- 2 values provided
						vmax = t
						t = _
					end

					if y then
						x = x+1

						if vmax then -- Draw couple data
							if opts.mode == 'delta' then
								v = vmax - v
								self.get():DrawLine((x-1)*sx, h - (y-min)*sy, x*sx, h - (v-min)*sy)
							else
								self.get():DrawLine(x*sx, h - (v-min)*sy, x*sx, h - (vmax-min)*sy)
if opts.debug then
	print(opts.debug, x*sx, h - (v-min)*sy, x*sx, h - (vmax-min)*sy)
end
							end
						else		-- Draw single data
							self.get():DrawLine((x-1)*sx, h - (y-min)*sy, x*sx, h - (v-min)*sy)
						end
					end
					y = v
				end
			end
		end


			--
			-- Drawing immediate
			--

		x = 0

		if opts.align == ALIGN_RIGHT then
			x = self.get():GetWidth() - data:HowMany()*sx
		end

		if gradient_srf then
			self.get():SetSourceSurface(gradient_srf)
		else
			self.setColor( color )
		end

if opts.debug then
	print(opts.debug, "drawing", data:HowMany(), min, max)
end
		local ansH,ansD
		for v,t,_ in data:iData() do
if opts.debug then
	print(opts.debug,  v,t,_, min,max, t == max)
end
			local vmax
			if _ then	-- 2 values provided
				vmax = t
				t = _
			end

			if y then
				x = x+1

				if opts.vlinesH then
					local hr = os.date('%H',t)
					if ansH and ansH ~= hr then
						self.get():SaveContext()
						self.setColor( opts.vlinesH )
						self.get():DrawLine(x*sx, 0, x*sx, self.get():GetHight())
						self.get():RestoreContext()
					end
					ansH = hr
				end

				if opts.vlinesD then
					local d = os.date('%d',t)
					if ansD and ansD ~= d then
						self.get():SaveContext()
						self.setColor( opts.vlinesD )
						self.get():DrawLine(x*sx, 0, x*sx, self.get():GetHight())
						self.get():RestoreContext()
					end
					ansD = d
				end

				if vmax then -- Draw couple data
					if opts.mode == 'delta' then
						v = vmax - v
						self.get():DrawLine((x-1)*sx, h - (y-min)*sy, x*sx, h - (v-min)*sy)
					else
						self.get():DrawLine(x*sx, h - (v-min)*sy, x*sx, h - (vmax-min)*sy)
if opts.debug then
	print(opts.debug, x*sx, h - (v-min)*sy, x*sx, h - (vmax-min)*sy)
end
					end
				else		-- Draw single data
					self.get():DrawLine((x-1)*sx, h - (y-min)*sy, x*sx, h - (v-min)*sy)
				end
			end
			y = v
		end

	end

	return self
end
