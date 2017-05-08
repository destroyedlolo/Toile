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
		-- Caution, overwriten in Menu
	opts.bgcolor = opts.bgcolor or COL_BLACK
	opts.unselcolor = opts.unselcolor or COL_LIGHTGREY
	opts.selcolor = opts.selcolor or COL_WHITE	

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
			self.SmartCR()
		end
	end

		-- Manage selection
	function self.selprev()
		if selected > 1 then
			selected = selected - 1
		end
		self.Update()
	end

	function self.selnext()
		if selected < #list then
			selected = selected + 1
		end
		self.Update()
	end

	self.Update()
	return self
end
