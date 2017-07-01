-- Generic class to handle incoming logs

function _MQTTLog(aname, atpc,	-- 1st topic
	srf,	-- where to display, must have a method Display(txt,user_dt)
	opts)
--[[ known options :
--]]
	local fifo = SelFIFO.Create(aname)

	local pushmsg	-- early defintion for callback function
	local self = MQTTinput(aname, atpc, 
		function (t,m) pushmsg(t,m); return true end, -- call the callback defined afterward
	opts)

	function self.fifoname()	-- function to be redefined to declare topic name
		return nil -- name of this fifo
	end

	function self.topic2udata()	-- function to be redefined to lookup userdata from a topic
		return nil	-- lookup table to get user data for a topic
	end	

	pushmsg = function (topic, data)
		local fifo = SelFIFO.Find(self.fifoname())
		SelFIFO.Push2FIFO(fifo, data, self.topic2udata(topic))
	end

	local function display()
		while true do
			local t,f = fifo:Pop()
			if not t then break end
			srf.Display( t,f )
		end
	end

	self.TaskOnceAdd( display )

	return self
end

function MQTTLog( aname, atpc,	-- 1st topic
	srf, -- where to display
	opts )
--[[ known options :
		udata = userdata for provided atpc (default : 0)
--]]
	if not opts then
		opts = {}
	end

	local t2u = {}	-- Lookup table b/w topic and userdata
	t2u[ atpc ] = opts.udata or 0

	local self = _MQTTLog(aname, atpc, srf, opts )

	function self.fifoname()
		return aname
	end

	function self.topic2udata(t)
		return t2u[t]
	end

	return self
end
