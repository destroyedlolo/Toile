-- Trace data collection

function StoreGfx(
	name,	-- Name of this collection
	sgfx,	-- surface to display the graphic (may be nil, opts.width must be provided)
	opts
)
--[[ known options  :
--	forced_min : force the minimum value to display
--	force_max_refresh : force refresh even if the max value doesn't change
--	force_min_refresh : force refresh even if the min value doesn't change
--	force_field : force refresh of given field
--		(usefull if Max overlap gfx with 'frozen under')
--	width : width of the gfx surface (mostly useful when sgfx can't be provided as with OLed interface)
--	smax : max surface
--	smin : min surface
--	rangeMin, rangeMax : reject data outside range
--	save_locally : flags to retrieve from local backup (to be handled externaly)
--	group : groups data by 'group' seconds
--	average : number of values in average collection
--	minmax_round ; if set, round the average min/max value (i.e. "%.3f" -> 0.001)
--
--	Mode :
--	------
--
--	example 1 :
--		no group provided	-> store raw data
--		no average provided
--
--		=> use SelTimedCollection
--
--	example 2 :
--		group = 60		-> provide min/max of every minutes (whatever the sample rate)
--		no average provided
--
--		=> use SelTimedWindowCollection
--
--	example 3 :	(providing data come every seconds)
--
--		group = 60		-> average are calculated on minute basis (60 seconds)
--		average = 120	-> store 120 average of minutes so 2 hours
--
--		=> use SelAverageCollection
--
--	NOTEZ-BIEN : if average === true, average is set equal to width
--
--]]
	if not opts then
		opts = {}
	end

	local dt
	if not opts.width then
		opts.width = sgfx.get():GetWidth()
	end

	if not opts.average then
		if opts.group then
			dt = SelTimedWindowCollection.Create(name, opts.width, opts.group)
		else
			dt = SelTimedCollection.Create(name, opts.width)
		end
	else
		if not opts.group then
			error("group option must be provided if opts.average is provided",2)
		end
		if opts.average == true then
			opts.average = opts.width
		end
		dt = SelAverageCollection.Create(name, opts.width, opts.average, opts.group)
	end

	local self = {}
	local ansmax, ansmin

	function self.getCollection()
		return dt
	end

	function self.getLocal()
		return opts.save_locally
	end

	function self.updmaxmin()	-- Update min/max fields
		local min,max
		if sgfx and sgfx.getMode() == 'delta' then
			min,max = dt:DiffMinMax()
			if not min then	-- The collection is still emtpy
				return
			end
		else
			min,max = dt:MinMax()
			if not min then	-- The collection is still emtpy
				return
			end

			if opts.minmax_round then
				if type(opts.minmax_round) == "string" then
					min = tonumber(string.format(opts.minmax_round, min))
					max = tonumber(string.format(opts.minmax_round, max))
				else
					min = math.floor(min)
					max = math.ceil(max)
				end
			end
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

	function self.updgfx()	-- Update graphics
		if sgfx then	-- Only if a gfx surface is provided
			sgfx.DrawGfx(dt, opts.forced_min)
		end
		self.updmaxmin()	-- Update min/max fields
	
		if sgfx then	-- Only if a gfx surface is provided
			sgfx.Refresh()
		end
	
		if opts.force_field then
if opts.debug then
print(opts.debug, "field upd")
end
			opts.force_field.updtxt()
		end

	end

	function self.adddtv( v )
if opts.debug then
print("adddtv", v)
end
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

			-- Submit gfx refreshing tasks
			-- don't do it in this function to avoir race condition
			-- if data are received in too fast way
		Selene.PushTask( self.updgfx, Selene.TaskOnceConst("LAST") )
	end

	return self
end
