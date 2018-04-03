draw [matrix [1 0 0 1 15 10] 
circle1: circle 180x170 160.0 
line1: push [pen blue line 20x170 340x170] 
line2: push [pen green line 180x10 180x330] 
ellipse2: push [pen papaya ellipse 60x130 240x80] 
group1: push [
	rotate -46439 180x170 
	rotate 92878 260x170 [
		circle2: circle 260x170 80.0 
		line3: push [
			line-cap round 
			pen mint 
			line-width 8 
			line 180x170 340x170
		] 
		line-width 1 
		circle3: push [
			fill-pen papaya 
			pen papaya 
			circle 299x170 1.0
]]	]	] 
animations {
group1/2/5: tick * 2
group1/2/2: negate tick
}