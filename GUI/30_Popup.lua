-- Handle popup menu

function PopUp(
	winparams,		-- window's parameters
	opts
)
--[[ known options :
--	opacity : window's opacity
--	bgcolor : background color (default = COL_BLACK)
--	bordercolor : color for window's border (default = COL_GREY)
--	keysactions : name of the Active KeysActions table
--]]
	if not opts then
		opts = {}
	end
	opts.opacity = opts.opacity or 0xff
	opts.bgcolor = opts.bgcolor or COL_BLACK
	opts.bordercolor = opts.bordercolor or COL_GREY
	winparams.stacking =  winparams.stacking or SelWindow.StackingConst('UPPER')

	local window = layer:CreateWindow(winparams)
	window:SetOpacity(opts.opacity)	-- Make the window visible
	local wsrf = window:GetSurface()
	local w,h = wsrf:GetSize()

		-- Draw borders
	wsrf:Clear( opts.bgcolor.get() )
	wsrf:SetColor( opts.bordercolor.get() )
	wsrf:DrawRectangle(0,0, w,h)
	wsrf:Flip(SelSurface.FlipFlagsConst("NONE"))

		-- work area
	local self = SubSurface( wsrf, 3,3, w-6, h-6 )

		-- manage keysactions
	local oldKA
	function self.setKeysActions( myKA )
		assert( opts.keysactions, "keysactions MUST be present if setKeysActions() is used")
		if not oldKA then	-- Save original one
			oldKA = _G[opts.keysactions]
		end
		_G[opts.keysactions] = myKA
	end
		
	function self.close()
		if oldKA then
			_G[opts.keysactions] = oldKA
		end
		window:Release()
	end

	return self
end
