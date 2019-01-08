-- Init the screen

DirectFB.init( DirectFB.CooperativeConst('NORMAL') )
layer = SelLayer.GetLayer(0)	-- Get primary layer
layer:SetCooperativeLevel( SelLayer.CooperativeLevelConst('ADMINISTRATIVE') )
psrf = layer:GetSurface()
psrf:Clear( COL_BLACK.get() )

