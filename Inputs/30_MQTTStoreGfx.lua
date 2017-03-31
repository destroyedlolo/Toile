-- Receive an MQTT data and trace it

function MQTTStoreGfx(
	name, topic,
	srf,	-- surface to display the value
	sgfx,	-- surface to display the graphic
	smax,	-- surface to display the maximum
	opts
)
--[[ known options  :
--	suffix : string to add to the value (i.e. : unit)
--	forced_min : force the minimum value to display
--
--	+ options supported by MQTTinput
--]]
	if not opts then
		opts = {}
	end

	local dt = SelCollection.create( sgfx.get():GetWidth() )
	local ansmax

	local self = MQTTDisplay( name, topic, srf, opts )

	local function adddt( )
		local v = self.get()	-- Retrieve last arrived data
		dt:Push(v)
	end

	local function updgfx()
		sgfx.DrawGfx(dt, opts.forced_min)
		SelShared.PushTask( sgfx.refresh, SelShared.TaskOnceConst("LAST") )
	end

	local function updmax()
		local _,max = dt:MinMax()
		if not ansmax or max ~= ansmax then
			smax.update( max )
			ansmax = max
		end
	end

	self.TaskOnceAdd( adddt )
	self.TaskOnceAdd( updgfx )
	self.TaskOnceAdd( updmax )

	return self
end
