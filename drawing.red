Red [
  Author: "Toomas Vooglaid"
  Last-version: 2018-02-19
]
system/view/auto-sync?: off
ctx: context [
	env: self
	step: 0
	start?: true
	figure: none;'line
	figures: #()
	transparent: 254.254.254 ; ????
	colors: exclude sort extract load help-string tuple! 2 [glass]
	pallette: copy [title "Select color" origin 1x1 space 1x1 style clr: base 15x15]
	x: 0 
	foreach j colors [
		append pallette compose/deep [
			clr (j) 
			on-up [color: (either j = 'transparent ['off][to-lit-word j]) unview]; return 'stop]
		] 
		if (x: x + 1) % 9 = 0 [append pallette 'return]
	] 
	color: black
	select-color: does [view/flags pallette [modal popup]]
	result: none
	write-program: has [result][
		prg-win: view/flags/no-wait [
			title "Program figure" 
			below
			result: area 300x100 
			return
			button "OK" [result: result/text unview]
			button "Cancel" [result: copy "" unview]
		][modal popup resize]
		prg-win/actors: [
			on-resize: func [f e][probe "hi"
				result/size: result/parent/size
				show result
			]
		]
		do-events
		result
	]
	ask-new-name: has [result][view/flags [title "Enter new name" result: field hint "New name" button "OK" [result: result/text unview]][modal popup] result]
	show-warning: func [msg][view/flags compose [title "Warning!" text (msg) button "OK" [unview]][modal popup]]
	action: 'draw
	last-action: none
	img: none
	figs: figs1: figs2: figs3: figs4: none
	sep1: sep2: sep3: none
	selection-start: none
	selection-end: none
	select-figure: func [/pos selected][; returns new `selected` for figs while deleting
		selected: any [selected figs/selected ]
		selected-figure/text: pick figs/data selected
		show selected-figure
		probe "start"
		probe selection-start: find-figure selected ;find img/draw load pick figs/data selected
		either selected = length? figs/data [probe "end"
			probe selection-end: length? selection-start
			either 1 < selected [selected - 1][none]  ;??? Check it!
		][probe "not end"
			probe selection-end: find next selection-start load pick figs/data selected + 1
			selected
		]
	]
	load-figure: func [fig][load pick figs/data fig]; Can be word! or block! (in case it is `pen`, `fill-pen` or `line-width`)
	find-figure: func [selected /tail /local figure found][
		either word? figure: load-figure selected [
			either tail [
				skip find-deep img/draw figure figure-length/pos selected
			][
				find-deep img/draw figure
			]
		][
			either found: find/reverse at figs/data selected form figure [
				n: 1
				while [found: find/reverse found form figure][n: n + 1]
				found: next find img/draw figure
				loop n [found: next find found figure]
				either tail [skip back found length? figure][back found]
			][
				found: find img/draw figure
				either tail [skip found length? figure][found]
			]
		]
	]
	find-deep: func [block needle /local found s][
		unless found: find probe block needle [
			parse block [
				some [to block! s: if (found: find-deep s/1 needle) break | skip]
			]
		]
		found
	]
	offset: func [_1 _2][offset? find-figure _1 find-figure _2]
	first-selected?: does [figs/selected = 1]
	second-selected?: does [figs/selected = 2]
	last-selected?: does [figs/selected = length? figs/data]
	last-but-one-selected?: does [(length? figs/data) = (figs/selected + 1)]
	next-figure: none
	redraw: does [img/draw: img/draw]
	figure-length: func [/pos selected /local figure selection][
		selected: any [selected figs/selected]
		figure: load first selection: at figs/data selected
		any [
			all [word? figure last-selected? selected length? find-figure selected]
			all [word? figure offset selected selected + 1]
			length? figure
		]
	]
	adjust-pens: has [found][
		if found: find/last img/draw 'line-width [pen-width/data: found/2 show pen-width]
		if found: find/last img/draw 'pen 		 [pen-color/color: get found/2 show pen-color]
		if found: find/last img/draw 'fill-pen   [fill-color/color: get found/2 show fill-color]
	]
	join: cap: none
	line-joins: copy []
	foreach join [miter bevel round] [
		append line-joins compose/deep [
			box 20x20 draw [pen gray box 0x0 19x19 pen black line-join (join) anti-alias off line-width 4 line 4x4 15x15 4x15][
				append img/draw [line-join (join)]
				append figs/data form [line-join (join)]
				figs/selected: length? figs/data
				select-figure 
				show figs
			]
		]
	]
	line-caps: copy []
	foreach cap [flat square round] [
		append line-caps compose/deep [
			box 20x20 draw [pen gray box 0x0 19x19 pen black line-cap (cap) anti-alias off line-width 4 line 4x10 15x10][
				append img/draw [line-cap (cap)]
				append figs/data form [line-cap (cap)]
				figs/selected: length? figs/data
				select-figure 
				show figs
			]
		]
	]
	move-in-list: func [to-position][
		;selected: figs/selected
		in-list: at figs/data figs/selected
		switch/default to-position [
			front 		[unless last-selected? 		[move in-list tail in-list]]
			forward 	[unless last-selected? 		[move in-list next in-list]]
			backward 	[unless first-selected? 	[move in-list back in-list]]
			back 		[unless first-selected? 	[move in-list head in-list]]
		][
			move in-list at figs/data to-position
		]

	]
	move-selection: func [to-position][
		switch to-position [
			front [
				unless last-selected? [
					move/part selection-start tail selection-start figure-length
					move-in-list 'front
					figs/selected: length? figs/data
				]
			]
			forward [
				unless last-selected? [;probe "fw"
					move/part selection-start either last-but-one-selected? [
						tail selection-start
					][
						back find-figure/tail figs/selected + 1
					]
					figure-length
					move-in-list 'forward
					figs/selected: figs/selected + 1
				]
			]
			backward [
				unless first-selected? [
					move/part selection-start find-figure figs/selected - 1 figure-length
					move-in-list 'backward
					figs/selected: figs/selected - 1 
				]
			]
			back [
				unless first-selected? [
					move/part selection-start head selection-start probe figure-length
					move-in-list 'back
					figs/selected: 1
				]
			]
			before [
				
			]
		]
		;move-in-list to-position
		select-figure 
		show [figs img] adjust-pens
		probe img/draw
	]
	insert-manipulation: func [type][
		change/part next selection-start 
		append/only copy switch type [
			translate 	[[translate 0x0]]
			scale 		[[scale 1 1]]
			skew		[[skew 0 0]]
			rotate		[[rotate 0 0x0]]
			transform	[[transform 0x0 0 1 1 0x0]]
		]
		copy/part next selection-start selection-end
		selection-end
	]
	new-manipulation: func [type][
		insert-manipulation type
		action: type
		step: 1
	]
	new-transformation: func [type][
		unless 'transform = second selection-start [;first get load-figure figs/selected [
			insert-manipulation 'transform
		]
		action: type
		step: 1
	]
	in-group?: false
	show-group-rule: [
		[['transform | 'translate | 'scale | 'skew | 'rotate] to block! | ahead block!] (in-group?: true) into show-group-rule to end
	|	if (in-group?) collect some [
			s: (probe s) set-word! keep (to-string s/1) | ['line-width | 'fill-pen | 'pen] keep (form copy/part s 2) | skip
		] (in-group?: false)
	]
	show-figs-rule: [
	;	[['transform | 'translate | 'scale | 'skew | 'rotate] to block! | ahead block!] (in-group?: true) into show-group-rule to end
	;|	if (in-group?) 
		collect some [
			s: (probe s) set-word! keep (to-string s/1) | ['line-width | 'fill-pen | 'pen] keep (form copy/part s 2) | skip
		] 
	;	(in-group?: false)
	;]
	]
	get-group-elements: does [] ;???
	remove-transformations: does [
		while [
			find/match [transform translate scale skew] first next selection-start 			
		][
			change/part next selection-start first find selection-start block! find/tail selection-start block!
		]
	]
	unwrap-group: does [
		remove-transformations
		head selection-start
		selection-start/2
	]
	over-xy: over-params: current-drawing: current-action: current-step: none
	recalc-info: has [i p][
		repeat i length? p: info-panel/pane [
			j: i - 1
			if i > 1 [p/:i/offset/x: p/(i - 1)/offset/x + p/(i - 1)/size/x + 5]
			p/:i/size/x: size-text p/:i
		]
		show info-panel
	]
	
	a-rate: none
	tick: 0
	phase: 1
	
	tab-pan: none
	drawing-panel-tab: none
	animations: scenes: none
	info-panel: options-panel: drawing-panel: figs-panel: anim-panel: none
	
	win: layout compose/deep [
		title "Drawing pad"
		size 600x500
		tab-pan: tab-panel  [
			"Drawing" [
				drawing-panel-tab: panel [
					across 
					info-panel: panel 480x20 [origin 0x0 space 4x0
						over-xy: text 10x20
						over-params: text 20x20
						current-action: text 40x20
						current-drawing: text 80x20
						current-step: text 40x20
					]
					return
					edit-panel: panel 480x20 [origin 0x0 space 4x0
						text 50x20 "Selected:" selected-figure: text 80x20 
					]
					return
					;below
					options-panel: panel 80x300 [
						origin 0x0 space 0x0
						style f: button 25x25 [
							env/figure: face/extra 
							start?: true 
							action: 'draw
							step: 0
							current-action/text: form action
							current-drawing/text: form face/extra
							current-step/text: rejoin ["Step: " step]
							recalc-info
						]
						f with [extra: 'line 		image: (draw 23x23 [line 5x5 17x17])]
						f with [extra: 'polyline 	image: (draw 23x23 [line 5x5 8x17 13x5 17x17])]
						f with [extra: 'arc 		image: (draw 23x23 [arc 11x13 6x6 -180 180])]
						return
						f with [extra: 'box 		image: (draw 23x23 [fill-pen snow box 5x7 17x15])]
						f with [extra: 'square 		image: (draw 23x23 [fill-pen snow box 5x5 17x17])]
						f with [extra: 'polygon 	image: (draw 23x23 [fill-pen snow polygon 5x8 11x5 17x8 14x17 8x17])]
						return
						f with [extra: 'ellipse 	image: (draw 23x23 [fill-pen snow ellipse 5x6 13x10])]
						f with [extra: 'circle 		image: (draw 23x23 [fill-pen snow circle 11x11 6])]
						f with [extra: 'sector 		image: (draw 23x23 [fill-pen snow arc 7x11 8x6 -50 100 closed])]
						return
						f with [extra: 'program 
							image: (draw 23x23 [line 5x5 10x5 line 5x7 14x7 line 5x9 10x9 line 5x11 17x11 line 7x13 10x13 line 7x15 12x15 line 5x17 8x17])
						]
						do [current-drawing/text: rejoin ["draw line"] recalc-info]
						return below
						group-box "pen" [
							origin 2x10 space 2x2
							pen-width: field 20x20 "1" [
								append img/draw reduce ['line-width face/data] 
								append figs/data form reduce ['line-width face/data] 
								figs/selected: length? figs/data
								select-figure 
								show figs
							]
							pen-color: base 20x20 black draw [pen gray box 0x0 19x19][
								select-color 
								face/color: get color
								show face  
								append img/draw reduce ['pen color]
								append figs/data form reduce ['pen color]
								figs/selected: length? figs/data
								select-figure 
								show figs
							] 
							return
							(line-joins) 
							return
							(line-caps)
						]
						group-box "fill" [
							fill-color: base 20x20 0.0.0.254 draw [pen gray box 0x0 19x19][
								select-color
								face/color: get color 
								show face
								append img/draw reduce ['fill-pen color]
								append figs/data form reduce ['fill-pen color] 
								figs/selected: length? figs/data
								select-figure 
								show figs
							]
						]
						button "clear" [
							clear img/draw ; this seems somehow to cause error in first drawing after `clear`. Problem appeared after introducing group handling.
							show img

							foreach-face figs-panel [
								clear face/data 
								either face/extra = 'figs1 [
								face/size/y: face/parent/size/y][face/visible?: false]
							] show figs-panel

							foreach key keys-of figures [figures/:key: 0]

							pen-width/data: 1
							pen-color/color: 0.0.0
							fill-color/color: 254.254.254.254
							show [pen-width pen-color fill-color]
							
							action: 'draw figure: 'line
							foreach-face info-panel [clear face/text] 
							current-action/text: "draw" current-drawing/text: "line"
							recalc-info
						]
					]
					;return
					drawing-panel: panel 300x300 [
						origin 0x0 space 0x0
						;img: image 300x300 all-over
						img: base white 300x300 all-over
						;rate 1;none
						draw []
						with [
							actors: object [
								pos1: 0x0
								last-pos: 0x0
								pre-diff: 0x0
								pre-angle: 0
								last-cur-angle: 0
								direction: none
								sector: none
								;fig-start: none
								on-wheel: func [face event][
									switch action [
										draw [
											unless face/draw/1 = 'scale [
												insert face/draw [scale 1 1]
											]
											sign: pick reduce [:+ :-] event/picked = 1
											face/draw/2: face/draw/3: face/draw/2 sign 0.1 
											show face
											;probe reduce [event/offset event/picked]
										]
									]
								]
								on-time: func [face event /local r-center angle scale-x scale-y translate][
									;if all [action = 'animate step = 2 selection-start/2 = 'transform] [
									;	selection-start/4: anim-step: anim-step + 1
									;	show face
									;]
									do bind bind probe load animations self env
									show img
								]
								on-down: func [face event /local code][;probe reduce [figure step pos1]; draw
									pos1: event/offset
									switch action [
										draw [
											case [
												find/match form figure "poly" [
													unless start? [
														env/step: 2
														either last-action = 'insert [
															next-figure: insert next-figure pos1
														][
															append selection-start pos1
														]
													]
												]
												find [arc sector] figure [
													if step = 1 [env/step: 2]
													if step = 3 [env/step: 0 start?: true]
												]
												figure = 'program [
													unless empty? code: write-program [
														if start? [
															either figures/:figure [
																figures/:figure: figures/:figure + 1
															][
																figures/:figure: 1
															]
															ff: rejoin [figure figures/:figure]
															either last-action = 'insert [
																insert figs/data ff
															][
																append figs/data ff 
																figs/selected: length? figs/data 
															]
															show figs
															selected-figure/text: ff 
															show selected-figure
															either last-action = 'insert [
																insert next-figure reduce [
																	to-set-word ff do bind bind load code self env
																]
															][
																append selection-start reduce [
																	to-set-word ff do bind bind load code self env
																] 
															]
															select-figure
															redraw
															start?: false 
															show img
														]
													]
												]
												'else [
													start?: true
												]
											]
										]
										translate [
											switch step [
												1 [	pos1: event/offset]
												2 [
													insert-manipulation action
													pos1: event/offset
												]
											]
											env/step: 2
										]
										scale [
											switch step [
												1 [	pos1: event/offset]
												2 [
													insert-manipulation action
													pos1: event/offset
												]
											]
											env/step: 2
										]
										skew [
											switch step [
												1 [	pos1: event/offset]
												2 [
													insert-manipulation action
													pos1: event/offset
												]
											]
											env/step: 2
										]
										rotate [
											switch step [
												1 [	pos1: selection-start/4: event/offset]
												2 [
													insert-manipulation action
													pos1: selection-start/4: event/offset
												]
											]
											env/step: 2
										]
										t-rotate [
											if step = 1 [pos1: selection-start/3: event/offset]
											env/step: 2
										]
										t-scale [
											if step = 1 [pos1: event/offset]
											env/step: 2
										]
										t-translate [
											switch step [
												1 [pos1: event/offset]
												2 [
													pre-diff: pos1 - event/offset + selection-start/7
													pos1: event/offset
												]
											]
											env/step: 2
										]
										;animate [
											;if all [selection-start/2 = 'transform][
											;	probe selection-start/3: event/offset ; For rotation
											;	pos1: event/offset 
												;probe img/rate: 10
											;]
											;env/step: 2 
										;] 
									]
								]
								on-over: func [face event /local mx pos2 draw-form ff i j pnum diff diff2][;pos
									over-xy/text: rejoin ["x: " event/offset/x " y: " event/offset/y]
									recalc-info
									;show info-panel;over-xy
									if all [event/down? figure <> 'program] [
										either start? [
											unless figure [figure: 'line]
											draw-form: switch/default figure [
												square 	 	['box] 
												polyline 	['line]
												sector		['arc]
											][figure]
											
											; Synchronize figs list --->
											either figures/:figure [
												figures/:figure: figures/:figure + 1
											][
												figures/:figure: 1
											]
											ff: rejoin [figure figures/:figure]
											either last-action = 'insert [
												insert at figs/data figs/selected ff
												;figs/selected: figs/selected
											][
												append figs/data ff
												figs/selected: length? figs/data 
											]
											show figs
											;<--- figs
											selected-figure/text: ff 
											show selected-figure
											
											;put-to: pick [:insert][:append] last-action = 'insert
											either last-action = 'insert [
												probe next-figure: insert next-figure reduce [
													to-set-word ff 
														draw-form pos1 switch/default figure [
															ellipse [0x0]
															circle  [0]
															polygon [env/step: 1 pos1]
															arc	or sector [env/step: 1 0x0]
														][pos1]
												]
												;select-figure
											][
												append selection-start reduce [
													to-set-word ff 
														draw-form pos1 switch/default figure [
															ellipse [0x0]
															circle  [0]
															polygon [env/step: 1 pos1]
															arc	or sector [env/step: 1 0x0]
														][pos1]
												]
											]
											either last-action = 'insert [
												switch figure [
													;next-figure: find-figure figs/selected + 1
													polygon [next-figure: insert next-figure pos1]
													arc		[next-figure: insert next-figure [180 1]]; fig-start: skip tail selection-start -5]
													sector	[next-figure: insert next-figure [180 1 closed]]; fig-start: skip tail selection-start -6]
												]
											][
												switch figure [
													polygon [append selection-start pos1]
													arc		[append selection-start [180 1]]; fig-start: skip tail selection-start -5]
													sector	[append selection-start [180 1 closed]]; fig-start: skip tail selection-start -6]
												]
											]
											if find [arc sector] figure [
												select-figure
												insert-manipulation 'rotate
												selection-start/4: pos1
												direction: 'cw
												sector: 'positive
											]
											start?: false
										][	
											pos2: event/offset
											diff: pos2 - pos1
											ang: 180 / pi * arctangent2 diff/y diff/x
											hyp: sqrt add diff/x ** 2 diff/y ** 2
											over-params/text: rejoin ["d: " diff " r: " round/to hyp .1 " α: " round/to ang .1]
											recalc-info
											switch action [
												draw [;probe event/flags
													;if event/ctrl? [pos2 - pos1]
													case [
														all [figure = 'polygon step = 1][; triangle?
															either last-action = 'insert [
																poke selection-start subtract offset? selection-start next-figure 1 pos2
																poke selection-start offset? selection-start next-figure pos2
															][
																poke selection-start subtract length? selection-start 1 pos2
																poke selection-start length? selection-start pos2
															]
														]
														find [arc sector] figure [
															switch step [
																1 [
																	pre-angle: 180 + round/to 180 / pi * arctangent2  diff/y diff/x 1 ; 
																	selection-start/3: 180 + round/to 180 / pi * arctangent2  diff/y diff/x 1
																	last-cur-angle: 180 + round/to 180 / pi * arctangent2  diff/y diff/x 1
																	selection-start/5/3: as-pair i: sqrt add power diff/x 2 power diff/y 2 i
																]
																2 [	
																	diff: event/offset - last-pos
																	cur-angle: round/to 180 / pi * arctangent2 diff/y diff/x 1
																	diff2: cur-angle - pre-angle
																	case [
																		all [last-cur-angle > 170 	cur-angle < -170]	[sector: pick ['negative 'positive] direction = 'cw]
																		all [last-cur-angle < -170 	cur-angle > 170]	[sector: pick ['positive 'negative] direction = 'cw]
																		all [pre-angle - 180 - last-cur-angle >= 0 pre-angle - 180 - cur-angle < 0]	[direction: 'cw  sector: 'positive]
																		all [pre-angle - 180 - last-cur-angle < 0 pre-angle - 180 - cur-angle >= 0]	[direction: 'ccw sector: 'negative]
																	]
																	last-cur-angle: cur-angle
																	poke selection-start/5 5 case [
																		all [direction = 'cw  sector = 'negative][540 + diff2]
																		all [direction = 'ccw sector = 'positive][-180 + diff2]
																		'else [180 + diff2]
																	]
																	;selection-start/4: selection-start/4
																	redraw
																]
															]
														]
														figure = 'program []
														'else [
															either last-action = 'insert [
																poke selection-start offset? selection-start next-figure switch/default figure [
																	square [dim: max diff/x diff/y pos1 + as-pair dim dim]
																	ellipse [diff]
																	circle [sqrt add power diff/x 2 power diff/y 2]
																][pos2]
															][
																poke selection-start length? selection-start switch/default figure [
																	square [dim: max diff/x diff/y pos1 + as-pair dim dim]
																	ellipse [diff]
																	circle [sqrt add power diff/x 2 power diff/y 2]
																][pos2] 
															]
														]
													]
													;redraw
													show face
												]
												move [; ???? Major reformulation needed
													unless find [pen fill-pen line-width] selection-start/1 [
														switch selection-start/2 [
															circle or ellipse [
																;diff: pos1 - event/offset
																selection-start/3: selection-start/3 + diff;- diff
																pos1: event/offset
															]
															box or line or polygon	[;probe reduce [selection-start selection-end]
																pnum: either block? selection-end [
																	subtract subtract index? selection-end index? selection-start 2
																][
																	subtract length? selection-start 2
																]
																repeat i pnum [
																	j: i + 2
																	;diff: pos1 - event/offset
																	poke selection-start j selection-start/:j + diff ;- diff
																]
																pos1: event/offset
															]
														]
														show face ;img
													]
												]
												translate [
													if step = 2 [
														selection-start/3: event/offset - pos1
														show face
													]
												]
												scale [
													if step = 2 [
														selection-start/3: add 1 diff/x / 100.0 
														selection-start/4: add 1 diff/y / 100.0
														show face
													]
												]
												skew [
													if step = 2 [
														selection-start/3: diff/x 
														selection-start/4: diff/y
														show face
													]
												]
												rotate [
													if step = 2 [
														selection-start/3: round/to 180 / pi * arctangent2  diff/y diff/x 0.1
														show face 
													]
												]
												t-rotate [
													if step = 2 [
														selection-start/4: round/to 180 / pi * arctangent2  diff/y diff/x 0.1
														show face 
													]
												]
												t-scale [
													if step = 2 [
														selection-start/5: add 1 diff/x / 100.0
														selection-start/6: add 1 diff/y / 100.0
														show face
													]
												]
												t-translate [
													if step = 2 [
														selection-start/7: diff + pre-diff
														show face
													]
												]
												;animate [
												;	if all [step = 2 img/rate] [
												;		img/rate: either 0 < diff/x [img/rate + diff/x][0:0:1 + divide absolute diff/x 10]
												;	]
												;]
											]
										]
										redraw
									]
								]
								on-up: func [face][
									if all [last-action = 'insert not find [polygon polyline] figure] [last-action: none]
									switch action [
										t-rotate [env/step: 1]
										draw [
											switch figure [
												arc or sector [
													if step = 2 [env/step: 3]
												]
											]
										]
									]
									select-figure 
									last-pos: pos1
									;probe reduce ["start" selection-start "end" selection-end]
									probe face/draw
								]
							]
						]
						do [selection-start: head img/draw selection-end: tail img/draw]
					]
					;return
					figs-panel: panel 100x300 [
						style fig-list: text-list 100x300 data [] ;265
						with [
							menu: [
								"Move-z" [
									"Front" 		front 
									"Forward" 		forward 
									"Backward" 		backward 
									"Back" 			back 
									"Before"		before ;TBD Move before the next selected element
								];"---"
								"Pens" [	; TBD
									"Line-width" 	line-width
									"Pen color" 	pen
									"Pen pattern" 	pen-pattern
									"Fill color" 	fill
									"Fill pattern" 	fill-pattern
								];"---"
								"Move" 			move ; Check
								"Points" 		points ; TBD Edit individual points
								"Manipulate" [
									"Translate"		translate
									"Scale"			scale
									"Skew" 			skew 
									"Rotate" 		rotate
									"Undo last"		undo-manipulation ; TBD Delete latest manipulation
									"Undo all"		undo-manipulations ; TBD Delete all manipulations
								]
								"Transform" [
									"Rotate"		t-rotate
									"Scale"			t-scale
									"Translate"		t-translate
									"Undo" [
										"Rotate"	undo-t-rotate
										"Scale"		undo-t-scale
										"Translate"	undo-t-translate
										"All"		undo-transforms
									]
								];"---"
								"Show transformations" show-transform	; TBD Show in separate window (like group elements), from where they can be edited
								"Hide transformations" hide-transform	; TBD
								"Animate" [
									"Translate" 	a-translate
									"Scale"			a-scale
									"Skew"			a-skew
									"Rotate"		a-rotate
								]
								"Stop"			stop-animation
								"Grouping" [
									"Group"			group
									"Show elements"	show-group
									"Hide elements"	hide-group
									"Ungroup"		ungroup		; TBD Remove group transformations and replace group with elementary contents
								]
								"Insert"		insert ;?? New one just before current one; TBD
								"Clone"			clone ; TBD Either group or element
								"Rename"		rename ; TBD
								"Delete" 		delete
							]
							actors: object [
								pos: 0x0
								last-selected: none
								;on-down: func [face event][
								;	pos: event/offset
								;]
								on-menu: func [face event /local sel elements][
									switch event/picked [
										move [env/action: 'move]
										front [move-selection 'front]
										forward [move-selection 'forward]
										backward [move-selection 'backward]
										back [move-selection 'back]
										before [move-selection 'before] ;??? TBD
										translate or scale or skew or rotate [new-manipulation event/picked]
										undo-manipulation []
										undo-manipulations []
										t-rotate or t-scale or t-translate [new-transformation event/picked]
										undo-t-rotate 		[selection-start/3: 0x0 selection-start/4: 0 show img]
										undo-t-scale 		[selection-start/5: selection-start/6: 1 show img]
										undo-t-translate 	[selection-start/7: 0x0 show img]
										undo-transforms 	[change skip selection-start 2 [0x0 0 1 1 0x0] show img]

										;animate [env/action: 'animate env/step: 1 img/rate: 10]
										stop-animation [img/rate: none env/step: 1]

										a-translate	[
											unless selection-start/2 <> 'translate [
												new-manipulation 'translate
											]
										]

										group [env/action: 'group]
										show-group [
											if elements: parse next selection-start show-group-rule [
												;probe sep1/size
												figs2/data: elements
												figs2/size/y: min 20 * length? elements 240
												face/size/y: face/parent/size/y - figs2/size/y - sep1/size/y
												sep1/offset/y: figs1/size/y
												figs2/offset: as-pair face/offset/x face/offset/y + face/size/y + sep1/size/y
												sep1/visible?: yes
												figs2/visible?: yes
												show figs2 show face show sep1
											]
										]
										hide-group [
											foreach fig next figs-panel/pane [
												fig/visible?: no
											]
											figs1/size/y: figs1/parent/size/y
											;show figs1 show figs2
											show figs-panel
										]
										ungroup [
											;either block? selection-start/2 [;probe selection-start/2
												replace face/data pick face/data face/selected parse next selection-start show-group-rule
												probe "hi"
												probe selection-end: offset? selection-start selection-end
												probe change/part probe selection-start probe unwrap-group probe selection-end ; first get to-word selection-start/1
												probe "ho"
												select-figure
												show [face img]
											;][
											;	show-warning 
											;	either find [transform translate scale skew rotate] selection-start/2 [
											;		"Please remove transformations first!"
											;	][
											;		"This is not a group!"
											;	]
											;]
										] ; TBD
										rename [
											new-name: ask-new-name
											either find face/data new-name [
												show-warning "Name should be unique!"
											][
												change at face/data face/selected new-name
												change selection-start to-set-word new-name
												selected-figure/text: new-name
												show selected-figure
												show face
											]
										]
										insert [
											env/last-action: 'insert 
											next-figure: selection-start
										]
										clone []
										delete [
											sel: select-figure 
											remove at face/data face/selected
											face/selected: sel
											remove/part selection-start selection-end
											selection-start: either block? selection-end [
												selection-end
											][
												either sel [select-figure/pos sel][none]
											]
											show face show img
										]
									]
								]
								on-down: func [face event][env/figs: face]
								;on-up: func [face event][probe "up"];selected-figure: pick face/data face/selected show selected-figure]
								on-select: func [face event][
									if action = 'group [last-selected: face/selected]
								]
								on-change: func [face event /local group-end new-group][;probe reduce ["change" selection-start selection-end] ; NB! adaption of menu here
									switch/default action [
										group [
											group-end: find-figure/tail face/selected
											either figures/group [figures/group: figures/group + 1][figures/group: 1]
											new-group: rejoin ['group figures/group]
											change/part selection-start 
												append/only 
													copy reduce [to-set-word new-group] 
													copy/part selection-start group-end ;/copy/deep ??
												group-end 
											probe img/draw
											change/part at face/data last-selected new-group face/selected - last-selected + 1
											face/selected: last-selected
											select-figure
											show face show img
											env/action: 'draw
										]
									][select-figure]
								]
							]
						]
						style sep: box loose 30x10 draw [pen gray line 0x4 30x4 line 0x6 30x6] hidden on-drag [
							face/offset/x: 35
							idx: index? find face/parent/pane face
							prev: face/parent/pane/(idx - 1)
							nex:  face/parent/pane/(idx + 1)
							tot: prev/size/y + face/size/y + nex/size/y
							prev/size/y: face/offset/y
							nex/offset/y: face/offset/y + face/size/y
							nex/size/y: tot - prev/size/y - face/size/y
							show prev show face show nex
						] 
						at 0x0 figs1: fig-list with [extra: 'figs1] do [env/figs: figs1]
						at 35x0 sep1: sep
						at 0x0 figs2: fig-list with [extra: 'figs2] hidden
						at 0x0 figs3: fig-list with [extra: 'figs3] hidden
						at 0x0 figs4: fig-list with [extra: 'figs4] hidden
						;across space 1x10
						;button 25x25 with [image: (draw 23x23 [fill-pen black polygon 10x17 12x17 12x8 14x8 11x5 8x8 10x8])][
							
						;]
						;button 25x25 with [image: (draw 23x23 [fill-pen black polygon 10x5 12x5 12x14 14x14 11x17 8x14 10x14])]
					]
					return
					anim-panel: panel 300x25 [
						origin 0x0 space 4x0
						text 30x23 "Rate:" a-rate: field 30x23 with [data: 10][img/rate: face/data]
						button "Animate" [
							insert clear body-of :img/actors/on-time [tick: tick + 1]
							append body-of :img/actors/on-time bind bind bind append load animations/text [show face] :img/actors/on-time img/actors env
							img/rate: a-rate/data
							show img
							;append img/draw clear []
						] 
						button "Stop" [img/rate: none] 
						button "Continue" [img/rate: a-rate/data show img]
					]
				]
			]
			"Animation" [
				animations: area 520x420
			]
			"Scenes" [
				;scenes: none
			]
		]
	]
	win/menu: [
		"File" [
			"New" 	new
			"Open" 	open
			"Save"	save
			"Save as.." save-as
		]
		"Help" help
	]
	win/actors: object [
		save-file-as: does [
			win/extra: request-file/save
			save-file
			win/text: to-local-file last split-path win/extra
			show win
		]
		save-file: does [save win/extra append/only insert/only next [draw animations] img/draw animations/text]
		on-menu: func [face event /local loaded][
			switch event/picked [
				open [
					win/extra: request-file
					loaded: load win/extra
					img/draw: select loaded 'draw
					animations/text: select loaded 'animations
					win/text: to-local-file last split-path win/extra
					redraw
					figs/data: parse probe img/draw show-figs-rule
					figs/selected: 1
					select-figure
					show win;[img figs animations]
				]
				save [either win/extra [save-file][save-file-as]]
				save-as [save-file-as]
				help [
					view/flags [
						below
						text 500x500 {Just few notes for current verison: To draw simple figures click on canvas and drag. To draw "poly-" figures (polyline and polygone) click and drag first line, then release and click and drag again to add lines. For manipulations (inserts separate `translate`, `scale`, `skew` and `rotate`) and transformations (inserts single `transform`) click and drag:
						
* for rotation, click sets the rotation center, drag creates "lever" (preferably drag initially away from center in 0 direction, i.e to right) to rotate the figure
* for scaling, click sets the start of scaling, drag scales in relation to 0x0 coordinates (I will implement "local" scaling, i.e. in relation to coordinates set by click)
* for skewing, again, click sets start, drag skews in relation to 0x0 (intend to implement "local" skewing)
* for translation, click sets start, drag translates.

To play with animations, you have to:

* first insert transformation(not manipulation!) for the figure, i.e. select figure and from menu select transformation and then click on canvas to set it,
* then add animation descriptions to the "Animation" tab (print figure name, slash, number of <transformed attribute>, i.e number according to transformation syntax (can also use this: 

`set [r-center angle scale-x scale-y translate][2 3 4 5 6]` ... `square1/:angle: tick` 

to change angle, tick is preset reserved word counting time ticks,
* click "Animate" button on "Drawing" tab,
}
						button "OK" [unview]
					][modal popup]
				]
			]
		]
		on-resizing: func [face event][
			tab-pan/size: win/size - 17
			foreach tab tab-pan/pane [
				tab/size: tab/parent/size; - 10;23x45
			]
			drawing-panel-tab/offset: 0x0
			drawing-panel-tab/size: drawing-panel-tab/parent/size - 4x20
			info-panel/size/y: info-panel/parent/size/y - info-panel/offset/y - 10
			options-panel/size/y: options-panel/parent/size/y - options-panel/offset/y - 10
			drawing-panel/size: ;as-pair 
				drawing-panel/parent/size - drawing-panel/offset - 120x50
				;drawing-panel/parent/size/y - drawing-panel/offset/y - 10
			img/size: drawing-panel/size
			figs-panel/offset/x: figs-panel/parent/size/x - 110
			figs-panel/size/y: figs-panel/parent/size/y - figs-panel/offset/y - 15
			figs1/size/y: figs-panel/size/y
			anim-panel/offset/x: anim-panel/parent/offset/x + 100
			anim-panel/offset/y: anim-panel/parent/size/y - 38
			anim-panel/size/x: drawing-panel/size/x
			animations/offset: 0x0
			animations/size: animations/parent/size - 5x25
			show win 
		]
	]
	win-view: view/no-wait/flags win [resize]
	;do-events
]
