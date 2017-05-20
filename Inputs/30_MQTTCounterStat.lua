-- Receive montly counter statistics
--[[ Format (as per /companions/PubCompteurs)
	Counter,year,month,value
consomation_HC,2017,05,207158
consomation_HP,2017,05,209223
production_BASE,2017,05,86780
consomation_HC,2017,04,420013
consomation_HP,2017,04,471851
production_BASE,2017,04,232737
consomation_HC,2017,03,450019
consomation_HP,2017,03,530525
production_BASE,2017,03,158005
consomation_HC,2017,02,650072
consomation_HP,2017,02,790182
production_BASE,2017,02,121320
]]

function MQTTCounterStat(
	name, topic,
	opts
)
--[[ known options  :
--
--]]
	if not opts then
		opts = {}
	end

	local self = MQTTinput(name, topic)
	local dt = {}

	function self.load( sdt )	-- load from a string
		dt = {}

		for l in (sdt.."\n"):gmatch"(.-)\n" do
			local name, year, month, val = string.match( l, '([%w%_]+),(%d+),(%d+),(%d+)')
			if val then
				if not dt[year] then
					dt[year] = {}
				end
				if not dt[year][month] then
					dt[year][month]={}
				end
				dt[year][month][name] = val
			end
		end
	end

	local function rcvdt()
		self.load( SelShared.get(name) )
	end
	self.TaskOnceAdd( rcvdt )

	return self
end
