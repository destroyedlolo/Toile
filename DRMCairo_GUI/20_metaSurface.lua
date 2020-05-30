-- metaSurface contains shared methods among *Surface objects

function metaSurface( 
	csrf 	-- Cairo's surface
)
	local self = {}

	----
	-- Fields
	----
	local sr,sg,sb,sa -- stored color

	----
	-- Methods
	----

	function self.get()	-- dummy function, will be overwritten
		return csrf
	end

	function self.setFont( f )	-- set the font
		self.get():SetFont( f.font, f.size )
	end

	function self.ColorApply()	-- Apply stored color
		self.get():SetColor( sr,sg,sb,sa )
	end

	function self.setColor( c )	-- Store color
		sr,sg,sb,sa = c.get()
		self.ColorApply()
	end

	function self.setColorRGB( ar,ag,ab,aa )	-- Store and set color from RGB values
		sr,sg,sb,sa = ar,ag,ab,aa
		self.ColorApply()
	end

	function self.getColorRGB()
		return sr,sg,sb,sa
	end

	return self
end
