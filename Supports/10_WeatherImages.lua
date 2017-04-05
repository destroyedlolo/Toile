-- Manage weather's images

function WeatherImages(
	dir,
	opts
)
--[[ known options  :
--]]

	if not opts then
		opts = {}
	end

	local self = {}
	local WeatherImg = {}

	function self.getImg( id )
		if not WeatherImg[ id ] then
			WeatherImg[ id ] = SelImage.create( dir .. id .. '.png' )
		end
		return WeatherImg[ id ]
	end

	return self
end

