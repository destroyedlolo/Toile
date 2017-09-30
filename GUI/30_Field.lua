-- Field to display a value

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
	if not opts.width then
		opts.width = font:StringWidth( opts.sample_text )
	end
	if not opts.height then
		opts.height = font:GetHeight()
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

	local self = SubSurface(psrf, x,y, opts.width, opts.height )
	self.get():SetFont( font )
	self.setColor( color )

		-- Handle watchdog
	local wdcnt	-- Watchdog counter
	local function watchdog()
		if wdcnt > 0 then
print("*I* Watchdog : ", wdcnt)
			wdcnt = wdcnt - 1
			if wdcnt == 0 then
print("*I* !!!! Watchdog")
			end
		end
	end

	if opts.timeout then
print("*I* init Watchdog")
		wdTimer.TaskOnceAdd(watchdog)
		wdcnt = opts.timeout
	end

	-- methods
	function self.getHight()
		return font:GetHeight()
	end

	function self.getAfter()
		return x + opts.width, y
	end

	function self.Clear()
		self.get():Clear( opts.bgcolor.get() )
	end

	function self.DrawStringOff( v, x,y )	-- Draw a string a the specified offset
		local srf = self.get()

		if opts.align == ALIGN_RIGHT or opts.align == ALIGN_FRIGHT then
			srf:DrawString( v, srf:GetWidth() - font:StringWidth(v) - x, y )
		elseif opts.align == ALIGN_CENTER then
			srf:DrawString( v, (srf:GetWidth() - font:StringWidth(v))/2 - x, y )
		else	-- left
			srf:DrawString( v, x,y )
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
		self.refresh()

		if opts.timeout then
print("*I* reset Watchdog")
			wdcnt = opts.timeout
		end
	end

	function self.update( v )
		if opts.gradient then
			self.setColorRGB( opts.gradient.findgradientcolor(v) )
		end

		self.updtxt( v )
	end

	return self
end

