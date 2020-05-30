-- Surfaces are off screen playground.
-- Drawing are done to it w/o impacting the real display in order to avoid
-- flickering during graphical operation.

function Surface( 
	primary_surface,	-- Physical screen
	srf_x, srf_y,		-- top left position
	srf_w, srf_h		-- size
)

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

	function self.Refresh()
		-- refresh content to the parent surface

		if displayed then	-- only if the surface is displayed
			primary_surface:Blit( self.get(), srf_x, srf_y )
		end
	end

	function self.Visibility( putonscreen )
		-- Change the visibility of this surface
		-- -> has to be put on screen
		-- if the surface goes to the screen, it is refreshed

		if displayed == false then	-- otherwise, already on screen : no refresh
			displayed = putonscreen
			if putonscreen then
				self.Refresh()
			end
		else
			displayed = putonscreen
		end
	end

	return self
end
