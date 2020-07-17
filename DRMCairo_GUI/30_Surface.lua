-- Surfaces are off screen playground.
-- Drawing are done to it w/o impacting the real display in order to avoid
-- flickering during graphical operation.

function Surface( 
	primary_surface,	-- Physical screen
	srf_x, srf_y,		-- top left position
	srf_w, srf_h,		-- size
	opts
)
--[[ known options  :
--	keepcontent : Don't erase the background when hidded
--		only when primary_surface is a physical surface
--		avoid flictering during page switch
--]]
	if not opts then
		opts = {}
	end

	local self = metaSurface( SelDCSurface.create(srf_w, srf_h) )

	----
	-- Fields
	----

		-- is this surface currently on screen ?
		-- it is initialized as false to force off screen initial drawing
	local displayed = false;

	----
	-- Methods
	----
	
	function self.getPhysical()	-- Return the physical playfield
		return primary_surface
	end
		
	function self.getPos()	-- return the top-left of this surface
		return srf_x, srf_y
	end

	function self.getSize()
		return srf_w, srf_h
	end

	function self.getDisplayed()
		return displayed
	end

	function self.Refresh(
		clipped -- Clipping region
	)
		-- refresh content to the parent surface
		if displayed then	-- only if the surface is displayed
			if type(primary_surface) == "table" then
					-- Determine clipping area
				if clipped then	-- Offset this surface
					clipped[1] = clipped[1]+srf_x
					clipped[2] = clipped[2]+srf_y
				else
					clipped = { srf_x, srf_y, srf_w, srf_h }
				end
				if primary_surface.Clear then
					primary_surface.Clear(clipped)	-- erase bellow
				end
				primary_surface.get():Blit( self.get(), srf_x, srf_y )
				if primary_surface.getDisplayed() then
					primary_surface.Refresh(clipped)
				end
			else
				if clipped then
					clipped[1] = clipped[1]+srf_x
					clipped[2] = clipped[2]+srf_y
					primary_surface:SaveContext()
					primary_surface:SetClipS( unpack(clipped) )
				end
				primary_surface:Blit( self.get(), srf_x, srf_y )
				if clipped then
					primary_surface:RestoreContext()
				end
			end
elseif opts.debug then
print("Surface", "not visible")
		end
	end

	function self.Visibility( putonscreen )
		-- Change the visibility of this surface
		-- -> has to be put on screen
		-- if the surface goes to the screen, it is refreshed

		if displayed == false then	-- currently hidden
			displayed = putonscreen
			if putonscreen then	-- do we have to display it ?
				self.Refresh()
			end
		else	-- currently displayed
			displayed = putonscreen
			if putonscreen == false then -- do we have to hide it ?
				if type(primary_surface) == "table" then
					primary_surface.Clear( {srf_x, srf_y, srf_w, srf_h} )
					primary_surface.Refresh( {srf_x, srf_y, srf_w, srf_h} )
				elseif not opts.keepcontent then	-- a physical surface
					primary_surface:SaveContext()
					primary_surface:SetClipS( srf_x, srf_y, srf_w, srf_h )
					primary_surface:Clear( COL_BLACK.get() )
					primary_surface:RestoreContext()
				end
			end
		end
	end

	return self
end
