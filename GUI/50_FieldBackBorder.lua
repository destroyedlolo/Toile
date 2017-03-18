-- Field with a backuped background and border around texts

function FieldBackBorder(
	psrf,	-- mother surface
	x,y,	-- position in the mother surface
	font,	-- font to use
	color,	-- initial foreground color
	opts 	-- See Field for known options
)
	if not opts then
		opts = {}
	end

		-- Add some room for the border
	if not opts.width then
		opts.width = font:StringWidth( ctxt ) + 4
	else
		opts.width = opts.width + 4
	end
	if not opts.height then
		opts.height = font:GetHeight() + 4
	else
		opts.height = opts.height + 4
	end

	local self = FieldBackground( psrf, x-2,y-2, font, color, opts )

	function self.update(v)
		self.Clear()

		-- draw borders
		self.get():SetColor( 0x00, 0x00, 0x00, 0xff)	-- Temporary set to black
		self.DrawStringOff(v, 0,0)
		self.DrawStringOff(v, 0,4)
		self.DrawStringOff(v, 4,0)
		self.DrawStringOff(v, 4,4)

		self.ColorApply()	-- Draw at requested color
		self.DrawStringOff(v, 1,1)

		self.refresh()
	end

	return self
end
