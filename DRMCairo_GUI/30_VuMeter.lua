-- classical vertical vumeter

function VuMeter(
	psrf,	-- mother surface
	sx,sy,	-- position
	sw,sh,	-- size
	color,	-- initial foreground color
	minv, mina,	-- Minimum value and angle
	maxv, maxa,	-- maximum value and angle
	opts
)
--[[ known options :
--  ox, oy		-- needle origin (size/2 by default)
--  length		-- needle length (size/2 by default)
--	bgcolor		-- background color (by default : black ; false : no clearing )
--	gradient 	-- gradient color
--	timeout		-- clear if no data received
--]]
	if not opts then
		opts = {}
	end

	if not opts.bgcolor and opts.bgcolor ~= false then
		opts.bgcolor = COL_BLACK
	end

	if not opts.ox then
		opts.ox = sw/2
	end
	if not opts.oy then
		opts.oy = sh/2
	end

	if not opts.length then
		opts.length = math.min( sw/2, sh/2 )
	end
	local scale = (maxa - mina)/(maxv - minv)

	if opts.timeout then
		wdTimer.TaskOnceAdd(watchdog)
		wdcnt = opts.timeout
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )
	self.setColor( color )

		-- Handle watchdog
	local ans = 0	-- previous value

	local function watchdog()
		if wdcnt > 0 then
			wdcnt = wdcnt - 1
			if wdcnt == 0 then
				if opts.bgcolor then
					self.get():Clear( opts.bgcolor.get() )
				end
			end
		end
	end

	function self.ping()	-- Notify the value has been updated
		if opts.timeout then
			wdcnt = opts.timeout
		end		
	end

	function self.update( v )	-- Callback when the field has to be updated
		if not v then	-- if called from tasks list
			v = SelShared.Get( self.varname )
		end

		if not v then	-- Secure field initialisation
			return
		end

		v = math.max( minv, v )
		v = math.min( maxv, v )

		if val ~= v then
			val = v
			
			self.Clear()

			if opts.gradient then
				self.setColorRGB( opts.gradient.findgradientcolor(v) )
			end

			-- calculate the angle
			v = mina + (v - minv)*scale

			self.get():DrawLine( opts.ox, opts.oy, opts.ox + opts.length*math.sin(v), opts.oy - opts.length*math.cos(v), 3)

			self.Refresh()
		end
	end

	return self
end
