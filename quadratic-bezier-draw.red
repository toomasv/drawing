draw [matrix [1.0 0 0 1.0 0 0]
polygon1: polygon 30x310 100x110 320x310
line-width 2
group1: [
line1: push [
pen green
line 30x310 100x110
]
circle1: push [
pen green circle 30x310 3
]
circle2: push [
pen green circle 100x110 3
]
circle3: push [
fill-pen papaya
pen papaya
circle 30x310 3
]
]
curve1: push [
pen papaya
line-width 3
curve 30x310 30x310 30x310
]
line-width 1
] animations {
tick: tick % 100
curve1/2/7: circle1/2/4: line1/2/4: tick / 100.0 * (polygon1/3 - polygon1/2) + polygon1/2
circle2/2/4: line1/2/5: tick / 100.0 * (polygon1/4 - polygon1/3) + polygon1/3
curve1/2/8: circle3/2/6: tick / 100.0 * (line1/2/5 - line1/2/4) + line1/2/4
} 
