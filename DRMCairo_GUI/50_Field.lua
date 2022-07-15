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
--		( default : black )
--		( false : no background color, only clear under surface ) 
--	ndecimal : round to ndecimal
--	ownsurface : it's not a subsurface but a real one that will be blited to
--		the parent at refresh. Needed if it overlaps another one and draws
--		transparent colors
--	included : this field is included and fully depend on his mother surface. Consequently :
--		* clear() is not called
--		* its content is only draw on its mother 
--		* so the result will be displayed at mother's refresh
--	suffix : string to add to the value (i.e. : unit)
--	gradient : gradient to colorize
--	timeout : force to timeoutcolor after timeout seconds without update
--	timeoutcolor : color to force to (default COL_DARKRED)
--	transparency : the surfaces below must be refreshed as this one has 
--		transparency. With this opt set, surfaces bellow are cleared first.
--		Mostly useful when it has background image.
--
--	At last one of sample_text or width MUST be provided
--
--
--	from DirectFB but not anymore used :
--	------------------------------------
--
--	refresh : force refresh even if the data doesn't change
--		(useful if smax overlap gfx with mask)
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

		-- Normalisation
	x,y = math.ceil(x), math.ceil(y)
	opts.width = math.ceil( opts.width )
	opts.height = math.ceil( opts.height )

	if not opts.bgcolor and opts.bgcolor ~= false then
		opts.bgcolor = COL_BLACK
	end
	if not opts.timeoutcolor then
		opts.timeoutcolor = COL_DARKRED
	end
	if opts.align == ALIGN_FRIGHT then
		x = x - opts.width
	end

	local self
	if opts.ownsurface == true then
		self = Surface(psrf, x,y, opts.width, opts.height, opts)
		self.Visibility(true) -- always put on its mother surface as it's not the primary
	else
		self = SubSurface(psrf, x,y, opts.width, opts.height, opts)
	end
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

	function self.Clear()
		if psrf.Clear and opts.transparency then
			psrf.Clear({x,y, opts.width, opts.height})
		end
		if opts.bgcolor then
			self.get():Clear( opts.bgcolor.get() )
		end
	end

	function self.DrawStringOff( v, x,y )	-- Draw a string at the specified offset
		local srf = self.get()
		local tsz = self.get():GetStringExtents(v) + 1

		if opts.align == ALIGN_RIGHT or opts.align == ALIGN_FRIGHT then
			srf:DrawStringTop( v, math.floor(srf:GetWidth() - tsz - x), y )
		elseif opts.align == ALIGN_CENTER then
			srf:DrawStringTop( v, math.floor((srf:GetWidth() - tsz)/2 - x), y )
		else	-- left
			srf:DrawStringTop( v, x,y )
		end
	end

	function self.updtxt( v )
		if not v then
			v = val

			if not v then	-- Secure initialisation
				return
			end
		end

if opts.debug then
print(">> updtxt", v)
end
		if opts.ndecimal then
			v = string.format("%." .. (opts.ndecimal or 0) .. "f", tonumber(v))
		end
		if opts.suffix then
			v = v .. opts.suffix
		end
		if not opts.included then
			self.Clear()
		end
		self.DrawStringOff(v, 0,0)
if opts.debug then
print(">> Draw", v)
end
		if not opts.included then
			self.Refresh()
elseif opts.debug then
print(">>>> pas de refresh")
		end
if opts.debug then
print(">> fin updtxt", v)
end
	end

	function self.ping()	-- Notify the value has been updated
		if opts.timeout then
			wdcnt = opts.timeout
		end		
	end

	function self.setGradient( g )
		opts.gradient = g
	end

	function self.update( v )	-- Callback when the field has to be updated
if opts.debug then
print("upd", v)
end
		val = v
		if not v then	-- Secure field initialisation
			return
		end

		if opts.gradient then
			self.setColorRGB( opts.gradient.findgradientcolor(v) )
		else
			self.setColor(color)
		end

		self.updtxt( v )
		self.ping()
if opts.debug then
print("fin upd", v)
end
	end

	return self
end
