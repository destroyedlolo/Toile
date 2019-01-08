-- Field that blink when a new value is received

function Blink(
	self,	-- Base field
	animTimer, -- Timer to use to animate the display
	color	-- initial foreground color
)
	-- Backup of parent functions
	local parent_update = self.update
	local parent_setColor = self.setColor
	local parent_setColorRGB = self.setColorRGB

	local val -- value to display
	local cur_r,cur_g,cur_b,cur_a -- Current color
	local cons_r,cons_g,cons_b,cons_a -- Consign color
	local fading = false -- are we fading

	local function fade()
		cur_r = math.max( cons_r, cur_r - 20 )
		cur_g = math.max( cons_g, cur_g - 20 )
		cur_b = math.max( cons_b, cur_b - 20 )
		cur_a = math.max( cons_a, cur_a - 20 )

		if cur_r - cons_r + cur_g - cons_g + cur_b - cons_b + cur_a - cons_a ~= 0 then	-- Fading
			parent_setColorRGB( cur_r, cur_g, cur_b, cur_a )
		else
			parent_setColorRGB( cons_r, cons_g, cons_b, cons_a )
			animTimer.TaskOnceRemove( fade )
			fading = false
		end

		self.updtxt( val )
	end

	-- Overloading
	function self.setColor( color )
		cons_r,cons_g,cons_b,cons_a = color.get()
		if fading == false then
			parent_setColor( color )
		end
	end

	function self.setColorRGB( r,g,b,a )
		cons_r,cons_g,cons_b,cons_a = r,g,b,a
		if fading == false then
			parent_setColorRGB( r,g,b,a )
		end
	end

	function self.update( v, keep )
		if keep == true then	-- Only refresh a subsurface
			self.updtxt(v)
			return
		end
			
		cur_r,cur_g,cur_b,cur_a = COL_WHITE.get()
		val = v
		parent_setColorRGB( cur_r,cur_g,cur_b,cur_a )
		parent_update(v)

		fading = true
		animTimer.TaskOnceAdd( fade )
	end

	-- initialisation
	self.setColor(color) -- because the constructor one hasn't been saved

	return self
end
