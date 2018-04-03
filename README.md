# Short intro to drawing-pad

To draw simple figures click on canvas and drag. To draw "poly-" figures (polyline, polygon, spline) click and drag first line, then release and click and drag again to add points. For manipulations (inserts separate `translate`, `scale`, `skew` and `rotate`) and transformations (inserts single `transform`) click and drag:

* for rotation, click sets the rotation center, drag creates "lever" (preferably drag initially away from center in 0 direction, i.e to right) to rotate the figure
* for scaling, click sets the start of scaling, drag scales in relation to 0x0 coordinates (I will implement "local" scaling, i.e. in relation to coordinates set by click)
* for skewing, again, click sets start, drag skews in relation to 0x0 (intend to implement "local" skewing)
* for translation, click sets start, drag translates.

Holding down control-key while drawing, switches on `ortho` mode, resulting in orthogonal (vertical or horizontal) lines. (As an interesting effect, if you hold control-key down while starting new line *after drawing an orthogonal line* the new line is drawn from starting  point orthogonally to the last line. To avoid this, start line in normal mode and press `control` only after starting. I have not decided yet whether to consider this as a bug or as a feature.)

Sift-key controls the grid-mode. If "Grid" is not checked, holding down `shift` switches grid-mode temporarily on, if it is checked, `shift` switches it temporarily off. Grid steps can be changed on edit-options-panel. (In second field, grid for angles is set (arc degrees to step)).

Wheel-rotation over drawing area zooms in and out. New figures are inserted correctly under cursor in zoomed views.

Pictures are inserted either from web (paste url into field) or from local file-system. First click after "OK" on file-selection window sets the top-left position for the picture, second click inserts picture - or - click and drag inserts picture to dragged dimensions. (Some bug, which I haven't succeeded to weed out, requires two mouse presses, instead of one. Working on this.)

Wheel rotation above figures-list on right now changes selection, ctrl-wheel moves the selected figure up or down in z-order.

Figure-manipulation commands can be selected from text-list's menu; for some commands keyboard shortcuts are defined. 

Local formatting for figures can be now selected from contextual menu on figures-list. E.g. to change pen color, select `Format->Pen->Color` and then select color from left side pen-color-picker. There are currently two color-pickers both for pen and fill-pen. First has Red-colors, second has full color-circle + transparency.

Draw-block can be seen/copied/edited by clicking "View->Draw window" (opens window with draw-block) or "View->Draw console" (makes VID code of current layer which may be pasted into console with `do [..]`) on main menu.

New layers are created by clicking on layer-tool on left panel.

To play with animations, you have to:

* first insert transformation (not manipulation!) for the figure, i.e. select figure and from menu select transformation and then click on canvas to set it (take eg. Transform->Translate", click on canvas and drag jst a little bit, relase),
* then add animation descriptions to the "Animation" tab (print figure name, slash, 2, slash, number of <transformed attribute>, i.e number according to transformation syntax. 

Can also use this: 

```
set [r-center angle scale-x scale-y translate][2 3 4 5 6]
square1/2/:angle: tick
``` 

to change angle (i.e. animate rotation). 
`tick` is preset reserved word counting time ticks,
* click "Animate" button on "Drawing" tab

You can try out exampe animation files `quadratic-bezier-draw.red` and `ellipse-draw.red`. Do just `File->Open` and click `Animate`.

Files can be saved and loaded, and layers can be exported to `png`, `jpeg` and `gif` formats.
