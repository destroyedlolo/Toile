-- Manage collection of images

function ImagesCollection(
	dir,	-- Where images can be found
	opts
)
--[[ known options  :
--	transparent : handle transparency
--]]

	if not opts then
		opts = {}
	end

	local self = {}
	local Imgs = {}

	function self.getImg( id )	-- Get one image for the collection
		if not Imgs[ id ] then	-- not yet loaded
			local t,err = SelImage.create( dir .. id .. '.png' )
			if not t then
				error(dir .. id .. '.png : ' .. err)
			end
			if not opts.transparent then
				Imgs[ id ] = t
			else
				Imgs[ id ] = t:toSurface()
				t:destroy()
			end
		end
		return Imgs[ id ]
	end

	function self.getTransparency()
		return opts.transparent
	end
		
	return self
end

