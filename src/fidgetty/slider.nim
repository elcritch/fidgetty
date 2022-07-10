import std/strformat

import widgets

proc slider*(
    value : var float,
    label = "",
    changed : WidgetProc = proc () = discard,
    disabled : bool = false
): SliderState {.statefulFidget.} =
  ## Draw a progress bars 

  init:
    box 0, 0, 100.WPerc, 2.Em
    textAutoResize tsHeight
    layoutAlign laStretch
    cornerRadius theme

  properties:
    pipDrag: bool
  
  render:
    let
      # some basic calcs
      sb = 0.3'em
      sbb = sb*2
      barOuter = 0.5'em
      bh = current.box.h
      bw = current.box.w
      bww = bw - bh

    onClick:
      self.pipDrag = true

    var oldValue = value
    if self.pipDrag:
      let mpx = mouse.x
      let sbx = current.screenBox.x
      value = float32 ((mpx - sbx - bh/2'ui)/bww).clamp(0'ui, 1.0'ui)
      self.pipDrag = buttonDown[MOUSE_LEFT]
      if oldValue != value:
        if not changed.isNil:
          changed()

    let
      pipPos = UICoord bww.float32*clamp(value, 0, 1.0)

    text "text":
      box 0, 0, bw, bh
      fill palette.text
      characters label
    rectangle "pip":
      box sb+pipPos, sb, bh-2*sb, bh-2*sb
      fill palette.cursor
      cornerRadius theme
      stroke theme.outerStroke
      clipContent true
      imageOf theme.gloss
    rectangle "fg-bar":
      box barOuter, barOuter, pipPos+bh/2, bh-barOuter*2
      fill palette.accent
      cornerRadius theme
      clipContent true
      imageOf theme.gloss, 0.77
    rectangle "bg":
      imageOf theme.gloss
      rotation 180
      box 0, 0, bw, bh
      fill palette.foreground
      cornerRadius theme
      clipContent true
      stroke theme.outerStroke