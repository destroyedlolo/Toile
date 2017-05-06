-- Handle popup menu

function PopUp(
	winparams,		-- window's parameters
	opts
)
--[[ known options :
--	opacity : window's opacity
--	bgcolor : background color (default = COL_BLACK)
--	bordercolor : color for window's border (default = COL_GREY)
--	keysactions : Active keys actions table
--	mykeysactions : Actions to apply to this popup (keysactions must be present)
--]]
	if not opts then
		opts = {}
	end
	if not opts.opacity then
		opts.opacity = 0xff
	end
	if not opts.bgcolor then
		opts.bgcolor = COL_BLACK
	end
	if not opts.bordercolor then
		opts.bordercolor = COL_GREY
	end
	if opts.mykeysactions then
		assert( opts.keysactions, "keysactions MUST be present if mykeysactions is used" )
	end

	self = {}

	local window = layer:CreateWindow(winparams)
	window:SetOpacity(0xff)	-- Make the window visible
	local wsrf = window:GetSurface()
	local w,h = wsrf:GetSize()

		-- Draw borders
	wsrf:Clear( opts.bgcolor.get() )
	wsrf:SetColor( opts.bordercolor.get() )
	wsrf:DrawRectangle(0,0, w,h)
	wsrf:Flip(SelSurface.FlipFlagsConst("NONE"))

		-- manage keysactions
	if opts.mykeysactions then
		local oldKA = opts.keysactions
		opts.keysactions = opts.mykeysactions
	end

	function self.get()
		return wsrf
	end

	function self.close()
		if opts.mykeysactions then
			opts.keysactions = oldKA
		end
		window:Release()
	end

	return self
end
