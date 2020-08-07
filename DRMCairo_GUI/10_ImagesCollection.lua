-- Manage collection of images

function ImagesCollection(
	dir,	-- Where images can be found
	opts
)
--[[ known options  :
--]]

	if not opts then
		opts = {}
	end

	local self = {}
	local Imgs = {}

	function self.getImg( id )	-- Get one image for the collection
		if not Imgs[ id ] then -- not yet loaded
			local t,err = SelDCSurfaceImage.createFromPNG( dir .. id .. '.png' )
			if not t then
				error(dir .. id .. '.png : ' .. err)
			end
			Imgs[ id ] = t
		end
		return Imgs[ id ]
	end

	return self
end

