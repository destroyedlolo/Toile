-- Manage FAI data

function FAIdata( name,
	TCapacity,	-- line capacity
	TTV,		-- TV consumption
	TInternet,	-- Internet consumption
	srf,		-- Surface to display the capacity
	gauge,		-- gauge to display the usage
	opts
)
--[[ known options  :
--]]

	if not opts then
		opts = {}
	end

	local self = MQTTinput( name, TCapacity )
	local tv = MQTTinput( name .. 'TV', TTV )
	local internet = MQTTinput( name .. 'Int', TInternet )

	function self.update()
		local vcap = self.get()
		local vtv = tv.get()
		local vint = internet.get()

		if vcap then
			srf.update( vcap )
		end

		if vcap and vtv and vint then
			gauge.update( vcap, vtv, vint )
		end
	end

	self.TaskOnceAdd( self.update )
	tv.TaskOnceAdd( self.update )
	internet.TaskOnceAdd( self.update )

	return self
end
