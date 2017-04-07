-- Short term weather

function Weather3H(
	dsp,	-- Where to display
	topic,
	city,
	time,	-- time offset
	opts
)
--[[ known options  :
--]]

	if not opts then
		opts = {}
	end

	local self = MQTTinput( city..'3H'..time, topic ..'/'.. city ..'/'.. time ..'/time')
	local icn = MQTTinput( city..'3H'..time..'acode', topic ..'/'.. city ..'/'.. time ..'/weather/acode')
	if dsp.desc then
		MQTTDisplay( city..'3H'..time..'desc', topic ..'/'.. city ..'/'.. time ..'/weather/description', dsp.desc)
	end
	if dsp.temp then
		MQTTDisplay( city..'3H'..time..'temp', topic ..'/'.. city ..'/'.. time ..'/temperature', dsp.temp )
	end
	if dsp.windspeed then
		MQTTDisplay( city..'3H'..time..'wspd', topic ..'/'.. city ..'/'.. time ..'/wind/speed', dsp.windspeed, { align = ALIGN_RIGHT } )
	end
	if dsp.windd then
print('avant')
		MQTTDisplay( city..'3H'..time..'wdir', topic ..'/'.. city ..'/'.. time ..'/wind/direction', dsp.windd)
print('apres')
	end
	if dsp.clouds then
		MQTTDisplay( city..'3H'..time..'clouds', topic ..'/'.. city ..'/'.. time ..'/clouds', dsp.clouds)
	end
	if dsp.humidity then
		MQTTDisplay( city..'3H'..time..'humidity', topic ..'/'.. city ..'/'.. time ..'/humidity', dsp.humidity)
	end

	dsp.setName( city..'3H'..time )
	
	self.TaskOnceAdd( dsp.updTime )
	icn.TaskOnceAdd( dsp.updateIcon )

	return self
end
