-- Field that blink when a new value is received

function FieldBlink(
	psrf,	-- mother surface
	animTimer, -- Timer to use to animate the display
	x,y,	-- position in the mother surface
	font,	-- font to use
	color,	-- initial foreground color
	opts 	-- See Field for known options
)
	local self = Field( psrf, x,y, font, color, opts )

	return Blink( self, animTimer, color )
end
