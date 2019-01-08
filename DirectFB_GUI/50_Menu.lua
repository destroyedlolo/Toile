-- Create a menu

function Menu(
	winparams,	-- window's parameters
	list,		-- list of entries
	font,		-- Items' font
	opts
)
--[[ known options :
--	bgcolor : background color (default = COL_BLACK)
--
--	title : title to display
--	titlefont : font for the title (default = font)
--	titlecolor (default = unselcolor)
--
--	unselcolor : color for unselected entries (default = COL_LIGHTGREY)
--	selcolor :  color for selected entry (default = COL_WHITE)
--	default : default selected item (default = 1)
--
--	bordercolor : color for window's border (default = COL_GREY)
--	keysactions : name of the Active KeysActions table
--]]
	if not opts then
		opts = {}
	end
	opts.bgcolor = opts.bgcolor or COL_BLACK
	opts.unselcolor = opts.unselcolor or COL_LIGHTGREY
	opts.selcolor = opts.selcolor or COL_WHITE

	opts.titlecolor = opts.titlecolor or opts.selcolor

	local w,h = 0,0	-- computed size
	local offy = 0	-- where to display the menu
	if opts.title then
		opts.titlefont = opts.titlefont or font
		w = math.max( w, opts.titlefont:StringWidth( opts.title ) )
		h = h + opts.titlefont:GetHeight() + 15

		offy = h
	end
	for i,v in ipairs( list ) do
		w = math.max( w, font:StringWidth(v[1]) )
		h = h + font:GetHeight()
	end

	if not winparams.size then	-- compute size if not provided
		winparams.size = { w+6, h+6 }
	end

	local popup = PopUp( winparams, opts )

	-- Draw the title
	if opts.title then
		popup.setColor( opts.titlecolor )
		popup.get():SetFont( opts.titlefont )
		popup.get():DrawString( opts.title, 0,0 )
		popup.refresh()
	end

	-- Items list
	local self = vsList( popup, 0, offy, w, list, font, opts )

	self.setKeysActions = popup.setKeysActions
	self.close = popup.close
	
	function self.getContenaire()
		return popup
	end

	return self
end

