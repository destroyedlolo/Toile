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
--	default : default selected value (default = 1st one)
--	userdata : object to be passed to each and every action functions
--]]
	if not opts then
		opts = {}
	end
		-- Caution, overwriten in Menu
	opts.bgcolor = opts.bgcolor or COL_BLACK
	opts.unselcolor = opts.unselcolor or COL_LIGHTGREY
	opts.selcolor = opts.selcolor or COL_WHITE	

	local selected = 1	-- selected entry
	if opts.default then
		for i,v in ipairs( list ) do
			if v[1] == opts.default then
				selected = i
			end
		end
	end

	local self = TextArea( prt.get(),
		x,y, w, font:GetHeight() * #list,
		font,
		opts.unselcolor,
		opts
	)

	function self.Update()
		self.Clear()
		for i,v in ipairs( list ) do
			if i ~= 1 then
				self.CR()
			end
			if i == selected then
				self.setColor( opts.selcolor )
			else
				self.setColor( opts.unselcolor )
			end
			self.DrawString( v[1] )
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

	function self.action()
		if list[selected][2] then
			list[selected][2]( prt )
		end
	end

	self.Update()
	return self
end

