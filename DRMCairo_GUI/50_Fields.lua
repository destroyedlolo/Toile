-- Display a text value

function Field(
	psrf,	-- mother surface
	x,y,	-- position in the mother surface
	font,	-- font to use
	color,	-- initial foreground color
	opts
)
--[[ known options  :
--	align : how to align the text (LEFT by default)
--	sample_text : text to use to compute the field width
--	width, height : force the field's geometry
--	bgcolor : background color
--	ndecimal : round to ndecimal
--	refresh : force refresh even if the data doesn't change
--		(useful if smax overlap gfx with mask)
--	suffix : string to add to the value (i.e. : unit)
--	gradient : gradient to colorize
--
--	timeout : force to timeoutcolor after timeout seconds without update
--	timeoutcolor : color to force to (default COL_DARKRED)
--
--	At last one of sample_text or width MUST be provided
--]]
	if not opts then
		opts = {}
	end

		-- initialize

	if not opts.width or not opts.height then
		-- We need a surface to get font's extends but ours is not
		-- yet created.
		-- As a drawback, we are using the parent one

		psrf.get():SaveContext()
		psrf.setFont(font)
		if not opts.width then
			opts.width = psrf.get():GetStringExtents( opts.sample_text )
		end
		if not opts.height then
			opts.height = psrf.get():GetFontExtents()
		end
		psrf.get():RestoreContext()
	end

	if not opts.bgcolor then
		opts.bgcolor = COL_BLACK
	end
	if not opts.timeoutcolor then
		opts.timeoutcolor = COL_DARKRED
	end
	if opts.align == ALIGN_FRIGHT then
		x = x - opts.width
	end

	local self = SubSurface(psrf, x,y, opts.width, opts.height)
	self.setFont( font )
	self.setColor( color )

		-- Handle watchdog
	self.updtxt = function () end -- forward definition
	local wdcnt	-- Watchdog counter
	local val	-- stored value
	local function watchdog()
		if wdcnt > 0 then
			wdcnt = wdcnt - 1
			if wdcnt == 0 then
				self.setColor(opts.timeoutcolor)
				if val then
					self.updtxt( val )
				end
			end
		end
	end

	if opts.timeout then
		wdTimer.TaskOnceAdd(watchdog)
		wdcnt = opts.timeout
	end

	----
	-- Methods
	----

	function self.getHight()
		return opts.width
	end

	function self.getAfter()
		return x + opts.width, y
	end

	function self.Clear()
		self.get():Clear( opts.bgcolor.get() )
	end

	function self.DrawStringOff( v, x,y )	-- Draw a string at the specified offset
		local srf = self.get()
		local tsz = self.get():GetStringExtents(v)

		if opts.align == ALIGN_RIGHT or opts.align == ALIGN_FRIGHT then
			srf:DrawStringTop( v, srf:GetWidth() - tsz - x, y )
		elseif opts.align == ALIGN_CENTER then
			srf:DrawStringTop( v, (srf:GetWidth() - tsz)/2 - x, y )
		else	-- left
			srf:DrawStringTop( v, x,y )
		end
	end

	function self.updtxt( v )
		if opts.ndecimal then
			v = string.format("%." .. (opts.ndecimal or 0) .. "f", tonumber(v))
		end
		if opts.suffix then
			v = v .. opts.suffix
		end
		self.Clear()
		self.DrawStringOff(v, 0,0)
		self.Refresh()
	end

	return self
end
