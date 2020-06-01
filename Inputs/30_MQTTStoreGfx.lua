-- Receive an MQTT data and trace it

function MQTTStoreGfx(
	name, topic,
	srf,	-- surface to display the value (may be nil)
	sgfx,	-- surface to display the graphic (may be nil, opts.width must be provided)
	opts
)
--[[ known options  :
--	forced_min : force the minimum value to display
--	force_max_refresh : force refresh even if the max value doesn't change
--		(usefull if Max overlap gfx with 'frozen under')
--	width : width of the gfx surface (mostly useful when sgfx can't be provided as with OLed interface)
--	smax : max surface
--	smin : min surface
--	group : groups data by 'group' seconds
--	rangeMin, rangeMax : reject data outside range
--
--	+ options supported by MQTTinput
--
-- Notez-bien : if sgfx is not provided, it means a "reduced" graphical layer is used (like OLed one) which is not able to handle layers.
-- Consequently, some options (auto-redraw, min/max automatic update, ...) are disabled
--]]
	if not opts then
		opts = {}
	end

	local dt
	if not opts.width then
		opts.width = sgfx.get():GetWidth()
	end

	if opts.group then
		dt = SelTimedWindowCollection.Create( opts.width, opts.group )
	else
		dt = SelTimedCollection.Create( opts.width )
	end
	local ansmax, ansmin

	local self = MQTTDisplay( name, topic, srf, opts )

	local function adddt( )
		local v = tonumber(self.get())	-- Retrieve last arrived data

		if opts.rangeMin then
			if v < opts.rangeMin then
				return;
			end
		end
		if opts.rangeMax then
			if v > opts.rangeMax then
				return;
			end
		end
		dt:Push(v)
	end

	function self.getName()
		return name
	end

	function self.getCollection()
		return dt
	end

	function self.getOpts()
		return opts
	end

	function self.updgfx()
		if sgfx then	-- Only if a gfx surface is provided
			sgfx.DrawGfx(dt, opts.forced_min)
		end
	end

	local function updmaxmin()
		local min,max
		if sgfx and sgfx.getMode() == 'delta' then
			min,max = dt:DiffMinMax()
		else
			min,max = dt:MinMax()
		end

		if opts.smax and (not ansmax or max ~= ansmax or opts.force_max_refresh) then
			opts.smax.update( max, ansmax == max)
			ansmax = max
		end

		if opts.smin and (not ansmin or min ~= ansmin or opts.force_min_refresh) then
			opts.smin.update( min, ansmin == min)
			ansmin = min
		end
	end

	self.TaskOnceAdd( adddt )
	self.TaskOnceAdd( self.updgfx )

	if opts.smax or opts.smin then
		self.TaskOnceAdd( updmaxmin )
	end

		-- Refresh is done at the very end in case of overlaping surfaces
	if sgfx then	-- Only if a gfx surface is provided
		self.TaskOnceAdd( sgfx.Refresh )
	end

	return self
end
