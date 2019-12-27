-- Declare graphics zone

function GfxArea( 
	offx, offy,	-- Top left of the surface area
	sw, sh,	-- Size
	opts
)
--[[ known options  :
--	btop_pattern, bbottom_pattern, bleft_pattern, bright_pattern :
--		Patterns for related border. 0 by default
--	clear : Clear the surface at every redraw
--	bgcolor : background color, 0 by default
--	fgcolor : forground color, 1 by default
--	align : how to align the graphic (LEFT by default, RIGHT known also)
--	stretch : if not null, enlarge the graphic to fit surface width (force left alignment)
--	min_delta : minimum delta b/w min and max value
--	mode : drawing mode
--		- 'delta' : draw min-max
--		- default or 'range' : min/max range
]]
	local self = {}

	if not opts then
		opts = { bgcolor=0, fgcolor=1 }
	end
	if opts.align ~= ALIGN_RIGHT or opts.stretch then
		opts.align = ALIGN_LEFT
	end
	if not opts.mode then
		opts.mode = 'range'
	end

	function self.decoration() -- Draw empty surface
		if opts.clear then
			FillRect( offx, offy, sw, sh, opts.bgcolors );
		end
		if opts.bleft_pattern then
			SelOLED.Line(offx, offy, offx, offy+sh, opts.fgcolor, opts.bleft_pattern)
		end
		if opts.bbottom_pattern then
			SelOLED.Line(offx, offy+sh, offx+sw, offy+sh, opts.fgcolor, opts.bbottom_pattern)
		end
		if opts.bright_pattern then
			SelOLED.Line(offx+sw, offy, offx+sw, offy+sh, opts.fgcolor, opts.bright_pattern)
		end
		if opts.btop_pattern then
			SelOLED.Line(offx, offy, offx+sw, offy, opts.fgcolor, opts.btop_pattern)
		end
	end

	function self.DrawGfx(data, amin)	-- Draw with data
		self.decoration()
	
		local min,max
		if opts.mode == 'delta' then
			min,max = data:DiffMinMax()
		else
			min,max = data:MinMax()
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

		if max == min then	-- No dynamic data to draw
			return
		end

		local h = sh-1
		local sy = h/(max-min) -- vertical scale
		local sx = sw/data:GetSize()
		if opts.stretch then
			if data:HowMany() == 0 then -- No data to display
				return
			end
			sx = sw/(data:HowMany() - 1) -- -1 as the 1st one doesn't have offset
		end

			--
			-- Drawing
			--

		local y		-- previous value
		local x=0	-- x position
		if opts.align == ALIGN_RIGHT then
			x = sw - data:HowMany()*sx
		end

		local ansH,ansD
		for v,t,_ in data:iData() do
			local vmax
			if _ then	-- 2 values provided
				vmax = t
				t = _
			end

			if y then
				x = x+1
--[[
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
--]]

				if vmax then -- Draw couple data
					if opts.mode == 'delta' then
						v = vmax - v
						SelOLED.Line(offx + (x-1)*sx, offy + h - (y-min)*sy, offx + x*sx, offy + h - (v-min)*sy, opts.fgcolor)
					else
						SelOLED.Line(offx + x*sx, offy + h - (v-min)*sy, offx + x*sx, offy + h - (vmax-min)*sy, opts.fgcolor)
					end
				else		-- Draw single data
					SelOLED.Line(offx + (x-1)*sx, offy + h - (y-min)*sy, offx + x*sx, offy + h - (v-min)*sy, opts.fgcolor)
				end
			end
			y = v
		end

	end

	return self
end
