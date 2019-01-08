-- Field with a backuped background

function FieldBackground(
	psrf,	-- mother surface
	x,y,	-- position in the mother surface
	font,	-- font to use
	color,	-- initial foreground color
	opts 	-- See Field for known options
)
--[[ known options  :
--]]

	local self = Field( psrf, x,y, font, color, opts )

	local back
	
	function self.KeepBackground()
		back = self.get():clone()
	end

	function self.Clear()
		self.get():restore(back)
	end

	self.KeepBackground()

	return self
end
