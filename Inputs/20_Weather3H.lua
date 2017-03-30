-- Short term weather

function Weather3H(
	topic,
	city,
	time, -- time offset
	opts
)
--[[ known options  :
--]]

	if not opts then
		opts = {}
	end

	local self = MQTTinput( city..'3H'..time, topic ..'/'.. city ..'/'.. time ..'/time')
	local icn = MQTTinput( city..'3H'..time..'acode', topic ..'/'.. city ..'/'.. time ..'/acode')
	local desc = MQTTinput( city..'3H'..time..'desc', topic ..'/'.. city ..'/'.. time ..'/description')
	local temp = MQTTinput( city..'3H'..time..'temp', topic ..'/'.. city ..'/'.. time ..'/temperature')
	local wspd = MQTTinput( city..'3H'..time..'wspd', topic ..'/'.. city ..'/'.. time ..'/wind/speed')
	local wdir = MQTTinput( city..'3H'..time..'wdir', topic ..'/'.. city ..'/'.. time ..'/wind/direction')
	local clouds = MQTTinput( city..'3H'..time..'clouds', topic ..'/'.. city ..'/'.. time ..'/clouds')
	local humidity = MQTTinput( city..'3H'..time..'humidity', topic ..'/'.. city ..'/'.. time ..'/humidity')

	function self.update()
print( city ..':' .. self.get() )
	end

	self.TaskOnceAdd( self.update )
	icn.TaskOnceAdd( self.update )
	desc.TaskOnceAdd( self.update )
	temp.TaskOnceAdd( self.update )
	wspd.TaskOnceAdd( self.update )
	wdir.TaskOnceAdd( self.update )
	clouds.TaskOnceAdd( self.update )
	humidity.TaskOnceAdd( self.update )

	return self
end
