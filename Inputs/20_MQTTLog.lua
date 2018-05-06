-- Generic class to handle incoming logs

--[[
--	logs are stored in a FIFO.
--	Data that have to be shared with the slave thread are stored in a SelShared
--	as bellow :
--	$$name$$<topic> - FIFO's name
--	$$udata$$<topic> - Udata associated with this topic
--]]

function MQTTLog( aname, atpc,	-- 1st topic
	srf, -- where to display
	aopts )
--[[ known options :
		udata = userdata for provided atpc (default : 0)
--]]
	if not aopts then
		aopts = {}
	end
	aopts.udata = aopts.udata or 0

	local fifo = SelFIFO.Create(aname)			-- Create the named fifo

	SelShared.Set("$$udata$$" .. atpc, aopts.udata) -- Share its udata

		-- Function to be launched at message arrival
		-- Stored as shared function as called from both main topic
		-- and additional ones
	local rcvfunc = SelShared.RegisterSharedFunction( 
		function (topic, data)
			local name = SelShared.Get("$$name$$" .. topic)
			local udata = SelShared.Get("$$udata$$" .. topic)

			local fifo = SelFIFO.Find( name )
			SelFIFO.Push2FIFO(fifo, data, udata)

			return true	-- Ensure callbacks are called as well
		end, "MQTTLog rcv function"
	)

		-- "$$name$$" .. atpc will be created by MQTTinput
	local self = MQTTinput(aname, atpc, rcvfunc, opts) -- Register initial topic

	function self.DisplayCallBack()	-- callback to display stored values
		while true do
			local t,f = fifo:Pop()
			if not t then break end
			srf.Display( t,f )
		end
	end
	self.TaskOnceAdd( self.DisplayCallBack )

	function self.RegisterTopic( name, tpc, opts )
--[[ Register an additional topic to this FIFO
	known options :
		udata = userdata for provided atpc (default : 0)
--]]
		if not opts then
			opts = {}
		end
		opts.udata = opts.udata or 0
		opts.taskonce = self.DisplayCallBack

		return MQTTinput( name, tpc, rcvfunc, opts)
	end

	return self
end

--[[ Example usage :

1/ Create the primary message logger

	local log = MQTTLog('marcel', 'Marcel.prod/Log/Information', Notification)

2/ Add another topic to it

	log.RegisterTopic( 'message', 'messages2', { udata=1 } )

--]]

