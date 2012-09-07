;; ===================================================
;; Script: simple-tooltip-style.r
;; downloaded from: www.REBOL.org
;; on: 27-Jul-2012
;; at: 15:53:25.346145 UTC
;; owner: luce80 [script library member who can update
;; this script]
;; ===================================================
REBOL [
	title: "Tooltip style example"
	file: %simple-tooltip-style.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 30-04-2011
	version: 0.9.3
	Purpose: {A quick way to add a simple tooltip to VID GUIs}
	comment: {You are strongly encouraged to post an enhanced version of this script}
	History: [
		0.0.1 [03-12-2010 "First version"]
		0.8.0 [08-01-2011 "Enhanced"]
		0.9.0 [16-01-2011 "Enhanced with function by Shadwolf, Boss, DideC, Volker and the tipped flag"]
		0.9.1 [08-02-2011 "Minor bug fixes and source retouches"]
		0.9.2 [19-02-2011 "Minor bug fix of offset/x"]
		0.9.3 [30-04-2011 "Minor source retouches"]
	]
	Category: [util vid view]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'how-to
		domain: [gui vid]
		tested-under: [View 2.7.7.3.1]
		support: none
		license: 'BSD
		see-also: %toolt4vid.r
	]
]

tip: make face [
	color: yello + 30
	font: make font [size: 11]
	para: make para [wrap?: false]
	edge: make edge [size: 1x1 color: gray]
	ticks: 0
	start_tip: func [face] [
		if ticks <> 0 [exit]
		if not text: face/help [exit]
		size: 4x6 + size-text self
		rate: 0:0:0.500
		offset: - size ; hide it
		remove find get in find-window face 'pane self
		append get in find-window face 'pane self
		show find-window face
	]
	open_tip: func [woffset /local wsize] [
		offset: woffset + 0x15
		wsize: get in find-window self 'size
		; keep inside window
		if offset/y > (wsize/y - size/y) [offset/y: offset/y - size/y - 16]
		offset/x: max min wsize/x - size/x offset/x 0
		show self/parent-face
	]
	close_tip: func [] [
		if size = 100x100 [exit] ; entering here before start_tip
		rate: none
		offset: - size
		ticks: 0
		show self/parent-face
	]
	feel: make feel [
		engage: func [face action event][
			if action = 'time [
				if ticks = 1 [open_tip event/offset]
				if ticks = 6 [close_tip]
				ticks: ticks + 1
			]
		]
	]

	over: func [face over? offset] [either all [over? not flag-face? face tipped] [start_tip face] [deflag-face face tipped close_tip]]
	engage: func [face action event] [if not flag-face? face tipped [flag-face face tipped close_tip]]
]

flag-face?: func [
	"Checks a flag in a VID face."
	face [object!] 'flag
] [all [in face 'flags face/flags find face/flags flag]] ; patched

; this function is taken from %toolt4vid.r (only a little modified)
Add-tooltip-2-style: func [ { Allow to add the  tooltip support to all widgets passed in parameter}
    style-lst [block! ] "Contains the listing of Vid widgets to patch"
    style-root "Countain the path of the root-styles to patch"
][
    foreach style style-lst [
        if find style-root style [     ; Teste si le style existe pour la compatibilité avec les versions antérieures de view
			style-root/:style/feel: make style-root/:style/feel [
				over*: :over
				over: func [face action offset][
					tip/over face action offset
					over* face action offset ; call original
				]
				engage*: :engage
				engage: func [face action event][
					engage* face action event
					tip/engage face action event
				]
			]
        ]
    ]
]

; here is the list of widget affected by the tooltip ability (does it make sense to patch also text?)
vid-styles: [image btn backtile box sensor key base-text vtext text body txt banner vh1 vh2 vh3 vh4 
             title h1 h2 h3 h4 h5 tt code button check radio check-line radio-line led 
             arrow toggle rotary choice drop-down icon field info area slider scroller progress 
             anim btn-enter btn-cancel btn-help logo-bar tog]

Add-tooltip-2-style vid-styles system/view/vid/vid-styles 
comment [
win: layout [
	area "another face" help "an area" 
	panel [across
		button "test" help "the first button"
		button "test2" help "the second button"
		btn "test3" help "the third button" [probe face/feel]
		button 120 "test4 without help"
	]
]

view center-face win
]