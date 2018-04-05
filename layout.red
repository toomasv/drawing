Red []
context [
	env: self
	canvas: none
	tab-pan: drawing-panel-tab: animations: none
	info-panel: edit-options-panel: options-panel: drawing-panel: figs-panel: anim-panel: none
	layer: layer1: drawing: selection-layer: grid-layer: drawing-layer: edit-layer: none
	win: layout/options compose/deep [
		title "Drawing pad"
		size 520x425 
		tab-pan: tab-panel  [
			"Drawing" [;backdrop rebolor 
				across 
				info-panel: panel 500x25 gold [origin 0x0 space 4x0]
				return 
				edit-options-panel: panel 500x25 brick [origin 0x0 space 4x0]
				return
				options-panel: panel 80x300 water [origin 0x0 space 0x0]
				drawing-panel: panel 300x300 snow [
					origin 0x0 space 0x0
					style layer: box glass ;draw []
					style drawing: base glass 300x300
					layer1: layer ;255.255.255.0
					do [env/canvas: layer1]
					at 0x0 selection-layer: box hidden
					at 0x0 grid-layer: box hidden
					at 0x0 drawing-layer: drawing ;transparent
					at 0x0 edit-layer: base 300x300 transparent hidden
				]
				figs-panel: panel 100x300 beige []
				return
				at 100x390 anim-panel: panel 300x25 crimson [origin 0x0 space 4x0]
			] 
			"Animation" [origin 0x0 space 0x0
				animations: area 500x405
			]
		]
		do [
			drawing-panel-tab: pane/1/pane/1 
			animations-panel-tab: pane/1/pane/2
		]
	][
		actors: object [
			on-resizing: func [face event][
				tab-pan/size: win/size - 20;x17
				foreach tab tab-pan/pane [
					tab/offset: tab/parent/offset + 2x24
					tab/size: tab/parent/size - 5x27
				]
				info-panel/size/x: info-panel/parent/size/x - info-panel/offset/x - 10
				edit-options-panel/size/x: edit-options-panel/parent/size/x - edit-options-panel/offset/x - 10
				options-panel/size/y: options-panel/parent/size/y - options-panel/offset/y - 10
				drawing-panel/size: drawing-panel/parent/size - drawing-panel/offset - 120x45
				foreach-face drawing-panel [face/size: drawing-panel/size]
				canvas/size: drawing-panel/size ; grid-layer/size: selection-layer/size: drawing-layer/size: 
				;poke grid-layer/draw length? grid-layer/draw canvas/size
				figs-panel/offset/x: figs-panel/parent/size/x - 110
				figs-panel/size/y: figs-panel/parent/size/y - figs-panel/offset/y - 10
				;figs1/size/y: figs-panel/size/y
				anim-panel/offset/x: drawing-panel/offset/x 
				anim-panel/offset/y: anim-panel/parent/size/y - 35
				anim-panel/size/x: drawing-panel/size/x
				animations/size: animations/parent/size - 1x0
				;show win 
			]
		]
	]
	view/flags win [resize]
	;view win
]						
						
