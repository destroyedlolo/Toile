-- Receive an MQTT data and trace it

function MQTTStoreGfx(
	name, topic,
	srf,	-- surface to display the value (may be nil)
	sgfx,	-- surface to display the graphic (may be nil, opts.width must be provided)
	opts
)
--[[ known options  :
--	+ options supported by StoreGfx
--	+ options supported by MQTTinput
--
-- Notez-bien : if sgfx is not provided, it means a "reduced" graphical layer is used (like OLed one) which is not able to handle layers.
-- Consequently, some options (auto-redraw, min/max automatic update, ...) are disabled
--]]
	if not opts then
		opts = {}
	end

--[[
	local dt
	if not opts.width then
		opts.width = sgfx.get():GetWidth()
	end

	if opts.group then
		dt = SelTimedWindowCollection.Create( name, opts.width, opts.group )
	else
		dt = SelTimedCollection.Create( name, opts.width )
	end
	local ansmax, ansmin
]]

	local self = MQTTDisplay( name, topic, srf, opts )
	local strgfx = StoreGfx( sgfx, opts )

		-- Merge objects
	for k,v in pairs(strgfx) do self[k] = v end

	local function adddt( )
		local v = tonumber(self.get())	-- Retrieve last arrived data
		self.adddtv(v)
	end

	function self.getName()
		return name
	end

	function self.getOpts()
		return opts
	end

	self.TaskOnceAdd( adddt )

	if opts.smax or opts.smin then
		self.TaskOnceAdd( self.updmaxmin )
	end

		-- Refresh is done at the very end in case of overlaping surfaces
	if sgfx then	-- Only if a gfx surface is provided
		self.TaskOnceAdd( sgfx.Refresh )
	end

	return self
end
