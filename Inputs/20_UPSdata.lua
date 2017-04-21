-- Manage UPS inputs

function UPSdata( name, topic, 
	topicnominal,	-- topic for nominal power
	srf,			-- surface to display the value
	gauge,			-- Gauge to display the usage
	opts
)
--[[ known options  :
--	vfunction : validation function
--]]

	if not opts then
		opts = {}
	end

	local self = MQTTinput( name, topic, opts.vfunction, opts )
	local nominal = MQTTinput( name .." nominal", topicnominal)

	function self.update()
		local v = self.get()
		local maxp = tonumber( nominal.get() )

		if maxp then	-- we can calculate the real power
			srf.update( string.format('%3.1f', v*maxp/100))
		else
			srf.update( v .. '%' )
		end

		if gauge then
			gauge.Draw(v)
		end
	end

	-- init
	self.TaskOnceAdd( self.update )

	return self
end
