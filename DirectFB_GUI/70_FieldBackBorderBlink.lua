-- Field with a backuped background and border around texts that blink when a new value is received

function FieldBackBorderBlink(
	psrf,	-- mother surface
	animTimer, -- Timer to use to animate the display
	x,y,	-- position in the mother surface
	font,	-- font to use
	color,	-- initial foreground color
	opts 	-- See Field for known options
)
	local self = FieldBackBorder(psrf, x,y, font, color, opts )
	
	return Blink( self, animTimer, color )
end

