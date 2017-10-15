-- Field with a backuped background and border around texts

function FieldBackBorder(
	psrf,	-- mother surface
	x,y,	-- position in the mother surface
	font,	-- font to use
	color,	-- initial foreground color
	opts 	-- See Field for known options
)
--[[ known options  :
--	ndecimal : round to ndecimal
--	keepbackground : don't clear background
--
--	TODO : all Field's need to be implemented
--	(gradient, ...) 
--]]
	if not opts then
		opts = {}
	end

		-- Add some room for the border
	if not opts.width then
		opts.width = font:StringWidth( opts.sample_text ) + 4
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
		if opts.ndecimal then
			v = string.format("%." .. (opts.ndecimal or 0) .. "f", tonumber(v))
		end
		if opts.suffix then
			v = v .. opts.suffix
		end

		if not opts.keepbackground then
			self.Clear()
		end

		-- draw borders
		self.get():SetColor( 0x00, 0x00, 0x00, 0xff)	-- Temporary set to black
		self.DrawStringOff(v, 0,0)
		self.DrawStringOff(v, 0,4)
		self.DrawStringOff(v, 4,0)
		self.DrawStringOff(v, 4,4)

		self.ColorApply()	-- Draw at requested color
		self.DrawStringOff(v, 1,1)

		self.refresh()

		if opts.timeout then
			self.wdcnt = opts.timeout
		end
	end

	return self
end
