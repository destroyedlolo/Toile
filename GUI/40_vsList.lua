-- Very simple choices list

function vsList(
	prt,	-- Parent
	x,y, w,	-- left top corner and width
	list,	-- list to be displayed { label, function to be called }
	font,	-- font to use
	opts
)
--[[ known options :
--	bgcolor : background color (default = COL_BLACK)
--	unselcolor : color for unselected entries (default = COL_LIGHTGREY)
--	selcolor :  color for selected entry (default = COL_WHITE)
--	default : default selected item (default = 1)
--]]
	if not opts then
		opts = {}
	end
	if not opts.bgcolor then
		opts.bgcolor = COL_BLACK
	end
	if not opts.unselcolor then
		opts.unselcolor = COL_LIGHTGREY
	end
	if not opts.selcolor then
		opts.selcolor = COL_WHITE
	end

	local selected = opts.default or 1	-- selected entry

	local self = TextArea( prt.get(),
		x,y, w, font:GetHeight() * #list,
		font,
		opts.unselcolor,
		opts
	)

	function self.Update()
		self.Clear()
		for i,v in ipairs( list ) do
			if i == selected then
				self.setColor( opts.selcolor )
			else
				self.setColor( opts.unselcolor )
			end
			self.DrawString( v[1] )
		end
	end

	self.Update()
	return self
end

